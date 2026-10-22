# ADR-0007：公开仓根 `AGENTS.md` 精简版与 `docs/agent-contract.md`

- 状态：Accepted
- 日期：2026-10-22
- 决策者：ReSerendipity（账号所有者）
- 相关：§7、ADR-0001、`governance/templates/`
- 部分修订：ADR-0001 的「只放一行引用、不复制正文」

## 背景

ADR-0001 把治理正文收敛到 `.github/governance`，各仓 README 只留一行链接；§7 又规定公开仓的 `AGENTS.md` 不入库。实测结果是：**新会话的 agent 只自动读 `README.md` 与 `AGENTS.md`**，不会顺着 README 里的链接去读治理正文。云电脑/fresh clone 里连 `AGENTS.md` 都没有，治理约束完全不在它的上下文里。

CI 能事后抓住结构违规（DCO、台账、漂移、本地文档入库），但抓不住行为违规（maintenance 仓加新功能、改平台设置、删除 WIP）。这类规则必须在 agent 开工时就被看到。

## 决策

1. 新增**契约文件** `docs/agent-contract.md`：内容固定在 `governance/templates/agent-contract.md`，各仓副本**逐字节一致**；`audit-drift.py` 比对，不一致判红。
2. 允许公开仓**入库根 `AGENTS.md` 精简版**：≤50 行、含 `<!-- governance:agent-contract v1 -->` 标记、只写公开安全内容、链接 `docs/agent-contract.md` 与治理仓。
3. 本地扩展版迁到 `local/AGENTS.md`（仍不入库，≤300 行）；模块级/嵌套 `AGENTS.md` 继续禁止入库。
4. `.gitignore` 由 `AGENTS.md` 改为 `AGENTS.md` + `!/AGENTS.md`：前者覆盖任意深度，后者只放行根文件。
5. `self-purify.yml` 的核心规则按上述边界调整：根精简版放行，其余本地治理文档仍阻断。
6. 新建仓脚手架直接生成这两个文件；存量仓分批迁移。

## 后果

- 优点：agent 在**任何新会话**里先看到 20–30 行可执行约束，再决定是否深入治理正文；云电脑也能看到。
- 优点：契约正文仍只有一份（模板），仓内副本有哈希校验，不靠人记同步。
- 代价：公开仓多了一个受维护的 tracked 文件；`AGENTS.md` 的「永不入库」语义被打破，需在 §7 与 CI 规则里同时改写，否则门禁会误杀。
- 代价：存量 7 个 active 仓已有 52–257 行的本地 `AGENTS.md`，迁移到 `local/AGENTS.md` 属本地文件操作，需逐仓确认，不能批量覆盖。
- 代价：精简版与完整契约存在**有意的两层结构**；若未来规则变动，只改模板 + 审计，不改仓内副本。

## 不采用

- 只加 `docs/agent-contract.md`（方案 2 单独）：agent 不一定会读 `docs/`，解决不了「只读 README/AGENTS.md」的观察。
- 只允许 tracked AGENTS.md（方案 3 单独）：正文会随仓复制，必然漂移；且 50 行装不下发布/结构/路径条款。
- 在 README 里复制完整规则：违反 ADR-0001，且 README 面向外部访客，不是 agent 上下文。
