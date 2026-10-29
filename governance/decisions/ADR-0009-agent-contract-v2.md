# ADR-0009：Agent 契约 v2——例外统一引用登记表

- 状态：Accepted
- 日期：2026-10-29
- 决策者：ReSerendipity（账号所有者）
- 相关：§7.1、§7.3、§10.5、`GOVERNANCE-EXCLUSIONS.md` §七

## 背景

契约 v1 的硬约束把 `docs/plans`、`docs/project`、`docs/execution` 一律列为禁止入库，但：

- §10.5 要求发布验证产物落在 `docs/execution/RELEASE_VERIFICATION.md`；
- §七 已登记 `SeedVR2-Lite` 的 `docs/plans|project` 与 `SpiritPal` 的 `docs/execution` 例外。

契约是逐字节分发的摘要，按 v1 执行会与规范正文冲突；把每个例外抄进契约又会形成第二份例外清单，必然漂移。

## 决策

1. 契约升级为 **v2**：目录级禁令保留，但显式放行「§10.5 发布验证产物」与「`GOVERNANCE-EXCLUSIONS.md` §七 已登记的仓/家族白名单路径」。
2. 例外只在 `GOVERNANCE-EXCLUSIONS.md` §七 登记；契约只引用登记表，不复制具体仓名与路径清单。
3. 同批更新模板、本仓副本与全部非归档仓副本；`audit-drift.py` 的逐字节比对继续作为同步载体。
4. 未登记的同类路径仍按违规处理。

## 后果

- 优点：契约与 §10.5 / §七 同口径，新增例外只改登记表，不必再改 36 份契约。
- 优点：逐字节审计仍是硬约束，副本漂移会被周检抓住。
- 代价：本次是家族级改动，需要一次性同步 36 个非归档仓副本；公开受保护仓须逐个 PR。

## 不采用

- 把每个例外抄进契约：会形成第二份例外清单，必然漂移。
- 删除 `docs/execution` 禁令：会让真正的本地治理文档失去约束。
