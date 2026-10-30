#!/usr/bin/env bash
# 新建仓库脚手架：按 §1 校验名称、按 §15 记录定位，并生成最小合规骨架。
#
# 用法：
#   bash .github/scripts/scaffold-repo.sh <Repo-Name> [--private|--public]
#        [--delivery release|service|tool|content] [--repos-root DIR] [--create-remote]
#
# 默认：private / tool / repos-root = 本规范仓的上一级目录（本机为 APP/repository）。
# 行为：只建本地仓库与骨架文件；不修改任何治理文档；--create-remote 才建远端并推送。
# 退出码：0=成功；1=目标已存在或校验失败；2=入参不可用。
set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
DEFAULT_REPOS_ROOT=$(cd "$REPO_ROOT/.." && pwd)
TEMPLATE="$REPO_ROOT/governance/templates/RELEASE_GOVERNANCE_TEMPLATE.md"
CONTRACT_TEMPLATE="$REPO_ROOT/governance/templates/agent-contract.md"
AGENTS_TEMPLATE="$REPO_ROOT/governance/templates/AGENTS.template.md"
HOOK_TEMPLATE="$SCRIPT_DIR/templates/pre-push"
OWNER=${GOVERNANCE_OWNER:-ReSerendipity}

err() { echo "ERROR: $*" >&2; }

NAME=''
VISIBILITY='private'
DELIVERY='tool'
REPOS_ROOT="$DEFAULT_REPOS_ROOT"
CREATE_REMOTE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --private) VISIBILITY='private'; shift ;;
    --public) VISIBILITY='public'; shift ;;
    --delivery) DELIVERY=${2:-}; shift 2 ;;
    --delivery=*) DELIVERY=${1#*=}; shift ;;
    --repos-root) REPOS_ROOT=${2:-}; shift 2 ;;
    --repos-root=*) REPOS_ROOT=${1#*=}; shift ;;
    --create-remote) CREATE_REMOTE=1; shift ;;
    -*) err "未知参数 '$1'"; exit 2 ;;
    *)
      if [ -n "$NAME" ]; then err "只能给一个仓库名，已给 '$NAME' 与 '$1'"; exit 2; fi
      NAME=$1; shift ;;
  esac
done

[ -n "$NAME" ] || { err "缺少仓库名。用法：scaffold-repo.sh <Repo-Name> [--private|--public] [--delivery ...] [--repos-root DIR] [--create-remote]"; exit 2; }
case "$DELIVERY" in release|service|tool|content) ;; *) err "--delivery 只支持 release|service|tool|content，实际='$DELIVERY'"; exit 2 ;; esac
[ -d "$REPOS_ROOT" ] || { err "repos-root 不存在：$REPOS_ROOT"; exit 2; }
[ -f "$TEMPLATE" ] || { err "找不到发布文档模板：$TEMPLATE"; exit 2; }
[ -f "$CONTRACT_TEMPLATE" ] || { err "找不到 agent 契约模板：$CONTRACT_TEMPLATE"; exit 2; }
[ -f "$AGENTS_TEMPLATE" ] || { err "找不到 AGENTS 模板：$AGENTS_TEMPLATE"; exit 2; }
[ -f "$HOOK_TEMPLATE" ] || { err "找不到 pre-push 模板：$HOOK_TEMPLATE"; exit 2; }

# §1 命名：字母/数字/短横线，分段首字母大写，禁止下划线、空段与连续短横线。
case "$NAME" in
  *[!A-Za-z0-9-]*) err "名称只允许字母、数字与短横线（§1）：'$NAME'"; exit 1 ;;
  -*|*-|*--*) err "名称不得以短横线开头/结尾或含连续短横线（§1）：'$NAME'"; exit 1 ;;
esac
IFS='-' read -ra SEGMENTS <<< "$NAME"
for seg in "${SEGMENTS[@]}"; do
  case "$seg" in
    [A-Z]*) ;;
    *) err "分段 '$seg' 未以大写字母开头（§1 Train Case）：'$NAME'"; exit 1 ;;
  esac
done

TARGET="$REPOS_ROOT/$NAME"
[ ! -e "$TARGET" ] || { err "目标已存在：$TARGET"; exit 1; }

mkdir -p "$TARGET/docs" "$TARGET/.githooks"
cd "$TARGET" || { err "无法进入 $TARGET"; exit 2; }
git init -b main --quiet || { err "git init 失败"; exit 2; }

cat > README.md <<EOF
# $NAME

> 治理规范：[ReSerendipity/.github/governance](https://github.com/ReSerendipity/.github/tree/main/governance)
>
> 治理定位：\`delivery=$DELIVERY\`；\`lifecycle\` 在 \`governance/desired-state.json\` 登记。

## 这是什么

（一句话说明用途，替换本行。）

## 快速开始

（安装 / 运行 / 测试命令。）
EOF

cat > CHANGELOG.md <<'EOF'
# Changelog

本文件遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

## [Unreleased]
EOF

cat > .gitignore <<'EOF'
# 新仓最小基线；密钥 / 大文件 / 构建产物等规则按 §3 / §9 继续追加
/local/
AGENTS.md
EOF

cp "$TEMPLATE" docs/release-governance.md
cp "$CONTRACT_TEMPLATE" docs/agent-contract.md
cp "$AGENTS_TEMPLATE" AGENTS.md
cp "$HOOK_TEMPLATE" .githooks/pre-push
chmod +x .githooks/pre-push 2>/dev/null || true
git config core.hooksPath .githooks

if [ "$CREATE_REMOTE" -eq 1 ]; then
  git add -A
  git update-index --chmod=+x .githooks/pre-push 2>/dev/null || true
  git commit -s -m "chore: scaffold $NAME" || { err "初始提交失败（检查 git 身份配置）"; exit 2; }
  gh repo create "$OWNER/$NAME" "--$VISIBILITY" --source . --push --remote origin \
    || { err "gh repo create 失败"; exit 2; }
fi

cat <<EOF

脚手架已生成：$TARGET
  README.md / CHANGELOG.md / AGENTS.md / docs/release-governance.md / docs/agent-contract.md / .gitignore / .githooks/pre-push
  core.hooksPath=.githooks（删除 main、非快进推送 main 会被本地拦截；逃生阀 SKIP_GOVERNANCE_HOOKS=1）

还需人工完成的五处同步（脚本不自动改文档）：
  1. governance/REPOSITORY_GUIDELINES.md §4 加一行（可见性 + delivery）
  2. governance/desired-state.json 的 repos 加一条（lifecycle 默认 active）
  3. governance/README.md 的计数（登记仓 +1）与根 README 索引（如涉及）
  4. 若为备份仓：governance/GOVERNANCE-EXCLUSIONS.md 加一条
  5. 治理仓改动按 §17.2：作者账号可直推，非作者走分支 + PR + DCO
EOF

if [ "$CREATE_REMOTE" -eq 0 ]; then
  echo ""
  echo "未创建远端：加 --create-remote，或手动 git remote add + push。"
fi
exit 0
