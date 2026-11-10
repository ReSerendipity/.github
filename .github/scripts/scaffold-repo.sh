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
AGENTS_TEMPLATE="$REPO_ROOT/governance/templates/AGENTS_TEMPLATE.md"
GOTCHAS_TEMPLATE="$REPO_ROOT/governance/templates/GOTCHAS_TEMPLATE.md"
REVISION_LOG_TEMPLATE="$REPO_ROOT/governance/templates/REVISION_LOG_TEMPLATE.md"
HOOK_TEMPLATE="$SCRIPT_DIR/templates/pre-push"
EDITORCONFIG_TEMPLATE="$REPO_ROOT/governance/templates/editorconfig.template"
CODEOWNERS_TEMPLATE="$REPO_ROOT/governance/templates/CODEOWNERS.template"
DEPENDABOT_TEMPLATE="$REPO_ROOT/governance/templates/dependabot.template.yml"
ARCH_TEMPLATE="$REPO_ROOT/governance/templates/ARCHITECTURE_TEMPLATE.md"
SECURITY_TEMPLATE="$REPO_ROOT/governance/templates/SECURITY_TEMPLATE.md"
CONTRIBUTING_TEMPLATE="$REPO_ROOT/governance/templates/CONTRIBUTING_TEMPLATE.md"
COC_TEMPLATE="$REPO_ROOT/governance/templates/CODE_OF_CONDUCT_TEMPLATE.md"
OWNER=${GOVERNANCE_OWNER:-ReSerendipity}

err() { echo "ERROR: $*" >&2; }

NAME=''
VISIBILITY='private'
DELIVERY='tool'
REPOS_ROOT="$DEFAULT_REPOS_ROOT"
CREATE_REMOTE=0
ARCHITECTURE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --private) VISIBILITY='private'; shift ;;
    --public) VISIBILITY='public'; shift ;;
    --delivery) DELIVERY=${2:-}; shift 2 ;;
    --delivery=*) DELIVERY=${1#*=}; shift ;;
    --repos-root) REPOS_ROOT=${2:-}; shift 2 ;;
    --repos-root=*) REPOS_ROOT=${1#*=}; shift ;;
    --create-remote) CREATE_REMOTE=1; shift ;;
    --architecture) ARCHITECTURE=1; shift ;;
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
[ -f "$GOTCHAS_TEMPLATE" ] || { err "找不到 GOTCHAS 模板：$GOTCHAS_TEMPLATE"; exit 2; }
[ -f "$REVISION_LOG_TEMPLATE" ] || { err "找不到 REVISION_LOG 模板：$REVISION_LOG_TEMPLATE"; exit 2; }
[ -f "$HOOK_TEMPLATE" ] || { err "找不到 pre-push 模板：$HOOK_TEMPLATE"; exit 2; }
[ -f "$EDITORCONFIG_TEMPLATE" ] || { err "找不到 editorconfig 模板：$EDITORCONFIG_TEMPLATE"; exit 2; }
[ -f "$CODEOWNERS_TEMPLATE" ] || { err "找不到 CODEOWNERS 模板：$CODEOWNERS_TEMPLATE"; exit 2; }
[ -f "$DEPENDABOT_TEMPLATE" ] || { err "找不到 dependabot 模板：$DEPENDABOT_TEMPLATE"; exit 2; }
[ -f "$ARCH_TEMPLATE" ] || { err "找不到 ARCHITECTURE 模板：$ARCH_TEMPLATE"; exit 2; }
[ -f "$SECURITY_TEMPLATE" ] || { err "找不到 SECURITY 模板：$SECURITY_TEMPLATE"; exit 2; }
[ -f "$CONTRIBUTING_TEMPLATE" ] || { err "找不到 CONTRIBUTING 模板：$CONTRIBUTING_TEMPLATE"; exit 2; }
[ -f "$COC_TEMPLATE" ] || { err "找不到 CODE_OF_CONDUCT 模板：$COC_TEMPLATE"; exit 2; }

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

