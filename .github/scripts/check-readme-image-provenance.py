#!/usr/bin/env python3
"""README 展示图来源审计（只读）。

两类检查：
1. 来源：README 图是否与仓内截图归档（screenshots/、docs/screenshots/、captures/、
   shots/、test-results/ 等）逐字节同源；同源即“复用历史截图”，判红。
2. 空白：下载 README 图，算近空白启发式（边缘能量 / 标准差 / 主色占比）；只告警，
   不阻断，用于提示“整屏空白/占位图”类画面。

用法：
    python .github/scripts/check-readme-image-provenance.py [--fail-on-reuse] [--only a,b] [--skip-blank]
"""

from __future__ import annotations

import argparse
import io
import json
import os
import re
import sys
import urllib.error
import urllib.request

try:  # 近空白检测依赖 Pillow；CI 里按需安装，缺失时自动跳过
    from PIL import Image
except ImportError:  # pragma: no cover
    Image = None

OWNER = "ReSerendipity"
API = "https://api.github.com"
SHOT_RE = re.compile(r"(?i)(^|/)(screenshots?|shots|captures?|snapshots?|test-results)/")
IMG_RE = re.compile(r"https?://[^\s\)\]\"']+\.(?:png|jpg|jpeg|gif|webp)", re.I)
JSDELIVR_RE = re.compile(
    r"https?://(?:gcore\.)?jsdelivr\.net/gh/[^@/]+/[^@]+@[^/]+/([^\s\)\]\"']+)", re.I
)

RASTER_EXTS = (".png", ".jpg", ".jpeg", ".gif", ".webp")


def token() -> str:
    value = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if not value:
        raise SystemExit("GH_TOKEN / GITHUB_TOKEN 未设置")
    return value


def api(path: str, raw: bool = False) -> bytes:
    req = urllib.request.Request(
        API + path,
        headers={
            "Authorization": f"Bearer {token()}",
            "Accept": "application/vnd.github.raw" if raw else "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "readme-image-provenance-audit",
        },
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        return resp.read()


def read_json(path: str):
    return json.loads(api(path).decode("utf-8"))


def read_text(path: str) -> str:
    return api(path, raw=True).decode("utf-8", errors="replace")


def load_repos(only: set[str] | None) -> list[str]:
    desired = json.loads(open("governance/desired-state.json", encoding="utf-8-sig").read())
    repos = []
    for repo in desired.get("repos", []):
        if repo.get("visibility") != "public":
            continue
        name = repo["name"]
        if only and name not in only:
            continue
        repos.append(name)
    return repos


def extract_paths(text: str) -> set[str]:
    paths: set[str] = set()
    for url in IMG_RE.findall(text):
        m = JSDELIVR_RE.search(url)
        if m:
            paths.add(m.group(1))
        elif url.startswith(f"https://github.com/{OWNER}/"):
            parts = url.split("/", 7)
            if len(parts) == 8 and parts[5] in {"main", "master"}:
                paths.add(parts[7])
    return paths


def fetch_image(repo: str, branch: str, path: str) -> bytes | None:
    """先走 gcore jsDelivr（本地可达），失败再退回 raw.githubusercontent。"""
    candidates = [
        f"https://gcore.jsdelivr.net/gh/{OWNER}/{repo}@{branch}/{path}",
        f"https://raw.githubusercontent.com/{OWNER}/{repo}/{branch}/{path}",
    ]
    for url in candidates:
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "readme-image-blank-check"})
            with urllib.request.urlopen(req, timeout=45) as resp:
                data = resp.read()
            if len(data) > 1024:
                return data
        except (urllib.error.URLError, OSError, ValueError):
            continue
    return None


