#!/usr/bin/env python3
"""治理漂移审计：以 governance/desired-state.json 为期望状态，逐仓比对 GitHub 实际状态。

只读：全部经 `gh api` 发 GET，不产生任何远端写入。
退出码：0=clean；1=drift；2=无法判定（取数失败 / 输入非法）。

判定口径（与 REPOSITORY_GUIDELINES 的两轴模型一致）：
- 存在性、可见性、默认分支、归档状态、delete_branch_on_merge：全部仓库。
- 分支保护与 ruleset：仅 public + active + 非 policy 仓强制；private 仓因 Free 计划
  无服务器侧保护能力，记 SKIP（能力缺口，不判红）；maintenance 仓的 ruleset 建议
  但非必需，不判红。ruleset 不只校验名字：`governance-baseline` 必须含
  deletion / non_fast_forward / pull_request / required_status_checks 且检查清单非空，
  `tag-protection-v` 必须含 deletion / non_fast_forward / update。
- 必需文件：全部仓库需 README.md；delivery=release 另需 CHANGELOG.md 与
  docs/release-governance.md。
- 契约一致性：公开非归档仓必须有 docs/agent-contract.md，且与
  governance/templates/agent-contract.md 逐字节一致（§7.3）；私有仓有则比对、无则跳过。
- 本地治理文档：非归档仓不得跟踪任何 AGENTS.md（§7.1）；可按仓登记
  `tracked_agents_allow` 前缀例外（私有资产备份仓）。
- 归档状态：archived 仓 README 必须含「状态：暂时归档」声明；非归档仓不得保留该声明
  （§15.7 / §18.1）。
- 复用工作流 SHA 固定：pinned_ref 为空时跳过（阶段 4 前）；非空时逐个调用点断言。
- exceptions（rewq）：只校验 `.gitignore` 仍排除声明的 scope，不限制正常提交。
"""

from __future__ import annotations

import argparse
import base64
import json
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(SCRIPT_DIR))
DESIRED_PATH = os.path.join(ROOT, "governance", "desired-state.json")

BASE_FILES = ("README.md",)
RELEASE_FILES = ("CHANGELOG.md", "docs/release-governance.md")
RULESET_RULES = {
    "governance-baseline": ("deletion", "non_fast_forward", "pull_request", "required_status_checks"),
    "tag-protection-v": ("deletion", "non_fast_forward", "update"),
}
RULESET_REQUIRED = tuple(RULESET_RULES)
CONTRACT_PATH = "docs/agent-contract.md"
CONTRACT_TEMPLATE = os.path.join(ROOT, "governance", "templates", "agent-contract.md")
ARCHIVE_MARKER = "状态：暂时归档"


def normalize_text(text):
    """统一换行并去掉尾部空行，用于逐字节契约比对。"""
    return text.replace("\r\n", "\n").replace("\r", "\n").rstrip("\n")


def load_contract_template():
    try:
        with open(CONTRACT_TEMPLATE, encoding="utf-8-sig") as handle:
            return normalize_text(handle.read()), None
    except OSError as exc:
        return None, f"读取契约模板失败：{exc}"


