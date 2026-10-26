#!/usr/bin/env python3
"""README 展示图来源审计（只读）。

检查每个公开仓 README 中的图片是否与仓内截图归档（screenshots/、docs/screenshots/、
captures/、shots/、test-results/ 等）逐字节同源。同源即视为“复用本地历史截图”，
在治理 §8.1 下判红。

用法：
    python .github/scripts/check-readme-image-provenance.py [--fail-on-reuse] [--only a,b]
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.request

OWNER = "ReSerendipity"
API = "https://api.github.com"
SHOT_RE = re.compile(r"(?i)(^|/)(screenshots?|shots|captures?|snapshots?|test-results)/")
IMG_RE = re.compile(r"https?://[^\s\)\]\"']+\.(?:png|jpg|jpeg|gif|webp)", re.I)
JSDELIVR_RE = re.compile(
    r"https?://(?:gcore\.)?jsdelivr\.net/gh/[^@/]+/[^@]+@[^/]+/([^\s\)\]\"']+)", re.I
)


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


def audit(repo: str) -> list[str]:
    default_branch = read_json(f"/repos/{OWNER}/{repo}")["default_branch"]
    readme = read_text(f"/repos/{OWNER}/{repo}/readme")
    readme_paths = extract_paths(readme)
    if not readme_paths:
        return []

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
    for path in sorted(readme_paths):
        sha = path_to_sha.get(path)
        if not sha:
            findings.append(f"{repo} | MISSING | {path}")
            continue
        others = [p for p in sha_to_paths.get(sha, []) if p != path and SHOT_RE.search(p)]
        if others:
            findings.append(f"{repo} | REUSE | {path} <- {', '.join(sorted(others))}")
    return findings


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--fail-on-reuse", action="store_true")
    parser.add_argument("--only", default="")
    args = parser.parse_args()
    only = {x.strip() for x in args.only.split(",") if x.strip()} or None

    all_findings: list[str] = []
    repos = load_repos(only)
    print(f"README 图片来源审计 owner={OWNER} 仓库={len(repos)}")
    for repo in repos:
        try:
            findings = audit(repo)
        except urllib.error.HTTPError as exc:
            all_findings.append(f"{repo} | ERROR | HTTP {exc.code}")
            continue
        if findings:
            all_findings.extend(findings)
        else:
            print(f"PASS {repo}")

    if all_findings:
        print("\n发现问题：")
        for line in all_findings:
            print(line)
    else:
        print("clean：README 图与截图归档无同源")
    return 1 if (args.fail_on_reuse and all_findings) else 0


if __name__ == "__main__":
    sys.exit(main())