def blank_metrics(data: bytes) -> dict[str, float] | None:
    """返回 64×64 缩略图上的标准差、边缘能量、主色占比；解码失败返回 None。"""
    if Image is None:
        return None
    try:
        img = Image.open(io.BytesIO(data)).convert("RGB")
    except Exception:
        return None
    img = img.resize((64, 64))
    px = [img.getpixel((x, y)) for y in range(64) for x in range(64)]
    lum = [0.299 * r + 0.587 * g + 0.114 * b for r, g, b in px]

    mean = sum(lum) / len(lum)
    std = (sum((v - mean) ** 2 for v in lum) / len(lum)) ** 0.5

    grad = 0.0
    count = 0
    for y in range(64):
        row = y * 64
        for x in range(64):
            i = row + x
            if x + 1 < 64:
                grad += abs(lum[i] - lum[i + 1])
                count += 1
            if y + 1 < 64:
                grad += abs(lum[i] - lum[i + 64])
                count += 1
    grad = grad / count if count else 0.0

    buckets: dict[tuple[int, int, int], int] = {}
    for r, g, b in px:
        key = (r >> 4, g >> 4, b >> 4)
        buckets[key] = buckets.get(key, 0) + 1
    dom = max(buckets.values()) / len(px)

    return {"mean": mean, "std": std, "grad": grad, "dom": dom}


def is_near_blank(m: dict[str, float]) -> bool:
    """近空白：几乎无边缘且颜色高度集中；阈值偏保守，只抓整屏纯色/单行字。"""
    return (m["grad"] < 1.5 and m["std"] < 8.0) or (m["dom"] > 0.97 and m["grad"] < 2.5)


def audit(repo: str, blank: bool) -> tuple[list[str], list[str]]:
    default_branch = read_json(f"/repos/{OWNER}/{repo}")["default_branch"]
    readme = read_text(f"/repos/{OWNER}/{repo}/readme")
    readme_paths = extract_paths(readme)
    if not readme_paths:
        return [], []

    tree = read_json(f"/repos/{OWNER}/{repo}/git/trees/{default_branch}?recursive=1").get("tree", [])
    sha_to_paths: dict[str, list[str]] = {}
    path_to_sha: dict[str, str] = {}
    for item in tree:
        if item.get("type") != "blob":
            continue
        path, sha = item["path"], item["sha"]
        path_to_sha[path] = sha
        sha_to_paths.setdefault(sha, []).append(path)

    findings: list[str] = []
    warnings: list[str] = []
    for path in sorted(readme_paths):
        sha = path_to_sha.get(path)
        if not sha:
            findings.append(f"{repo} | MISSING | {path}")
            continue
        others = [p for p in sha_to_paths.get(sha, []) if p != path and SHOT_RE.search(p)]
        if others:
            findings.append(f"{repo} | REUSE | {path} <- {', '.join(sorted(others))}")

        if blank and path.lower().endswith(RASTER_EXTS):
            data = fetch_image(repo, default_branch, path)
            if data:
                metrics = blank_metrics(data)
                if metrics and is_near_blank(metrics):
                    warnings.append(
                        f"{repo} | NEAR_BLANK | {path} | "
                        f"std={metrics['std']:.1f} grad={metrics['grad']:.2f} dom={metrics['dom']:.2f}"
                    )
    return findings, warnings


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--fail-on-reuse", action="store_true")
    parser.add_argument("--only", default="")
    parser.add_argument("--skip-blank", action="store_true", help="跳过近空白检测（不下载图片）")
    args = parser.parse_args()
    only = {x.strip() for x in args.only.split(",") if x.strip()} or None
    blank = not args.skip_blank

    all_findings: list[str] = []
    all_warnings: list[str] = []
    repos = load_repos(only)
    print(f"README 图片来源审计 owner={OWNER} 仓库={len(repos)} blank_check={blank}")
    if blank and Image is None:
        print("提示：未安装 Pillow，近空白检测已跳过（pip install pillow）")

    for repo in repos:
        try:
            findings, warnings = audit(repo, blank)
        except urllib.error.HTTPError as exc:
            all_findings.append(f"{repo} | ERROR | HTTP {exc.code}")
            continue
        if findings:
            all_findings.extend(findings)
        else:
            print(f"PASS {repo}")
        all_warnings.extend(warnings)

    if all_findings:
        print("\n发现问题：")
        for line in all_findings:
            print(line)
    else:
        print("clean：README 图与截图归档无同源")

    if all_warnings:
        print(f"\n近空白告警（{len(all_warnings)} 条，不阻断）：")
        for line in all_warnings:
            print(line)

    return 1 if (args.fail_on_reuse and all_findings) else 0


if __name__ == "__main__":
    sys.exit(main())
