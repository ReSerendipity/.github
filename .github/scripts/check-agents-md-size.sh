#!/usr/bin/env bash
# 检查一个仓库内的 AGENTS.md 家族是否超出 REPOSITORY_GUIDELINES.md §7 约定的行数上限。
#
# 为什么需要这个脚本：§7 与 self-purify.yml 都把 AGENTS.md 的行数约束交给
# 「AI 会话自检 + 本地钩子」，但两者都没有可执行载体，也没有成文数值。
# 本脚本提供载体：本地手工调用（也可挂进钩子），AGENTS.md 按 §7 永不入库，
# 所以这道检查天然只能在机器上跑、不可能进 CI（检出里没有这个文件）。
#
# 上限默认 300，来源是 2026-10-17 对本机 14 个根级第一方 AGENTS.md 的实测：
#   min=21 median=90.5 p90=163 max=724；<=300 的 13 个，>300 的只有 1 个
#   （Prompt-Library/AGENTS.md = 724，已作为现存欠账登记在 §7）。
#   300 高于合规簇最大值 257，因此不会追溯性地把既有文件全判红，同时仍是真实约束。
#   要改数值请用 --max-lines 传参，别改默认值后忘记记理由。
#
# 扫描口径（每条排除都会在输出里显式列出来，不静默吞文件）：
#   - 只扫一个仓库（--root，默认当前目录）；
#   - 排除生成物与第三方目录名；
#   - 排除归档/备份副本（*backup* / _archive / 备份）：它们不是活动上下文；
#   - 排除「嵌套 git 仓」的目录：嵌套仓不属于本仓的跟踪树，其中的 AGENTS.md
#     （无论上游 vendored 还是另行 checkout 的子项目）由那个仓自己判。
#     用 --include-nested 可以连它们一起查。
#
# 用法：
#   bash .github/scripts/check-agents-md-size.sh [--root DIR] [--max-lines N] [--include-nested]
# 退出码：
#   0 = clean（无超标；或该目录没有 AGENTS.md —— §7 视 clone/CI 环境无此文件为预期）
#   1 = 有文件超过上限
#   2 = 入参不可用（目录不存在 / 上限非正整数）
set -uo pipefail

ROOT=.
MAX=300
INCLUDE_NESTED=0

while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT=${2:-}; shift 2 ;;
    --root=*) ROOT=${1#*=}; shift ;;
    --max-lines) MAX=${2:-}; shift 2 ;;
    --max-lines=*) MAX=${1#*=}; shift ;;
    --include-nested) INCLUDE_NESTED=1; shift ;;
    *) echo "ERROR: 未知参数 '$1'" >&2; exit 2 ;;
  esac
done

[ -d "$ROOT" ] || { echo "ERROR: 目录不存在：$ROOT" >&2; exit 2; }
case "$MAX" in
  ''|*[!0-9]*) echo "ERROR: --max-lines 需为正整数，实际='$MAX'" >&2; exit 2 ;;
esac
[ "$MAX" -gt 0 ] || { echo "ERROR: --max-lines 必须 > 0" >&2; exit 2; }

PRUNE=( -name node_modules -o -name .git -o -name .venv -o -name venv
        -o -name vendor -o -name third_party -o -name dist -o -name build
        -o -name target -o -name .qoder -o -name _archive -o -name 备份
        -o -iname '*backup*' -o -name 'pytest-tmp-*' )

# 先找出嵌套 git 仓（排除各仓自身根目录），再据此剪枝。
# 用真换行的临时文件承载清单：早先用字符串拼 \n 时，展示走 printf '%b' 看起来是对的，
# 而 -path 实参里带着字面量反斜杠 n，于是剪枝静默失效——显示与判定口径必须同源。
NESTED_ALL=$(mktemp); NESTED_SKIP=$(mktemp)
trap 'rm -f "$NESTED_ALL" "$NESTED_SKIP"' EXIT
find "$ROOT" \( -name node_modules -o -name .git \) -prune -o -type d -print 2>/dev/null > "$NESTED_ALL" || true
while IFS= read -r d; do
  [ -n "$d" ] || continue
  case "$d" in "$ROOT") continue ;; esac
  [ -e "$d/.git" ] && printf '%s\n' "$d" >> "$NESTED_SKIP"
done < "$NESTED_ALL"
SKIP_COUNT=$(grep -c . "$NESTED_SKIP" 2>/dev/null || true)

if [ "${SKIP_COUNT:-0}" -gt 0 ] && [ "$INCLUDE_NESTED" -eq 0 ]; then
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    # 必须带 -o 前缀：PRUNE 是以 -o 串联的扁平数组，直接追加 -path 会和上一项
    # 形成 AND 语义（实测会让嵌套仓「被列为排除但根本没被剪掉」）。
    PRUNE+=( -o -path "$d" )
  done < "$NESTED_SKIP"
fi

FILES=$(find "$ROOT" \( "${PRUNE[@]}" \) -prune -o -type f -name 'AGENTS.md' -print 2>/dev/null | sort)

echo "AGENTS.md 行数检查：上限 ${MAX} 行，root=$ROOT"
if [ "${SKIP_COUNT:-0}" -gt 0 ] && [ "$INCLUDE_NESTED" -eq 0 ]; then
  echo "  已排除嵌套 git 仓 ${SKIP_COUNT} 个（加 --include-nested 可连它们一起查）："
  sed 's/^/    - /' "$NESTED_SKIP"
fi

if [ -z "$FILES" ]; then
  echo "clean：$ROOT 下没有活动 AGENTS.md（§7 视之为预期，不当缺失处理）"
  exit 0
fi

echo "  待检 $(printf '%s\n' "$FILES" | grep -c .) 个文件"
OVER=()
while IFS= read -r f; do
  [ -n "$f" ] || continue
  n=$(wc -l < "$f")
  if [ "$n" -gt "$MAX" ]; then
    OVER+=("  - ${f}（${n} 行 > ${MAX}）")
    printf "  OVER  %6s 行  %s\n" "$n" "$f"
  else
    printf "  ok    %6s 行  %s\n" "$n" "$f"
  fi
done <<EOF
$FILES
EOF

if [ "${#OVER[@]}" -gt 0 ]; then
  echo "" >&2
  echo "超标文件（${#OVER[@]} 个）：" >&2
  for line in "${OVER[@]}"; do echo "$line" >&2; done
  echo "拆分办法见 §7.5：模块 / 任务内容下沉到 local/agents/<module|task>.md；" >&2
  echo "本地维护说明进 local/README.internal.md；文档分流判据见 §13.1。" >&2
  exit 1
fi
echo "clean：所有活动 AGENTS.md 均未超过 ${MAX} 行"
exit 0
