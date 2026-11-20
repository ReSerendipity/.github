# ADR-0021：MirrorDuo 归档时入库根 AGENTS.md（§7.1 例外）

- 状态：Accepted
- 日期：2026-11-20
- 决策者：ReSerendipity（账号所有者，本会话明确指令「解除 ignore，push」「作为例外」）
- 关联：修订 **§7.1**（`AGENTS.md` 一律不入库）在单一仓库上的适用范围；落地于 `governance/desired-state.json` 的 `tracked_agents_allow`

## 背景

`MirrorDuo` 于 2026-11-20 按 §15.7 完成归档：仓内 README 先加统一声明块（`93e503c`），再 `gh repo archive`（实测 `isArchived=true`），治理台账 `lifecycle` 同步为 `archived`。归档后 owner 要求删除本地工作副本 `C:\Users\Doro\APP\repository\MirrorDuo`。

该仓 `AGENTS.md`（6.9 KB）按 §7.1 一直只存在于本地、不入库。删目录即永久丢失，而它承载的是**仓内知识**而非个人隐私：目录结构、构建与回归命令（`assets/build_html.py` 重建 `index.html`、`assets/snapshot.py` 18 个 fixture 逐值比对）、素材形态铁律（一组 = 动物↔人物隔 180°、每张图左右镜像）与 `preset` 设计取舍。

owner 在本轮明确指示解除 ignore 并推送，即要求该文件随仓保留，构成对 §7.1 硬规则的一次显式例外。

## 决策

1. **仅对 `MirrorDuo` 放开根 `AGENTS.md`**：`.gitignore` 去掉 `AGENTS.md` 与 `**/AGENTS.md` 两条，保留 `AGENTS.*.md` 忽略；`AGENTS.md` 以 `6d3ce72` 入库后立即重新归档。
2. **例外在台账登记**：`governance/desired-state.json` 中该仓增加 `"tracked_agents_allow": ["AGENTS.md"]`。该字段 `audit-drift.py` 已支持（`path.rsplit('/', 1)[-1] == "AGENTS.md"` 且未命中 allow 前缀即报 drift），无需改脚本。
3. **范围严格限定**：不适用于其他任何仓库；不改变 §7.1 对 `docs/AGENTS.md`、`local/AGENTS.md`、模块级 `AGENTS.md` 的禁止；不改变 §7.3 `self-purify.yml` 的默认行为与 §7.2 的 300 行上限口径。

## 后果

- 该仓 `AGENTS.md` 现为 tracked 文件，`git clone` 即可得；删除本地目录后无信息损失，`backup` 仍为 `github-only`，无需额外备份仓。
- 仓内 `.githooks/pre-push` 第 1 项仍按 §7.1 硬编码阻断「误跟踪 AGENTS.md」，故本次推送使用 `--no-verify` 并在提交信息与本 ADR 中记录理由；若将来解档后再推送，需显式绕过或改造该 hook（届时另议）。
- `audit-drift.py` 对 `archived` 仓本就跳过 §7.1 该段检查，日常 drift 审计不受影响；若解档，`tracked_agents_allow` 会继续放行该前缀，不会产生 DRIFT。
- 该例外**不可作为先例引用**：其他仓库若需同类处理，须另行出 ADR 并由 owner 逐仓确认。
