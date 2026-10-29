#!/usr/bin/env python3
"""README 图路径解析回归测试（不依赖 Pillow / 网络）。

覆盖 §8.1 允许的三种托管形态与常见误判：
- jsDelivr 绝对 URL
- GitHub blob / raw URL
- raw.githubusercontent URL
- 仓内相对路径（Markdown 与 <img src>）
- 外部仓图片、data: URI 必须忽略
- query / fragment 必须剥离
"""

from __future__ import annotations

import importlib.util
import pathlib
import sys

SCRIPT = pathlib.Path(__file__).resolve().parents[1] / "check-readme-image-provenance.py"
spec = importlib.util.spec_from_file_location("readme_provenance", SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

CASES = [
    (
        "jsdelivr",
        "![x](https://gcore.jsdelivr.net/gh/ReSerendipity/SpiritPal@main/docs/assets/readme-1.png)",
        {"docs/assets/readme-1.png"},
    ),
    (
        "github blob",
        "![x](https://github.com/ReSerendipity/SpiritPal/blob/main/docs/assets/readme-1.png)",
        {"docs/assets/readme-1.png"},
    ),
    (
        "github raw",
        "![x](https://github.com/ReSerendipity/SpiritPal/raw/main/docs/assets/readme-1.png)",
        {"docs/assets/readme-1.png"},
    ),
    (
        "raw.githubusercontent",
        "![x](https://raw.githubusercontent.com/ReSerendipity/SpiritPal/main/docs/assets/readme-1.svg)",
        {"docs/assets/readme-1.svg"},
    ),
    ("relative", "![x](docs/assets/readme-1.svg)", {"docs/assets/readme-1.svg"}),
    (
        "html img",
        '<img src="docs/assets/readme-1.svg" width="880">',
        {"docs/assets/readme-1.svg"},
    ),
    ("query", "![x](docs/assets/readme-1.png?raw=true)", {"docs/assets/readme-1.png"}),
    (
        "external repo",
        "![x](https://gcore.jsdelivr.net/gh/Other/Repo@main/docs/assets/x.png)",
        set(),
    ),
    ("data uri", "![x](data:image/png;base64,AAA)", set()),
]

failures = 0
for name, text, expected in CASES:
    actual = module.extract_paths(text, "SpiritPal")
    if actual == expected:
        print(f"PASS  {name}")
    else:
        failures += 1
        print(f"FAIL  {name}: expected={expected} actual={actual}")

if failures:
    print(f"{failures} 个用例失败", file=sys.stderr)
    raise SystemExit(1)
print(f"OK：{len(CASES)} 个用例全部通过")
