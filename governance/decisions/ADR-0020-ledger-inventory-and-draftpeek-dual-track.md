# ADR-0020：台账盘点修正与 DraftPeek 双轨台账追认

- 状态：Accepted
- 日期：2026-11-17
- 决策者：ReSerendipity（账号所有者）
- 相关：修正 **ADR-0019 第 6 条**（脱敏盘点漏计）；追认 **ADR-0019 第 3 条**在 DraftPeek 的实况演进；强化 **§4 / §6** 平台动作顺序约束。来源为 2026-11-16 治理枢纽深度审查（`_reports/2026-11-16-github-governance-review`）与同日全量漂移审计。

## 背景

2026-11-16 的审查与 5 仓抽查发现三个台账制度问题：

1. **ADR-0019 第 6 条盘点漏计 `TTS-MultiModel`**：原文称"台账正文含本机用户名绝对路径者共 2 仓 9 行（公开仓 DraftPeek 3 / SpiritPal 6）"。实查 `TTS-MultiModel` 的 `local/agents/GOTCHAS.md` 有 6 行、`REVISION_LOG.md` 有 1 行含真实 `C:\Users\Doro\...`，已随 ADR-0019 的台账入库**公开可见**——既未脱敏，也无迁移记录。漏计原因可溯：第 6 条盘点先于该仓台账自 `local/docs-archive/agents/` 归位（第 5 条动作），扫描时该文件不在预期路径上。
2. **DraftPeek 双轨台账与 ADR-0019 第 3 条文字相悖，但实况更优**：第 3 条设想"docs/agents/ 形态的仓只放行两份台账"；实况是该仓主 GOTCHAS（DP-01～31）保持仅本地历史分片，入库载体为 `docs/project/KNOWN_GOTCHAS.md` 续写台账（DP-31 起），pre-push 闸以 `-GotchasPath` 显式指向。该安排已在 `GOVERNANCE-EXCLUSIONS.md` §七 7.1 白名单与仓内 DP-32/33 留痕，证据链完整，唯独 ADR-0019 正文未随之修订，形成「ADR 说 A、EXCLUSIONS 登记 B、仓库做 B」的三方不一。
3. **平台动作后置入账**：`DormitoryNotes-Godot` 于 2026-11-16 远程改名（先动远程）、`P0-Murder-Mystery` 可见性翻转，均未先改台账，周检判红后才由对账修复批次补录。§4 虽有「新增/改名先改 §4，再改远程」，但未覆盖可见性与平台设置，也没有违规发生时的入账先例。

## 决策

1. **盘点修正**：ADR-0019 第 6 条的「2 仓 9 行」更正为「**3 仓**：DraftPeek 3 行、SpiritPal 6 行、TTS-MultiModel 7 行（GOTCHAS 6 + REVISION_LOG 1）」。TTS 按 ADR-0019 第 6 条同一手法处置：`C:\Users\Doro\...` 改写为 `%USERPROFILE%\...` 占位符，表尾追加迁移记录行（写明改动行号、改前改后、触发条款）；「不删不改历史行」的纪律以**显式登记的改写**延续。
2. **DraftPeek 双轨追认**：主 GOTCHAS（DP-01～30）保持仅本地历史分片，不入库；公开续写台账以 `docs/project/KNOWN_GOTCHAS.md` 为**唯一入库载体**，自 DP-31 起追加；pre-push 闸以 `-GotchasPath docs/project/KNOWN_GOTCHAS.md` 显式指向。ADR-0019 第 3 条中「docs/agents/ 形态的仓只放行两份台账」的设想由本条取代；`GOVERNANCE-EXCLUSIONS.md` §七 7.1 白名单继续承载。若未来想把 DP-01～30 历史分片入库，须先完成其脱敏（DP-07 / DP-18 仍含真实本机路径）。
3. **平台动作顺序约束**：§6 的执行顺序由「改名三步」扩展为——**改名 / 可见性 / 归档 / 平台设置（`delete_branch_on_merge`、`allow_auto_merge`、ruleset）一律先改台账（§4 + `desired-state.json`）再动远程**；先动了远程的，按对账修复批次当日补录并在 §4 留痕（2026-11-17 变更条为首个先例）。

## 后果

- TTS 公开台账的本机路径暴露在本 ADR 落地后消除；ADR-0019 第 6 条的盘点以「3 仓」为准确口径。
- DraftPeek 的台账制度从「文字相悖」变为「有 ADR 依据的双轨」；公开面只含已脱敏内容，历史分片继续本地保存。
- 平台动作与台账的先后顺序有了明文与先例；周检判红从「常态」回归「异常」。
- 代价：ADR-0020 与 ADR-0019 第 3/6 条并存，读者需按取代关系读（索引已标注）；双轨台账多一个查找路径，闸口已用显式参数消除歧义。

## 不采用

- **直接修改 ADR-0019 正文**：违反「已 Accepted 的 ADR 不改正文」纪律；修正以新 ADR 承载。
- **把 DP-01～30 历史分片强行入库再脱敏**：该分片 DP-07 / DP-18 含真实本机路径，先入库后改会让公开历史短暂留有本机路径；且续写台账已承载公开知识，迁移收益低。
- **只写顺序条款不留先例**：无先例的顺序约束会被下一次赶工绕过；本次 §4 的 2026-11-17 变更条即为先例。
