# ADR-0010：CI 远程化与本地最小化

- 状态：Accepted
- 日期：2026-10-30
- 决策者：ReSerendipity（账号所有者）
- 相关：§10.1（远端优先）、§15.2（审计频度）、§19、ADR-0004、`GOVERNANCE-EXCLUSIONS.md` §五

## 背景

2026-10-30 同日两次迭代：先裁决「不需要定时任务」（当时理解为包括 Actions cron），后经澄清——工作流跑在 GitHub 托管 runner 上，公开仓走免费额度、不占本机资源——owner 修订定稿为「**远程的尽可能多，本地的尽可能少**」。这正是本仓一贯方向的延伸：§4 对照表 2026-10-18 已从"本地命令 + 记性"挪上远端 CI，§10.1 把发布链计算全部远端化；但"检查层远端化"此前只散落在变更记录与注释里，没有正式条款，也没有定义远端盲区（私有仓）的补齐路径。

## 决策

1. 升格为正式条款 **§20（CI 远程化与本地最小化）**，与 §17/§18 同为跨 delivery 通用条款。
2. 原则：可执行检查必须有远端载体（PR/push 门禁、schedule、workflow_dispatch 按 §15.2 频度择用）；本地机器不得承载定时任务；天然本地载体（pre-push、AGENTS 行数、scaffold、私有仓核对）除外。
3. 私有仓远端盲区补齐：可选配置**只读 fine-grained PAT** 到 Actions Secret `GOVERNANCE_READ_PAT`；`drift-audit.yml` 仅在 schedule / 手动派发使用，PR 触发表达式层固定回退默认令牌（Secret 不进 PR 运行上下文）。
4. 远端与本地同一脚本、同一退出码纪律（失败关闭，不把空集合当通过）。

## 后果

- 优点：检查不依赖"人记不记得、机器开不开机"；公开仓周检零成本；配置 PAT 后 48 仓核对全远程化。
- 代价：远端载体受 GitHub 可用性影响；`UNVERIFIABLE`/`PARTIAL` 不等于通过。
- 代价：PAT 虽只读、有到期，但 Secret 仍是敏感面——因此 PR 上下文一律不用，且 `pull_request` 运行使用的是 base 分支 workflow 定义（头部分支改不了自己的 token 路由）。
- 依赖用户动作：PAT 由 owner 在 GitHub 侧创建与配置（本仓只提供接入点）。

## 不采用

- 本机定时任务（crontab / 任务计划 / 助手侧 cron）承载周检：关机断网即静默漏检。
- 全权 OAuth token 入 Secret：违反最小权限。
- 为私有仓加定时作业：账号 Free 计划下私有 Actions 消耗账单分钟数（§10.6 实测挂起中），不成立。