mkdir -p "$TARGET/docs" "$TARGET/.githooks" "$TARGET/.github"
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
mkdir -p local/agents
[ -f local/agents/GOTCHAS.md ] || cp "$GOTCHAS_TEMPLATE" local/agents/GOTCHAS.md
[ -f local/agents/REVISION_LOG.md ] || cp "$REVISION_LOG_TEMPLATE" local/agents/REVISION_LOG.md
cp "$HOOK_TEMPLATE" .githooks/pre-push
chmod +x .githooks/pre-push 2>/dev/null || true
git config core.hooksPath .githooks

# §12.5 通用工程件：四件按分档生成，一律取模板正文（去掉模板头注释），不覆盖已有
awk '/^root = true$/{p=1} p' "$EDITORCONFIG_TEMPLATE" > .editorconfig
awk '/^# ============================================================$/{p=1} p' "$CODEOWNERS_TEMPLATE" \
  | sed "s/<Repo-Name>/$NAME/" > .github/CODEOWNERS
if [ "$VISIBILITY" = "public" ]; then
  cp "$DEPENDABOT_TEMPLATE" .github/dependabot.yml
  awk '/^# 安全策略 — /{p=1} p' "$SECURITY_TEMPLATE" \
    | sed "s/<Repo-Name>/$NAME/; s/<owner>/$OWNER/; s/<repo>/$NAME/" > SECURITY.md
  awk '/^# 行为准则 — /{p=1} p' "$COC_TEMPLATE" | sed "s/<Repo-Name>/$NAME/" > CODE_OF_CONDUCT.md
  case "$DELIVERY" in
    release|service|policy)
      awk '/^# 贡献指南 — /{p=1} p' "$CONTRIBUTING_TEMPLATE" | sed "s/<Repo-Name>/$NAME/" > CONTRIBUTING.md ;;
  esac
fi
mkdir -p skills
[ -f skills/README.md ] || cat > skills/README.md <<'EOF'
# Skills

本目录存放 agent 运维 skill，每个 skill 一个子目录：`<kebab-case>/SKILL.md`。
`SKILL.md` 的 frontmatter 必填 `name` 与触发导向的 `description`；复杂 skill 可带 `references/`、`scripts/`、`assets/`。

产品提示词资产、学习素材、采集的外部文档**不在此列**（治理规范 §12.5 条款 9）。

## 当前 skill

（新增 skill 时在此登记一行：`<name>` — 一句话用途。）
EOF
case "$DELIVERY" in release|service|policy) ARCHITECTURE=1 ;; esac
if [ "$ARCHITECTURE" -eq 1 ]; then
  awk '/^# 架构 — /{p=1} p' "$ARCH_TEMPLATE" \
    | sed "s/<Repo-Name>/$NAME/; s/delivery=<release|service|tool|content|policy>/delivery=$DELIVERY/" \
    | sed 's/lifecycle=<active|maintenance>/lifecycle=active/' > ARCHITECTURE.md
fi

if [ "$CREATE_REMOTE" -eq 1 ]; then
  git add -A
  git update-index --chmod=+x .githooks/pre-push 2>/dev/null || true
  git commit -s -m "chore: scaffold $NAME" || { err "初始提交失败（检查 git 身份配置）"; exit 2; }
  gh repo create "$OWNER/$NAME" "--$VISIBILITY" --source . --push --remote origin \
    || { err "gh repo create 失败"; exit 2; }
fi

cat <<EOF

脚手架已生成：$TARGET
  README.md / CHANGELOG.md / AGENTS.md / ARCHITECTURE.md / SECURITY.md / CODE_OF_CONDUCT.md / CONTRIBUTING.md
  docs/release-governance.md / docs/agent-contract.md / skills/README.md
  .editorconfig / .github/CODEOWNERS / .github/dependabot.yml / .gitignore / .githooks/pre-push
  core.hooksPath=.githooks（删除 main、非快进推送 main 会被本地拦截；逃生阀 SKIP_GOVERNANCE_HOOKS=1）

  §12.5 通用工程件生成口径：
    .editorconfig        无条件
    .github/CODEOWNERS   无条件
    skills/README.md     无条件（skill 本体按需新增）
    .github/dependabot.yml / SECURITY.md / CODE_OF_CONDUCT.md  仅 --public
    CONTRIBUTING.md      仅 --public 且 release|service|policy
    ARCHITECTURE.md      仅 release|service|policy 或显式 --architecture

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
