#!/usr/bin/env bash
# 治理单一事实来源一致性检查（只读）。
#
# 断言：
#   1. governance/desired-state.json 的仓集合 == GitHub 实际仓集合（双向差集为空）
#   2. desired-state 内部合法：仓名不重复；lifecycle / delivery / distribution 取值均有规则
#   3. check-repo-registry.sh 的 EXCLUDED_FROM_REGISTRY：名字都在 desired-state 内，
#      项数 == GOVERNANCE-EXCLUSIONS.md 的声明值
#   4. check-release-standard.sh 的 EXCLUDED_FROM_RELEASE_STANDARD：同上
#   5. governance/README.md 的「N 项不适用整部规范」+「M 个管辖仓」+ 规范仓自身 1
#      == desired-state 总数；且 N == §10 审计载体项数
#
# 只读：仅向 GitHub 发 GET，不产生任何远端写入。
# 用法：bash .github/scripts/check-governance-consistency.sh
# 退出码：0=clean；1=gap；2=无法判定（依赖/取数/文档结构失败）。
set -uo pipefail

REPO_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
DESIRED="$REPO_ROOT/governance/desired-state.json"
EXCL="$REPO_ROOT/governance/GOVERNANCE-EXCLUSIONS.md"
GREAD="$REPO_ROOT/governance/README.md"
REGISTRY_SCRIPT="$REPO_ROOT/.github/scripts/check-repo-registry.sh"
RELEASE_SCRIPT="$REPO_ROOT/.github/scripts/check-release-standard.sh"
OWNER=${GOVERNANCE_OWNER:-ReSerendipity}

err() { echo "ERROR: $*" >&2; }

for f in "$DESIRED" "$EXCL" "$GREAD" "$REGISTRY_SCRIPT" "$RELEASE_SCRIPT"; do
  [ -f "$f" ] || { err "找不到 $f"; exit 2; }
done

command -v gh >/dev/null 2>&1 || { err "需要 gh（只读取数），本机未找到"; exit 2; }

if command -v python3 >/dev/null 2>&1; then
  PY=python3
elif command -v python >/dev/null 2>&1; then
  PY=python
else
  err "需要 python3 或 python 解析 desired-state.json"
  exit 2
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# ---- 解析 desired-state -----------------------------------------------------
if ! "$PY" - "$DESIRED" > "$TMP_DIR/desired.tsv" <<'PY'
import json
import sys

try:
    # 期望状态可能由 PowerShell 写出而带 UTF-8 BOM，统一按 utf-8-sig 读取。
    with open(sys.argv[1], encoding="utf-8-sig") as handle:
        data = json.load(handle)
except Exception as exc:  # noqa: BLE001 - 任何解析失败都不具备判定条件
    print(f"ERR\t无法解析期望状态：{exc}")
    sys.exit(1)

rules = data.get("rules") or {}
lifecycles = rules.get("lifecycle") or {}
deliveries = rules.get("delivery") or {}
distributions = rules.get("distribution") or {}

errors = []
names = []
print(f"OWNER\t{data.get('owner', '')}")
for repo in data.get("repos") or []:
    name = repo.get("name")
    if not name:
        errors.append("存在缺少 name 的条目录")
        continue
    names.append(name)
    if repo.get("lifecycle") not in lifecycles:
        errors.append(f"{name}: lifecycle={repo.get('lifecycle')!r} 无对应规则")
    if repo.get("delivery") not in deliveries:
        errors.append(f"{name}: delivery={repo.get('delivery')!r} 无对应规则")
    for item in repo.get("distribution") or []:
        if item not in distributions:
            errors.append(f"{name}: distribution={item!r} 无对应规则")

for name in sorted({item for item in names if names.count(item) > 1}):
    errors.append(f"仓名重复：{name}")

print(f"TOTAL\t{len(names)}")
for name in names:
    print(f"NAME\t{name}")
for item in errors:
    print(f"ERR\t{item}")
sys.exit(1 if errors else 0)
PY
then
  err "desired-state.json 解析或结构校验失败，见上列 ERR"
  grep '^ERR' "$TMP_DIR/desired.tsv" >&2 || true
  exit 2
fi

DESIRED_OWNER=$(awk -F'\t' '$1=="OWNER"{print $2}' "$TMP_DIR/desired.tsv")
DESIRED_TOTAL=$(awk -F'\t' '$1=="TOTAL"{print $2}' "$TMP_DIR/desired.tsv")
awk -F'\t' '$1=="NAME"{print $2}' "$TMP_DIR/desired.tsv" | sort > "$TMP_DIR/desired.names"

if [ "$DESIRED_OWNER" != "$OWNER" ]; then
  err "desired-state.owner=$DESIRED_OWNER 与检查目标 owner=$OWNER 不一致"
  exit 2
fi

# ---- 远程仓清单 -------------------------------------------------------------
if ! gh repo list "$OWNER" --limit 200 --json name --jq '.[].name' > "$TMP_DIR/remote.names" 2>"$TMP_DIR/gh.err"; then
  err "gh repo list $OWNER 取数失败：$(cat "$TMP_DIR/gh.err")"
  exit 2
fi
sort -o "$TMP_DIR/remote.names" "$TMP_DIR/remote.names"
REMOTE_TOTAL=$(grep -c . "$TMP_DIR/remote.names" || true)
if [ "${REMOTE_TOTAL:-0}" -eq 0 ]; then
  err "远程清单返回 0 条，无法判定（拒绝把空集合当通过）"
  exit 2
fi

