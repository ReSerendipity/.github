#!/usr/bin/env bash
# 校验 REPOSITORY_GUIDELINES.md §4 的现网仓库对照表是否与 GitHub 实际一致。
# 只读：仅向 GitHub 发 GET，不产生任何远端写入。
# 用法：bash .github/scripts/check-repo-registry.sh
# 退出码：0=clean（文档与远程一致）；1=gap（存在差集或计数不符）；2=无法判定（依赖/取数失败）。
set -uo pipefail

REPO_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
GUIDELINES="$REPO_ROOT/REPOSITORY_GUIDELINES.md"
OWNER=${REGISTRY_OWNER:-ReSerendipity}

# §1 认可的例外：系统保留名不按 Train Case 判定。
EXEMPT_NAMES=".github"

err() { echo "ERROR: $*" >&2; }

[ -f "$GUIDELINES" ] || { err "找不到 $GUIDELINES"; exit 2; }
command -v gh >/dev/null 2>&1 || { err "需要 gh（只读取数），本机未找到"; exit 2; }

REMOTE_TSV=$(mktemp)
trap 'rm -f "$REMOTE_TSV"' EXIT

# 取远程权威清单（分页取满；该端点结构性地只返回公开仓库）。
if ! gh api "users/$OWNER/repos" --paginate --jq '.[] | "\(.name)\t\(.private)"' > "$REMOTE_TSV" 2>/dev/null; then
  err "gh api users/$OWNER/repos 取数失败（网络/凭据/限流）"
  exit 2
fi
REMOTE_N=$(grep -c . "$REMOTE_TSV" || true)
if [ "${REMOTE_N:-0}" -eq 0 ]; then
  # 空结果不是 clean：无法区分「真没有仓」与「取数被静默截断」。
  err "远程清单返回 0 条，无法判定（拒绝把空集合当通过）"
  exit 2
fi

REMOTE_PUBLIC=$(awk -F'\t' '$2=="false"{print $1}' "$REMOTE_TSV" | sort)
REMOTE_ALL=$(cut -f1 "$REMOTE_TSV" | sort)

