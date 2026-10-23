# ADR-0008：单一本地 `AGENTS.md`（不入库）

- 状态：Accepted
- 日期：2026-10-23
- 决策者：ReSerendipity（账号所有者）
- 相关：§7、§16、ADR-0001、ADR-0007
- 取代：ADR-0007

## 背景

ADR-0007 为让新会话 agent 看到约束，允许公开仓入库 ≤50 行根 `AGENTS.md`，并把完整上下文放 `local/AGENTS.md` 或私有仓 `docs/agent-context.md`。实际运行暴露两个问题：

1. 两层结构形成事实上的「AGENTS.md 双版本」，根文件与完整版容易脱节；
2. 新 agent 找不到完整版，根文件又没有指向 `local/AGENTS.md` 的指令。

账号所有者明确：每个仓只需要一个 `AGENTS.md`，并保持 gitignore、仅本地留存。

## 决策

1. 每个仓**只有一个**根 `AGENTS.md`，位于仓库根目录，**一律不入库**。
2. `.gitignore` 只写 `AGENTS.md`（无斜线模式，匹配任意深度），不再有 `!/AGENTS.md` 白名单。
3. 行数上限 **300 行**；超过时按 §7.5 拆分到 `local/agents/<module|task>.md`，根文件只做路由器。
4. 拆分文件头部必须写完整标注（来源章节、范围、负责人、最后更新、上游入口），根索引同步登记。
5. 公开契约仍由 `docs/agent-contract.md` 承载（tracked、逐字节模板）；fresh clone / CI 没有 `AGENTS.md` 属预期。
6. 私有仓也不上传 `AGENTS.md`；备份对象是非 AGENTS.md 的本地上下文。
7. 存量已跟踪的根 `AGENTS.md` 逐仓 `git rm --cached`，本地文件保留；迁移完成前 `self-purify.yml` 暂不翻转。

## 后果

- 优点：一个文件、一个位置、一个上限，消除双版本与查找分叉。
- 优点：本地文件可写本机路径与内部细节（不得写密钥 / token / 口令），不会误入库。
- 代价：fresh clone / 云电脑 agent 看不到本地 `AGENTS.md`，只能依赖 `docs/agent-contract.md` 与根 `README.md`；这是接受的取舍。
- 代价：32 个非归档仓需要迁移已跟踪的根 `AGENTS.md`；迁移前自净化规则保持兼容模式。

## 不采用

- 保留公开精简版 + 本地完整版（ADR-0007）：双版本，维护成本高，且新 agent 找不到完整版。
- 只保留 `docs/agent-context.md`：仍是第二个上下文文件，且与私有仓实际文件名不一致。
