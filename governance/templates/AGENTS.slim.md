# AGENTS.md（本地维护版）

<!-- 本文件不入库，仅本地保留；公开契约见 docs/agent-contract.md -->

> 完整契约：[docs/agent-contract.md](docs/agent-contract.md)
> 治理规范：[ReSerendipity/.github/governance](https://github.com/ReSerendipity/.github/tree/main/governance)
> 维护规则：本文件 ≤300 行；超过时按 §7.5 拆分到 `local/agents/`。

## 开工前

1. 读 `docs/agent-contract.md` 与根 `README.md`。
2. 确认本仓定位：`maintenance` 只修 bug / 依赖 / 安全，`active` 才允许新功能。
3. 需要模块细节时，只读下方索引指向的 `local/agents/*.md`，不要求全读。

## 硬约束

- 密钥、token、口令不得写进本文件；本机路径可记录，但不得提交入库。
- 本文件与 `local/` 不入库；提交必须 `git commit -s`（DCO），身份用 noreply。
- 不改分支保护 / ruleset / Secrets / 仓库可见性。
- 不删他人 WIP，不 `git add -A`。

## 交付前

- `git status` 只含本次改动；跑 README 的测试命令；失败如实报告。

## 索引

| 文件 | 来源章节 | 管什么 | 什么时候读 | 最后更新 |
|---|---|---|---|---|
| `local/agents/GOTCHAS.md` | 本文件 §4 | 踩坑与失败签名 | 遇到同类报错前 | 2026-10-23 |
| `local/agents/<module>.md` | 本文件 §X | 模块命令与禁区 | 改该模块时 | YYYY-MM-DD |
| `local/agents/<task>.md` | 本文件 §Y | 任务 playbook | 执行该任务时 | YYYY-MM-DD |

## 维护

- 踩坑后按 §7.4 把可复用结论写进 `local/agents/GOTCHAS.md`；本文件只留稳定入口。
- 本文件超过 300 行时按 §7.5 拆分，保持「开工前 / 硬约束 / 交付前 / 索引」四块，并在拆分文件头部写完整标注。
- 收尾按 §17 清理、分批提交，并把 CI 盯到终态。
- 文档改动按 §18 检查入链、旧路径、计数快照与状态标记。
