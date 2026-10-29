#!/usr/bin/env bash
# 治理单一事实来源一致性检查（只读）。
#
# 断言：
#   1. governance/desired-state.json 的仓集合 == GitHub 实际仓集合（双向差集为空）
#   2. desired-state 内部合法：仓名不重复；lifecycle / delivery / distribution 取值均有规则
#   3. check-repo-registry.sh 的 EXCLUDED_FROM_REGISTRY：集合 == desired-state 的 backup 仓集合，
#      项数 == 文档声明 == desired-state 的 backup 仓数（8）
#   4. check-release-standard.sh 的 EXCLUDED_FROM_RELEASE_STANDARD：集合 == desired-state 的非 release 仓集合
#   5. governance/README.md 的「40 个登记仓」+「8 个备份仓」== desired-state 总数 48
#   6. 根 README / 规范正文 / 分档矩阵 SVG 的硬编码计数与 desired-state 一致（中英 + 图文）
#
# 只读：仅向 GitHub 发 GET，不产生任何远端写入。
# 用法：bash .github/scripts/check-governance-consistency.sh [--public-only]
#   --public-only：只校验与公开仓有关的差集；Actions 默认 GITHUB_TOKEN 看不到
#   其他私有仓，CI 用此模式；完整 48 仓校验需本地 owner 凭据。
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

PUBLIC_ONLY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --public-only) PUBLIC_ONLY=1; shift ;;
    *) err "未知参数：$1"; exit 2 ;;
  esac
done

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
        errors.append("存在缺少 name 的条目")
        continue
    names.append(name)
    print(f"VIS\t{name}\t{repo.get('visibility', '')}")
    print(f"DEL\t{name}\t{repo.get('delivery', '')}")
    if repo.get("lifecycle") not in lifecycles:
        errors.append(f"{name}: lifecycle={repo.get('lifecycle')!r} 无对应规则")
    if repo.get("delivery") not in deliveries:
        errors.append(f"{name}: delivery={repo.get('delivery')!r} 无对应规则")
    for item in repo.get("distribution") or []:
        if item not in distributions:
            errors.append(f"{name}: distribution={item!r} 无对应规则")

for name in sorted({item for item in names if names.count(item) > 1}):
    errors.append(f"仓名重复：{name}")

for key in ("delivery", "lifecycle"):
    counter = {}
    for repo in data.get("repos") or []:
        value = repo.get(key)
        counter[value] = counter.get(value, 0) + 1
    for value, count in sorted(counter.items()):
        print(f"COUNT\t{key}\t{value}\t{count}")

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
awk -F'\t' '$1=="VIS" && $3=="public"{print $2}' "$TMP_DIR/desired.tsv" | sort > "$TMP_DIR/desired.public.names"
awk -F'\t' '$1=="VIS" && $3=="private"{print $2}' "$TMP_DIR/desired.tsv" | sort > "$TMP_DIR/desired.private.names"
awk -F'\t' '$1=="DEL" && $3=="backup"{print $2}' "$TMP_DIR/desired.tsv" | sort > "$TMP_DIR/desired.backup.names"
awk -F'\t' '$1=="DEL" && $3!="release"{print $2}' "$TMP_DIR/desired.tsv" | sort > "$TMP_DIR/desired.nonrelease.names"
PRIVATE_TOTAL=$(grep -c . "$TMP_DIR/desired.private.names" || true)

if [ "$DESIRED_OWNER" != "$OWNER" ]; then
  err "desired-state.owner=$DESIRED_OWNER 与检查目标 owner=$OWNER 不一致"
  exit 2
fi

# ---- 远程仓清单 -------------------------------------------------------------
if [ "$PUBLIC_ONLY" -eq 1 ]; then
  REMOTE_JSON='name,isPrivate'
  REMOTE_JQ='.[] | select(.isPrivate==false) | .name'
else
  REMOTE_JSON='name'
  REMOTE_JQ='.[].name'
fi
if ! gh repo list "$OWNER" --limit 200 --json "$REMOTE_JSON" --jq "$REMOTE_JQ" > "$TMP_DIR/remote.names" 2>"$TMP_DIR/gh.err"; then
  err "gh repo list $OWNER 取数失败：$(cat "$TMP_DIR/gh.err")"
  exit 2
