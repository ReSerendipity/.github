# ADR-0004：私有仓分支保护——Free 计划能力缺口

> **历史快照（2026-10-22）**：本文的私有仓数量（当时 4 个）不代表当前状态；当前 21 个私有仓均按本 ADR 记平台能力缺口，逐仓定位以 `governance/desired-state.json` 为准。

- 状态：Accepted
- 日期：2026-10-22
- 决策者：ReSerendipity（账号所有者）
- 相关：§2、§15.2

## 背景

GitHub Free 计划对**私有仓**不提供服务器侧分支保护：

- `PUT /repos/{owner}/{repo}/branches/main/protection` 返回 `403 Upgrade to GitHub Pro`（2026-10-21 在 `Agent-Knowledge` 实测）。
- 仓库级 rulesets API 同样返回 `403`。
- 公开仓不受此限制，已实测 9 个公开仓 ruleset 生效。

4 个受管私有仓（`Agent-Knowledge`、`Image-Scrapers`、`Nekogal-DL`、`Prompt-Library`）因此没有服务器侧保护。

## 决策

- **不为私有仓升级计划，不做替代性服务器改造**。
- 记为**平台能力缺口**，不是仓库欠账，不在审计中判红。
- 替代控制：各仓本地 `.githooks/pre-push`（阻止删除 `main`、阻止非快进推送）+ 本地预检脚本；逃生阀 `SKIP_GOVERNANCE_HOOKS=1`。
- 审计口径：`audit-drift.py` 对私有仓的保护检查记 `SKIP`，仅校验可见性、默认分支、归档状态与 `delete_branch_on_merge`（owner 凭据下可读）。

## 后果

- 优点：不为一年的订阅成本改变账号模型；本地钩子已能拦住最常见的误操作。
- 代价：私有仓的 `main` 在平台侧**完全不设防**；协作者（若有）可 force-push 或删除分支。
- 重新评估条件：升级 Pro、引入协作者、或任一私有仓发生误删/误推事故。

## 不采用

- 升级 Pro：当前 4 仓均为低协作、低外发风险，成本收益不成立。
- 用镜像仓伪造保护：会制造第二事实来源，违反 ADR-0001。
