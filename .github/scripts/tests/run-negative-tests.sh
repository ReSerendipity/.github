#!/usr/bin/env bash
# 门禁反例测试：每个门禁都要有「正例必须绿、负例必须红」的成对断言，
# 否则把断言改松/改错时不会被发现。
#
# 覆盖：registry（§4 对照）、release（§10 收敛）、agents（§7 行数）、signoff（DCO）。
# 用法：bash .github/scripts/tests/run-negative-tests.sh
# 退出码：0=全部符合预期；1=有用例不符合；2=环境不可用。
set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
# SCRIPT_DIR 在本仓为 <root>/.github/scripts/tests，向上三级即仓库根。
REPO_ROOT=$(cd "$SCRIPT_DIR/../../.." && pwd)
SCRIPTS="$REPO_ROOT/.github/scripts"
FIXTURES="$SCRIPT_DIR/fixtures"
GUIDE="$REPO_ROOT/governance/REPOSITORY_GUIDELINES.md"

[ -d "$SCRIPTS" ] || { echo "ERROR: 找不到 $SCRIPTS" >&2; exit 2; }
[ -f "$GUIDE" ] || { echo "ERROR: 找不到 $GUIDE" >&2; exit 2; }
command -v git >/dev/null 2>&1 || { echo "ERROR: 需要 git" >&2; exit 2; }

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

PASS=0
FAIL=0

run_case() {  # $1=用例名 $2=期望退出码，其余=命令
  local name="$1" expect="$2"; shift 2
  "$@" > "$TMP/case.out" 2>&1
  local rc=$?
  if [ "$rc" -eq "$expect" ]; then
    printf 'PASS  %-28s rc=%s\n' "$name" "$rc"
    PASS=$((PASS+1))
  else
    printf 'FAIL  %-28s 期望 rc=%s，实际 rc=%s\n' "$name" "$expect" "$rc"
    sed 's/^/      /' "$TMP/case.out"
    FAIL=$((FAIL+1))
  fi
}

# ── registry：从 §4 真实台账生成远程清单，再制造缺一/多一 ────────────
awk -v RS='\r?\n' '
  /^## 4\./ { insec=1; next }
  insec && /^## / { insec=0 }
  insec && /^\|/ {
    if ($0 ~ /^\|[ ]*-+/) next
    split($0, c, "|"); name=c[2]; vis=c[3]
    gsub(/^[ \t]+|[ \t]+$/, "", name); gsub(/^[ \t]+|[ \t]+$/, "", vis)
    if (name=="仓库" || name=="" || vis=="") next
    print name "\t" (vis=="private" ? "true" : "false")
  }
' "$GUIDE" | sort -u > "$TMP/remote_ok.tsv"

if [ ! -s "$TMP/remote_ok.tsv" ]; then
  echo "ERROR: 无法从 §4 解析台账" >&2
  exit 2
fi

grep -v $'^Image-DuoModel\t' "$TMP/remote_ok.tsv" > "$TMP/remote_missing.tsv"
{ cat "$TMP/remote_ok.tsv"; printf 'Unregistered-Test\tfalse\n'; } > "$TMP/remote_extra.tsv"

run_case "registry 正例" 0 \
  env REGISTRY_REMOTE_TSV="$TMP/remote_ok.tsv" REGISTRY_OWNER=ReSerendipity \
  bash "$SCRIPTS/check-repo-registry.sh"

run_case "registry 远程少一个台账仓" 1 \
  env REGISTRY_REMOTE_TSV="$TMP/remote_missing.tsv" REGISTRY_OWNER=ReSerendipity \
  bash "$SCRIPTS/check-repo-registry.sh"

run_case "registry 远程多一个未登记仓" 1 \
  env REGISTRY_REMOTE_TSV="$TMP/remote_extra.tsv" REGISTRY_OWNER=ReSerendipity \
  bash "$SCRIPTS/check-repo-registry.sh"

# ── release：正例 / 缺发布文档 ─────────────────────────────────
cp -r "$FIXTURES/release-ok" "$TMP/release-missing"
rm -rf "$TMP/release-missing/docs"

run_case "release 正例" 0 bash "$SCRIPTS/check-release-standard.sh" --root "$FIXTURES/release-ok"
run_case "release 缺发布文档" 1 bash "$SCRIPTS/check-release-standard.sh" --root "$TMP/release-missing"

# ── agents：正例 / 超行数 ───────────────────────────────────────
# 夹具以 AGENTS.md.fixture 入库：本仓自我净化规则禁止跟踪任何 AGENTS.md，
# 测试时复制成真正的 AGENTS.md 再跑。
mkdir -p "$TMP/agents-ok"
cp "$FIXTURES/agents-ok/AGENTS.md.fixture" "$TMP/agents-ok/AGENTS.md"
mkdir -p "$TMP/agents-over"
seq 1 301 | sed 's/^/line /' > "$TMP/agents-over/AGENTS.md"

run_case "agents 正例" 0 bash "$SCRIPTS/check-agents-md-size.sh" --root "$TMP/agents-ok"
run_case "agents 超行数" 1 bash "$SCRIPTS/check-agents-md-size.sh" --root "$TMP/agents-over"

# ── signoff：正例 / 缺尾注 ──────────────────────────────────────
git init -q -b main "$TMP/signoff"
cd "$TMP/signoff" || exit 2
git config user.name "Gate Test"
git config user.email "gate-test@example.com"
printf 'a\n' > a.txt
git add a.txt
git commit -q -m "base"
BASE=$(git rev-parse HEAD)
git commit -q --allow-empty -m "signed change" -m "Signed-off-by: Gate Test <gate-test@example.com>"
SIGNED=$(git rev-parse HEAD)
git commit -q --allow-empty -m "unsigned change"
UNSIGNED=$(git rev-parse HEAD)

run_case "signoff 正例" 0 bash "$SCRIPTS/check-signoff.sh" "$BASE" "$SIGNED"
run_case "signoff 缺尾注" 1 bash "$SCRIPTS/check-signoff.sh" "$SIGNED" "$UNSIGNED"
cd "$REPO_ROOT" || exit 2

echo ""
echo "结果：PASS $PASS / FAIL $FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
