# ADR-0024：待删除仓不登记（`pending_delete`）与 whalemate 撤登记

- 状态：Accepted
- 日期：2026-11-21
- 决策者：ReSerendipity（账号所有者，本会话指令「`whalemate` 这个不需要登记，它里面几乎没有什么内容，后续是直接删除的」）
- 关联：修订 **§4 台账** 的登记范围；新增 `governance/desired-state.json` 的 `pending_delete`；落地于 `check-governance-consistency.sh` / `check-repo-registry.sh` / `check-release-standard.sh` / `audit-drift.py`；口径说明见 `governance/GOVERNANCE-EXCLUSIONS.md` §十二

## 背景

`whalemate` 于 2026-11-20 由另一会话补登记（`8659568`，private / tool / active / none，作为例外名「产品名连写：鲸伴 WhaleMate」入 §4）。登记当次只改了 `desired-state.json` 与 §4，派生面（矩阵 SVG、徽章、ARCHITECTURE 等）在 `6b97de5` 批次才补齐。

2026-11-21 owner 裁决该仓不需要登记：本地 `C:\Users\Doro\APP\repository\whalemate` 只剩空壳（`.git` 无对象、无提交，`HEAD` 指向 `refs/heads/.invalid`，工作区无文件），且该仓后续会被直接删除。

**事实边界**：远端 `ReSerendipity/whalemate` 当时仍有 13 个提交、约 20 MB（鲸伴桌宠 Tauri MVP 与 docs），不是空仓。本 ADR 只处理「是否纳入治理台账」，不处理「是否删除远端」——删除是不可恢复动作，需 owner 单独确认后执行。

## 决策

1. **撤登记**：从 `desired-state.json` 的 `repos` 与 §4 例外名表移出 `whalemate`；§4 由 54 行降为 53 行（例外名 11 → 10，Train Case 43 不变），合计 64 → 63 仓（53 + 10 备份仓），`active` 26 → 25，`tool` 24 → 23。
2. **新增「待删除仓」显式状态**：`desired-state.json` 顶层增加 `pending_delete: ["whalemate"]`。语义是**已知远端存在、明确不纳入治理、计划删除**，既不是「未登记漂移」，也不是通用豁免清单。
3. **四处脚本识别该状态**：
   - `check-governance-consistency.sh`：读 `pending_delete`，从「远端有、desired-state 无」的未登记差集中扣除；并交叉校验另两个脚本内联的 `PENDING_DELETE` 名单与它逐项一致。
   - `check-repo-registry.sh`：`PENDING_DELETE` 跳过差集 B（未登记）与差集 C（§1 命名校验）。
   - `check-release-standard.sh`：本地残留目录不纳入发布规范审计；`EXCLUDED_FROM_RELEASE_STANDARD` 由 53 项降为 52 项（63 − 11）。
   - `audit-drift.py`：不计入未登记漂移，审计尾部单列「待删除仓（不登记）」。
4. **留痕**：`GOVERNANCE-EXCLUSIONS.md` 新增 §十二 待删除仓表（仓名 / 可见性 / 裁决日期 / 理由 / 落地位置），并同步 §三、§四 计数。

## 后果

- 台账 63 仓、§4 53 行；根 README 徽章与中英 alt、矩阵展示图换版 `readme-govgithub-3-20261121-r2.svg`（63 仓 / 53 行 / 例外名 10 + Train Case 43 / 合计 25-25-13）。
- 本地全量门禁保持 clean：一致性、registry、`audit-drift.py`（PASS 50 / SKIP 14 / DRIFT 0）均 rc=0；CI 走 `--public-only`，不受影响。
- 远端若在 GitHub 上删除，须**同一批次**从 `pending_delete` 与 §十二 表中移除该行并复跑门禁；因该仓已不计入台账，计数不再变化。
- `pending_delete` **不得**用于「想保留但不想治理」的仓：与 `repos` 重叠会被一致性脚本判 gap，且删除后必须出清。其他仓若需同类处理，逐仓出 ADR。