def gh_api(path):
    """调用 gh api GET；返回 (data, error)。"""
    try:
        proc = subprocess.run(
            ["gh", "api", "--method", "GET", path],
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
    except FileNotFoundError:
        return None, "本机未找到 gh CLI"
    if proc.returncode != 0:
        return None, (proc.stderr or proc.stdout or "").strip()
    try:
        return json.loads(proc.stdout), None
    except json.JSONDecodeError as exc:
        return None, f"响应不是合法 JSON：{exc}"


def gh_file(owner, repo, path):
    """读取仓库内单个文件的文本内容；返回 (text, error)。"""
    data, err = gh_api(f"repos/{owner}/{repo}/contents/{path}")
    if data is None:
        return None, err
    content = data.get("content") or ""
    try:
        return base64.b64decode(content).decode("utf-8", "replace"), None
    except (ValueError, TypeError) as exc:
        return None, f"base64 解码失败：{exc}"


def not_found(err):
    return "HTTP 404" in err or "Not Found" in err


def check_repo(owner, spec, template_text):
    name = spec["name"]
    out = {
        "name": name,
        "visible": False,
        "drift": [],
        "unverified": [],
        "skipped": [],
        "limited": [],
        "fatal": [],
    }

    facts, err = gh_api(f"repos/{owner}/{name}")
    if facts is None:
        if not_found(err) and spec["visibility"] == "private":
            out["unverified"].append("私有仓对当前凭据不可见，跳过全部平台项")
        elif not_found(err):
            out["drift"].append("仓库不存在或对当前凭据不可见")
        else:
            out["fatal"].append(f"读取仓库元数据失败：{err}")
        return out

    out["visible"] = True
    # delete_branch_on_merge / 分支保护 / ruleset 仅对 admin 可读。Actions 默认
    # GITHUB_TOKEN 对其它仓只有 read 权限，读到的 dboM 恒为 false，不能当真值。
    is_admin = bool((facts.get("permissions") or {}).get("admin"))

    actual_vis = "private" if facts.get("private") else "public"
    if actual_vis != spec["visibility"]:
        out["drift"].append(f"可见性 {actual_vis} ≠ 期望 {spec['visibility']}")

    want_archived = spec["lifecycle"] == "archived"
    if bool(facts.get("archived")) != want_archived:
        out["drift"].append(
            f"归档状态 archived={bool(facts.get('archived'))} ≠ 期望 {want_archived}"
        )

    branch = facts.get("default_branch")
    if branch != "main":
        out["drift"].append(f"默认分支 {branch!r} ≠ 'main'")

    if not want_archived:
        if not is_admin:
            out["limited"].append("delete_branch_on_merge")
        elif not facts.get("delete_branch_on_merge"):
            out["drift"].append("delete_branch_on_merge=false")

    required_protection = (
        spec["visibility"] == "public"
        and spec["lifecycle"] == "active"
        and spec["delivery"] != "policy"
    )
    if required_protection and not is_admin:
        out["limited"].append("分支保护")
        out["limited"].append("ruleset")
    elif required_protection:
        protection, perr = gh_api(f"repos/{owner}/{name}/branches/{branch or 'main'}")
        if protection is None:
            out["unverified"].append(f"分支保护读取失败：{perr}")
        elif not protection.get("protected"):
            out["drift"].append("main 分支未受保护")
        rulesets, rerr = gh_api(f"repos/{owner}/{name}/rulesets")
        if rulesets is None:
            out["unverified"].append(f"ruleset 读取失败：{rerr}")
        else:
            by_name = {
                item.get("name"): item.get("id")
                for item in rulesets
                if isinstance(item, dict) and item.get("name")
            }
            missing = [item for item in RULESET_REQUIRED if item not in by_name]
            if missing:
                out["drift"].append("缺少 ruleset：" + "、".join(missing))
            for rs_name, expected_rules in RULESET_RULES.items():
                ruleset_id = by_name.get(rs_name)
                if not ruleset_id:
                    continue
                detail, derr = gh_api(f"repos/{owner}/{name}/rulesets/{ruleset_id}")
                if detail is None:
                    out["unverified"].append(f"ruleset {rs_name} 规则读取失败：{derr}")
                    continue
                rules = [item for item in (detail.get("rules") or []) if isinstance(item, dict)]
                actual_rules = {item.get("type") for item in rules}
                lacking = [item for item in expected_rules if item not in actual_rules]
                if lacking:
                    out["drift"].append(
                        f"ruleset {rs_name} 缺少规则：" + "、".join(lacking)
                    )
                if rs_name == "governance-baseline" and "required_status_checks" in actual_rules:
                    rule = next(
                        (item for item in rules if item.get("type") == "required_status_checks"),
                        {},
                    )
                    checks = (rule.get("parameters") or {}).get("required_status_checks")
                    if not checks:
                        out["drift"].append(
                            "ruleset governance-baseline 的 required_status_checks 为空"
                        )
    elif spec["visibility"] == "private" and spec["lifecycle"] == "active":
        out["skipped"].append("私有仓无服务器侧保护能力（Free 计划），跳过保护项")

    tree, terr = gh_api(f"repos/{owner}/{name}/git/trees/{branch or 'main'}?recursive=1")
    if tree is None:
        if not_found(terr) and out["drift"]:
            pass  # 仓库已判不存在，不再叠加取树失败
        else:
            out["fatal"].append(f"读取文件树失败：{terr}")
    else:
        paths = {node.get("path") for node in tree.get("tree", [])}
        required = list(BASE_FILES)
        if spec["delivery"] == "release":
            required += list(RELEASE_FILES)
        for item in required:
            if item not in paths:
                out["drift"].append(f"缺少必需文件 {item}")

        # §7.1 非归档仓不得跟踪 AGENTS.md；私有资产备份仓可按 tracked_agents_allow 放行。
        if not want_archived:
            allow = tuple(str(item) for item in (spec.get("tracked_agents_allow") or ()) if str(item))
            tracked_agents = [
                path
                for path in paths
                if path.rsplit("/", 1)[-1] == "AGENTS.md"
                and not any(path.startswith(prefix) for prefix in allow)
            ]
            if tracked_agents:
                out["drift"].append(
                    "跟踪了 AGENTS.md（§7.1 应仅本地保留）：" + "、".join(sorted(tracked_agents)[:5])
                )

        # §7.3 公开契约逐字节一致：公开非归档仓必须存在；私有仓有则比对、无则跳过。
        if not want_archived and CONTRACT_PATH in paths:
            contract, cerr = gh_file(owner, name, CONTRACT_PATH)
            if contract is None:
                out["unverified"].append(f"读取 {CONTRACT_PATH} 失败：{cerr}")
            elif template_text is not None and normalize_text(contract) != template_text:
                out["drift"].append(
                    f"{CONTRACT_PATH} 与 governance/templates/agent-contract.md 不一致（§7.3）"
                )
        elif not want_archived and spec["visibility"] == "public":
            out["drift"].append(f"缺少 {CONTRACT_PATH}（§7.3 公开契约）")

        # §15.7 / §18.1 归档声明：归档仓必须有；非归档仓不得残留。
        if "README.md" in paths:
            readme, rerr = gh_file(owner, name, "README.md")
            if readme is None:
                out["unverified"].append(f"读取 README.md 失败：{rerr}")
            else:
                has_marker = ARCHIVE_MARKER in readme
                if want_archived and not has_marker:
                    out["drift"].append("归档仓 README 缺少「状态：暂时归档」声明（§15.7）")
                elif not want_archived and has_marker:
                    out["drift"].append("非归档仓 README 仍保留「状态：暂时归档」声明（§18.1 状态）")

    return out


def check_exception(owner, name, spec, visible):
    out = {
        "name": name,
        "drift": [],
        "unverified": [],
        "skipped": [],
        "limited": [],
        "fatal": [],
    }
    if spec.get("rule") != "no-private-key-upload":
        out["skipped"].append(f"未知例外规则 {spec.get('rule')!r}，未校验")
        return out
    text, err = gh_file(owner, name, ".gitignore")
    if text is None:
        if not_found(err) and not visible:
            out["unverified"].append("私有仓对当前凭据不可见，跳过例外校验")
        elif not_found(err):
            out["drift"].append("缺少 .gitignore")
        else:
            out["fatal"].append(f"读取 .gitignore 失败：{err}")
        return out
    scope = (spec.get("scope") or "").strip()
    lines = {line.strip() for line in text.splitlines()}
    if scope not in lines:
        out["drift"].append(f".gitignore 不再排除 {scope}")
    tracked, terr = gh_api(f"repos/{owner}/{name}/git/trees/main?recursive=1")
    if tracked is None:
        if not_found(terr) and not visible:
            out["unverified"].append("私有仓对当前凭据不可见，跳过密钥目录跟踪校验")
        else:
            out["fatal"].append(f"读取文件树失败：{terr}")
    else:
        leaked = [
            node["path"]
            for node in tracked.get("tree", [])
            if scope and str(node.get("path", "")).startswith(scope)
        ]
        if leaked:
            out["drift"].append(f"已跟踪密钥目录内容：{', '.join(leaked[:5])}")
    return out


def check_pins(owner, pins, selected):
    out = {"name": "复用工作流 SHA 固定", "drift": [], "unverified": [], "skipped": [], "limited": [], "fatal": []}
    ref = (pins.get("pinned_ref") or "").strip()
    callers = [c for c in pins.get("callers", []) if c.get("repo") in selected]
    if not callers:
        return None
    if not ref:
        out["skipped"].append(
            f"pinned_ref 为空，阶段 4 前跳过（待校验 {len(callers)} 个调用点）"
        )
        return out
    for caller in callers:
        repo, path, workflow = caller.get("repo"), caller.get("file"), caller.get("workflow")
        expected = (caller.get("ref") or ref).strip()
        text, err = gh_file(owner, repo, path)
        if text is None:
            out["fatal"].append(f"{repo}/{path} 读取失败：{err}")
            continue
        lines = [
            line.strip()
            for line in text.splitlines()
            if "uses:" in line and str(workflow) in line
        ]
        if not lines:
            out["drift"].append(f"{repo}/{path} 找不到 {workflow} 的调用点")
            continue
        for line in lines:
            # 允许行尾注释（# pinned YYYY-MM-DD）：只取 @ 后的 ref 字段比对。
            actual = line.rsplit("@", 1)[-1].split()[0].strip()
            if actual != expected:
                out["drift"].append(f"{repo}/{path} 未固定到 {expected[:12]}：{line}")
    return out


def load_desired(path):
    try:
        # 期望状态可能由 PowerShell 写出而带 UTF-8 BOM，统一按 utf-8-sig 读取。
        with open(path, encoding="utf-8-sig") as handle:
            return json.load(handle), None
    except OSError as exc:
        return None, f"读取期望状态失败：{exc}"
    except json.JSONDecodeError as exc:
        return None, f"期望状态不是合法 JSON：{exc}"


def main(argv):
    parser = argparse.ArgumentParser(description="治理漂移审计（只读）")
    parser.add_argument("--owner", default=None, help="覆盖 desired-state.json 的 owner")
    parser.add_argument("--only", default="", help="只审计指定仓库，逗号分隔")
    parser.add_argument("--delivery", default="", help="只审计指定 delivery，逗号分隔")
    parser.add_argument("--lifecycle", default="", help="只审计指定 lifecycle，逗号分隔")
    args = parser.parse_args(argv)

    desired, err = load_desired(DESIRED_PATH)
    if desired is None:
        print(f"ERROR: {err}", file=sys.stderr)
        return 2

    owner = args.owner or desired.get("owner")
    if not owner:
        print("ERROR: 期望状态缺少 owner", file=sys.stderr)
        return 2

    template_text, terr = load_contract_template()
    if template_text is None:
        print(f"ERROR: {terr}", file=sys.stderr)
        return 2

    repos = desired.get("repos") or []
    only = {item.strip() for item in args.only.split(",") if item.strip()}
    deliveries = {item.strip() for item in args.delivery.split(",") if item.strip()}
    lifecycles = {item.strip() for item in args.lifecycle.split(",") if item.strip()}

    known = {spec.get("name") for spec in repos}
    unknown = only - known
    if unknown:
        print(f"ERROR: --only 含期望状态里不存在的仓库：{', '.join(sorted(unknown))}", file=sys.stderr)
        return 2

    selected = [
        spec
        for spec in repos
        if (not only or spec["name"] in only)
        and (not deliveries or spec["delivery"] in deliveries)
        and (not lifecycles or spec["lifecycle"] in lifecycles)
    ]
    if not selected:
        print("ERROR: 过滤后没有可审计的仓库", file=sys.stderr)
        return 2

    with ThreadPoolExecutor(max_workers=8) as pool:
        results = list(pool.map(lambda spec: check_repo(owner, spec, template_text), selected))

    for name, spec in (desired.get("exceptions") or {}).items():
        target = next((item for item in results if item["name"] == name), None)
        if target is None:
            continue
        extra = check_exception(owner, name, spec, target.get("visible", False))
        for key in ("drift", "unverified", "skipped", "fatal"):
            target[key].extend(extra[key])

    pins_result = check_pins(owner, desired.get("reusable_workflows") or {}, {s["name"] for s in selected})
    all_rows = results + ([pins_result] if pins_result else [])

    lines = [
        "治理漂移审计",
        f"  期望源：governance/desired-state.json  owner={owner}  仓库 {len(selected)} 个",
        "  口径：只读 gh api；私有仓不可见或令牌无 admin 权限时，对应项记 UNVERIFIABLE / PARTIAL（不判红），"
        "完整覆盖需在本地用 owner 凭据运行。",
        "",
    ]
    counts = {"PASS": 0, "PARTIAL": 0, "DRIFT": 0, "UNVERIFIABLE": 0, "SKIP": 0}
    drift_details = []
    unverified_details = []
    fatal_details = []
    limited_fields = set()

    for result in all_rows:
        problems = result["drift"]
        unverified = result["unverified"]
        skipped = result["skipped"]
        limited = result.get("limited") or []
        fatal = result["fatal"]
        limited_fields.update(limited)
        fatal_details.extend(f"{result['name']}: {item}" for item in fatal)
        if problems:
            status = "DRIFT"
            counts["DRIFT"] += 1
            drift_details.extend(f"{result['name']}: {item}" for item in problems)
        elif unverified:
            status = "UNVERIFIABLE"
            counts["UNVERIFIABLE"] += 1
            unverified_details.extend(f"{result['name']}: {item}" for item in unverified)
        elif limited:
            status = "PARTIAL"
            counts["PARTIAL"] += 1
        elif skipped:
            status = "SKIP"
            counts["SKIP"] += 1
        else:
            status = "PASS"
            counts["PASS"] += 1
        lines.append(f"{status:<13}{result['name']}")
        for item in problems:
            lines.append(f"               - {item}")
        for item in unverified:
            lines.append(f"               ? {item}")
        for item in skipped:
            lines.append(f"               · {item}")

    lines.append("")
    if pins_result:
        lines.append(
            f"汇总：{len(results)} 仓 + 1 项横切校验 · PASS {counts['PASS']} · PARTIAL {counts['PARTIAL']} · "
            f"DRIFT {counts['DRIFT']} · UNVERIFIABLE {counts['UNVERIFIABLE']} · SKIP {counts['SKIP']}"
        )
    else:
        lines.append(
            f"汇总：{len(results)} 仓 · PASS {counts['PASS']} · PARTIAL {counts['PARTIAL']} · "
            f"DRIFT {counts['DRIFT']} · UNVERIFIABLE {counts['UNVERIFIABLE']} · SKIP {counts['SKIP']}"
        )
    if limited_fields:
        lines.append(
            "口径受限：当前令牌无 admin 权限，"
            + " / ".join(sorted(limited_fields))
            + " 未校验（Actions 默认 GITHUB_TOKEN）；完整覆盖需在本地用 owner 凭据运行。"
        )
    if drift_details:
        lines.append("漂移明细：")
        lines.extend(f"  - {item}" for item in drift_details)
    if unverified_details:
        lines.append("无法判定：")
        lines.extend(f"  - {item}" for item in unverified_details)
    if fatal_details:
        lines.append("取数失败：")
        lines.extend(f"  - {item}" for item in fatal_details)

    if fatal_details:
        lines.append("结论：无法判定（rc=2）")
        code = 2
    elif drift_details:
        lines.append("结论：drift（rc=1）")
        code = 1
    else:
        lines.append("结论：clean（rc=0）")
        code = 0

    report = "\n".join(lines)
    print(report)
    summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary_path:
        with open(summary_path, "a", encoding="utf-8") as handle:
            handle.write(report + "\n")
    return code


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
