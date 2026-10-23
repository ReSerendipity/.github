# ReSerendipity .github

本仓库承载 ReSerendipity 账号的**默认社区健康文件**（default community health files）。

> 这里是治理文件仓库，不是个人主页。个人主页介绍请查看 [ReSerendipity/ReSerendipity](https://github.com/ReSerendipity/ReSerendipity)。

当某个下属仓库没有自带对应文件时，GitHub 会自动回退使用本仓库中的默认版本：

| 文件 | 作用 |
|---|---|
| `CODE_OF_CONDUCT.md` | 社区行为准则（Contributor Covenant 2.1） |
| `CONTRIBUTING.md` | 贡献指南（Conventional Commits + DCO） |
| `SECURITY.md` | 安全披露策略（默认版；各仓库自带版本优先） |
| `SUPPORT.md` | 支持渠道说明 |
| `governance/REPOSITORY_GUIDELINES.md` | **仓库治理规范**：命名与目录（§1，含原 §4/§6 归口；Train Case + 短横线、现网台账、本地与远程一致）、分支（main + 保护规则 + `delete_branch_on_merge`）、密钥备份模式、单一本地 `AGENTS.md`（§7，不入库，≤300 行；自进化 §7.4 / 拆分 §7.5）、README 双版本（根 README 对外 / local/README.internal.md 对内不入库）、本地产物排除、发布/分发统一规范（§10：release + package + deployment 合一，远端优先）、许可证规范（§11）、结构与路径（§12，含原 §13 归口）、硬编码规范（§14）、治理分档（§15：lifecycle × delivery 两轴派生适用条款；§15.7 暂时归档）、开工前工作区判定、任务收尾与 CI 收敛（§17）、Markdown 文档健康（§18） |
| `governance/GOVERNANCE-EXCLUSIONS.md` | **治理分档与例外记录**：现行口径、7 个备份仓的整部豁免、命名/发布载体对照，以及 2026-10-18~21 四轮豁免的历史原文（语义已被 ADR-0006 取代，仅留痕） |
| `governance/desired-state.json` | **声明式期望状态**：45 仓的 lifecycle / delivery / distribution / risk / backup 定位与复用工作流调用点；`audit-drift.py` 与 `check-governance-consistency.sh` 的数据源 |
| `governance/decisions/` | **ADR 决策记录**：ADR-0001 单一事实来源、ADR-0002 旧豁免语义（已取代）、ADR-0003 `enforce_admins=false`、ADR-0004 私有仓保护缺口、ADR-0005 备份策略、ADR-0006 两轴分档、ADR-0007 公开 Agent 契约（已被 ADR-0008 取代）、ADR-0008 单一本地 `AGENTS.md` |
| `governance/templates/agent-contract.md` | **Agent 契约模板**：各仓 `docs/agent-contract.md` 的唯一来源；根 `AGENTS.md` 为单一本地文件（不入库，≤300 行），公开入口是 `docs/agent-contract.md` 与根 `README.md` |
| `RELEASE_GOVERNANCE_TEMPLATE.md` | **发布文档统一模板**（§10 的执行件）：各仓复制为 `docs/release-governance.md` 后只填本仓特有项。配套核验脚本 `.github/scripts/check-release-standard.sh`（审计收敛进度，**非**每 PR 门禁）。计划迁入 `governance/`，因在途 WIP 暂缓（截至 2026-10-23） |
| `.github/ISSUE_TEMPLATE/` | 通用 Issue 表单（Bug / 功能 / 提问；各仓库自带定制表单优先） |
| `.github/PULL_REQUEST_TEMPLATE.md` | 通用 Pull Request 检查清单 |

使用规则：

- 默认文件**只在其所属仓库未定义同名文件时生效**（查找优先级：`仓库 .github/` → `仓库根目录` → `仓库 docs/` → 本组织默认）。
- 需要项目定制的仓库（如专属许可说明、安全设计、模型合规条目）应自行提供同名文件覆盖默认。
- 本仓库本身不承载任何项目代码。
- 主页简介由同名仓库 `ReSerendipity/ReSerendipity` 承载。本账号是个人账号，`profile/README.md` 属组织账号（Organization）专属机制，在个人账号下不会渲染，因此本仓库不保留该文件。

治理约定细节见 `governance/REPOSITORY_GUIDELINES.md`（命名/分支/密钥备份/两轴分档）、`CONTRIBUTING.md`、`CODE_OF_CONDUCT.md`、`SECURITY.md`、`SUPPORT.md`；适用条款派生见 `governance/desired-state.json` 与 §15，例外记录见 `governance/GOVERNANCE-EXCLUSIONS.md`。

## 复用工作流

`.github/workflows/` 中的家族复用工作流由各仓通过 `workflow_call` 接入。调用方应引用已审阅的提交 SHA，而不是会漂移的 `@main`。`self-purify.yml` 默认维持非阻断兼容模式；调用仓完成规则核查后，可设置 `enforce_critical_checks: true`，将“本地治理文档不得被 git 跟踪”作为独立阻断门禁，其余健康检查仍保持告警性质。本仓自身另有六项检查：工作流 lint、DCO 签名、复用工作流冒烟、§4 仓库对照表、§10 发布规范审计、治理漂移审计。其中 §4 对照在每次 PR/推送与 `schedule` 周检上运行；§10 审计仅在 `schedule` 周检上运行；漂移审计在周检、手动触发与命中 `governance/desired-state.json` 的 PR 上运行，用于捕捉账号内新建/改名/删除仓库造成的台账与平台状态漂移。

## 维护原则

- 默认文件保持通用，不写入某个项目独有的运行步骤或模型说明。
- 项目需要例外规则时，应在项目仓库提供同名文件覆盖默认版本。
- 涉及安全、许可证和第三方模型的内容，优先链接到项目自己的合规文档。
- 只把稳定、可长期维护的约定放入默认文件，避免让所有仓库继承实验性规则。
