# AGENTS.md — {{REPO}}

<!-- governance:agents-local v2 -->
<!-- 本文件仅本地保留：.gitignore 规则 AGENTS.md（无斜线，匹配任意深度）；不入库、不推送。 -->

> 最后更新：{{DATE}} ｜ 契约版本：v2 ｜ 拆分标准：阅读频率二分（§7.5）
> 公开契约（tracked，fresh clone / CI / 云电脑兜底）：`docs/agent-contract.md`
> 治理规范：ReSerendipity/.github/governance

## 0. 本仓定位
- `delivery={{DELIVERY}}`、`lifecycle={{LIFECYCLE}}`、`distribution={{DIST}}`（`governance/desired-state.json`）
- 职责：{{ONE_LINER}}
- 技术栈 / 入口：{{STACK}}

## 1. 开工前
1. 本文件已内联契约 v2；新会话先读本文件，不需要再跳 `docs/agent-contract.md`。
2. 读根 `README.md`（公开说明）与 `local/README.internal.md`（本机内部说明，本地保留）。
3. `git status --short` / `git worktree list` / `git log --oneline -5`；工作区不干净时按 §17.5 判定是否有其他 agent，再决定跳过、开分支或清理遗留。
4. 只读第 7 节索引中与本任务相关的拆分文件，不要求全读。

## 2. 硬约束（契约 v2 内联）
- 禁止入库：密钥 / token / 口令 / 连接串；本机绝对路径与用户名；`local/` 内容；嵌套或模块级 `AGENTS.md`；`docs/plans`、`docs/project`、`docs/_devarchive`、`docs/agents`、`docs/execution`。
  **例外**：`docs/execution/RELEASE_VERIFICATION.md`（§10.5 发布验证产物）与 `GOVERNANCE-EXCLUSIONS.md` §七 已登记的仓/家族白名单路径；未登记的同类路径仍按违规处理。
- 提交必须带 DCO：`git commit -s`，身份用 noreply；不得使用个人邮箱。
- 不改平台设置（分支保护、ruleset、Secrets、仓库可见性），除非任务明确要求且所有者授权。
- 不删除、不重置、不 stash 用户未提交的改动；不 `git add -A`。
- 发布链只按 §10：远端优先、tag 驱动、资产附 `SHA256SUMS.txt`。
- 契约条款以 `.github/governance/templates/agent-contract.md` 为准；仓内 tracked 副本 `docs/agent-contract.md` 由漂移审计比对。

## 3. 本仓专属红线
{{REPO_RED_LINES}}

## 4. 常用命令与验证
{{COMMANDS}}

## 5. 结构与发布 / CI
{{STRUCTURE_CI}}

## 6. 交付前
- `git status` 只含本次改动；`git diff` 能逐行解释。
- 跑 `README.md` / 第 4 节里的测试与检查命令；失败不隐藏、不静默跳过。
- PR 描述写清：改了什么、为什么、怎么验证、哪些没做。
- 提交、推送、合并与 CI 监控在任务结尾自主完成，不询问用户（§17 / ADR-0015）；破坏性操作 / 平台设置 / 凭据缺失才先问。

## 7. 索引（拆分文件与本地文档）
| 文件 | 来源章节 | 管什么 | 什么时候读 | 最后更新 |
|---|---|---|---|---|
{{INDEX_ROWS}}

## 8. 维护（阅读频率二分）
- 本文件 ≤300 行（推荐 ≤150）；每次开工必读的内容留在这里。
- 只有特定模块 / 任务才读的内容 → `local/agents/<module|task>.md`，文件头按 §7.5 写 `<!-- agents-split -->` 标注，根索引同步登记。
- 存量 `docs/agents/**`（仅本地、已 gitignore）视为历史分片，保留并由索引指向；新增拆分优先进 `local/agents/`。
- 同一事实只留一处权威来源；改治理口径先提 ADR；收尾按 §17 清理并盯 CI 终态。
