# ADR 索引与格式

> 决策记录（Architecture / Governance Decision Record）。**不可变**：已 Accepted 的 ADR 不改正文，修订以新 ADR 覆盖并在旧文首标注 `Superseded by ADR-XXXX`。

## 编号规则

- `ADR-NNNN-<kebab-title>.md`，四位递增，不复用编号。
- 状态取值：`Proposed` / `Accepted` / `Superseded by ADR-XXXX` / `Rejected`。
- 每篇必含：状态、日期、决策者、背景、决策、后果（含代价）、不采用的方案。

## 索引

| 编号 | 标题 | 状态 |
|---|---|---|
| [ADR-0001](ADR-0001-single-source-governance.md) | 治理单一事实来源（方案 A：规范仓 + 一行引用） | Accepted |
| [ADR-0002](ADR-0002-exclusion-semantics.md) | 豁免语义：2026-10-19/21「29 项整部不适用」 | Superseded by ADR-0006 |
| [ADR-0003](ADR-0003-enforce-admins-false.md) | `enforce_admins=false`：个人账号直推的取舍 | Accepted |
| [ADR-0004](ADR-0004-private-repo-protection-gap.md) | 私有仓分支保护：Free 计划能力缺口 | Accepted |
| [ADR-0005](ADR-0005-repo-backup-local-mirror.md) | 仓库备份：接受 GitHub 单远端，本地镜像暂缓 | Accepted |
| [ADR-0006](ADR-0006-two-axis-profiling.md) | lifecycle × delivery 两轴分档与 44 仓重定位 | Accepted |
| [ADR-0007](ADR-0007-public-agent-contract.md) | 公开仓根 `AGENTS.md` 精简版与 `docs/agent-contract.md` | Superseded by ADR-0008 |
| [ADR-0008](ADR-0008-single-local-agents-md.md) | 单一本地 `AGENTS.md`，不入库，300 行上限 | Accepted |
| [ADR-0009](ADR-0009-agent-contract-v2.md) | Agent 契约 v2：例外统一引用登记表 | Accepted |

## 与规范的关系

ADR 记录**为什么这样定**；`REPOSITORY_GUIDELINES.md` 记录**现在要求什么**。两者冲突时以规范为执行口径，但改规范须先有 Accepted 的 ADR。
