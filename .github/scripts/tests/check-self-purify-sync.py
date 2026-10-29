#!/usr/bin/env python3
"""self-purify.yml 中两处「本地治理文档不得被 git 跟踪」规则必须逐字节一致。

同一段判定逻辑分别存在于阻断 job（critical-governance）与非阻断 job（self-purify）：
前者是默认门禁，后者只在已登记例外仓回退时执行。单边修改会让两种路径判定分叉，
因此用本测试把“两处同步”变成可复跑的断言。
"""

from __future__ import annotations

import difflib
import pathlib
import sys

WORKFLOW = pathlib.Path(__file__).resolve().parents[2] / "workflows" / "self-purify.yml"
MARKER = "本地治理文档不得被 git 跟踪"


def extract_blocks(lines: list[str]) -> list[str]:
    blocks: list[str] = []
    for index, line in enumerate(lines):
        stripped = line.strip()
        if not stripped.startswith("- name:") or MARKER not in line:
            continue
        cursor = index + 1
        while cursor < len(lines) and not lines[cursor].strip().startswith("run: |"):
            cursor += 1
        if cursor >= len(lines):
            continue
        base_indent = len(lines[cursor]) - len(lines[cursor].lstrip())
        body: list[str] = []
        cursor += 1
        while cursor < len(lines):
            current = lines[cursor]
            indent = len(current) - len(current.lstrip())
            if current.strip() and indent <= base_indent:
                break
            body.append(current[base_indent + 2 :] if len(current) > base_indent + 2 else "")
            cursor += 1
        blocks.append("\n".join(body).strip("\n"))
    return blocks


def main() -> int:
    if not WORKFLOW.is_file():
        print(f"ERROR: 找不到 {WORKFLOW}", file=sys.stderr)
        return 2
    blocks = extract_blocks(WORKFLOW.read_text(encoding="utf-8").splitlines())
    if len(blocks) != 2:
        print(f"FAIL 期望 2 处规则，实际找到 {len(blocks)} 处", file=sys.stderr)
        return 1
    if blocks[0] != blocks[1]:
        diff = difflib.unified_diff(
            blocks[0].splitlines(),
            blocks[1].splitlines(),
            fromfile="critical-governance",
            tofile="self-purify",
            lineterm="",
        )
        print("FAIL 两处规则文本不一致：\n" + "\n".join(diff), file=sys.stderr)
        return 1
    print("OK：两处规则文本逐字节一致")
    return 0


if __name__ == "__main__":
    sys.exit(main())
