# 文档索引（docs/INDEX）

> 最后核对：2026-11-10　｜　维护：文档整理工单 WO-DOC-B01
> 本文件是 `.github` 仓 Markdown 的机器可读总索引：仓根 7 篇 + `docs/` 1 篇 + `governance/` 32 篇 + `.github/` 3 篇 + `local/` 3 篇 = 46 篇；其中 `local/` 3 篇不入库，`git ls-files '*.md'` 计 43 篇。
> **权威顺序**（照 [`governance/README.md`](../governance/README.md) 第 17–23 行）：本仓 `governance/` 政策文档 > 各仓 `docs/` > 各仓 `README.md`；本文件只是索引，不承载政策正文。

## 状态口径

| 状态 | 含义 |
|---|---|
| 现行 | 仍是有效政策、模板、清单或登记表 |
| 历史 | 时点记录或已被取代的记录，只作追溯 |
| 废弃 | 已被后继文档取代（ADR 被取代时在旧文首标 `Superseded by ADR-XXXX`） |
| 模板 | 供各仓复制使用的模板（正文以模板为准，改动须同步各仓副本） |
| 本地 | 仅本地保留、不入库 |

## 一、仓根入口文档

| 文档 | 用途 | 状态 | 核对日期 |
|---|---|---|---|
| [`README.md`](../README.md) | 组织默认社区健康文件与复用工作流的说明入口 | 现行 | 2026-11-10 |
| [`AGENTS.md`](../AGENTS.md) | 本仓编码代理契约（内联契约 v2 与必读内容） | 现行 | 2026-11-10 |
| [`ARCHITECTURE.md`](../ARCHITECTURE.md) | 本仓结构说明：治理手册 / 模板 / 工作流 / 脚本的分工 | 现行 | 2026-11-10 |
| [`CONTRIBUTING.md`](../CONTRIBUTING.md) | 贡献指南（组织级默认） | 现行 | 2026-11-10 |
| [`CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md) | 行为准则（组织级默认） | 现行 | 2026-11-10 |
| [`SECURITY.md`](../SECURITY.md) | 安全策略与漏洞披露（组织级默认） | 现行 | 2026-11-10 |
| [`SUPPORT.md`](../SUPPORT.md) | 支持渠道说明（组织级默认） | 现行 | 2026-11-10 |

## 二、docs/（本仓自用文档）

| 文档 | 用途 | 状态 | 核对日期 |
|---|---|---|---|
| [`agent-contract.md`](agent-contract.md) | Agent 契约 v2 的仓内副本，**须与 `governance/templates/agent-contract.md` 逐字节一致**（漂移审计校验） | 现行（模板副本） | 2026-11-10 |

## 三、governance/（政策单一事实来源）

### 3.1 政策正文

| 文档 | 用途 | 状态 | 核对日期 |
|---|---|---|---|
| [`README.md`](../governance/README.md) | 治理手册入口：文件分工表、权威顺序、引用方式（含 2026-10-27 允许形态）、新建仓脚手架、变更流程 | 现行 | 2026-11-10 |
| [`REPOSITORY_GUIDELINES.md`](../governance/REPOSITORY_GUIDELINES.md) | 治理规范 §1–§21（命名与目录、分支、密钥备份、变更流程、本地 `AGENTS.md`、README 双版本与展示图真实性、发布分发、许可证、结构与路径、治理分档、Markdown 文档健康、依赖升级、CI 远程化、仓库描述） | 现行 | 2026-11-10 |
| [`GOVERNANCE-EXCLUSIONS.md`](../governance/GOVERNANCE-EXCLUSIONS.md) | 治理分档与例外记录：现行口径、备份仓与命名/发布载体对照、四轮豁免历史原文、§六–§十 例外 | 现行 | 2026-11-10 |

### 3.2 决策记录 `decisions/`（ADR-0001 ~ ADR-0018，编号不重用）

| 文档 | 用途 | 状态 | 核对日期 |
|---|---|---|---|
| [`README.md`](../governance/decisions/README.md) | ADR 索引与格式约定（编号规则、状态取值、必含小节） | 现行 | 2026-11-10 |
| [`ADR-0001-single-source-governance.md`](../governance/decisions/ADR-0001-single-source-governance.md) | 政策单一事实来源：`governance/` 立为唯一正文，各仓只放引用行 | 现行 | 2026-11-10 |
| [`ADR-0002-exclusion-semantics.md`](../governance/decisions/ADR-0002-exclusion-semantics.md) | 治理豁免的语义定义（什么算例外、如何登记） | 现行 | 2026-11-10 |
| [`ADR-0003-enforce-admins-false.md`](../governance/decisions/ADR-0003-enforce-admins-false.md) | Ruleset 不强制 admin，admin 直推的边界与替代门禁 | 现行 | 2026-11-10 |
| [`ADR-0004-private-repo-protection-gap.md`](../governance/decisions/ADR-0004-private-repo-protection-gap.md) | 私有仓分支保护缺口的事实记录与处置 | 现行 | 2026-11-10 |
| [`ADR-0005-repo-backup-local-mirror.md`](../governance/decisions/ADR-0005-repo-backup-local-mirror.md) | 仓备份采用本地镜像而非远端 fork | 现行 | 2026-11-10 |
| [`ADR-0006-two-axis-profiling.md`](../governance/decisions/ADR-0006-two-axis-profiling.md) | 仓库两轴定位（`delivery` / `lifecycle`） | 现行 | 2026-11-10 |
| [`ADR-0007-public-agent-contract.md`](../governance/decisions/ADR-0007-public-agent-contract.md) | 公开仓根 `AGENTS.md` 精简版与 `docs/agent-contract.md` | 废弃（Superseded by ADR-0008） | 2026-11-10 |
| [`ADR-0008-single-local-agents-md.md`](../governance/decisions/ADR-0008-single-local-agents-md.md) | 单一本地 `AGENTS.md`、不入库、≤300 行（§7.5 路由条款由 ADR-0011 修订） | 现行 | 2026-11-10 |
| [`ADR-0009-agent-contract-v2.md`](../governance/decisions/ADR-0009-agent-contract-v2.md) | Agent 契约 v2 定稿与逐字节一致性要求 | 现行 | 2026-11-10 |
| [`ADR-0010-ci-remote-first.md`](../governance/decisions/ADR-0010-ci-remote-first.md) | CI 远程优先、本地最小化 | 现行 | 2026-11-10 |
| [`ADR-0011-inline-full-agents-md.md`](../governance/decisions/ADR-0011-inline-full-agents-md.md) | 根 `AGENTS.md` 内联全文（修订 ADR-0008 §7.5 路由条款） | 现行 | 2026-11-10 |
| [`ADR-0012-self-evolution-ledgers.md`](../governance/decisions/ADR-0012-self-evolution-ledgers.md) | 自进化台账标准化（GOTCHAS / REVISION_LOG） | 现行 | 2026-11-10 |
| [`ADR-0013-ledger-migration-and-lossless-verification.md`](../governance/decisions/ADR-0013-ledger-migration-and-lossless-verification.md) | 台账迁移与无损校验方法 | 现行 | 2026-11-10 |
| [`ADR-0014-multi-agent-concurrency-enforcement.md`](../governance/decisions/ADR-0014-multi-agent-concurrency-enforcement.md) | 多 agent 并发的执行件与跨机边界（补 §17.5） | 现行 | 2026-11-10 |
| [`ADR-0015-autonomous-commit-push-ci-monitoring.md`](../governance/decisions/ADR-0015-autonomous-commit-push-ci-monitoring.md) | 执行方自主提交、推送、合并与 CI 监控的授权边界 | 现行 | 2026-11-10 |
| [`ADR-0016-account-password-vault-naming.md`](../governance/decisions/ADR-0016-account-password-vault-naming.md) | 账号级口令保险库 `KeyBackup-Passwords` 的命名例外 | 现行 | 2026-11-10 |
| [`ADR-0017-dsh-superagent-upstream-naming.md`](../governance/decisions/ADR-0017-dsh-superagent-upstream-naming.md) | `dsh-superagent` 上游生态名例外与同批新增仓命名裁决 | 现行 | 2026-11-10 |
| [`ADR-0018-new-repo-registration-and-archive-name.md`](../governance/decisions/ADR-0018-new-repo-registration-and-archive-name.md) | `dsh-superagent-archive` 例外名继承、`BookSpine-Wall` / `MirrorDuo` / `OrbitCube` 入账、遗留计数修正 | 现行 | 2026-11-10 |

### 3.3 模板 `templates/`

| 文档 | 用途 | 状态 | 核对日期 |
|---|---|---|---|
| [`agent-contract.md`](../governance/templates/agent-contract.md) | Agent 契约 v2 模板：各仓 `docs/agent-contract.md` 逐字节复制，漂移审计校验 | 模板 | 2026-11-10 |
| [`AGENTS.template.md`](../governance/templates/AGENTS.template.md) | 本地 `AGENTS.md` 模板：内联契约 v2、本地唯一完整版（不入库、≤300 行） | 模板 | 2026-11-10 |
| [`ARCHITECTURE.template.md`](../governance/templates/ARCHITECTURE.template.md) | 仓 `ARCHITECTURE.md` 模板 | 模板 | 2026-11-10 |
| [`CODE_OF_CONDUCT.template.md`](../governance/templates/CODE_OF_CONDUCT.template.md) | 行为准则模板 | 模板 | 2026-11-10 |
| [`CONTRIBUTING.template.md`](../governance/templates/CONTRIBUTING.template.md) | 贡献指南模板（含分支约定、行为准则引用） | 模板 | 2026-11-10 |
| [`GOTCHAS.template.md`](../governance/templates/GOTCHAS.template.md) | 自进化坑点台账模板（§7.4.1） | 模板 | 2026-11-10 |
| [`RELEASE_GOVERNANCE_TEMPLATE.md`](../governance/templates/RELEASE_GOVERNANCE_TEMPLATE.md) | §10 发布文档统一模板（2026-10-30 自仓根迁入） | 模板 | 2026-11-10 |
| [`REVISION_LOG.template.md`](../governance/templates/REVISION_LOG.template.md) | 自进化修订记录模板（§7.4.2） | 模板 | 2026-11-10 |
| [`SECURITY.template.md`](../governance/templates/SECURITY.template.md) | 安全策略模板 | 模板 | 2026-11-10 |
| [`SKILL.template.md`](../governance/templates/SKILL.template.md) | Skill 编写模板 | 模板 | 2026-11-10 |

> `governance/desired-state.json` 为**声明式期望状态**（59 仓两轴定位 + 复用工作流调用点，漂移审计数据源），非 Markdown，不在本索引正文；口径说明见 [`governance/README.md`](../governance/README.md)。

## 四、.github/（平台配置文件）

| 文档 | 用途 | 状态 | 核对日期 |
|---|---|---|---|
| [`.github/PULL_REQUEST_TEMPLATE.md`](../.github/PULL_REQUEST_TEMPLATE.md) | PR 模板（DCO 签署与验证栏位） | 现行 | 2026-11-10 |
| `.github/scripts/tests/fixtures/release-ok/`（2 篇：`CHANGELOG.md`、`docs/release-governance.md`） | 发布校验脚本的**测试夹具**，非文档 | 夹具 | 2026-11-10 |
| `.github/workflows/`（7 个 yml：`ci` / `dco-signoff` / `drift-audit` / `python-quality-baseline` / `readme-image-provenance` / `scorecard` / `self-purify`） | 复用工作流与门禁，**本轮工单明确不改 `workflows/*`**，仅登记 | 现行 | 2026-11-10 |

## 五、local/（本地维护层，不入库）

| 文档 | 用途 | 状态 | 核对日期 |
|---|---|---|---|
| [`local/README.internal.md`](../local/README.internal.md) | 本地维护层说明 | 本地 | 2026-11-10 |
| [`local/agents/GOTCHAS.md`](../local/agents/GOTCHAS.md) | 坑点台账（§7.4.1） | 本地 | 2026-11-10 |
| [`local/agents/REVISION_LOG.md`](../local/agents/REVISION_LOG.md) | 修订记录（§7.4.2） | 本地 | 2026-11-10 |

## 六、索引维护规则

1. **新增政策文件**：进 `governance/` 并在 §3 补一行；同时按 [`governance/README.md`](../governance/README.md) §变更流程 做五处同步（规范正文、`check-repo-registry.sh`、`check-release-standard.sh`、治理 README、`GOVERNANCE-EXCLUSIONS.md`）。
2. **新增 ADR**：四位递增、不复用编号；在 [`decisions/README.md`](../governance/decisions/README.md) 索引与本文件 §3.2 同步补行；被取代的旧 ADR 在文首标 `Superseded by ADR-XXXX`，正文不改。
3. **模板改动**：`templates/*` 改动即视为政策变更，须同步各仓已复制的副本（`agent-contract.md` 走漂移审计），本文件同步刷新「核对日期」。
4. **`workflows/*`**：本索引只做登记，正文改动不在文档整理范围内。
5. **核对日期**：整仓复核时统一刷新。
