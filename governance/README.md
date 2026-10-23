# 治理手册（governance/）

本目录是 ReSerendipity 账号的**政策文档单一事实来源**；`.github` 仍承担默认社区健康文件与复用工作流，两者分工如下。

| 文件 | 作用 | 适用范围 |
|---|---|---|
| `REPOSITORY_GUIDELINES.md` | 治理规范 §1–§18：命名与目录（§1 含原 §4/§6 归口）、分支、密钥备份、变更流程、单一本地 `AGENTS.md`（§7，含自进化 §7.4 / 拆分 §7.5）、README 双版本、本地产物、发布分发、许可证、结构与路径（§12 含原 §13 归口）、硬编码、治理分档与暂时归档（§15 / §15.7）、任务收尾与 CI 收敛（§17）、Markdown 文档健康（§18） | 38 个登记仓；7 个备份仓按 §3 单独管理 |
| `GOVERNANCE-EXCLUSIONS.md` | 治理分档与例外记录：现行口径、7 个备份仓与命名/发布载体对照，以及四轮豁免历史原文 | 全账号 |
| `desired-state.json` | 声明式期望状态：45 仓两轴定位 + 复用工作流调用点；漂移审计与一致性检查的数据源 | 全账号 |
| `decisions/` | ADR 决策记录（ADR-0001~ADR-0008）：为什么这样定；ADR-0007 已被 ADR-0008 取代 | 全账号 |
| `templates/agent-contract.md` | Agent 契约模板（v1）：各仓 `docs/agent-contract.md` 逐字节复制，漂移审计校验；根 `AGENTS.md` 为单一本地文件（不入库，≤300 行） | 各仓 |
| `RELEASE_GOVERNANCE_TEMPLATE.md`（暂留根目录） | §10 发布文档统一模板；因在途 WIP 暂缓迁入（截至 2026-10-23） | 发布型仓 |

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

## 新建仓库

先跑脚手架，再改治理文档：

```bash
bash .github/scripts/scaffold-repo.sh <Repo-Name> [--private|--public] [--delivery release|service|tool|content] [--create-remote]
```

脚本生成 README（含治理引用）、CHANGELOG、`docs/release-governance.md`、`.gitignore`、`.githooks/pre-push`，并设置 `core.hooksPath`；不自动改治理文档，结束时打印五处同步清单。

## 变更流程

- 改动按 §17.2 的推送策略：作者账号可直推，非作者走分支 + PR + DCO；合并前 `check-repo-registry.sh`、`check-governance-consistency.sh` 必须 `rc=0`
- 清单类改动需五处同步：规范正文、`check-repo-registry.sh` 的 `EXCLUDED_FROM_REGISTRY`、`check-release-standard.sh` 的 `EXCLUDED_FROM_RELEASE_STANDARD`、本文件、`GOVERNANCE-EXCLUSIONS.md`
- 定位改动同时改 `desired-state.json`；`audit-drift.py` 在周检、手动触发与命中 `desired-state.json` 的 PR 上对账
- 版本记录写在各文件自身的变更段落，不另建 CHANGELOG