fi
sort -o "$TMP_DIR/remote.names" "$TMP_DIR/remote.names"
RELEASE_TOTAL=$(awk -F'\t' '$1=="COUNT" && $2=="delivery" && $3=="release"{print $4}' "$TMP_DIR/desired.tsv")
BACKUP_TOTAL=$(awk -F'\t' '$1=="COUNT" && $2=="delivery" && $3=="backup"{print $4}' "$TMP_DIR/desired.tsv")
if [ -z "$RELEASE_TOTAL" ] || [ -z "$BACKUP_TOTAL" ]; then
  err "无法从 desired-state 解析 release / backup 仓数"
  exit 2
fi
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
README_REGISTERED=$(grep -oE '[0-9]+ 个登记仓' "$GREAD" | head -1 | grep -oE '[0-9]+')
README_BACKUP=$(grep -oE '[0-9]+ 个备份仓' "$GREAD" | head -1 | grep -oE '[0-9]+')

if [ -z "$DOC_REGISTRY" ] || [ -z "$DOC_RELEASE" ] || [ -z "$README_REGISTERED" ] || [ -z "$README_BACKUP" ]; then
  err "文档声明值抽取失败（GOVERNANCE-EXCLUSIONS.md 表格或 governance/README.md 措辞已变）"
  exit 2
fi

# ---- 断言 -------------------------------------------------------------------
GAPS=""

if [ "$PUBLIC_ONLY" -eq 1 ]; then
  COMPARE_DESIRED="$TMP_DIR/desired.public.names"
else
  COMPARE_DESIRED="$TMP_DIR/desired.names"
fi
MISSING_ON_REMOTE=$(comm -23 "$COMPARE_DESIRED" "$TMP_DIR/remote.names")
UNLISTED=$(comm -13 "$COMPARE_DESIRED" "$TMP_DIR/remote.names")
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

REGISTRY_MISSING=$(comm -23 "$TMP_DIR/desired.backup.names" "$TMP_DIR/registry.names")
REGISTRY_EXTRA=$(comm -13 "$TMP_DIR/desired.backup.names" "$TMP_DIR/registry.names")
if [ -n "$REGISTRY_MISSING" ]; then
  GAPS="${GAPS}EXCLUDED_FROM_REGISTRY 漏列 backup 仓：\n$(echo "$REGISTRY_MISSING" | sed 's/^/  - /')\n"
fi
if [ -n "$REGISTRY_EXTRA" ]; then
  GAPS="${GAPS}EXCLUDED_FROM_REGISTRY 多列非 backup 仓：\n$(echo "$REGISTRY_EXTRA" | sed 's/^/  - /')\n"
fi
RELEASE_MISSING=$(comm -23 "$TMP_DIR/desired.nonrelease.names" "$TMP_DIR/release.names")
RELEASE_EXTRA=$(comm -13 "$TMP_DIR/desired.nonrelease.names" "$TMP_DIR/release.names")
if [ -n "$RELEASE_MISSING" ]; then
  GAPS="${GAPS}EXCLUDED_FROM_RELEASE_STANDARD 漏列非 release 仓：\n$(echo "$RELEASE_MISSING" | sed 's/^/  - /')\n"
fi
if [ -n "$RELEASE_EXTRA" ]; then
  GAPS="${GAPS}EXCLUDED_FROM_RELEASE_STANDARD 多列 release 仓：\n$(echo "$RELEASE_EXTRA" | sed 's/^/  - /')\n"
fi