# 解析 §4 两张表：抽取 (小节, 仓库名, 可见性) 与标题声明条数。
ROWS=$(awk -v RS='\r?\n' '
  /^## 4\./ { insec=1; next }
  insec && /^## / { insec=0 }
  insec && /^### / { cur=$0; sub(/^### /,"",cur); next }
  insec && /^\|/ {
    line=$0
    if (line ~ /^\|[ ]*-+/) next                 # 分隔行
    split(line, c, "|")
    name=c[2]; vis=c[3]
    gsub(/^[ \t]+|[ \t]+$/, "", name)
    gsub(/^[ \t]+|[ \t]+$/, "", vis)
    if (name=="仓库" || name=="" || vis=="") next  # 表头
    print cur "\t" name "\t" vis
  }
' "$GUIDELINES")

REGISTRY_NAMES=$(printf '%s\n' "$ROWS" | cut -f2 | sort)

# 标题声明条数 vs 实际行数
COUNT_GAPS=""
while IFS= read -r sub; do
  [ -n "$sub" ] || continue
  declared=$(printf '%s' "$sub" | grep -oE '[0-9]+ 个' | grep -oE '[0-9]+' || true)
  actual=$(printf '%s\n' "$ROWS" | awk -F'\t' -v s="$sub" '$1==s' | grep -c . || true)
  if [ -z "$declared" ]; then
    COUNT_GAPS="${COUNT_GAPS}  - 小节「${sub}」标题未声明条数（实际 ${actual} 行）\n"
  elif [ "$declared" != "$actual" ]; then
    COUNT_GAPS="${COUNT_GAPS}  - 小节「${sub}」标题声明 ${declared} 个，实际 ${actual} 行\n"
  fi
done <<EOF
$(printf '%s\n' "$ROWS" | cut -f1 | sort -u)
EOF

# 差集 A：表里声明为 public，远程却没有同名仓。
MISSING_ON_REMOTE=""
while IFS= read -r n; do
  [ -n "$n" ] || continue
  vis=$(printf '%s\n' "$ROWS" | awk -F'\t' -v x="$n" '$2==x{print $3; exit}')
  [ "$vis" = "public" ] || continue
  echo "$REMOTE_ALL" | grep -qx "$n" || MISSING_ON_REMOTE="${MISSING_ON_REMOTE}  - $n（表内标为 public）\n"
done <<EOF
$REGISTRY_NAMES
EOF

# 差集 B：远程存在，表里没登记。
UNLISTED=""
while IFS= read -r n; do
  [ -n "$n" ] || continue
  echo "$REGISTRY_NAMES" | grep -qx "$n" || UNLISTED="${UNLISTED}  - $n\n"
done <<EOF
$(cut -f1 "$REMOTE_TSV")
EOF

# 差集 C：名称违反 §1（含下划线，或某个短横线分段不以大写开头）。
# 豁免来源有两个：§1 认可的系统保留名，以及 §4 里那行「已知命名不合规待改名」——
# 后者把尚未处理的远程改名欠账显式记在文档里，避免检查器长期报红而被当成噪声忽略。
DOC_EXEMPT=$(grep -oE '已知命名不合规待改名.*' "$GUIDELINES" 2>/dev/null | tail -1 |
  sed 's/.*：//' | tr '、' '\n' | sed 's/^[ \t]*//;s/[ \t]*$//' | grep -v '^$' || true)

NONCONFORMING=""
while IFS= read -r n; do
  [ -n "$n" ] || continue
  case "$n" in
    .*) continue ;;
  esac
  if echo "$EXEMPT_NAMES" | grep -qx "$n"; then continue; fi
  if [ -n "$DOC_EXEMPT" ] && echo "$DOC_EXEMPT" | grep -qx "$n"; then continue; fi
  if echo "$n" | grep -q '_'; then
    NONCONFORMING="${NONCONFORMING}  - $n（含下划线，§1 禁止）\n"
    continue
  fi
  bad_seg=""
  IFS='-' read -ra segs <<< "$n"
  for s in "${segs[@]}"; do
    [ -n "$s" ] || continue
    case "$s" in
      [A-Z]*) ;;
      *) bad_seg="$s" ;;
    esac
  done
  [ -n "$bad_seg" ] && NONCONFORMING="${NONCONFORMING}  - $n（分段「$bad_seg」未大写开头，§1 要求 Train Case）\n"
done <<EOF
$(printf '%s\n' "$REGISTRY_NAMES" "$REMOTE_ALL" | grep -v '^$' | sort -u)
EOF

echo "仓库注册表对照检查  owner=$OWNER  基准=GitHub API 实际仓名"
echo "  远程取到 $REMOTE_N 个仓（其中公开 $(echo "$REMOTE_PUBLIC" | grep -c . || true) 个）；§4 表登记 $(printf '%s\n' "$ROWS" | grep -c . || true) 条"
echo "  口径说明：users/<owner>/repos 只返回公开仓，表内标为 private 的行无法被该端点证实，故不参与差集 A。"
if [ -n "$DOC_EXEMPT" ]; then
  echo "  命名欠账（§4 已登记、待远程改名授权后消解，本轮不参与差集 C）：$(echo "$DOC_EXEMPT" | tr '\n' ' ')"
fi
echo ""

rc=0
if [ -n "$COUNT_GAPS" ]; then rc=1; printf '计数不符：\n%b\n' "$COUNT_GAPS"; fi
if [ -n "$MISSING_ON_REMOTE" ]; then rc=1; printf '表里有、远程无：\n%b\n' "$MISSING_ON_REMOTE"; fi
if [ -n "$UNLISTED" ]; then rc=1; printf '远程有、表里无：\n%b\n' "$UNLISTED"; fi
if [ -n "$NONCONFORMING" ]; then rc=1; printf '命名不合规：\n%b\n' "$NONCONFORMING"; fi

if [ "$rc" -eq 0 ]; then
  echo "clean：§4 对照表与远程一致"
else
  echo "gap：见上列差集，需按现网真值更新 REPOSITORY_GUIDELINES.md §4"
fi
exit "$rc"
