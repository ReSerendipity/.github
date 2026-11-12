# ADR-0019：自进化台账纳入版本控制

- 状态：Accepted
- 日期：2026-11-12
- 决策者：ReSerendipity（账号所有者）
- 相关：取代 **ADR-0013 第 5 条**（「台账均为本地文件、不入远端」）；修订 **§13.1** 的 `local/` 容器模板与「目录级一条规则、永不增长」；承接 **ADR-0012 第 2/5 条**（路径优先 `local/agents/`、缺台账者新建）；不改动 **§7.1**（根 `AGENTS.md` 仍仅本地保留）

## 背景

2026-11-12 的 README 展示图整改轮里，`DraftPeek` 的一笔 `.gitignore` 变更被 pre-push 的 ledger-gate 拦下，要求「GOTCHAS 须新增一行」。按闸口要求补行后再 `git add` 被拒：该仓台账位于 `docs/agents/`，而 `.gitignore` 里有 `docs/agents/`。顺查全库得到三个事实：

1. **17 个仓的台账全部不入库**——`local/agents/`（16 仓）或 `docs/agents/`（DraftPeek）都在 ignore 覆盖内，跟踪数为 0，远端 404。闸口要求「补一行」，补的是**本机文件**：知识既不进仓也不上 GitHub，换机即丢，且多人协作时他人看不到任何坑点。
2. **6 个仓连台账都不存在**（`BookSpine-Wall`、`MirrorDuo`、`OrbitCube`、`Prompt-Provenance`、`Scan-Memories`、`TTS-MultiModel`）。`check-ledger-append.ps1` 的 `Resolve-Ledger` 只查 `local/agents/` 与 `docs/agents/` 两级，找不到就打印「台账缺失，跳过」并 **exit 0**——即这 6 仓的自进化门禁是**静默关闭**的，不报错、不拦人。
3. **`TTS-MultiModel` 的台账活着但放错路径**：`local/agents/_migration/migrate_gotchas.py:27` 声明输出到 `docs/agents/GOTCHAS.md`，而该目录已不存在；实际文件在 `local/docs-archive/agents/GOTCHAS.md`（270 KB / 169 行 / 156 条，2026-11-03 仍在追加）。它既不在闸口的查找路径里，也不在任何人的视野里。

同时，把 `local/agents/` 从忽略里放出来时踩到一个非显然的技术事实：**git 无法在父目录被排除时重新包含其子文件**。`/local/` + `!local/agents/GOTCHAS.md` 实测无效（`git check-ignore` 仍命中 `/local/`，`git add -n` 直接拒绝），必须改成「排除目录内容 + 逐级反包含」的四段式。这与 §13.1 原句「目录级一条规则、永不增长」直接冲突。

## 决策

1. **台账入库**：`GOTCHAS.md` 与 `REVISION_LOG.md` 纳入版本控制并推送远端。其余 `local/` 内容（`README.internal.md`、实验记录、`_migration/`、`.ledger-baseline.json`、各类内部文档与素材清单）**继续仅本地**，`.gitignore` 仍须挡住。
2. **`.gitignore` 统一模板改为四段式**（§13.1 同步修订，取消「永不增长」表述）：

   ```gitignore
   /local/*
   !/local/agents/
   /local/agents/*
   !/local/agents/GOTCHAS.md
   !/local/agents/REVISION_LOG.md
   AGENTS.md
   ```

   存量形态按各自写法等价改写：`local/`（无前导斜杠）、`/local/*`（已是内容级，只补后三段）、`docs/agents/`（该目录即目标，写 `docs/agents/*` + 两条反包含）。
3. **`AGENTS.md` 边界不变**：§7.1 的「仅本地保留」继续适用，本 ADR **不**放开 `AGENTS.md`；`docs/agents/` 形态的仓（DraftPeek）只放行两份台账，同目录其它文件（如 `CODE_STYLE.md`）仍忽略。
4. **缺台账者按模板新建**：ADR-0012 第 5 条的既有要求，本轮落地——6 仓补建。新建只复制模板正文，**禁止编造坑点条目或填假日期**；坑点必须来自真实踩坑。
5. **放错路径者归位**：`TTS-MultiModel` 的台账自 `local/docs-archive/agents/` 复制到 `local/agents/`（闸口可发现），归档原件保留不删；其头注释里指向已消失的 `docs/agents/GOTCHAS.md` 一并改正并注明归位日期。
6. **§13.1 Q1 的冲突用「脱敏 + 登记」解决，而非豁免**：Q1 把 `C:\Users\Doro` 列为「敏感或本机环境细节 → 仅本地」。台账正文含此类路径者共 **4 仓 10 行**（公开仓 `DraftPeek` 2 / `SpiritPal` 6，私有仓 `Agent-Knowledge` 1 / `rewq` 1）。处置：把 `C:/Users/Doro` 改写为 `%USERPROFILE%` 占位符（与 MACHINE-PATH 门禁既有口径一致），并在各仓台账表尾**追加一行迁移记录**，写明改动行号、改前改后与触发条款。这既满足 Q1，又不违反「不删不改历史行」——因为改动被显式登记而非静默发生，与 ADR-0013 第 2 条处理 Image-DuoModel 乱码的手法同构。
7. **基线刷新为收尾必做**：沿用 ADR-0013 第 4 条——台账行数变化后，对每个受影响仓跑 `check-ledger-append.ps1 -Root <repo>`（**不带 `-Enforce`**）重写 `local/agents/.ledger-baseline.json`。注意 GOTCHAS #11 的坑：带 `-Enforce` 在有未推提交的工作树上预跑会把基线推高，导致真推送反被拦。

## 后果

- 坑点开始跨机、跨会话、跨协作者可见；换机或重装后不再归零。
- 6 仓的 ledger-gate 从「静默跳过」变为生效；`.ledger-baseline.json` 首次生成时闸口会初始化并放行一次，此后严格判 `>`。
- 公开仓的坑点成为世界可读内容。发布前已按 §13.1 Q1 做过全量扫描：**无 token / 密钥 / 口令 / 连接串**，`@` 命中全部是 `pixi-live2d-display@0.4.0`、`reqwest@0.12.28` 这类「包名@版本」，IP 命中全部是 `127.0.0.1`、`10.0.2.2`（Android 模拟器宿主别名）、`999.1.1.1`/`224.0.0.0`（SSRF 单测样本），唯一实质暴露项是用户名，已按第 6 条脱敏。
- 代价：`local/` 容器规则从 1 条变 5 条，后续若要再放行别的文件，必须沿用四段式而不是往 `/local/` 上叠否定行（叠了不生效）。
- 代价：台账入库后，「追加一行」成为可被他人审查的公开动作，凑数行更容易被发现——这是期望中的副作用。

## 不采用

- 只改闸口、不改 ignore：闸口要求补行而补的行永远不入库，等于把门禁变成对本地文件的仪式。
- 把整个 `local/` 放开：会把 `README.internal.md`、`nsfw-levels.md`/`image-prompts.md`（Prompt-Library）、`admin-site-defaults.md`（rewq）、SpiritPal 的 ADR 与 `SOPS.md`、以及机器本地的 `.ledger-baseline.json` 一并公开。
- 在 `/local/` 后直接加 `!local/agents/GOTCHAS.md`：父目录已被排除，反包含无效，实测 `git add` 仍被拒。
- 静默改掉 10 行机器路径而不登记：违反台账「不删不改历史行」。
- 用 `[skip-ledger]` 或 `--no-verify` 绕过闸口：只治当次，且把「代码变更须留坑点」这条自进化机制掏空。
