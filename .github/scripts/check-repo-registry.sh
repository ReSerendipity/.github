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

# 「§4 台账豁免」声明：备份仓 / 非台账副本不进「现网命名台账」，也不参与差集 B/C。
# 为什么在脚本里再声明一次：这些仓目前是私有，`users/<owner>/repos` 端点看不到它们，
# 因此当下不会触发任何差集；但**一旦某个仓转为公开**，差集 B（远程有、表里无）与差集 C
# （命名不符 §1）就会凭空报红。把排除显式写在这里，这份排除才有可执行载体。
#
# 与 §10 的关系（2026-10-19 豁免升级后两清单已同源）：
#   - §10 范围声明的「排除清单」共 17 项 = 不适用**整个规范**（用户裁决，见 §10 与 §4 的
#     2026-10-19 变更记录）。
#   - 本清单 = 其中参与「§4 台账 + §1 命名」维度的 13 项载体（§10 清单里其余 4 项为
#     Website-Genshin-Impact / Website-Honkai-Star-Rail / Website-Wuthering-Waves /
#     Website-Zenless-Zone-Zero——它们此前就不在 §4 表内、属台账豁免的固有覆盖，
#     且均为私有、公开端点不可见，无需单列亦不触发差集；如转公开需补入本清单）。
# 维护要求：本清单与 §4 的补充说明、以及 C:/Users/Doro/APP/repository/GOVERNANCE-EXCLUSIONS.md 同步修改。
# 2026-10-19 豁免升级（用户裁决）：排除清单 17 项由「不适用 §10」升级为「不适用整个规范」。
# 豁免 = 不进 §4 台账、不参与差集 B/C（§1 命名校验随之关闭）。清单共 13 项：
#   - 7 项备份/非台账仓（rewq、Assets-Backup、5 个 *-KeyBackup）
#   - 6 项用户点名仓（ComfyUI-BatchPromptLoader / Multi-Tracker / Bilibili-Follow-Manager /
#     Hugging-Face / Unfading-Wall / Unity）——2026-10-19 起随豁免升级进入本清单并已
#     从 §4 表移除；其已交付产物（发布文档 / CHANGELOG / 流水线）一律保留。
EXCLUDED_FROM_REGISTRY="rewq
Android-IconAutoArrange-Assets-Backup
Android-IconAutoArrange-KeyBackup
DraftPeek-KeyBackup
Image-DuoModel-KeyBackup
SeedVR2-Lite-KeyBackup
TTS-MultiModel-KeyBackup
ComfyUI-BatchPromptLoader
Multi-Tracker
Bilibili-Follow-Manager
Hugging-Face
Unfading-Wall
Unity"
is_excluded() { printf '%s\n' "$EXCLUDED_FROM_REGISTRY" | grep -qx "$1"; }

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
  is_excluded "$n" && continue
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
  if is_excluded "$n"; then continue; fi
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
  echo "  本脚本对备份仓/非台账副本有显式声明（EXCLUDED_FROM_REGISTRY），后者不参与差集 B/C。"
  echo "  §10 的发布规范豁免清单是另一份（含 6 个用户点名仓），不以本脚本的台账豁免表达。"
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