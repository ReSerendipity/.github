#!/usr/bin/env python3
"""README 图审计新增检查回归测试（本地假数据，不联网、不依赖 Pillow / GitHub）。

覆盖 2026-11-11 新增的三类判定纯函数（正例 + 反例成对）：
- check_topics：公开仓 topics 为空 → TOPICS 告警；取不到（None）→ 跳过
- check_inplace：同名路径原地修改 > 1 次且文件名无 -YYYYMMDD 后缀 → INPLACE 告警；
  仅新增 1 次或带日期后缀 → 不告警
- check_caption：同图多处引用 alt 不一致 → CAPTION；缺 alt → ALT
以及 extract_refs 的 alt 捕获（Markdown / HTML / 缺 alt）与 extract_paths 旧行为兼容。
"""

from __future__ import annotations

import importlib.util
import pathlib
import sys

SCRIPT = pathlib.Path(__file__).resolve().parents[1] / "check-readme-image-provenance.py"
spec = importlib.util.spec_from_file_location("readme_provenance", SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

failures = 0


def check(name: str, cond: bool, detail: str = "") -> None:
    global failures
    if cond:
        print(f"PASS  {name}")
    else:
        failures += 1
        print(f"FAIL  {name}: {detail}")


# ── check_topics：空数组告警 / 非空不告警 / 取不到跳过 ──────────
w = module.check_topics("Demo-Repo", [])
check("topics 空数组告警", w is not None and "TOPICS" in w and "topics 为空" in w, repr(w))
w = module.check_topics("Demo-Repo", ["python", "readme"])
check("topics 非空不告警", w is None, repr(w))
w = module.check_topics("Demo-Repo", None)
check("topics 取不到跳过", w is None, repr(w))

# ── check_inplace：原地覆盖告警 / 新增 1 次与日期后缀豁免 ──────
w = module.check_inplace("Demo-Repo", "docs/assets/readme-ecosystem.svg", 2)
check("原地修改 2 次告警", w is not None and "INPLACE" in w and "2 次" in w, repr(w))
w = module.check_inplace("Demo-Repo", "readme-reserendipity-ecosystem.svg", 3)
check("原地修改 3 次告警", w is not None and "3 次" in w, repr(w))
w = module.check_inplace("Demo-Repo", "docs/assets/readme-ecosystem.svg", 1)
check("仅新增 1 次不告警", w is None, repr(w))
w = module.check_inplace("Demo-Repo", "docs/assets/readme-20261108.svg", 3)
check("日期后缀名豁免", w is None, repr(w))
w = module.check_inplace("Demo-Repo", "docs/assets/readme-20261108-2.png", 4)
check("日期+序号后缀名豁免", w is None, repr(w))

# ── check_caption：一致不告警 / 同语言不一致 CAPTION / 缺 alt ALT ────
w = module.check_caption("Demo-Repo", "docs/assets/a.png", ["架构图"])
check("单处引用非空不告警", w == [], repr(w))
w = module.check_caption("Demo-Repo", "docs/assets/a.png", ["架构图", "架构图"])
check("多处引用 alt 一致不告警", w == [], repr(w))
w = module.check_caption("Demo-Repo", "docs/assets/a.png", ["架构图", "Architecture"])
check("跨语言不同 alt 不报 CAPTION", w == [], repr(w))
w = module.check_caption("Demo-Repo", "docs/assets/a.png", ["架构图", "框架图"])
kinds = {k for k, _ in w}
check("同语言（CJK）不同 alt 报 CAPTION", kinds == {"CAPTION"}, repr(w))
w = module.check_caption("Demo-Repo", "docs/assets/a.png", ["Diagram", "Architecture"])
kinds = {k for k, _ in w}
check("同语言（非 CJK）不同 alt 报 CAPTION", kinds == {"CAPTION"}, repr(w))
w = module.check_caption("Demo-Repo", "docs/assets/a.png", [""])
kinds = {k for k, _ in w}
check("缺 alt 告警 ALT", kinds == {"ALT"}, repr(w))
w = module.check_caption("Demo-Repo", "docs/assets/a.png", ["", "图"])
kinds = {k for k, _ in w}
check("空 alt 与 CJK alt 属跨语言：仅 ALT", kinds == {"ALT"}, repr(w))
w = module.check_caption("Demo-Repo", "docs/assets/a.png", ["", "Architecture"])
kinds = {k for k, _ in w}
check("空 alt 与英文 alt 同属非 CJK 且不一致：ALT+CAPTION", kinds == {"ALT", "CAPTION"}, repr(w))

# ── extract_refs：alt 捕获与保序保重复 ────────────────────────
refs = module.extract_refs("![架构图](docs/assets/a.png)", "Demo-Repo")
check("markdown alt 捕获", refs == [("docs/assets/a.png", "架构图")], repr(refs))
refs = module.extract_refs('<img src="docs/assets/a.png" alt="架构图">', "Demo-Repo")
check("html alt 捕获", refs == [("docs/assets/a.png", "架构图")], repr(refs))
refs = module.extract_refs('<img src="docs/assets/a.png" width="880">', "Demo-Repo")
check("html 缺 alt 记空", refs == [("docs/assets/a.png", "")], repr(refs))
refs = module.extract_refs("![一](docs/assets/a.png)\n![二](docs/assets/a.png)", "Demo-Repo")
check(
    "多处引用保序保重复",
    [p for p, _ in refs] == ["docs/assets/a.png", "docs/assets/a.png"],
    repr(refs),
)

# ── extract_paths：兼容旧调用（仍返回路径集合）────────────────
paths = module.extract_paths("![x](docs/assets/a.png)\n![y](docs/assets/b.svg)", "Demo-Repo")
check("extract_paths 仍返回集合", paths == {"docs/assets/a.png", "docs/assets/b.svg"}, repr(paths))

if failures:
    print(f"{failures} 个用例失败", file=sys.stderr)
    raise SystemExit(1)
print("OK：新增检查全部用例通过")
