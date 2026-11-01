#!/usr/bin/env bash
# 门禁反例测试：每个门禁都要有「正例必须绿、负例必须红」的成对断言，
# 否则把断言改松/改错时不会被发现。
#
# 覆盖：registry（§4 对照）、release（§10 收敛 / delivery 分档）、agents（§7 行数）、
# signoff（DCO）、agent-session（§17.5 并发判定）、consistency / audit-drift（失败关闭）、
# self-purify（两处规则同步）。
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
mkdir -p "$TMP/GalgameShell" "$TMP/SeedVR2-Lite" "$TMP/Android-IconAutoArrange"
run_case "release 非 release 仓跳过" 0 bash "$SCRIPTS/check-release-standard.sh" --root "$TMP/GalgameShell"
run_case "release 归档 release 仓跳过" 0 bash "$SCRIPTS/check-release-standard.sh" --root "$TMP/Android-IconAutoArrange"
run_case "release release 仓仍检查" 1 bash "$SCRIPTS/check-release-standard.sh" --root "$TMP/SeedVR2-Lite"

# ── agents：正例 / 超行数 ───────────────────────────────────────
# 夹具以 AGENTS.md.fixture 入库：本仓自我净化规则禁止跟踪任何 AGENTS.md，
# 测试时复制成真正的 AGENTS.md 再跑。
mkdir -p "$TMP/agents-ok"
cp "$FIXTURES/agents-ok/AGENTS.md.fixture" "$TMP/agents-ok/AGENTS.md"
mkdir -p "$TMP/agents-over"
seq 1 301 | sed 's/^/line /' > "$TMP/agents-over/AGENTS.md"

run_case "agents 正例" 0 bash "$SCRIPTS/check-agents-md-size.sh" --root "$TMP/agents-ok"
run_case "agents 超行数" 1 bash "$SCRIPTS/check-agents-md-size.sh" --root "$TMP/agents-over"

# 嵌套 git 仓默认排除（--include-nested 才纳入）；Windows 反斜杠 root 的剪枝回归
mkdir -p "$TMP/agents-nested/nested"
printf 'root agent\n' > "$TMP/agents-nested/AGENTS.md"
seq 1 301 | sed 's/^/line /' > "$TMP/agents-nested/nested/AGENTS.md"
git init -q -b main "$TMP/agents-nested/nested"
run_case "agents 嵌套仓默认排除" 0 bash "$SCRIPTS/check-agents-md-size.sh" --root "$TMP/agents-nested"
run_case "agents 嵌套仓显式纳入" 1 bash "$SCRIPTS/check-agents-md-size.sh" --root "$TMP/agents-nested" --include-nested

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

# ── agent-session：§17.5 四查判定与锁（ADR-0014）────────────────
AS_REPO="$TMP/agent-session-repo"
AS_REMOTE="$TMP/agent-session-remote.git"
AS_LOCK="$AS_REPO/.git/agent-session.lock"
git init -q -b main "$AS_REPO"
git init -q --bare "$AS_REMOTE"
git -C "$AS_REPO" config user.name "Gate Test"
git -C "$AS_REPO" config user.email "gate-test@example.com"
printf 'a\n' > "$AS_REPO/tracked.txt"
git -C "$AS_REPO" add tracked.txt
git -C "$AS_REPO" commit -q -m "base"
git -C "$AS_REPO" remote add origin "$AS_REMOTE"
git -C "$AS_REPO" push -q -u origin main

run_case "agent-session 正例(干净)" 0 \
  bash "$SCRIPTS/check-agent-session.sh" --root "$AS_REPO" --no-remote

# stat-only 假阳性：只动 mtime、内容与 HEAD 一致，不应算 dirty（GOTCHAS #7/#8）
touch "$AS_REPO/tracked.txt"
run_case "agent-session stat 脏但无内容差异" 0 \
  bash "$SCRIPTS/check-agent-session.sh" --root "$AS_REPO" --no-remote

printf 'new\n' > "$AS_REPO/untracked.txt"
run_case "agent-session 未跟踪文件算脏" 4 \
  bash "$SCRIPTS/check-agent-session.sh" --root "$AS_REPO" --no-remote
rm -f "$AS_REPO/untracked.txt"

printf 'b\n' >> "$AS_REPO/tracked.txt"
run_case "agent-session 脏文件新鲜" 4 \
  bash "$SCRIPTS/check-agent-session.sh" --root "$AS_REPO" --no-remote
git -C "$AS_REPO" checkout -q -- tracked.txt

printf 'session=other\npid=99999\nstarted=%s\nheartbeat=%s\n' "$(date +%s)" "$(date +%s)" > "$AS_LOCK"
run_case "agent-session 活锁判 BRANCH" 3 \
  bash "$SCRIPTS/check-agent-session.sh" --root "$AS_REPO" --no-remote

printf 'session=old\npid=99999\nstarted=%s\nheartbeat=%s\n' \
  "$(( $(date +%s) - 3600 ))" "$(( $(date +%s) - 3600 ))" > "$AS_LOCK"
run_case "agent-session 过期锁可接管" 0 \
  bash "$SCRIPTS/check-agent-session.sh" --root "$AS_REPO" --no-remote --acquire --session takeover
run_case "agent-session 锁写入正确" 0 grep -q '^session=takeover$' "$AS_LOCK"
run_case "agent-session 拒释放他人锁" 6 \
  bash "$SCRIPTS/check-agent-session.sh" --root "$AS_REPO" --no-remote --release --session intruder
run_case "agent-session 释放本会话锁" 0 \
  bash "$SCRIPTS/check-agent-session.sh" --root "$AS_REPO" --no-remote --release --session takeover
run_case "agent-session 锁已删除" 1 test -f "$AS_LOCK"

git -C "$AS_REPO" worktree add -q -b wt2 "$TMP/agent-session-wt2"
run_case "agent-session 多 worktree" 3 \
  bash "$SCRIPTS/check-agent-session.sh" --root "$AS_REPO" --no-remote
git -C "$AS_REPO" worktree remove --force "$TMP/agent-session-wt2"

git -C "$AS_REPO" branch agent/demo
git -C "$AS_REPO" push -q origin agent/demo
run_case "agent-session 远端 agent 分支" 3 \
  bash "$SCRIPTS/check-agent-session.sh" --root "$AS_REPO"

mkdir -p "$TMP/not-a-git"
run_case "agent-session 非 git 目录" 2 \
  bash "$SCRIPTS/check-agent-session.sh" --root "$TMP/not-a-git" --no-remote

# ── 门禁自身：参数失败关闭 / self-purify 两处规则同步 ─────────────
run_case "consistency 未知参数退 2" 2 bash "$SCRIPTS/check-governance-consistency.sh" --bogus
run_case "audit-drift 未知仓退 2" 2 python3 "$SCRIPTS/audit-drift.py" --only Not-A-Repo
run_case "self-purify 两处规则同步" 0 python3 "$SCRIPTS/tests/check-self-purify-sync.py"

# ── readme 图路径：相对路径 / jsDelivr / GitHub blob/raw / SVG ──
run_case "readme 图路径解析" 0 python3 "$SCRIPTS/tests/check-readme-image-paths.py"

cd "$REPO_ROOT" || exit 2

echo ""
echo "结果：PASS $PASS / FAIL $FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
