# ADR-0011：根 AGENTS.md 内联完整契约并取消 docs/local 副本

- 状态：Accepted
- 日期：2026-10-30
- 决策者：ReSerendipity（账号所有者）
- 相关：§7、§7.2、§7.3、§7.4、§7.5、ADR-0008、ADR-0009
- 部分修订：ADR-0008 第 3 条「行数超限时根文件只做路由器」

## 背景

ADR-0008 把 AGENTS.md 收敛为「每仓一个根文件、只本地保留」，但落地后出现两层残留：

1. 13 个仓的根 `AGENTS.md` 仍是 ADR-0007 时代的 24–32 行指针版，正文只写「完整契约见 `docs/agent-contract.md`」「完整本地上下文见 `local/`」，新会话只自动读根文件，实际硬约束不可见；
2. 真正的完整内容存在第二份副本：9 个仓的 `local/AGENTS.md`（5–33 KB）与 5 个仓的 `docs/AGENTS.md`（1.5–85 KB）。这与 ADR-0008「每仓只有一个 AGENTS.md」直接冲突，并形成事实上的双版本。

账号所有者明确：根目录 `AGENTS.md` 就是完整内容本体，取代现有 `docs/AGENTS.md` 与 `local/AGENTS.md` 副本；`local/README.internal.md` 保持不变。

## 决策

1. 根 `AGENTS.md` 是**本地唯一完整版**：内联契约 v2 全部条款（禁止入库清单与例外、DCO/noreply、平台设置、WIP 保护、发布链），再写本仓定位、专属红线、常用命令与验证、结构与发布/CI、交付前、索引、维护。
2. `docs/AGENTS.md` 与 `local/AGENTS.md` 的内容逐条并入根文件后**删除**；不再保留第二份 AGENTS 副本。删除前必须确认 `git ls-files <path>` 为空，被跟踪则停止上报。
3. `AGENTS.md` 仍一律不入库：`.gitignore` 写无斜线的 `AGENTS.md`（匹配任意深度），`git ls-files "*AGENTS.md"` 必须为空；私有仓同样不上传。
4. 拆分标准为**阅读频率二分**：每次开工必读的内容留根；只在特定模块/任务才读的细节下沉 `local/agents/<module|task>.md`，并带 §7.5 标注头、根索引同步登记。存量 `docs/agents/**` 保留为历史分片，不强制迁移。
5. 根文件 ≤300 行（推荐 ≤150）；拆分文件建议 ≤300 行；同一事实只留一处权威来源。
6. `docs/agent-contract.md` 继续 tracked，作为 fresh clone / CI / 云电脑兜底；仓内副本仍由 `audit-drift.py` 逐字节比对。
7. 模板由 `governance/templates/AGENTS.slim.md` 更名为 `governance/templates/AGENTS.template.md`；`scaffold-repo.sh` 与治理文档同步。
8. 本次落地范围：16 个本地治理仓（.github + 15 业务仓）。未克隆仓在下次成为工作区时按同一模板落地。

## 后果

- 优点：一个入口即完整约束，新会话不再需要跳文件；消除双版本与查找分叉；根文件可记录本机路径等本地细节。
- 优点：契约只在根文件与 tracked 副本各出现一次，规则边界清晰。
- 代价：16 仓一次性合并，Prompt-Library 需拆 4 个 `local/agents/*.md`；本地文件不进远端备份；fresh clone / 云电脑仍只能看到 `docs/agent-contract.md`。
- 观察项：10 个仓的 `docs/agent-contract.md` 仍为 v1，需按 drift-audit 后续同步（不在本次范围）。

## 不采用

- 保留指针版根文件：新会话读不到约束，问题维持原状。
- 保留 `local/AGENTS.md` 或 `docs/AGENTS.md` 作为完整版：违反 ADR-0008 单一文件原则，且双版本必然漂移。
- 把 Prompt-Library 734 行原文整体塞进根文件：超过 300 行硬上限，且大部分内容只在特定任务才读。
