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
| [ADR-0008](ADR-0008-single-local-agents-md.md) | 单一本地 `AGENTS.md`，不入库，300 行上限 | Accepted（§7.5 路由条款由 ADR-0011 修订） |
| [ADR-0009](ADR-0009-agent-contract-v2.md) | Agent 契约 v2：例外统一引用登记表 | Accepted |
| [ADR-0010](ADR-0010-ci-remote-first.md) | CI 远程化与本地最小化：检查必须有远端载体，私有仓盲区可选 PAT 补齐 | Accepted |
| [ADR-0011](ADR-0011-inline-full-agents-md.md) | 根 AGENTS.md 内联完整契约并取消 docs/local 副本 | Accepted |
| [ADR-0012](ADR-0012-self-evolution-ledgers.md) | 自进化台账标准化：GOTCHAS / REVISION_LOG | Accepted |
| [ADR-0013](ADR-0013-ledger-migration-and-lossless-verification.md) | 大台账格式迁移落地与无损校验口径修正 | Accepted |
| [ADR-0014](ADR-0014-multi-agent-concurrency-enforcement.md) | 多 Agent 并发的执行件与跨机边界 | Accepted |
| [ADR-0015](ADR-0015-autonomous-commit-push-ci-monitoring.md) | 执行方自主提交、推送、合并与 CI 监控 | Accepted |
| [ADR-0016](ADR-0016-account-password-vault-naming.md) | 账号级口令保险库 `KeyBackup-Passwords` 的命名例外 | Accepted |
| [ADR-0017](ADR-0017-dsh-superagent-upstream-naming.md) | `dsh-superagent` 的上游生态名例外与同批新增仓命名裁决 | Accepted |
| [ADR-0018](ADR-0018-new-repo-registration-and-archive-name.md) | `dsh-superagent-archive` 例外名继承与 `BookSpine-Wall` / `MirrorDuo` / `OrbitCube` 入账、遗留计数修正 | Accepted |
| [ADR-0019](ADR-0019-ledger-versioning.md) | 自进化台账纳入版本控制（取代 ADR-0013 第 5 条；修订 §13.1 `local/` 容器模板） | Accepted |
| [ADR-0020](ADR-0020-ledger-inventory-and-draftpeek-dual-track.md) | 台账盘点修正（补计 TTS-MultiModel，取代 ADR-0019 第 6 条）与 DraftPeek 双轨台账追认（取代 ADR-0019 第 3 条设想）；强化 §4/§6 平台动作顺序约束 | Accepted |
| [ADR-0021](ADR-0021-mirrordou-archive-agents-md.md) | `MirrorDuo` 归档时入库根 `AGENTS.md`，作为 §7.1「一律不入库」的单仓例外（`tracked_agents_allow`） | Accepted |
| [ADR-0022](ADR-0022-verification-trust-and-gate-coverage.md) | 验证可信度入规（§7.4 第6触发 + §17.4 防假绿自检）；门禁接入期望复用 `reusable_workflows.callers`，不新增 gates 字段 | Accepted |
| [ADR-0023](ADR-0023-doc-health-criteria-refinement.md) | §18.1 文档健康判据细化（入链/路径/快照豁免）、首审结果归档，维持 §18.3 暂不绑门禁 | Accepted |
| [ADR-0024](ADR-0024-pending-delete-repos.md) | 待删除仓不登记（`pending_delete`）：远端仍存在但已裁决不入 §4 台账的仓不计未登记漂移、不参与 §1 命名校验与发布审计；`whalemate` 据此撤登记 | Accepted |

## 与规范的关系

ADR 记录**为什么这样定**；`REPOSITORY_GUIDELINES.md` 记录**现在要求什么**。两者冲突时以规范为执行口径，但改规范须先有 Accepted 的 ADR。