# ---- 从脚本里抽取排除数组 ---------------------------------------------------
extract_array() {
  local file="$1" var="$2"
  awk -v var="$var" '
    index($0, var "=\"") > 0 { inside=1; sub(".*" var "=\"", "") }
    inside {
      if (substr($0, length($0), 1) == "\"") { print substr($0, 1, length($0)-1); inside=0 }
      else print
    }
  ' "$file"
}

extract_array "$REGISTRY_SCRIPT" "EXCLUDED_FROM_REGISTRY" | grep -v '^$' | sort > "$TMP_DIR/registry.names"
extract_array "$RELEASE_SCRIPT" "EXCLUDED_FROM_RELEASE_STANDARD" | grep -v '^$' | sort > "$TMP_DIR/release.names"
REGISTRY_N=$(grep -c . "$TMP_DIR/registry.names" || true)
RELEASE_N=$(grep -c . "$TMP_DIR/release.names" || true)

if [ "${REGISTRY_N:-0}" -eq 0 ] || [ "${RELEASE_N:-0}" -eq 0 ]; then
  err "排除数组抽取为空，脚本结构可能已变（检查变量名与引号格式）"
  exit 2
fi

# ---- 文档声明值 -------------------------------------------------------------
DOC_REGISTRY=$(grep -E '^\| `check-repo-registry\.sh`' "$EXCL" | grep -oE '\*\*[0-9]+\*\*' | head -1 | tr -d '*')
DOC_RELEASE=$(grep -E '^\| `check-release-standard\.sh`' "$EXCL" | grep -oE '\*\*[0-9]+\*\*' | head -1 | tr -d '*')
README_EXEMPT=$(grep -oE '[0-9]+ 项不适用整部规范' "$GREAD" | head -1 | grep -oE '[0-9]+')
README_GOVERNED=$(grep -oE '[0-9]+ 个管辖仓' "$GREAD" | head -1 | grep -oE '[0-9]+')

if [ -z "$DOC_REGISTRY" ] || [ -z "$DOC_RELEASE" ] || [ -z "$README_EXEMPT" ] || [ -z "$README_GOVERNED" ]; then
  err "文档声明值抽取失败（GOVERNANCE-EXCLUSIONS.md 表格或 governance/README.md 措辞已变）"
  exit 2
fi

# ---- 断言 -------------------------------------------------------------------
GAPS=""

MISSING_ON_REMOTE=$(comm -23 "$TMP_DIR/desired.names" "$TMP_DIR/remote.names")
UNLISTED=$(comm -13 "$TMP_DIR/desired.names" "$TMP_DIR/remote.names")
if [ -n "$MISSING_ON_REMOTE" ]; then
  GAPS="${GAPS}desired-state 有、远程无：\n$(echo "$MISSING_ON_REMOTE" | sed 's/^/  - /')\n"
fi
if [ -n "$UNLISTED" ]; then
  GAPS="${GAPS}远程有、desired-state 无：\n$(echo "$UNLISTED" | sed 's/^/  - /')\n"
fi

NOT_IN_DESIRED=$(comm -23 "$TMP_DIR/registry.names" "$TMP_DIR/desired.names")
if [ -n "$NOT_IN_DESIRED" ]; then
  GAPS="${GAPS}EXCLUDED_FROM_REGISTRY 含 desired-state 之外的仓：\n$(echo "$NOT_IN_DESIRED" | sed 's/^/  - /')\n"
fi
NOT_IN_DESIRED=$(comm -23 "$TMP_DIR/release.names" "$TMP_DIR/desired.names")
if [ -n "$NOT_IN_DESIRED" ]; then
  GAPS="${GAPS}EXCLUDED_FROM_RELEASE_STANDARD 含 desired-state 之外的仓：\n$(echo "$NOT_IN_DESIRED" | sed 's/^/  - /')\n"
fi

[ "$REGISTRY_N" = "$DOC_REGISTRY" ] || GAPS="${GAPS}  - EXCLUDED_FROM_REGISTRY 实有 $REGISTRY_N 项，GOVERNANCE-EXCLUSIONS.md 声明 $DOC_REGISTRY 项\n"
[ "$RELEASE_N" = "$DOC_RELEASE" ] || GAPS="${GAPS}  - EXCLUDED_FROM_RELEASE_STANDARD 实有 $RELEASE_N 项，GOVERNANCE-EXCLUSIONS.md 声明 $DOC_RELEASE 项\n"
[ "$README_EXEMPT" = "$DOC_RELEASE" ] || GAPS="${GAPS}  - governance/README.md 声明 $README_EXEMPT 项豁免，§10 审计载体为 $DOC_RELEASE 项\n"

ARITHMETIC=$((README_EXEMPT + README_GOVERNED + 1))
[ "$ARITHMETIC" = "$DESIRED_TOTAL" ] || GAPS="${GAPS}  - README 分组计数 $README_EXEMPT + $README_GOVERNED + 1 = $ARITHMETIC，desired-state 共 $DESIRED_TOTAL 个仓\n"

echo "治理单一事实来源一致性检查  owner=$OWNER"
echo "  desired-state：$DESIRED_TOTAL 仓；远程：$REMOTE_TOTAL 仓"
echo "  排除数组：EXCLUDED_FROM_REGISTRY=$REGISTRY_N（文档 $DOC_REGISTRY）；EXCLUDED_FROM_RELEASE_STANDARD=$RELEASE_N（文档 $DOC_RELEASE）"
echo "  README 分组：豁免 $README_EXEMPT + 管辖 $README_GOVERNED + 规范仓 1 = $ARITHMETIC"
echo ""

if [ -n "$GAPS" ]; then
  printf 'gap：\n%b' "$GAPS"
  exit 1
fi

echo "clean：desired-state、远程仓清单、两份排除数组与文档计数一致"
exit 0