[ "$REGISTRY_N" = "$DOC_REGISTRY" ] || GAPS="${GAPS}  - EXCLUDED_FROM_REGISTRY 实有 $REGISTRY_N 项，GOVERNANCE-EXCLUSIONS.md 声明 $DOC_REGISTRY 项\n"
[ "$RELEASE_N" = "$DOC_RELEASE" ] || GAPS="${GAPS}  - EXCLUDED_FROM_RELEASE_STANDARD 实有 $RELEASE_N 项，GOVERNANCE-EXCLUSIONS.md 声明 $DOC_RELEASE 项\n"
[ "$REGISTRY_N" = "$BACKUP_TOTAL" ] || GAPS="${GAPS}  - EXCLUDED_FROM_REGISTRY 实有 $REGISTRY_N 项，desired-state 的 backup 仓为 $BACKUP_TOTAL 个\n"
[ "$README_BACKUP" = "$BACKUP_TOTAL" ] || GAPS="${GAPS}  - governance/README.md 声明 $README_BACKUP 个备份仓，desired-state 为 $BACKUP_TOTAL 个\n"
[ "$RELEASE_N" = "$((DESIRED_TOTAL - RELEASE_TOTAL))" ] || GAPS="${GAPS}  - EXCLUDED_FROM_RELEASE_STANDARD 实有 $RELEASE_N 项，应为非 release 仓 $((DESIRED_TOTAL - RELEASE_TOTAL)) 个\n"
[ "$README_REGISTERED" = "$((DESIRED_TOTAL - BACKUP_TOTAL))" ] || GAPS="${GAPS}  - governance/README.md 声明 $README_REGISTERED 个登记仓，应为 $((DESIRED_TOTAL - BACKUP_TOTAL)) 个\n"

ARITHMETIC=$((README_REGISTERED + README_BACKUP))
[ "$ARITHMETIC" = "$DESIRED_TOTAL" ] || GAPS="${GAPS}  - README 分组计数 $README_REGISTERED + $README_BACKUP = $ARITHMETIC，desired-state 共 $DESIRED_TOTAL 个仓\n"

# ---- 文档硬编码计数（防止“正文/英文表/展示图”与 JSON 再次漂移）-------------
ROOT_README="$REPO_ROOT/README.md"
GUIDE="$REPO_ROOT/governance/REPOSITORY_GUIDELINES.md"
ACTIVE_TOTAL=$(awk -F'\t' '$1=="COUNT" && $2=="lifecycle" && $3=="active"{print $4}' "$TMP_DIR/desired.tsv")
MAINT_TOTAL=$(awk -F'\t' '$1=="COUNT" && $2=="lifecycle" && $3=="maintenance"{print $4}' "$TMP_DIR/desired.tsv")
ARCHIVED_TOTAL=$(awk -F'\t' '$1=="COUNT" && $2=="lifecycle" && $3=="archived"{print $4}' "$TMP_DIR/desired.tsv")

DOC_BACKUP_ZH=$(grep -oE '[0-9]+ 个密钥/资产备份仓' "$ROOT_README" | head -1 | grep -oE '[0-9]+')
DOC_BACKUP_EN=$(grep -oE '[0-9]+ backup-repo exemptions' "$ROOT_README" | head -1 | grep -oE '[0-9]+')
DOC_LEDGER=$(grep -oE '[0-9]+ 个台账登记仓' "$ROOT_README" | head -1 | grep -oE '[0-9]+')
DOC_GUIDE_BACKUP_A=$(grep -oE 'delivery=backup[`] 的 [0-9]+ 个仓' "$GUIDE" | head -1 | grep -oE '[0-9]+')
DOC_GUIDE_BACKUP_B=$(grep -oE '[0-9]+ 个 [`]backup[`] 仓不登记' "$GUIDE" | head -1 | grep -oE '[0-9]+')
README_LC=$(grep -oE 'active [0-9]+ / maintenance [0-9]+ / archived [0-9]+' "$ROOT_README" | head -1)
SVG_MATRIX=$(ls -1 "$REPO_ROOT"/docs/assets/readme-govgithub-3-*.svg 2>/dev/null | tail -1)

if [ -z "$DOC_BACKUP_ZH" ] || [ -z "$DOC_BACKUP_EN" ] || [ -z "$DOC_LEDGER" ] || [ -z "$DOC_GUIDE_BACKUP_A" ] || [ -z "$DOC_GUIDE_BACKUP_B" ]; then
  GAPS="${GAPS}  - 文档硬编码计数抽取失败：根 README 或规范正文措辞已变，需同步本脚本\n"
