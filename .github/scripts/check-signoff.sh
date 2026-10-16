#!/usr/bin/env bash
# 校验一段提交区间内的每笔提交都带 Signed-off-by 尾注（CONTRIBUTING.md 的 DCO 要求）。
#
# 用法：bash .github/scripts/check-signoff.sh <base-sha> <head-sha>
#   区间语义为 git 的 base..head，即 base 之后的提交；base 自身不检查。
#
# 退出码：
#   0 = 区间内所有非 merge 提交都有尾注
#   1 = 存在缺尾注的提交
#   2 = 区间无法解析（参数缺失/对象不存在）——失败关闭，绝不退 0，
#       否则一旦 CI 拿不到 base 就会变成"永远绿"的空跑门禁。
#
# merge 提交不计：GitHub 非 squash 合并自动生成的 merge commit 不会带贡献者的
# Signed-off-by，把它算进来会让每个合并都变红（假阳性）。区间里被展开的
# 逐笔贡献提交仍照常检查。
set -uo pipefail

err() { echo "ERROR: $*" >&2; }

BASE=${1:-}
HEAD=${2:-}

if [ -z "$BASE" ] || [ -z "$HEAD" ]; then
  err "需要 base 与 head 两个提交参数，实际 base='$BASE' head='$HEAD'"
  exit 2
fi
# 全零 SHA 是 Git 表示"该 ref 尚不存在"的约定，不是可解析对象。
case "$BASE" in
  0000000000000000000000000000000000000000) err "base 为全零 SHA（新建 ref），无法界定检查区间"; exit 2 ;;
esac
for ref in "$BASE" "$HEAD"; do
  if ! git cat-file -e "${ref}^{commit}" 2>/dev/null; then
    err "提交 $ref 在本检出中不可解析（fetch-depth 不足或对象被 GC）"
    exit 2
  fi
done
if ! git merge-base --is-ancestor "$BASE" "$HEAD" 2>/dev/null; then
  err "$BASE 不是 $HEAD 的祖先，base..head 区间无意义"
  exit 2
fi

# 归一到完整 SHA，否则传相对引用（如 main~1）时日志里的区间会被截断成误导性文本。
BASE=$(git rev-parse "$BASE^{commit}")
HEAD=$(git rev-parse "$HEAD^{commit}")

mapfile -t COMMITS < <(git rev-list --no-merges "${BASE}..${HEAD}")
COUNT=${#COMMITS[@]}

echo "Signed-off-by 检查：区间 ${BASE:0:7}..${HEAD:0:7}，待检 ${COUNT} 笔（不含 merge）"

if [ "$COUNT" -eq 0 ]; then
  # 区间为空在本仓 CI 语义下是异常而非常态：push 到 main 至少带一笔新提交，
  # PR 更新也至少带一笔。退 2 让这种情况显式暴露，而不是静默通过。
  err "区间内没有任何非 merge 提交：要么这次改动确实不产生提交，要么基线取错"
  exit 2
fi

MISSING=()
for c in "${COMMITS[@]}"; do
  # 只要求存在 Signed-off-by 尾注行且其后有非空内容（DCO 惯例格式为 Name <email>）；
  # 不去校验邮箱形状，否则 noreply、别名等多种合法写法会被误判。
  if ! git log -1 --format=%B "$c" | grep -qiE '^[[:space:]]*Signed-off-by:[[:space:]]*[^[:space:]]'; then
    MISSING+=("$c")
  fi
done

if [ "${#MISSING[@]}" -gt 0 ]; then
  echo "以下 ${#MISSING[@]} 笔提交缺少 Signed-off-by 尾注：" >&2
  for c in "${MISSING[@]}"; do
    echo "  - $(git log -1 --format='%h %s' "$c")" >&2
  done
  echo "" >&2
  echo "补法：对未推送的提交用 git commit --amend -s 或 git rebase -i --signoff <base>；" >&2
  echo "已合入 main 的历史如需补签名属改写历史操作，需单独授权。" >&2
  exit 1
fi

echo "OK：${COUNT} 笔提交均含 Signed-off-by"
exit 0
