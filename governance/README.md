# 治理手册（governance/）

本目录是 ReSerendipity 账号的**政策文档单一事实来源**；`.github` 仍承担默认社区健康文件与复用工作流，两者分工如下。

| 文件 | 作用 | 适用范围 |
|---|---|---|
| `REPOSITORY_GUIDELINES.md` | 治理规范 §1–§20：命名与目录（§1 含原 §4/§6 归口）、分支、密钥备份、变更流程、单一本地 `AGENTS.md`（§7，含自进化 §7.4 / 拆分 §7.5）、README 双版本与展示图真实性（§8 / §8.1）、本地产物、发布分发、许可证、结构与路径（§12 含原 §13 归口）、硬编码、治理分档与暂时归档（§15 / §15.7）、开工前工作区判定、任务收尾与 CI 收敛（§17）、Markdown 文档健康（§18）、Dependabot 与依赖升级处置（§19）、CI 远程化与本地最小化（§20） | 40 个登记仓；8 个备份仓按 §3 单独管理 |
| `GOVERNANCE-EXCLUSIONS.md` | 治理分档与例外记录：现行口径、8 个备份仓与命名/发布载体对照、四轮豁免历史原文，以及 §六–§十 例外（生成物、本地治理目录、暂缓、展示图、私有资产备份） | 全账号 |
| `desired-state.json` | 声明式期望状态：48 仓两轴定位 + 复用工作流调用点；漂移审计与一致性检查的数据源 | 全账号 |
| [`decisions/`](decisions/README.md) | ADR 决策记录（ADR-0001~ADR-0011）：为什么这样定；ADR-0007 已被 ADR-0008 取代，ADR-0008 的 §7.5 路由条款由 ADR-0011 修订 | 全账号 |
| [`templates/agent-contract.md`](templates/agent-contract.md) | Agent 契约模板（v2）：各仓 `docs/agent-contract.md` 逐字节复制，漂移审计校验；例外只引用 `GOVERNANCE-EXCLUSIONS.md` §七 | 各仓 |
| [`templates/AGENTS.template.md`](templates/AGENTS.template.md) | 本地 `AGENTS.md` 模板：根文件内联契约 v2、本地唯一完整版（不入库，≤300 行），`scaffold-repo.sh` 按此生成 | 各仓 |
| [`templates/RELEASE_GOVERNANCE_TEMPLATE.md`](templates/RELEASE_GOVERNANCE_TEMPLATE.md) | §10 发布文档统一模板（2026-10-30 自仓根迁入 `governance/templates/`，暂缓迁入的在途 WIP 前置已消除） | 发布型仓 |

## 权威顺序

1. 本目录政策文档 > 各仓 `docs/` > 各仓 `README.md`
2. 平台配置（ruleset、必需检查）是政策的**执行层**，不另行成文
3. 适用条款由 `desired-state.json` 的 `delivery` 派生，`lifecycle` 决定变更许可与审计频率（§15）
4. ADR 记录决策理由；与规范冲突时以规范为执行口径

## 引用方式

各仓根 `README.md` 只放一行：

```markdown
> 治理规范：[ReSerendipity/.github/governance](https://github.com/ReSerendipity/.github/tree/main/governance)
```

**不复制正文**，避免多副本漂移。

**适用范围（2026-10-27 明确）**：

| 仓类别 | 是否要求引用行 | 依据 |
|---|---|---|
| 公开仓，`lifecycle` 为 `active` / `maintenance`，`delivery` 非 `backup` | **必须** | §8 公开仓适用范围 |
| 公开仓，`archived` | 不追溯；既有变体链接（如指向 `blob/main/governance/REPOSITORY_GUIDELINES.md`）视为有效 | §8 装修不追溯（2026-10-23） |
| 私有仓 | 建议放置，不作闸（私有仓不强制双版本分流） | §8 私有仓例外 |
| `backup` 仓 | 不要求 | §15.3：`backup` 仅适用 §3 |

指向具体文件的变体（`REPOSITORY_GUIDELINES.md` / `CONTRIBUTING.md`）**不判为死链**，只在上述「必须」类仓要求补齐标准 `tree/main/governance` 引用行。

**允许形态（2026-10-27 明确，按现网 16 仓实测收敛为两种）**：只要指向的 URL 是 `https://github.com/ReSerendipity/.github/tree/main/governance`，以下任一形态均合规，不强制统一——

1. **引用行**（默认）：上面那行 blockquote；
2. **Governance 徽章**：`[![Governance](https://img.shields.io/badge/governance-ReSerendipity%2F.github-blue)](https://github.com/ReSerendipity/.github/tree/main/governance)`，适合已有 badge 带的仓，与 §8「带 badges」要求同处一行更协调。

徽章颜色、`alt` 文案与中英措辞（`治理规范` / `Governance` / `治理规范 / Governance`）自由；判据只有两条：**URL 指向 governance 目录**、**不复制政策正文**。

## 新建仓库

先跑脚手架，再改治理文档：

```bash
bash .github/scripts/scaffold-repo.sh <Repo-Name> [--private|--public] [--delivery release|service|tool|content] [--create-remote]
```

脚本生成 README（含治理引用）、CHANGELOG、`docs/release-governance.md`、`.gitignore`、`.githooks/pre-push`，并设置 `core.hooksPath`；不自动改治理文档，结束时打印五处同步清单。

## 变更流程

- 改动按 §17.2 的推送策略：作者账号可直推，非作者走分支 + PR + DCO；合并前 `check-repo-registry.sh`、`check-governance-consistency.sh` 必须 `rc=0`。CI 的 `repo-registry` 作业在每次 PR / 推送跑这两个脚本（一致性用 `--public-only`）；完整 48 仓（含私有仓）用 owner 凭据本地跑无参模式。
- 清单类改动需五处同步：规范正文、`check-repo-registry.sh` 的 `EXCLUDED_FROM_REGISTRY`、`check-release-standard.sh` 的 `EXCLUDED_FROM_RELEASE_STANDARD`、本文件、`GOVERNANCE-EXCLUSIONS.md`
- 定位改动同时改 `desired-state.json`；`audit-drift.py` 在周检、手动触发与命中 `desired-state.json` 的 PR 上对账（2026-10-30 定稿：远程优先、本地最少化）
- 版本记录以**条款级日期标注**写在正文本身：节标题或引用块内标「（YYYY-MM-DD 新增 / 定稿 / 修订 / 扩充）」，不另建 CHANGELOG，也不建独立的变更段落。新增小节须带落地日期；既有条款被扩充或改口径时，在标题追加日期或在该节内加留痕引用块，**不改写历史日期**（§18.1 快照）
