#!/usr/bin/env bash
# §17.5 多 Agent 并发判定执行件（ADR-0014）。
# 只读四查：dirty 文件 mtime / worktree 数 / agent-session.lock 心跳 / 远端 agent/* 分支。
# 用法：
#   bash .github/scripts/check-agent-session.sh [--root DIR] [--no-remote]
#   bash .github/scripts/check-agent-session.sh [--root DIR] --acquire --session <id>
#   bash .github/scripts/check-agent-session.sh [--root DIR] --release --session <id>
#   （长任务每 ≤10 分钟重跑 --acquire 刷新心跳，否则会被判为不确定 / 过期）
# 退出码：0=START 可开工；2=环境不可用；3=BRANCH 有活跃 agent 且工作区干净；
#         4=DEFER 有活跃 agent / 不确定且工作区不干净；5=LEGACY 工作区不干净但无其他 agent（先处置遗留）；
#         6=锁归属不匹配，拒绝释放。
# 阈值：≤600s 活跃，600–1800s 不确定（按有 agent 处理），>1800s 过期；与 §17.5 一致。
set -uo pipefail

ROOT=$(pwd)
NO_REMOTE=0
MODE=check
SESSION=""
ACTIVE_SEC=600
STALE_SEC=1800

while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="$2"; shift 2 ;;
    --no-remote) NO_REMOTE=1; shift ;;
    --acquire) MODE=acquire; shift ;;
    --release) MODE=release; shift ;;
    --session) SESSION="$2"; shift 2 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "agent-session: 未知参数 $1" >&2; exit 2 ;;
  esac
done

top=$(git -C "$ROOT" rev-parse --show-toplevel 2>/dev/null) \
  || { echo "agent-session: 不是 git 工作区：$ROOT" >&2; exit 2; }
common=$(git -C "$top" rev-parse --git-common-dir 2>/dev/null) \
  || { echo "agent-session: 无法解析 git-common-dir" >&2; exit 2; }
