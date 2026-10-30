"""与 smokepkg 配套的夹具测试：覆盖样例包全部语句，保证 --cov 与 mypy 两道门禁能真实跑绿。"""

from __future__ import annotations

from smokepkg.core import normalize, word_count


def test_normalize_collapses_whitespace() -> None:
    assert normalize("  A   B\nC\t") == "a b c"


def test_word_count_counts_and_zero() -> None:
    assert word_count("one two  three") == 3
    assert word_count("     ") == 0
