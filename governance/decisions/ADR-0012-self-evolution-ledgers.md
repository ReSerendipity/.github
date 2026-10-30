# ADR-0012：自进化台账标准化（GOTCHAS / REVISION_LOG）

- 状态：Accepted
- 日期：2026-10-30
- 决策者：ReSerendipity（账号所有者）
- 相关：§7.4、§7.5、ADR-0008、ADR-0011

## 背景

自进化协议已在 5 个仓落地（DraftPeek、Image-DuoModel、SeedVR2-Lite、SpiritPal、TTS-MultiModel），但台账形态不一致：

1. 路径分裂：Image-DuoModel / SpiritPal 用 `local/agents/GOTCHAS.md`、`REVISION_LOG.md`；DraftPeek / TTS 用 `docs/agents/` 同名文件；SeedVR2 两处都没有，记录暂记在根 AGENTS §8。
2. 格式分裂：GOTCHAS 有的用 6 列表格、有的用编号条目；REVISION_LOG 有的 6 列、有的内联在 AGENTS.md。
3. 新仓没有台账；治理规范只写了“踩坑台账”一行，未定义表头、编号、追加规则与校验口径。
4. ADR-0011 之后根 AGENTS.md 不再内联修订数据行，台账必须成为唯一权威落点。

## 决策

1. **两个标准台账**：`GOTCHAS.md`（坑点/失败签名）与 `REVISION_LOG.md`（自进化修订记录）。它们是自进化协议的唯一台账，根 AGENTS.md 只保留协议与索引，不再内联数据行。
2. **路径**：优先 `local/agents/`；存量 `docs/agents/` 同名台账保留为历史分片并继续追加，不复制双份。同一仓不得同时维护两份活跃台账。
3. **GOTCHAS 格式**：固定 6 列表格 `# | 坑点标题 | 触发场景 | 现象/报错 | 正确做法 | 首次发现日期`；编号稳定递增、追加到表尾；一条只写一个坑；推荐带 `[sig:<kebab-case>]` 失败签名；不得写密钥/token/口令或限制级正文。
4. **REVISION_LOG 格式**：固定 6 列表格 `自进化版本 | 日期 | 触发原因 | 更新内容摘要 | 对应项目版本 | 已校验`；版本唯一且单调、日期单调不减；一行一次修订；历史行不删不改；顶部协议版本号与最后一行对应。
5. **适用范围**：16 个非归档本地治理仓全部适用。已有台账的继续维护；只有 `docs/agents/` 的保留为历史分片；两者都没有的新建 `local/agents/` 版本。归档仓不追溯。
6. **模板与脚手架**：新增 `governance/templates/GOTCHAS.template.md`、`REVISION_LOG.template.md`；`scaffold-repo.sh` 在生成根 AGENTS.md 时同步创建 `local/agents/` 并复制模板（已存在则不覆盖）。
7. **校验**：有 `scripts/check_revision_log.py` 的仓继续用机械闸；没有的由任务收尾自检人工核对版本唯一/日期单调/列数一致。台账为本地文件，不进 CI。

## 后果

- 优点：5 个存量仓的台账口径统一；新仓开箱即用；根 AGENTS.md 不再与台账双份漂移。
- 优点：GOTCHAS 与 REVISION_LOG 各自有固定表头，机器与人眼都易检索。
- 代价：16 仓需要一次性初始化或确认台账；`docs/agents/` 与 `local/agents/` 会长期并存（历史分片）。
- 观察项：部分仓的 `docs/agents/GOTCHAS.md` 体量已达数百 KB，迁移不在本次范围，只登记索引。

## 不采用

- 只写进 §7.4 不落模板：新仓仍会各写一套表头。
- 全仓强制迁移到 `local/agents/`：需要移动数百 KB 历史台账并改大量引用，收益低。
- 把台账内联回根 AGENTS.md：违反 §7.2 行数上限，也重新制造双份漂移。