else
  [ "$DOC_BACKUP_ZH" = "$BACKUP_TOTAL" ] || GAPS="${GAPS}  - 根 README 声明 $DOC_BACKUP_ZH 个备份仓，应为 $BACKUP_TOTAL 个\n"
  [ "$DOC_BACKUP_EN" = "$BACKUP_TOTAL" ] || GAPS="${GAPS}  - 根 README 英文表声明 $DOC_BACKUP_EN 个 backup exemptions，应为 $BACKUP_TOTAL 个\n"
  [ "$DOC_LEDGER" = "$((DESIRED_TOTAL - BACKUP_TOTAL))" ] || GAPS="${GAPS}  - 根 README 声明 $DOC_LEDGER 个台账登记仓，应为 $((DESIRED_TOTAL - BACKUP_TOTAL)) 个\n"
  [ "$DOC_GUIDE_BACKUP_A" = "$BACKUP_TOTAL" ] || GAPS="${GAPS}  - 规范 §2 声明 $DOC_GUIDE_BACKUP_A 个 backup 仓，应为 $BACKUP_TOTAL 个\n"
  [ "$DOC_GUIDE_BACKUP_B" = "$BACKUP_TOTAL" ] || GAPS="${GAPS}  - 规范 §15.6 声明 $DOC_GUIDE_BACKUP_B 个 backup 仓，应为 $BACKUP_TOTAL 个\n"
fi

if [ -z "$README_LC" ]; then
  GAPS="${GAPS}  - 根 README 未找到 lifecycle 计数行（active / maintenance / archived）\n"
else
  read -r R_ACTIVE R_MAINT R_ARCHIVED <<< "$(printf '%s\n' "$README_LC" | grep -oE '[0-9]+' | tr '\n' ' ')"
  [ "$R_ACTIVE" = "$ACTIVE_TOTAL" ] || GAPS="${GAPS}  - 根 README 声明 active $R_ACTIVE，应为 $ACTIVE_TOTAL\n"
  [ "$R_MAINT" = "$MAINT_TOTAL" ] || GAPS="${GAPS}  - 根 README 声明 maintenance $R_MAINT，应为 $MAINT_TOTAL\n"
  [ "$R_ARCHIVED" = "$ARCHIVED_TOTAL" ] || GAPS="${GAPS}  - 根 README 声明 archived $R_ARCHIVED，应为 $ARCHIVED_TOTAL\n"
fi

if [ -n "$SVG_MATRIX" ]; then
  SVG_MAINT=$(grep -oE '月检 · [0-9]+ 仓' "$SVG_MATRIX" | head -1 | grep -oE '[0-9]+')
  if [ -z "$SVG_MAINT" ]; then
    GAPS="${GAPS}  - 分档矩阵 SVG 未找到 maintenance 计数\n"
  else
    [ "$SVG_MAINT" = "$MAINT_TOTAL" ] || GAPS="${GAPS}  - 分档矩阵 SVG 声明 maintenance $SVG_MAINT 仓，应为 $MAINT_TOTAL\n"
  fi
fi

echo "治理单一事实来源一致性检查  owner=$OWNER"
if [ "$PUBLIC_ONLY" -eq 1 ]; then
  echo "  模式：public-only（远程仅公开仓；私有 $PRIVATE_TOTAL 仓需 owner 凭据本地跑）"
else
  echo "  模式：full（远程 $REMOTE_TOTAL 仓）"
fi
echo "  desired-state：$DESIRED_TOTAL 仓（release $RELEASE_TOTAL / backup $BACKUP_TOTAL）；远程：$REMOTE_TOTAL 仓"
echo "  排除数组：EXCLUDED_FROM_REGISTRY=$REGISTRY_N（文档 $DOC_REGISTRY）；EXCLUDED_FROM_RELEASE_STANDARD=$RELEASE_N（文档 $DOC_RELEASE）"
echo "  README 分组：登记 $README_REGISTERED + 备份 $README_BACKUP = $ARITHMETIC"
echo "  文档计数：备份 zh=$DOC_BACKUP_ZH / en=$DOC_BACKUP_EN；台账=$DOC_LEDGER；规范 §2=$DOC_GUIDE_BACKUP_A §15.6=$DOC_GUIDE_BACKUP_B；lifecycle=${README_LC:-n/a}"
echo ""

if [ -n "$GAPS" ]; then
  printf 'gap：\n%b' "$GAPS"
  exit 1
fi

echo "clean：desired-state、远程仓清单、两份排除数组集合、文档硬编码计数一致"
exit 0