case "$common" in
  /*|[A-Za-z]:*) ;;
  *) common="$top/$common" ;;
esac
lock="$common/agent-session.lock"
now=$(date +%s)

# ── 查 1：dirty 文件与最新 mtime ──────────────────────────────
dirty_count=0
newest_epoch=0
dirty_state=clean
while IFS= read -r line; do
  [ -n "$line" ] || continue
  dirty_count=$((dirty_count + 1))
  path=${line:3}
  path=${path##* -> }
  [ -f "$top/$path" ] || continue
  mt=$(stat -c %Y "$top/$path" 2>/dev/null || date -r "$top/$path" +%s 2>/dev/null || echo 0)
  case "$mt" in ''|*[!0-9]*) mt=0 ;; esac
  [ "$mt" -gt "$newest_epoch" ] && newest_epoch=$mt
done < <(git -C "$top" status --porcelain --untracked-files=no 2>/dev/null)

if [ "$dirty_count" -gt 0 ]; then
  if [ "$newest_epoch" -gt 0 ] && [ $((now - newest_epoch)) -le "$ACTIVE_SEC" ]; then
    dirty_state=fresh
  elif [ "$newest_epoch" -gt 0 ] && [ $((now - newest_epoch)) -le "$STALE_SEC" ]; then
    dirty_state=uncertain
  else
    dirty_state=stale
  fi
fi

# ── 查 2：worktree 数 ────────────────────────────────────────
wt_count=$(git -C "$top" worktree list --porcelain 2>/dev/null | grep -c '^worktree ')

# ── 查 3：锁心跳 ─────────────────────────────────────────────
lock_state=absent
lock_session=""
lock_age=""
if [ -f "$lock" ]; then
  lock_session=$(sed -n 's/^session=//p' "$lock" 2>/dev/null | head -n1)
  hb=$(sed -n 's/^heartbeat=//p' "$lock" 2>/dev/null | head -n1)
  [ -n "$hb" ] || hb=$(stat -c %Y "$lock" 2>/dev/null || date -r "$lock" +%s 2>/dev/null || echo "$now")
  case "$hb" in ''|*[!0-9]*) hb=$now ;; esac
  lock_age=$((now - hb))
  [ "$lock_age" -lt 0 ] && lock_age=0
  if [ "$lock_age" -le "$ACTIVE_SEC" ]; then
    lock_state=active
  elif [ "$lock_age" -le "$STALE_SEC" ]; then
    lock_state=uncertain
  else
    lock_state=stale
  fi
fi

# ── 查 4：远端 agent/* 分支（跨机唯一信号）────────────────────
remote_state=skipped
remote_count=0
if [ "$NO_REMOTE" -eq 0 ]; then
  heads=$(git -C "$top" ls-remote --heads origin 'refs/heads/agent/*' 2>/dev/null)
  if [ $? -ne 0 ]; then
    remote_state=unknown
  else
    remote_state=ok
    remote_count=$(printf '%s\n' "$heads" | grep -c 'refs/heads/agent/')
  fi
fi

# ── 判定矩阵（§17.5）────────────────────────────────────────
active_agent=no
[ "$lock_state" = active ] && active_agent=yes
[ "$lock_state" = uncertain ] && active_agent=yes
[ "$wt_count" -gt 1 ] && active_agent=yes
[ "$remote_count" -gt 0 ] && active_agent=yes
[ "$dirty_state" = fresh ] && active_agent=yes
[ "$dirty_state" = uncertain ] && active_agent=yes

if [ "$dirty_count" -eq 0 ]; then
  if [ "$active_agent" = yes ]; then verdict=BRANCH; rc=3; else verdict=START; rc=0; fi
else
  if [ "$active_agent" = yes ]; then verdict=DEFER; rc=4; else verdict=LEGACY; rc=5; fi
fi

mtime_text=未知
[ "$newest_epoch" -gt 0 ] && mtime_text="$((now - newest_epoch))s 前"
lock_text=$lock_state
[ -n "$lock_session" ] && lock_text="$lock_text (session=$lock_session)"
[ -n "$lock_age" ] && lock_text="$lock_text (心跳 ${lock_age}s 前)"

echo "agent-session: root=$top"
echo "  dirty=$dirty_count (状态=$dirty_state, 最新 mtime=$mtime_text)"
echo "  worktrees=$wt_count"
echo "  lock=$lock_text"
echo "  remote-agent-branches=$remote_count (状态=$remote_state)"
echo "VERDICT: $verdict (rc=$rc)"

# ── 锁操作 ──────────────────────────────────────────────────
write_lock() {
  printf 'session=%s\npid=%s\nstarted=%s\nheartbeat=%s\nworktree=%s\n' \
    "$SESSION" "$1" "$2" "$now" "$top" > "$lock"
}

if [ "$MODE" = acquire ]; then
  [ -n "$SESSION" ] || { echo "agent-session: --acquire 需要 --session <id>" >&2; exit 2; }
  if [ -f "$lock" ] && [ "$lock_session" = "$SESSION" ]; then
    write_lock "$(sed -n 's/^pid=//p' "$lock" | head -n1 | tr -dc '0-9')" "$now"
    echo "agent-session: 已刷新心跳（session=$SESSION）"
    exit 0
  fi
  if [ "$verdict" != START ]; then
    echo "agent-session: 判定 $verdict，不获取锁；按 §17.5 处理" >&2
    exit "$rc"
  fi
  if ( set -o noclobber; printf 'session=%s\npid=%s\nstarted=%s\nheartbeat=%s\nworktree=%s\n' \
        "$SESSION" "$$" "$now" "$now" "$top" > "$lock" ) 2>/dev/null; then
    echo "agent-session: 已原子获取锁 session=$SESSION"
    exit 0
  fi
  if [ "$lock_state" = stale ]; then
    write_lock "$$" "$now"
    echo "agent-session: 接管过期锁（原 session=${lock_session:-未知}）"
    exit 0
  fi
  echo "agent-session: 锁被 session=${lock_session:-未知} 持有，不接管" >&2
  exit 3
fi

if [ "$MODE" = release ]; then
  [ -n "$SESSION" ] || { echo "agent-session: --release 需要 --session <id>" >&2; exit 2; }
  if [ ! -f "$lock" ]; then
    echo "agent-session: 无锁可释放"
    exit 0
  fi
  if [ "$lock_session" != "$SESSION" ]; then
    echo "agent-session: 锁归属 session=${lock_session:-未知}，拒绝释放" >&2
    exit 6
  fi
  rm -f "$lock"
  echo "agent-session: 已释放锁（session=$SESSION）"
  exit 0
fi

exit "$rc"
