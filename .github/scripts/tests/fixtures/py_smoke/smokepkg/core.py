"""最小样例：让覆盖率门禁与 mypy ratchet 都真实跑通的纯标准库代码。"""

from __future__ import annotations


def normalize(text: str) -> str:
    """压缩空白并转小写。"""
    return " ".join(text.split()).strip().lower()


def word_count(text: str) -> int:
    """按空白分词计数；纯空白返回 0。"""
    normalized = normalize(text)
    return len(normalized.split()) if normalized else 0
