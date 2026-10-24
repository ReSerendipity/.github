# ReSerendipity 仓库治理规范

本文件是账号 `ReSerendipity` 下**所有仓库的命名与治理权威依据**。新建仓库、重命名仓库、配置分支保护前，先读本文件。

---

## 1. 命名规范（Repository Naming Convention）

账号下所有仓库统一采用 **Train Case（单词首字母大写 + 短横线分隔）**：

- 每个独立单词首字母大写：`Image`、`MultiModel`、`KeyBackup`
- 单词之间用短横线 `-` 连接：`Image-MultiModel`
- **禁止**：下划线（`Image_MultiModel`）、全小写连写（`image-scrapers`）、无分隔长串（`WebsiteZenlessZoneZero`）

示例（正确）：
- `Image-MultiModel`
- `TTS-MultiModel`
- `Website-Genshin-Impact`
- `DraftPeek-KeyBackup`

例外（保持连写，不加短横线）：
- 品牌/专有词：`Unity`、`SpiritPal`、`GalgameShell`、`DraftPeek`、`ReSerendipity`
- 系统保留名：`.github`
- 技术缩写按惯例保留大写：`TTS`、`RTX`、`VSR`、`H3`、`DL`、`CI`、`ComfyUI`

密钥备份仓固定格式：**`<项目名>-KeyBackup`**，且必须为私有仓库。

### 1.4 命名台账与本地一致性（原 §4、§6）

- 现网命名台账以 **§4 表**为唯一数据源（39 行：8 个例外名 + 31 个 Train Case）；新增 / 改名先改 §4，再改远程。
- 本地克隆目录名必须与远程逐字符一致；远程重命名三步见 **§6**。
- 命名例外须先落 ADR，再改 §4；§4 表由 `check-repo-registry.sh` 对账。
- 本节是 §4 与 §6 的归口；两节保留原编号，分别作为数据附表与执行细则。

## 2. 分支规范（Branch Convention）

- 所有仓库默认分支统一为 **`main`**（不使用 `master`）。**2026-10-19 起全账号达成**：最后一个 `master`（`ComfyUI-BatchPromptLoader`）已迁移（同 commit 建 `main` → PATCH 默认分支 → 删 `master`，workflow 无 `master` 硬编码，文档引用随 PR #5 同步）。
- `main` 分支受保护 —— **逐仓实测已完成（2026-10-19，41 仓全量，取数口径见下，零无法判定）**：
  - 本仓 `.github`：2026-10-17 此前实测为 `404 Branch not protected` + `rulesets: []`（即毫无保护），现已配置经典分支保护并回读确认 `protected=true`，必需检查为 `Workflow lint (actionlint + YAML)`、`DCO sign-off (Signed-off-by)`、`Reusable workflow smoke (self-purify) / 自净化核心规则（阻断）`、`Repository registry (§4 vs GitHub)` **四项**（第四项 2026-10-18 新增，见 §4），且禁止 force push 与删除分支。
  - **`enforce_admins=false`，这是有意的**：本账号是个人账号，若设为 true 会连账号本人都无法直推 `main`，与下面第一条既有约定冲突。代价必须写明白——**保护不约束账号本人**，本人仍可绕过上述四项；对非管理员协作者与 force-push/删除操作才是真约束。要让它也约束本人，需同时改写本节，属单独决定。
  - **账号本人（Doro / ReSerendipity）可直接推送**，跳过 PR 流程；
  - **其他协作者一律走 Pull Request**，不得直接推送 `main`。
  - **实测结果（2026-10-19）**：**11 仓 `protected=true`**——`.github`、`ComfyUI-Experiment-Toolbox`、`DraftPeek`、`GalgameShell`、`Github-Repo-Scan`、`Image-DuoModel`、`MiniMax-H3-Lite`、`ReSerendipity`、`SeedVR2-Lite`、`SpiritPal`、`TTS-MultiModel`（恰为有活跃 CI / 发布链的仓 + 规范仓自身）；**其余 30 仓 `protected=false`**。其中 23 仓属排除清单（2026-10-19 豁免升级：不适用整个规范，**无需保护考量**），故**待立项候选实为 7 仓**：`Agent-Knowledge`、`Card-Studio`、`Health-Info-Card`、`Image-Scrapers`、`Lineart-Painter`、`Nekogal-DL`、`Prompt-Library`（2026-10-21 第四轮豁免后，`Card-Studio` / `Health-Info-Card` / `Lineart-Painter` 已入排除清单，**待立项候选实为 4 仓**：`Agent-Knowledge`、`Image-Scrapers`、`Nekogal-DL`、`Prompt-Library`）。是否批量配置保护（同 `enforce_admins=false` 口径）属**待立项决定**，未配置前 GitHub 侧不会拦截直推 `main`。
  - 取数口径：公开仓返 404/空数组＝确无保护；私有仓在免费档下这两个请求返 403＝**无法判定**，不得据此写「未保护」。已配置后再判，须看 `branches/main` 的 `protected` 与 protection 回读的 `contexts` 数量，别只看有没有 404。本轮用 `GET /repos/<owner>/<repo>/branches/<default>` 的 `protected` 字段（认证态），41 仓全部返回明确布尔值，零 403。
- **Ruleset 基线（2026-10-21 新增，按可见性分流）**：
  - **公开仓**统一启用两个 ruleset：`governance-baseline`（branch：`deletion` + `non_fast_forward` + `pull_request` + `required_status_checks`，检查名只填实测近 60 天成功过的项）与 `tag-protection-v`（tag：`v*` 的 `deletion` + `non_fast_forward` + `update`）。
  - **私有仓不启用 ruleset**：GitHub Free 对私有仓的 rulesets API 返回 `403 Upgrade to GitHub Pro`；**经典分支保护同样 403**（2026-10-21 实测 `PUT /branches/main/protection` on `Agent-Knowledge` → 403）。2026-10-21 用户裁决——**不为此升级计划、不做替代改造**，服务器侧保护对私有仓不可用，记为**平台能力缺口而非欠账**；替代控制是各仓本地 `.githooks/pre-push`（已有多仓在跑）与本地预检脚本。将来升级 Pro 后，ruleset 按同一 JSON 补发，经典保护按需补配。
  - 已下发范围（2026-10-21 实测）：9 个公开管辖仓 branch+tag；`ReSerendipity` 保留既有等价 branch 规则（id 25288027）并补 tag。私有仓 4 个（`Agent-Knowledge`、`Image-Scrapers`、`Nekogal-DL`、`Prompt-Library`）按上条跳过。
  - **按 lifecycle 分档（2026-10-22 新增，ADR-0006）**：`active` 的公开仓必须同时具备 `governance-baseline` 与 `tag-protection-v`；`maintenance` 只要求默认分支 `main` 与 `delete_branch_on_merge=true`（已配置的 ruleset 保留，不强制新增）；`archived` 不要求任何服务器侧保护。
- 功能开发使用独立分支（`feat/*`、`fix/*`、`ci/*`、`chore/*`），完成后合入 `main`。
- **合并后自动删除源分支（2026-10-20 新增）**：所有仓库必须将 GitHub 仓库级开关 **`delete_branch_on_merge` 设为 `true`**——PR 合并后由 GitHub 自动删除 head 分支，不依赖合并者手动加 `--delete-branch`（该参数易被遗漏，实测曾导致 13 仓积压 23 条已合并分支）。
  - 开关为**仓库级设置**，不是分支保护字段：`PATCH /repos/<owner>/<repo>` 的 `delete_branch_on_merge`。取数口径：`GET /repos/<owner>/<repo>` 的 `delete_branch_on_merge` 字段。
  - **不得删除的分支**：默认分支 `main`、Pages 部署目标 `gh-pages`、release-please 工作分支 `release-please--branches--main`（合并后由机器人自行重建，删除属正常行为）、以及刻意命名的归档/备份本地分支（`archive/*DO-NOT-PUSH*`、`backup/*`）——这些是**保留对象**，不是"漏删"。
  - **清理判据**：squash 合并会使分支不再是 `main` 的祖先，`git merge-base --is-ancestor` **不可作为判断依据**；应以其**关联 PR 状态为 `MERGED`** 为准。
  - 存量清理：开关开启后，已合并的残留分支需一次性清理（2026-10-20 已执行：13 管辖仓 23 条 + `.github` 12 条）。
  - 排除清单（`GOVERNANCE-EXCLUSIONS.md` 29 项）不适用本规范，不强制开启；已开启的一律保留。
- 本地与远程命名保持一致；远程重命名后需同步本地 remote URL。

## 3. 密钥与敏感信息备份规范（Secret Backup）

- 含有发布签名密钥 / 私钥的项目（Tauri rsign key、RSA key、JKS 等），密钥**不得入库**（.gitignore 忽略）。
- 备份模式：私有仓库 **`<项目名>-KeyBackup`**，内含：
  - 加密包 `*.enc.7z`（7-Zip AES-256，`-mhe=on` 加密文件头）
  - `README.md`（说明用途与恢复步骤）
  - `SHA256SUMS.txt`（校验清单）
- 口令**不放入仓库**，另行安全保管。
- 双保险：远程私有仓 + 本地加密副本。
- 参考实现：`DraftPeek-KeyBackup`（该模式的原型）。

## 4. 现网仓库命名对照（§1.4 数据附表，2026-10-24 更新，39 行）

### 例外名（品牌 / 系统保留名 / 已登记命名债务，8 个）

> **何为例外名**：已对外使用、改名代价高于规范收益的名字（外链、徽章、搜索结果、用户记忆都会断）。
> `.github` 属 GitHub **系统保留名**；`Code-Time-Machine-1024` 是**已登记债务**，
> 因 `1024` 为活动品牌长期保留。

| 仓库 | 可见性 | delivery | 例外依据 |
|---|---|---|---|
| SpiritPal | public | release | 品牌连写（§1） |
| GalgameShell | public | tool | 品牌连写（§1） |
| DraftPeek | public | release | 品牌连写（§1） |
| ReSerendipity | public | content | 品牌兼账号名（§1） |
| Unity | private | tool | 品牌专有词（§1） |
| rewq | private | service | 历史品牌名；按 §15.5 `credentials` 管理 |
| .github | public | policy | 系统保留名（§1） |
| Code-Time-Machine-1024 | public | service | `1024` 为活动品牌，长期登记 |

### Train Case（31 个）

| 仓库 | 可见性 | delivery |
|---|---|---|
| Agent-Knowledge | private | content |
| Android-IconAutoArrange | public | release |
| Bilibili-Follow-Manager | private | tool |
| Card-Studio | public | release |
| ChatGPT-Timezone-Fix | public | tool |
| ComfyUI-BatchPromptLoader | public | tool |
| ComfyUI-Experiment-Toolbox | public | tool |
| Free-Model-Probe | public | service |
| Github-Repo-Scan | public | tool |
| Health-Info-Card | public | release |
| Hugging-Face | private | tool |
| Image-DuoModel | public | release |
| Image-Scrapers | private | tool |
| Lineart-Painter | public | release |
| MiniMax-H3-Lite | public | release |
| MiniMax-H3-Lite-Local | private | tool |
| Mooncake-Deconstruction | public | service |
| Multi-Tracker | public | tool |
| Nekogal-DL | private | tool |
| Offer-Landing-Kit | public | service |
| P0-Murder-Mystery | public | service |
| Prompt-Library | private | content |
| RTX-VSR-Lite | public | library |
| SeedVR2-Lite | public | release |
| TTS-MultiModel | public | release |
| Unfading-Wall | public | service |
| Website-Genshin-Impact | private | service |
| Website-Honkai-Star-Rail | private | service |
| Website-Site-Toolchain | public | tool |
| Website-Wuthering-Waves | private | service |
| Website-Zenless-Zone-Zero | private | service |

> 已登记命名例外（品牌与待改名债务，不参与 §1 命名校验）：rewq、Code-Time-Machine-1024
>
> 2026-10-24 变更：新增 `Website-Site-Toolchain`（public / tool / active，2026-10-23 创建的结构签名门禁工具链），本表 38 → 39 行，Train Case 30 → 31；总数 45 → 46。
>
> 2026-10-23 变更：新增 `MiniMax-H3-Lite-Local`（private / tool / maintenance），本表 37 → 38 行，Train Case 29 → 30；总数 44 → 45。
>
> 2026-10-22 变更（两轴模型落地，ADR-0006）：本表由 19 行扩为 37 行 = 全部非 `backup` 仓，7 个备份仓退出本表；
> 例外名独立成表（9 行），不再依赖「豁免清单」隐藏命名问题。此前四轮豁免历史见 `GOVERNANCE-EXCLUSIONS.md`。
>
> 2026-10-22 改名：`p0-murder-mystery` → `P0-Murder-Mystery`（`gh repo rename`，旧名保留重定向），
> 从例外名表转入 Train Case；例外名 9 → 8，Train Case 28 → 29，总数仍 37。

> 2026-10-13 变更：`agent-knowledge` → `Agent-Knowledge`、`prompt-library` → `Prompt-Library`（远程 + 本地均已改名，旧名保留重定向）。
>
> 2026-10-16 变更：`Image-MultiModel` → `Image-duoModel`（远程已改名，旧名保留重定向，本表此前未跟上）；补入此前完全未登记的 `Android-IconAutoArrange`、`Free-Model-Probe`、`chatgpt-timezone-fix`；本节标题条数由 27 修正为实际 32 行。
>
> 2026-10-17 变更：`chatgpt-timezone-fix` → `ChatGPT-Timezone-Fix`（`gh repo rename`，同一仓库 id 1421498928，旧名保留重定向；本机无该仓克隆，故 §6 的目录同步三步不适用）。
>
> 2026-10-17 变更：`Image-duoModel` → `Image-DuoModel`（`gh repo rename`，同一仓库 id 1329392361；改名前后 `pushed_at=2026-10-17T03:21:29Z` 未变，据此判定无并发写入）。本机克隆目录 `Image-MultiModel` 与 remote URL 已按 §6 三步一并校正为 `Image-DuoModel`。旧名 `Image-duoModel` / `Image-MultiModel` 均保留 GitHub 重定向，外链不断。**命名不合规欠账至此清零**，§4 检查脚本不再需要任何命名欠账豁免行。
>
> 取数口径：`GET /users/ReSerendipity/repos` 只返回公开仓，标为 `private` 的行无法由该端点证实或证伪，本轮未逐一复核（含三个 `-KeyBackup` 仓与 `Image-MultiModel-KeyBackup` 这条沿用旧项目名的条目）。任何"可见性/存在性"结论都要现场重取。
>
> 2026-10-19 变更：`Image-MultiModel-KeyBackup` → `Image-DuoModel-KeyBackup`（`gh repo rename`，父仓 `Image-MultiModel` → `Image-DuoModel` 两轮改名后，备份仓名按 §3 模式 `<项目名>-KeyBackup` 跟进对齐；旧名保留 GitHub 重定向，实测旧名请求返 200）。
>
> 2026-10-19 变更（**豁免升级**，用户裁决）：**排除清单 17 项由「不适用 §10」升级为「不适用整个 REPOSITORY_GUIDELINES.md（§1-§11；2026-10-21 起随 §12-§14 新增，现行范围已扩至 §1–§14）」**。据此从本表移除 10 行：`Unity`（保留名）、`Multi-Tracker`、`Unfading-Wall`、`ComfyUI-BatchPromptLoader`、`Bilibili-Follow-Manager`、`Hugging-Face`（用户点名豁免 6 个中的 5 个短横线名）与 4 个 `*-KeyBackup`；保留名 6→5、短横线 32→23，全表 38→28 行。被移除仓不再参与 §1 命名校验与差集 B/C（脚本 `EXCLUDED_FROM_REGISTRY` 扩至 13 项），其存在与豁免语义由脚本声明与本仓 `GOVERNANCE-EXCLUSIONS.md` 承载。**已交付产物（发布文档、CHANGELOG、流水线）一律保留。**
>
> 2026-10-19 变更（**第二轮豁免**，用户裁决）：`Mooncake-Deconstruction`、`Offer-Landing-Kit`、`Android-IconAutoArrange`、`Free-Model-Probe`、`ChatGPT-Timezone-Fix`、`RTX-VSR-Lite` 六仓加入豁免清单（共 23 项）。本表再移除 6 行：短横线 23→17，全表 28→22 行；脚本 `EXCLUDED_FROM_REGISTRY` 扩至 19 项。
>
> 2026-10-18 追加：**备份仓 / 非台账副本不进本对照表**——`rewq`（非台账副本）、`Android-IconAutoArrange-Assets-Backup`（资源备份仓）、`Android-IconAutoArrange-KeyBackup`（密钥备份仓）三者未登记于此（2026-10-19 起表内也不再有任何 `*-KeyBackup` 行，本原则完全成立）。**豁免语义（2026-10-21 第四轮后）**：排除清单 29 项整体豁免整个规范；脚本 `EXCLUDED_FROM_REGISTRY`（25 项）承载「台账 + 命名」维度的豁免载体——两者同源，不可只改一处。
>
> 2026-10-20 变更（**第三轮豁免 + 备份仓补录**，用户裁决）：`Code-Time-Machine-1024`（当日新建的 TRAE 1024Builder 展示站；远程实名即此大写形式）与 `SpiritPal-KeyBackup`（§3 密钥备份仓，2026-10-20 新建、此前遗漏）加入豁免清单（**共 25 项**），**均不登记本表**；脚本 `EXCLUDED_FROM_REGISTRY` 扩至 **21 项**、`EXCLUDED_FROM_RELEASE_STANDARD` 扩至 **25 项**。用户同时裁决：**密钥/资产备份仓按性质即须豁免，不需逐仓审批**。`Code-Time-Machine-1024` 的分段 `1024` 以数字开头、不合 §1 Train Case，因整体豁免不作整改；撤销豁免前须先改名并补登本表。
>
> 2026-10-21 变更（**第四轮豁免**，用户点名）：`p0-murder-mystery`、`Health-Info-Card`、`Lineart-Painter`、`Card-Studio` 四仓加入豁免清单（**共 29 项**，均为 public），**均不登记本表**；本表再移除 3 行（后三者原登记于短横线节，`p0-murder-mystery` 此前未登记）：短横线 17→14，全表 22→19 行。脚本 `EXCLUDED_FROM_REGISTRY` 扩至 **25 项**、`EXCLUDED_FROM_RELEASE_STANDARD` 扩至 **29 项**。语义：不适用整部规范，已交付产物一律保留。
>
> 2026-10-18 新增：本节对照表已从「本地命令手工跑」改为**远端 CI 门禁**——`ci.yml` 的 `repo-registry` 作业在任何 PR 与本仓推送时自动对账，并挂 `schedule` 周检（周一 03:00 UTC），覆盖「本仓无改动、台账却被外部动作改漂移」的场景。脚本与退出码口径不变（1=有差集，2=无法判定，两者都判红），本机不再需要跑它。该作业同时是 `main` 的必需检查之一（见 §2）。

## 5. 变更流程

- **新建仓库**：先跑 `.github/scripts/scaffold-repo.sh <Repo-Name> [--private|--public] [--delivery release|service|tool|content] [--create-remote]` 生成骨架（README 含治理引用、CHANGELOG、`docs/release-governance.md`、`.gitignore`、`.githooks/pre-push`，并设 `core.hooksPath`），再按脚本打印的五处清单补治理文档。**不要先手搓目录**——骨架漏项是最常见的返工来源。
- 重命名仓库：先改远程（`gh repo rename`，旧名保留重定向），再同步本地目录与 remote URL，详细步骤见 §6。
- 本地目录被占用（进程/Agent 活动）时不强行改名，等待释放后处理。
- 本规范变更需同步更新 `.github` 仓库中的本文件与 README 索引。

## 6. 本地目录与远程仓库一致性（§1.4 执行细则，2026-10-13 新增）

- 本地克隆目录名必须与远程仓库名**逐字符一致**（含大小写）：远程 `Image-Scrapers` ↔ 本地 `Image-Scrapers`。
- 远程重命名后本地同步三步：
  1. `gh repo rename <新名> -R <owner>/<旧名>`（GitHub 旧名自动重定向，外链不断）；
  2. 本地更新 remote URL：`git remote set-url origin https://github.com/<owner>/<新名>.git`；
  3. 本地目录改名（Windows 文件系统大小写不敏感，须两段式：`mv Old Old.__tmp__ && mv Old.__tmp__ New`）。
- 重命名后仓库内引用旧名的位置需同步更新：文档（README）、`.github/CODEOWNERS`、hooks、CI 配置。
- 已知历史偏差（2026-10-13 已全部对齐）：`image-scrapers`→`Image-Scrapers`、`MiniMax-H3-lite`→`MiniMax-H3-Lite`、`SeedVR2-lite`→`SeedVR2-Lite`（仅本地）；`prompt-library`→`Prompt-Library`、`agent-knowledge`→`Agent-Knowledge`（远程 + 本地）。
- 2026-10-17 追加对齐：远程 `Image-MultiModel` 经 `Image-duoModel` 两次改名后定为 `Image-DuoModel`；本机克隆目录与 remote URL 已按本节三步同步为 `Image-DuoModel`。

## 7. AGENTS.md 治理（单一本地文件 / 自进化 / 拆分）

**定位**：每个仓库只有一个根 `AGENTS.md`，只在本机保留、不入库；需要沉淀的细节拆到 `local/agents/**`，不产生第二个 `AGENTS.md`。

### 7.1 归属与入库

- 每个仓**只有一个** `AGENTS.md`，位于仓库根目录；嵌套/模块级 `AGENTS.md` 一律不建、不入库。
- `AGENTS.md` **一律不入库**：在仓库**现有** `.gitignore` 中增加 `AGENTS.md`（无斜线模式，匹配任意深度），**不得删除或覆盖**密钥、大文件、构建产物、`local/` 等既有规则；不再有 `!/AGENTS.md` 白名单。
- 公开仓与私有仓同一口径：`AGENTS.md` 是本地维护者上下文，私有仓也不上传 `AGENTS.md`。
- 公开可分发入口是 `docs/agent-contract.md`（tracked，逐字节复制模板）与根 `README.md`；fresh clone / CI / 协作者环境中没有 `AGENTS.md` 属预期。
- 私有仓的备份对象是非 `AGENTS.md` 的本地上下文（`local/agents/**`、`FIX_LOG.md` 等）；是否上传按各仓现有 `.gitignore` 与本节执行。
- 误入库恢复：`git rm --cached AGENTS.md` + `.gitignore` 写 `AGENTS.md` + commit + push；本地文件保留。
- **迁移欠账（2026-10-23）**：存量已跟踪的根 `AGENTS.md` 需按上述流程逐仓移除；迁移完成前 `self-purify.yml` 暂不翻转，避免 26 个非归档仓同时红（另有 11 个归档仓也跟踪 `AGENTS.md`，按只读处理，迁移需先 unarchive）。清单由长任务审计输出。

### 7.2 质量标准

- **行数上限**：根 `AGENTS.md` ≤**300 行**（唯一硬阈值）；拆分后的 `local/agents/<module|task>.md` 单文件建议 ≤300 行，超过继续按主题拆分。
- **最小结构**：至少含「开工前」「硬约束」「交付前」「索引」四块；可在此基础上增加快速命令、禁区、已知坑、架构地图等章节。
- **单一职责**：全仓规则只写根文件；拆分文件只写本模块/任务内容，不复制全仓规则。
- **时效性**：文首维护「最后更新 / 对应版本」；目录结构或发布版本变化后同步更新。
- **引用可解析**：文中出现的仓内路径必须真实存在；引用 `local/` 文档时标注「本地文档，未随仓库发布」。
- **本地安全**：虽然不入库，仍不得把密钥、token、口令写进 `AGENTS.md`；需要记录位置时只写指路。
- **vendored / 上游子目录**：自带嵌套 `.git` 的第三方目录不纳入本节；其 `AGENTS.md` 归上游。

### 7.3 执行载体

- **入库侧**：`self-purify.yml` 的目标规则是阻断任何被跟踪的 `AGENTS.md`；存量迁移完成后再翻转（见 §7.1 迁移欠账）。
- **契约一致性**：`audit-drift.py` 比对仓内 `docs/agent-contract.md` 与 `governance/templates/agent-contract.md`，不一致判红。
- **行数检查**：`.github/scripts/check-agents-md-size.sh` 默认上限 300，检查根 `AGENTS.md` 与 `local/agents/*.md`；非 CI 门禁。
- **脚手架**：`scaffold-repo.sh` 生成根 `AGENTS.md`（本地文件）并写入新仓最小 `.gitignore`（`/local/` + `AGENTS.md`）；密钥、大文件、构建产物等规则由各仓按 §3/§9 继续追加，不是替换整个 `.gitignore`。
- **调用**：`bash .github/scripts/check-agents-md-size.sh --root <仓库目录>`；可挂本地 `pre-commit`。
- **扫描口径**：只算活动文件，排除归档/备份副本、生成目录与嵌套 git 仓；`--include-nested` 显式纳入。

### 7.4 自进化协议

**触发条件（任一命中，任务收尾时必须处理）**：

1. 同一失败签名第二次出现；
2. 新验证出可复用的命令 / 构建 / 测试 / 发布路径；
3. 目录结构、依赖版本、平台约束变化；
4. 用户对同一做法纠正 ≥2 次或给出长期偏好；
5. 新增安全 / 合规 / 平台硬约束。

**写到哪里**：

| 内容 | 位置 |
|---|---|
| 根入口、硬约束、交付前、索引 | 根 `AGENTS.md`（≤300 行，本地） |
| 模块 / 任务细节 | `local/agents/<module\|task>.md`（本地） |
| 踩坑台账 / 失败签名 | `local/agents/GOTCHAS.md`（本地） |
| 公开安全的最小契约 | `docs/agent-contract.md`（tracked，逐字节模板） |
| 一次性日志、调试过程、机器绝对路径 | 不入库，留在 `local/` 或删除 |

**单条记录格式**（缺任一项视为未沉淀）：

- 日期 + 稳定编号；
- 触发场景 / 现象（可检索的报错原文或命令）；
- 根因（一句话）；
- 正确做法 / 命令；
- 证据（commit、run id、日志路径）；
- 适用范围与复核日期；
- 失败签名 `[sig:<kebab-case>]`。

**变更流程**：

1. 先验证，禁止把猜测写成规范；
2. 只追加或精修，不静默改写硬约束 / 安全条款 / 治理规则；改治理口径先提 ADR；
3. `AGENTS.md` 与拆分文件是本地文件，不走 PR；`docs/agent-contract.md` 变更按 §17.2（作者可直推，非作者走 PR + DCO）；
4. 同一事实只留一处权威来源；
5. 文首维护协议版本 / 最后更新 / 对应项目版本；
6. 归档仓按 §15.7 处理。

**个性化边界**：各仓可增加架构地图、常用命令、领域术语、模块边界、已知坑；不得删减根文件四块；不得复制别仓路径 / 账号 / 端口 / 模型名。

**参考实现**：DraftPeek 的本地 `AGENTS.md`（自进化协议 v1.2）+ `local/agents/GOTCHAS.md` + `FIX_LOG.md`（失败签名 → 假设 → 动作 → 结果）。

**定期收敛**：每个 Release 或至少每月复核，删除失效条目、合并重复签名、上提稳定结论、清理一次性内容。

### 7.5 拆分规则与标注

**触发阈值**：根 `AGENTS.md` > 300 行；某章节只对一个模块 / 任务有效；根文件需要跳转才能读完。

**拆分去向**：统一进 `local/agents/`：

- 模块：`local/agents/<module>.md`
- 任务：`local/agents/<task>.md`
- 排障：`local/agents/GOTCHAS.md`

禁止新增第二个 `AGENTS.md`。

**参考实践（2026-10-23 调研）**：

- [AGENTS.md 开放格式](https://agents.md/)把它定位为「给 agent 的 README」，根文件保持短小；
- [OpenAI Codex](https://github.com/openai/codex)支持从根到当前目录逐级读取嵌套 `AGENTS.md`，越深优先级越高，默认合并上限 32 KiB；
- [Claude Code memory](https://code.claude.com/docs/en/memory)建议单个指令文件 <200 行，超出后用 imports / path-scoped rules 做渐进披露；
- 社区经验：先合并重复条目，再按「每个任务都要看 / 只在某类任务看」二分；根文件常见控制在 50–150 行。

本账号适配：公开仓不跟踪嵌套 `AGENTS.md`，所以用 `local/agents/<module|task>.md` + 根索引实现同样的分层；**300 行是硬上限，推荐控制在 150 行以内**。

**根文件只做路由器**，保留四块：`开工前`、`硬约束`、`交付前`、`索引`。索引表固定列：`文件 | 来源章节 | 管什么 | 什么时候读 | 最后更新`。

**完整标注（强制）**：每个拆分文件头部必须包含：

```markdown
<!-- agents-split
source: AGENTS.md#<section-anchor>
scope: <module|task>
owner: <repo/role>
updated: YYYY-MM-DD
-->
> 来源：根 `AGENTS.md` §X「章节名」｜范围：<module|task>｜最后更新：YYYY-MM-DD
> 上游入口：[根 AGENTS.md](../../AGENTS.md)
```

根索引必须同步增加一行；如果拆分文件被跟踪（私有仓上传），提交信息写 `拆分：AGENTS.md#<section> → local/agents/<file>.md`。

**拆分纪律**：

1. 只移动，不删内容；同批更新根索引与所有引用；
2. 不新增被跟踪的嵌套 `AGENTS.md`；
3. 单个规则只在一个文件里定义；
4. 根文件 ≤300 行，拆分文件建议 ≤300 行；
5. 读取顺序：根 `AGENTS.md` → `docs/agent-contract.md` → 根 `README.md` → 只读相关拆分文件；
6. agent 可自行拆分，但必须完成上述标注并跑 `check-agents-md-size.sh`；
7. 内容矛盾时以代码 / 配置与治理规范为准，同批修正。

## 8. README 双版本制度（2026-10-13 新增；2026-10-19 按可见性分流）

**本节适用范围：公开仓库。私有仓见下方例外。**

每个仓库有且仅有两份 README，分工如下：

| 文件 | 定位 | 是否入库（公开仓） |
|---|---|---|
| 根目录 `README.md` | **对外展示版**：这是什么、怎么用、怎么参与，面向 GitHub 访客 | 入库、GitHub 渲染 |
| `local/README.internal.md` | **对内维护者说明**：本地环境约定、部署细节、内部字段引用、实验产物清单、维护者备忘 | **不入库**（§13.1 `local/` 容器整体 ignore；2026-10-19 由 `docs/README.internal.md` 迁位） |

规则：

- **更新顺序（2026-10-23 定稿）**：默认只更新 `local/README.internal.md`；根 `README.md` 仅在用户明确要求时更新。对外版本更新时，必须同步检查安装 / 使用入口是否仍真实，避免“装修”掩盖失效。
- **对外版最低要求（公开仓根 README）**：
  - 至少中英双语（中文为主 + English summary 或完整英文段）；
  - 至少 1 张项目展示图片（截图 / 架构图 / 效果图），必要时加 GIF 或短视频链接；
  - 带 GitHub Topics 与 badges（CI、license、version / release 至少其一）；
  - 图片 / 视频 / GIF 使用仓库内相对路径或稳定公开链接，禁止本地绝对路径；
  - 功能、限制、许可证必须真实，不得用装修掩盖未实现能力。
- **对外版更新触发**：用户明确要求；或对外可见的安装 / 使用入口已失效且属于 §18 的死引用 / 状态问题。其余默认只改内部版。
- **引用与状态检查**：根 README 的链接、图片、badges、Topics、Release / 许可证状态在每次对外更新时检查；死链、失效 badge、过时版本判红（与 §18 联动）。
- 分流判据：**陌生用户读了能否行动**——能行动的写根 `README.md`；不能行动的一律进内部版，不得写回根 README。
- 判据落地三问（任一命中即进内部版）：① 是否必须使用本机路径 / 私有账号 / 内部数据才能照做？② 照做后能否得到可验证结果（装好、跑起来、配置生效）？③ 内容是否只对维护者有意义（实验记录、临时备忘、调试过程）？——**三问全否才写根 README**。
- 正例（留根）：安装与启动命令、环境变量表、端口与访问地址、Docker / APK / 桌面安装步骤、常见报错与处理。
- 反例（进内部版）：本机模型目录与盘符、内部账号与密钥、实验产物清单、维护者备忘、某次调试过程记录。
- **边界声明**：上述判据只约束**两份 README 之间**的分工；全仓文档放哪个目录（`docs/` 入库 vs `local/` 不入库）由 §13.1 规定，两者不互相替代。
- 内部版位置统一 `local/README.internal.md`（§13.1 `local/` 容器）；历史形态 `docs/README.internal.md` 与大写 `DOCS/` 变体均为旧位（`DOCS/` 历史 2026-10-13 已迁移 GalgameShell / Github-Repo-Scan；`docs/` 前缀 2026-10-19 起统一迁 `local/`）。
- 内部版不入库；已误入库的按 §7.1 恢复流程处理。
- 根 README 中的仓库链接与远程 URL 必须与实际仓库名大小写一致（例：Github-Repo-Scan 不得写 `github-repo-scan`）。
- **私有仓例外（2026-10-19 新增）**：私有仓不强制双版本分流，`local/README.internal.md` **应当入库**（与 §7.1 私有仓例外同理——尽可能上传作备份）；分流判据在私有仓仅作编写建议，不作入库闸。
- **`backup` 与 `archived` 仓的重构豁免（2026-10-22 新增）**：这两类仓不要求把 `local/README.internal.md` 入库，也不对既有 README 做双版本拆分；新建内容仍按判据书写。
- **对外版装修要求不追溯（2026-10-23）**：`backup` 与 `archived` 仓的既有 README 不强制补齐双语 / 图片 / badges；新增内容仍须真实、无死链。

## 9. 本地产物与依赖不进库（2026-10-13 新增）

- 本地 agent 工作目录一律 ignore：`.qoder/`、`.workbuddy/`、`.workbuddy-ai/`、`.trae/`、`.zcode/` 等。
- `node_modules/` 等依赖目录默认不入库；**例外**：私有仓可显式声明「全量备份」策略将依赖纳入版本管理（如 `Image-Scrapers`，其 `.gitignore` 注释中的策略记录为权威依据）。
- 注意：`.gitignore` 规则对**已跟踪**文件无效——事后添加 ignore 规则不会取消跟踪；真实排除须 `git rm -r --cached`，但若该跟踪本身是仓级既定策略，应保持跟踪。
- 运行时日志与扫描快照（`*.log`、`server.log`、`scan_run*.txt` 等）不入库，已有约定以各仓 ADR 为准。

---

## 10. 发布 / 分发统一规范（Release / Package / Deployment，2026-10-18 新增）

本节把此前散在各处的发布口径收敛为**一条标准**，同时覆盖 **release（发布）、package（打包）、deployment（部署）** 三类：源头是 Image-DuoModel / SeedVR2-Lite / TTS-MultiModel 的三份 `docs/release-governance.md`、DraftPeek `docs/VERSIONING.md`，以及各仓的 `release.yml` / `docker-publish.yml` / `pages-deploy.yml`。

> **范围声明（2026-10-19 更新）**：**已完成对账号内现存仓库的下发**——共 **29 个仓**在默认分支上持有本地化 `docs/release-governance.md`，全部位于 `main`（`ComfyUI-BatchPromptLoader` 于 2026-10-19 由 `master` 迁移，`master` 分支已删），且均含「远端优先」标记。逐仓差异与剩余欠账见 §10.6。
>
> 2026-10-18 补：其中 **6 个仓**（`ComfyUI-BatchPromptLoader` / `Multi-Tracker` / `Bilibili-Follow-Manager` / `Hugging-Face` / `Unfading-Wall` / `Unity`）已由用户点名**豁免 §10**——其已落地的文档与流水线**保留不动**，仅不再纳入 §10 的要求与审计范围（详见下方排除清单）。
>
> **2026-10-19 豁免升级（用户裁决）**：下方排除清单由「不适用 §10」升级为「不适用整个 REPOSITORY_GUIDELINES.md（§1-§14）」——不再要求、不再审计本规范任何章节（含 §1 命名、§2 保护、§4 台账、§7/§8、§10、§12 结构、§13 路径、§14 硬编码）；同日**第二轮点名**再增 6 仓，2026-10-20 **第三轮点名 +1、备份仓补录 +1**，2026-10-21 **第四轮点名 +4**，清单共 **29 项**。台账/命名维度的执行载体见 §4 的 2026-10-19 变更记录与脚本 `EXCLUDED_FROM_REGISTRY`（25 项）。已交付产物（发布文档、CHANGELOG、流水线、AGENTS.md 上传）**一律保留**。
>
> 下发方式：**按 §17.2 推送**（作者账号可直推；非作者逐仓开分支 + PR + 合并）；文档一律以本仓 `RELEASE_GOVERNANCE_TEMPLATE.md` 为结构、以本节为公共条款，只填本仓特有项，不得改写公共条款。
>
> **排除清单（2026-10-19 豁免升级：整部规范（§1–§14）不适用，共 29 项，逐条留痕）**：
>
> - **密钥 / 资产备份仓（7 个，按 §3 属备份仓、无发布链）**：`DraftPeek-KeyBackup`、`Image-DuoModel-KeyBackup`（2026-10-19 前名 `Image-MultiModel-KeyBackup`，随父仓改名跟进）、`SeedVR2-Lite-KeyBackup`、`TTS-MultiModel-KeyBackup`、`Android-IconAutoArrange-KeyBackup`（2026-10-18 补录，此前误记为"4 个"）、`Android-IconAutoArrange-Assets-Backup`（内含加密签名密钥的口令台账与 PoC APK）、`SpiritPal-KeyBackup`（2026-10-20 补录）。**此类仓按性质即须豁免，不需逐仓审批（2026-10-20 用户裁决）。**
> - **网站仓（4 个）**：`Website-Genshin-Impact`、`Website-Honkai-Star-Rail`、`Website-Wuthering-Waves`、`Website-Zenless-Zone-Zero`。
> - **非 §4 台账副本（1 个）**：`rewq`。
> - **用户点名豁免（6 个，2026-10-18）**：`ComfyUI-BatchPromptLoader`、`Multi-Tracker`、`Bilibili-Follow-Manager`、`Hugging-Face`、`Unfading-Wall`、`Unity`。
> - **用户点名豁免（第二轮，6 个，2026-10-19）**：`Mooncake-Deconstruction`、`Offer-Landing-Kit`、`Android-IconAutoArrange`、`Free-Model-Probe`、`ChatGPT-Timezone-Fix`、`RTX-VSR-Lite`。
> - **用户点名豁免（第三轮，1 个，2026-10-20）**：`Code-Time-Machine-1024`（TRAE 1024Builder 作品秀/展示站，2026-10-20 建仓；无 `.github/`、无发布链、无版本位，与 `Offer-Landing-Kit` 同类展示型仓）。其分段 `1024` 以数字开头，不符合 §1 Train Case，**因整体豁免故不作命名整改**；若将来撤销豁免，须先按 §1 改名并补登 §4 台账。
> - **用户点名豁免（第四轮，4 个，2026-10-21）**：`p0-murder-mystery`、`Health-Info-Card`、`Lineart-Painter`、`Card-Studio`。（均为公开仓；语义：不适用整部规范，产物保留。）
>   **语义边界（重要）**：豁免表示**整部规范（§1–§14）不再要求、不再审计**（不只 §10）；这些仓此前已落地的 `docs/release-governance.md`、根级 `CHANGELOG.md` 与发布链改动**一律保留、不删除、不回滚**。若将来要撤销这些产物，属单独决定。账号级安全与法律义务（密钥泄露、许可证侵权、平台规则）不因本豁免而免除。
>
> 维护规则：本清单与 §4 台账表、`check-repo-registry.sh` 的 `EXCLUDED_FROM_REGISTRY`、`check-release-standard.sh` 的 `EXCLUDED_FROM_RELEASE_STANDARD`、以及本仓根 `GOVERNANCE-EXCLUSIONS.md` **五处同步修改**。

> **2026-10-22 起本节的适用范围由 §15 派生**：只有 `delivery=release` 的仓取 §10 全量检查；
> `library` 只取版本号与 CHANGELOG 子集；`service` 只取部署/回滚子集；`tool` / `content` / `backup`
> 不适用本节。具体检查项再按 `distribution` 取值细分（`github-release` / `ghcr` / `pages` /
> `direct-ssh` / `none`）。**下面 2026-10-18/19 的名单与四轮豁免段落转为历史记录**，
> 不再作为现行范围口径；历史原文保留于本文件与 `GOVERNANCE-EXCLUSIONS.md`。

### 10.1 三条根原则

1. **远端优先**：发布链的构建、打包、签名、扫描、上传、推送**一律在 GitHub Actions 远端完成**；本地只保留三件轻量动作——改版本位、落 CHANGELOG、`git tag` + `git push`。**本地不执行打包 / 签名 / 镜像构建 / 发布上传**：既减少本机压力，也让产物可复现（runner 固定、依赖锁定）。
2. **tag 驱动**：`push: tags: v*` 触发发布链；禁止在本地产出交付物后手工上传充当发布。
3. **产物必须可校验（2026-10-18 修订）**：Release 资产须附 `SHA256SUMS.txt`；**防伪造**改由桌面壳的 **Tauri ed25519 签名**承担（`*.sig` / `*.sig.ed25519`，已在 SpiritPal / Image-DuoModel 实际产出）。**GPG 分离签名已裁决撤掉**——理由与善后见 §10.6。

### 10.2 release（发布）

- 版本号遵循 **SemVer** `MAJOR.MINOR.PATCH`，预发布用 `-alpha.N` / `-beta.N` / `-rc.N`。
- CHANGELOG 遵循 **Keep a Changelog**：每次合并 `main` 在 `[Unreleased]` 追加，`feat→Added`、`fix→Fixed`、`refactor→Changed`；发版时 `[Unreleased]` → `[VERSION] - YYYY-MM-DD`。
- **版本位须多点一致，漂一处即判红**。可参照的实现：TTS-MultiModel `tests/test_version_consistency.py::test_all_version_sites_agree` 逐条比对仓内跟踪的版本位；Image-DuoModel 已恢复 release-please 自动（`version.txt` 自动改写、`config.yaml` 顶层 `version` 由人补齐），另需 `CHANGELOG.md` 跟随。
- 发布链固定为：本地 `git tag v<X.Y.Z>` → `git push origin v<X.Y.Z>` → **远端**建 draft Release 并挂资产 → 人工审核后 `published`（DraftPeek 口径）。
- **回滚**以 `git revert` 为主（保历史、可再 forward）。**重指向或删除 tag、移动任何远端 ref 属破坏性远端动作，须仓库所有者单独授权**——`release.yml` 由 `push: tags` 触发，移动已发布 tag 会当场重跑发布链，DraftPeek 历史上因此产出过混年代 Release 资产。

### 10.3 package（打包 / 可分发产物）

- **Python**：以 `pyproject.toml` 为唯一声明源；依赖改动同步 `requirements.txt` / `requirements-lock.txt`；wheel / sdist 由远端构建。
- **容器镜像**：统一推 **ghcr.io**，`permissions: packages: write`，用 `GITHUB_TOKEN` 登录；tag 取**不可变标签**——semver（`{{version}}` / `{{major}}.{{minor}}`）+ 每次构建的 `sha`。
  - **不以 floating `latest` 作为发布基线**（SeedVR2 口径，其评估报告把 latest 列为反模式 #3）。**2026-10-18 收敛后账号内已无仓启用 floating `latest`**：TTS 的 `type=raw,value=latest,enable={{is_default_branch}}` 行已删除；GHCR 上的历史 `:latest` tag 仍在，但不再更新、不作任何下游引用的版本依据。
  - **镜像引用必须全小写**：`${{ github.repository }}` 展开带大写，而 OCI 引用规范只允许小写，Trivy 在解析阶段会直接 FATAL「could not parse reference」。TTS 与 SeedVR2 都踩过这个坑。
  - 镜像内不含模型权重（`.dockerignore` 排除 `model/`），运行时挂载。
- **桌面分发**（Tauri / NSIS / APK）：签名密钥**不入库**，按 §3 走私有 `<项目名>-KeyBackup`；构建与签名在远端完成，密钥经 Actions Secrets 注入。**防伪造仅由 Tauri 的 ed25519 更新器签名承担**（`*.sig` / `*.sig.ed25519`）；`SHA256SUMS.txt` 只用于防传输损坏；**GPG 分离签名已撤掉**（见 §10.6）。
- **npm**：目前仅 `Image-Scrapers` 使用；其 `node_modules` 入库属 §9 已登记的私有仓例外。

### 10.4 deployment（部署）

**判据（一句话分界）**：问「这条部署动作的**执行位置**是远端，还是使用者本机」——
- **远端可完成** → 一律远端执行，见下面「远端侧」清单；
- **只有本机才能完成** → 落在**本地运行边界**内，不在本节管辖，标准既不要求也不禁止远端化。

**远端侧（能远端的一律远端）**：GitHub Pages；镜像推送后的滚动更新；需集群 / 远程主机凭据的 K8s 或服务器部署（凭据存 GitHub Secrets，不落本地）。此类部署**默认即执行**，不需要额外授权。

**本地运行边界（明确列举，边界内不做远端化改造）**：
- 本机运行的自部署服务（本地 Web 服务、本地 API 端点）；
- 桌面应用（Tauri / NSIS / APK）的**安装与运行**——注意其**构建与打包**仍按 §10.3 在远端完成，二者是两件事；
- 本机 GPU 推理进程、本地引擎进程（如本机 ComfyUI）；
- 在本机用 `docker-compose.yml` 拉起容器——**镜像由远端 ghcr 构建提供，容器运行在本机**。

边界内的事项是**运行态而非构建态**，因此**不构成本机算力负担**，无需为"减负"做任何改造。

**执行授权规则（2026-10-18 追加）**：
- 能远端完成的部署动作 → **默认执行**（远端），无需另行确认；
- 不能远端完成、且使用者**未明确提出**的部署动作 → **一律不做**：不主动在本机执行、不主动做远端化改造、不要求使用者配合改动本地环境。

**部署前扫描与供应链元数据（2026-10-18 收敛）**：
- 部署前扫描：镜像发布前须经 **Trivy**（`CRITICAL,HIGH`、`ignore-unfixed`），**默认阻断**；豁免须在 `.trivyignore.yaml` 逐条登记理由与 expiration。**2026-10-18 收敛结果**：TTS 与 SeedVR2 的 `docker-publish.yml` 均为阻断（`exit-code: '1'`）；SeedVR2 转阻断前实测该镜像在门禁口径下**零发现**（日志中无 CVE 行、无 `Total:` 行），故不需要任何存量豁免条目。**2026-10-18 批 4 收敛**：MiniMax-H3-Lite 的 `docker-scan.yml` 亦已转阻断（PR #98），账号内镜像扫描已统一为阻断口径。
- SBOM / provenance：**推荐开启**。SeedVR2-Lite 与 MiniMax-H3-Lite 用 buildx 内联字段（`provenance: true` + `sbom: true`）；TTS 因发布链是「build（`push: false`）→ Trivy 扫 → 手动 `docker push`」，buildx 内联 attestation 不可用，已改用 `actions/attest-sbom` + `attest-build-provenance` 绑定**已推送 digest**（机制等价替代，见 §10.6）。

### 10.5 发布验证产物

发布后须留可复核记录，落 `docs/execution/RELEASE_VERIFICATION.md`。该路径已在 `self-purify.yml` 白名单内放行，属允许入库的样例。

### 10.6 收敛结果与剩余欠账（2026-10-18 实测更新）

**已收敛（均经远端复核）**

| 项 | 结果 | 落地证据 |
|---|---|---|
| 标准下发 | 29 仓默认分支均有本地化 `docs/release-governance.md`，全部含「远端优先」标记 | 见 §10 范围声明；逐仓开分支 + PR 合并，排除 10 项已逐条留痕 |
| 发布总纲统一 | 各仓文档以 `RELEASE_GOVERNANCE_TEMPLATE.md` 为结构、以本节为公共条款 | DraftPeek 原 `docs/VERSIONING.md` 已收敛为指向 `release-governance.md` 的迁移指针（184 行 → 3 行） |
| 镜像 tag | **账号内已无仓启用 floating `latest`** | TTS-MultiModel `docker-publish.yml` 的 `type=raw,value=latest` 行已删（PR #190） |
| 镜像扫描 | TTS 与 SeedVR2 的 `docker-publish.yml` 均转阻断（`exit-code: '1'`） | SeedVR2-Lite PR #164；转阻断前实测该镜像零发现，故未建豁免条目 |
| GPG 分离签名 | 6 仓的 `gpg-signed-release.yml` 已**全部删除并合并** | SpiritPal #146 / MiniMax-H3-Lite #95 / DraftPeek #131 / Image-DuoModel #129 / SeedVR2-Lite #164 / TTS-MultiModel #190 |
| 发布链最小修正 | 4 仓补上远端 SHA256SUMS 生成与挂载 | GalgameShell #10 / Health-Info-Card #3 / RTX-VSR-Lite #9 / ComfyUI-Experiment-Toolbox #2 —— 均只动 `release.yml` / `build-firmware.yml`，符合 §10.1 |
| 根级 `CHANGELOG.md` | **29 仓全部建立**（Keep a Changelog）：Unity 由既有 `docs/CHANGELOG.md` 搬迁至根级并留指针、`Health-Info-Card` 按本仓惯例双语配对（`CHANGELOG.md` + `CHANGELOG.zh_CN.md`）；无 tag / Release 的仓仅含 `[Unreleased]` 并如实注明，未编造版本号与日期 | 21 单 PR：#2 Unity / #11 GalgameShell / #6 ReSerendipity / #3 ComfyUI-Experiment-Toolbox / #4 Github-Repo-Scan / #7 Lineart-Painter / #2 Unfading-Wall / #9 Multi-Tracker / #4 Health-Info-Card / #6 Card-Studio / #4 Mooncake-Deconstruction / #2 Offer-Landing-Kit / #3 Android-IconAutoArrange / #4 Free-Model-Probe / #2 ChatGPT-Timezone-Fix / #2 Bilibili-Follow-Manager / #2 Hugging-Face / #2 Nekogal-DL / #2 Agent-Knowledge / #2 Prompt-Library / #3 ComfyUI-BatchPromptLoader。有 tag 的 5 仓版本段日期逐仓与真实 tag 提交/发布时间核对一致 |

| 镜像扫描双口径 | MiniMax-H3-Lite 的 `docker-scan.yml` 已由观察模式转**阻断**（`--exit-code 1`），与仓内 `trivy.yml` / `docker-gate.yml` 同口径 | PR #98 |
| SBOM / provenance | SeedVR2 用 buildx 内联字段；MiniMax-H3-Lite `ghcr.yml` 补 `provenance: true` + `sbom: true`；TTS 改用 `actions/attest-sbom` + `attest-build-provenance` 绑定**已推送 digest**（机制说明见剩余欠账表） | PR #98 / TTS #191 |
| 版本自动化 | Image-DuoModel 已**恢复 release-please 自动**（`release-type: simple`；`version.txt` 自动改写、`config.yaml` 人工补齐，与 TTS 口径统一） | PR #130 |
| 发布链 draft 化 | Multi-Tracker / Lineart-Painter / ComfyUI-BatchPromptLoader 三条链改为 **draft + 远端资产（含 `SHA256SUMS.txt`）**，人工审核后 published | PR #10 / #8 / #4 |
| 无发布链仓补链 | `Android-IconAutoArrange`（APK，runner 内手搓构建）与 `ChatGPT-Timezone-Fix`（MV3 扩展 zip）已补 tag 驱动 `release.yml` | PR #4 / #3 |

**剩余欠账（§10.7 的核验脚本定位为审计 + 进度对账，不是每 PR 门禁，故下面各项不阻断合并）**

| 项 | 实测现状 | 待办 |
|---|---|---|
| 私有仓 Actions 账单/额度 | Prompt-Library / Image-Scrapers / Nekogal-DL 的作业因账号级账单注解无法启动（annotation 原文已取证） | **账号级问题、非仓库代码问题**；由账号所有者处理 Billing 后自动恢复（用户已指示本轮跳过） |
**非欠账说明（列出仅为留痕，不构成待办）**
**明确不补链的仓**：`Offer-Landing-Kit`（静态单文件站：无构建步骤、无打包脚本、无版本位，对外分发即 Pages 线上站点，已满足 §10.4 远端部署）、`Hugging-Face`（无 `.github/`、无构建产物）、`Unity`（Unity 工程需 Unity 授权，托管 runner 无法构建）——不补空链；待这些仓真正产生需版本化分发的产物时再立项。
**TTS 镜像 attestation 机制**：TTS 因「先构建不推送 → 扫描 → 再推送」结构，无法用 buildx 内联 `provenance: true`（docker exporter 不承载 attestation），已改用官方 attest-action 绑定已推送 digest；属机制等价替代，非欠账。

### 10.7 本节的执行件

  | 执行件 | 用途 |
  |---|---|
  | `RELEASE_GOVERNANCE_TEMPLATE.md`（本仓根目录） | 各仓发布文档的**统一模板** + 差异点采集清单；收敛时复制为各仓 `docs/release-governance.md`，只填本仓特有项 |
  | `.github/scripts/check-release-standard.sh` | **收敛核验**（审计 + 进度对账，只读、无网络）；**非**每 PR 必需门禁——收敛完成前必然大面积 FAIL，挂上去只会常红；2026-10-19 起已挂入本仓 `ci.yml` 的 `schedule` 周检（`release-standard-audit` 作业，批量浅克隆后跑 `--repos-dir`），排除清单在脚本内 `EXCLUDED_FROM_RELEASE_STANDARD` 声明，与本节范围声明同源 |

---

## 11. 许可证规范（License，2026-10-19 新增）

- **新创建的公开仓库**：默认 **Apache License 2.0**（SPDX: `Apache-2.0`）——建仓时随初始提交在根目录落**官方全文** `LICENSE` 文件（不用自创变体、不用改写版），版权行格式 `Copyright (c) 2026 Doro (ReSerendipity)`。
- **特殊仓豁免**：`.github`（治理规范仓）与 `ReSerendipity`（profile 仓）等"内容即文档/身份"的仓库**不需要许可证**。
- **存量仓不追溯**：本条生效（2026-10-19）前创建的仓库不强制补 LICENSE，是否补属各仓单独决定。
- **私有仓**：不需要许可证（无对外分发语义）。
- 已持有其他许可证的仓**保持原状**，不强制迁移；更换许可证属单独决定（注意 Apache-2.0 与 GPLv2 的单向兼容等约束）。

---

## 12. 项目结构规范（Repository Layout，2026-10-19 新增）

> **适用范围**：§4 台账登记仓。**定位**：不强制全仓统一布局——技术栈异构（Rust / JS / Python / Kotlin / Unity / ComfyUI 插件），语言生态的固定布局（ComfyUI 插件、Unity `Assets/`、Kotlin `src/test/`、Rust 工作区）**不迁就本节**；本节只钉死跨仓通用件的位置。
> **实测依据（2026-10-19，23 管辖仓全量普查）**：`docs/` 14/14、`.github/` 13/14、`tests/` 9/14、`scripts/` 7/14；根目录散落文档 93 个 + 散落脚本约 52 个（合计 150 文件 / 20 仓）；仓内引用面 ≈949 处。

### 12.1 位置约定（硬条款）

| 对象 | 位置 | 说明 |
|---|---|---|
| 文档（`.md`，本表"留根例外"除外） | `docs/`（小写；`DOCS/` 禁用） | 延续 §8 并扩展到全部文档；`docs/` 为**纯入库**目录 |
| `README.md` / `CHANGELOG.md` / `LICENSE` | **留根** | §8 / §10.2 / §11 约定 |
| 语言/框架入口与构建配置（`pyproject.toml`、`package.json`、`Cargo.toml`、`Dockerfile`、`Makefile`、`*.csproj`、`manifest.json` 等） | **留根** | 语言惯例优先 |
| 自动化脚本（`.py` / `.ps1` / `.sh` / `.mjs` / `.js`） | `scripts/` | 可按需分子目录 |
| 测试 | `tests/` | 语言惯例优先（内联 `#[cfg(test)]`、`src/test/` 不强迁） |
| 构建产物（`dist/`、`target/`、`build/`、`out/`） | 不入库 | §9 具体化；普查 0 仓违规 |
| 归档 | `_archive/`（下划线前缀） | 前缀即"非活动区"，§10 审计自动豁免 |
| 仅本地内容（内部说明 / agent 上下文 / 实验记录 / 纯历史） | `local/`（根目录） | **§13.1 的唯一 ignore 容器**，整体不入库 |
| 数据文件 | `data/` | 引导级 |
| 仓级 CI | `.github/workflows/` | GitHub 硬要求 |

### 12.2 存量收敛（方案 A：全量迁移，2026-10-19 裁决）

- **范围**：17 个管辖仓的散落文件迁移（git mv 保留历史）+ 仓内引用同步修链；普查口径 23 仓实测 150 文件 / ≈949 处引用，其中 6 仓随第二轮豁免移出批次，批次实际规模以逐仓清单为准。
- **迁移映射**：根级非入口 `.md` → `docs/`；根级脚本 → `scripts/`；`docs/README.internal.md` → `local/README.internal.md`；`docs/agents/**` → `local/agents/**`（公开仓已跟踪的同步 `git rm --cached`，见 §7）；纯历史类散落文档 → `_archive/`（**增量判据**为不提交，见 §13.1）。
- **执行方式**：豆包 agent 并行（本机有克隆的仓走**本地电脑**模式，无克隆的仓走**云电脑**模式）；agent 只开 PR **不合并**，本机逐仓独立验收后合并。
- **例外注记**：私有仓 CI 因账号账单挂起时，其 PR 照旧开 + admin 合并，标注"CI 不可验证"。
- **验收标准（每 PR）**：①diff 仅含 rename + 引用修链 + `.gitignore`/workflow 路径同步；②修链后仓内 `git grep` 旧路径**零命中**（§13.3 允许的历史叙事除外，但"照此操作"引用必须更新）；③文档内相对链接渲染有效。
- **完成判据**：普查复跑，根目录散落文档/脚本 = 0，本节欠账清零。

### 12.3 存量收敛结果（2026-10-19 实测回填）

**批次执行**：17 个管辖仓全部经豆包 agent 并行迁移（本地电脑模式 14 单 + 云电脑模式 3 单），agent 只开 PR、编排方独立验收后合并。

| 仓 | PR | 备注 |
|---|---|---|
| Agent-Knowledge / ComfyUI-Experiment-Toolbox / GalgameShell / Github-Repo-Scan / Image-DuoModel / Image-Scrapers / MiniMax-H3-Lite / Nekogal-DL / Prompt-Library / ReSerendipity / SeedVR2-Lite / SpiritPal / TTS-MultiModel | #4 / #4 / #12 / #5 / #132 / #22 / #99 / #4 / #4 / #7 / #165 / #154 / #192 | 提交全部为迁移 + 修链，纯净通过 |
| Card-Studio | #7 | 含 §7 家族 `git rm --cached`（公开仓 local/ 保留） |
| Health-Info-Card | #5 | 同上（AGENTS/CLAUDE 双语四件） |
| Lineart-Painter | #9 + **#10（补漏）** | 工具脚本 7 个迁 scripts/、应用源码 8 个按语言惯例留根；复跑发现 2 个历史调研报告漏归档，补 PR 归档 `_archive/` |
| DraftPeek | **#133（#132 拆分）** | agent 将本机 14 个未授权 WIP 提交一并打包进 #132，验收查出后拆分：3 个迁移提交 cherry-pick 零冲突重放为 #133 合并，WIP 剥离至本机 `wip/local-20261019` 分支待所有者处置，旧 PR 关闭留痕 |

**复跑普查（收敛后，远端 main）**：14 仓根目录散落清零；4 项**合规保留**如实记录——`ComfyUI-Experiment-Toolbox/run.py`（唯一入口，语言惯例留根）、`Card-Studio/CONTRIBUTING.md`（GitHub 社区健康文件）、`Health-Info-Card` 的 `CHANGELOG.zh_CN.md` / `README.zh_CN.md`（双语配对跟随主文件留根）、`Prompt-Library` 根级 7 个中文规范文档（该仓内容主体即规范条目，属交付物非项目文档）。**本节欠账清零。**

### 12.4 路径与文档分流（原 §13）

- 仓内路径一律 `/` 相对仓根、逐字符一致；禁止机器绝对路径进入可执行文件 / 配置。
- 文档入库三问与 `local/` 容器见 **§13.1**；`local/` 是唯一本地容器，`AGENTS.md` 与 `local/agents/**` 均属本地上下文（§7）。
- 本节是 §13 的归口；§13 保留原编号作为执行细则。

## 13. 路径规范（§12.4 执行细则，2026-10-19 新增）

> **适用范围**：§4 台账登记仓。**痛点**：本机 Windows + 远端 Linux runner 双环境长期共存；Windows 大小写不敏感会掩盖路径漂移，Linux 会炸。

- 引用**仓库内路径**（文档与代码）：一律 `/` 分隔、相对仓根、与文件系统**逐字符一致**（含大小写）。
- **禁止机器特定绝对路径进入可执行文件与配置**（`C:\Users\...`、`/home/<user>/...`）——用环境变量 / CLI 参数 / 相对路径 + 配置承载。
- **文档叙事中的本机路径允许**（case-study / SOP / 审计报告属历史事实记录）；"照此操作"的步骤不得依赖机器特定路径。
- 跨平台写法：PowerShell 用 `Join-Path`/`Split-Path`（不手工拼 `\`）；bash 用 POSIX；Python 用 `pathlib`；workflow 内按 Linux runner 书写。
- 配置文件中的路径基准 = 相对仓根，除非文件自己声明基准。

### 13.1 文档入库分流（`local/` 容器，2026-10-19 定稿）

**判据（三问决策树，新建任何文档时按序问）**：

```
Q1 内容含敏感或本机环境细节？（密钥/token/内网地址/C:\Users\Doro/服务器信息）
   ├─ 是 → 仅本地（不入库）
Q2 陌生协作者 clone 后能否凭它行动？（能跑 / 能复现 / 能参与 / 能懂架构）
   ├─ 能 → 入库 docs/
Q3 都不是（纯历史：审计快照 / 一次性评估 / 执行对照 / 实验记录）
   → 仅本地（增量不提交；确有长期档案价值的走 _archive/ 入库）
```

- **公开 / 私有上传策略（2026-10-23 明确）**：公开仓遵循「非必要不上传」——只有陌生协作者能据此行动的文档才进 `docs/`，其余留在 `local/`；私有仓相反，**尽可能把可备份的 Markdown 上传入库**（密钥、token、口令除外；`AGENTS.md` 按 §7.1 始终只留本地），作为远程备份。

**物理载体（`.gitignore` 模板，每仓统一，仅两条）**：

```gitignore
/local/      # 仅本地容器：内部说明、agent 上下文、实验记录、纯历史（§13.1）
AGENTS.md    # §7 家族（无斜线模式，匹配任意深度）
```

- `local/` 是**唯一**的仅本地容器，目录级一条规则、永不增长；`docs/` 由此保持**纯入库**语义（治理文档与对外文档不受任何 ignore 影响）。
- 迁移映射：`docs/README.internal.md` → `local/README.internal.md`（§8）；`docs/agents/**` → `local/agents/**`（§7）；`docs/local/` 概念废除（未实施即由 `local/` 取代）。
- **边界案例**：双语配对（`X.md` + `X.zh_CN.md`）跟随主文档判定；生成类文档（API docs / coverage 报告）属构建产物不入库（§9）；已在 `docs/` 下的存量历史文档**不迁移、保留原位**，新增的不提交。

## 14. 硬编码规范（Hardcoding，2026-10-19 新增）

> **适用范围**：§4 台账登记仓。**分层口径**对齐 §10 核验脚本的 FAIL/WARN 精神。

**禁止入库（FAIL 级）**：

1. 敏感值：密钥 / token / 口令 / 连接串——延续 §3 与 §10.3/§10.4 的 Secrets 口径（收拢，不新增语义）。
2. 机器特定值：本机绝对路径、本机用户名（`Doro`）、内网 IP / 主机名——出现在可执行文件与配置中即违规。

**应避免（WARN 级）**：

3. owner / 仓库名字面量：**集中在文件顶部 `env:` 声明一次**（范式：规范仓 `ci.yml` 的 `REGISTRY_OWNER`）。存量 workflow 字面量随各仓下次改 workflow 时顺手收敛，不专项迁移。
4. 魔数：提取为具名常量；阈值类必须注释来源（§7 的"300 行上限带实测分布出处"为正面示范）。
5. 版本号字面量不得出现第三处：以 §10.2 唯一权威版本位为准。

**允许**：公开文档 URL、第三方公开端点、文档叙事中的历史路径 / 用户名（与 §13「文档叙事中的本机路径允许」同口径）。

**载体**：本节与 §12/§13 先纯条款落地；账号级审计脚本以 SpiritPal `scripts/check_no_hardcoded_paths.py` 为参考实现，收敛批次完成后单独立项。

---

## 15. 治理分档（Governance Tiers，2026-10-22 新增）

> **定位**：把「哪些条款适用、查多严、多久查一次」从人记转为可派生的声明。唯一机器可读载体是
> `governance/desired-state.json`；本节是它的人类可读版本，两者由 `audit-drift.py` 与
> `check-governance-consistency.sh` 对账。

### 15.1 两轴模型

单一 profile 会把三件互不相关的事压进一个值：交付形态、维护状态、敏感级别，导致「active 的静态站」
与「active 的桌面应用」被塞进同一档，条款只能取并集。本节拆为两个正交轴：

| 轴 | 取值 | 决定什么 |
|---|---|---|
| **lifecycle**（主轴） | `active` / `maintenance` / `archived` | 变更许可、审计频率、平台要求 |
| **delivery**（副轴） | `release` / `library` / `service` / `tool` / `content` / `backup` / `policy` | 适用哪些章节 |
| distribution | `github-release` / `ghcr` / `pages` / `direct-ssh` / `none` | 触发 §10 的哪几条检查 |
| risk | `signing-key` / `credentials` | 额外的禁止项 |
| backup | `github-only` / `key-only` / `separate-encrypted` | 副本策略（ADR-0005） |

### 15.2 lifecycle

| lifecycle | 判据 | 变更许可 | 审计 |
|---|---|---|---|
| `active` | 近 90 天有新功能提交或新 Release | 允许新功能 | 周检 |
| `maintenance` | 只修 bug / 依赖 / 安全 | 仅修复与密钥轮换 | 月检 |
| `archived` | GitHub 已归档（暂时归档，可 unarchive） | 平台只读 | 不检查 |

active 与 maintenance 的**适用条款完全相同**，差别只有变更许可、审计频率与平台要求三处。
「有没有偷偷加功能」审计查不出，靠提交审查与 PR 约定。

平台要求：`active` 的公开仓必须有 `governance-baseline` + `tag-protection-v`；`maintenance`
只要求 `main` + `delete_branch_on_merge=true`（已配置的 ruleset 保留）；`archived` 不要求。
私有仓在 Free 计划下无服务器侧保护能力，以本地 `.githooks/pre-push` 作为替代控制（ADR-0004）。

### 15.3 delivery → 适用条款

| delivery | 适用 | 不适用 |
|---|---|---|
| `release` | §1–§14 全部（§10 按 distribution 取子集） | — |
| `library` | §1、§2、§7、§8、§9、§10（仅版本/CHANGELOG）、§11、§12（含原 §13）、§14 | 产物完整性、SBOM、镜像扫描 |
| `service` | §1、§2、§7、§8、§9、§10（部署/回滚）、§11、§12（含原 §13）、§14 | §10 版本/产物子集、§3 |
| `tool` | §1、§2、§7、§8、§9、§11、§12（含原 §13）、§14 | §3、§10 |
| `content` | §1、§2、§7、§8、§9、§12（含原 §13） | §3、§10、§11、§14 |
| `backup` | §3（KeyBackup 结构、允许轮换更新） | 其余全部 |
| `policy` | §1–§18 自身维护 | §10 发布链 |

> **跨 delivery 通用条款（2026-10-23）**：§17、§18 不参与本表裁剪，对全部 `delivery` 类型生效；§16 已并入 §7，按 §7 的适用范围执行；`backup` 仓仅在其 §3 允许的维护动作中适用 §7 / §17 / §18。

### 15.4 distribution → §10 检查子集

| distribution | 生效检查 |
|---|---|
| `github-release` | 资产 SHA256、Release 说明、回滚 |
| `ghcr` | Trivy、provenance、SBOM |
| `pages` | 部署回滚 |
| `direct-ssh` | 部署脚本回滚 |
| `none` | 无发布检查 |

### 15.5 风险标签与例外

- `signing-key`：签名私钥不得入库；备份按 §3。
- `credentials`：仓库内含服务器/账号凭据相关内容（当前仅 `rewq`）；硬约束是 `.gitignore`
  排除 `ssh-backup/` 与私钥，不限制正常提交。
- 命名例外（品牌 / 系统保留名 / 已登记债务）见 §4；任何新增例外须先落 ADR，再改 §4。

### 15.6 46 仓定位

完整定位（含 visibility、distribution、risk、backup）以 `governance/desired-state.json`
为唯一事实来源；§4 的 39 行是其中**非备份仓**的命名台账，7 个 `backup` 仓不登记。
修改定位须同时改文档与 JSON，`check-governance-consistency.sh` 会校验计数一致。

### 15.7 归档操作规范（暂时归档，2026-10-23 新增）

本账号的归档一律是**暂时归档（temporary archive）**：不是永久归档、不是项目终止，也不删除仓库。归档只把仓库切换为 GitHub 只读状态，可随时 unarchive 恢复。

| 项 | 要求 |
|---|---|
| 性质 | 暂时只读；代码、历史、已有 Release / Pages 保留；公开仓可克隆、Star、Fork，私有仓仅限现有协作者 |
| README | **归档前**必须在仓库根 `README.md` 顶部加入下方统一声明块；README 未更新不得归档 |
| 恢复 | unarchive → 更新 README（移除或改写声明）→ 把 `desired-state.json` 的 `lifecycle` 改回 `active` / `maintenance` → 跑 `audit-drift.py` 确认无漂移 |
| 已归档仓补声明 | 先 unarchive，补 README 并合并，再重新 archive；期间 `lifecycle` 保持 `archived` |
| 审计 | 归档仓按 §15.2 跳过常规审计；README 存在性仍属基础要求 |

统一声明块（逐字复制，仅日期按实际归档日调整）：

```markdown
> **状态：暂时归档（Temporary Archive）｜YYYY-MM-DD**
>
> 本仓库处于 GitHub 只读归档状态。这是**暂时归档**，不是永久归档，也不代表项目终止。
> 归档期间，代码、提交历史以及已有的 Release / Pages 保持可访问；公开仓可克隆、Star、Fork，私有仓仅限现有协作者。不能提交代码、发起 Issue / PR、评论或发布新版本。
> 恢复开发时，由仓库所有者解除归档（unarchive），更新本声明，并同步修改治理台账中的 `lifecycle`。
> 治理口径见 [ReSerendipity/.github 治理规范 §15.7](https://github.com/ReSerendipity/.github/blob/main/governance/REPOSITORY_GUIDELINES.md)。
```

## 16. AGENTS.md 自进化与拆分（已并入 §7.4 / §7.5）

> 本节内容已合并至 §7.4「自进化协议」与 §7.5「拆分规则与标注」；保留本节编号作为历史锚点，不再单独维护正文。

## 17. 任务完成后的清理、提交与 CI 收敛（2026-10-23 新增）

**完成定义**：任务只有同时满足以下五项才算完成，缺一项只能报「未完成 + 阻塞原因」。

1. 改动已实现并通过本地验证；
2. 工作区干净：`git status` 只剩本次有意改动；
3. 提交已分批、显式路径、DCO 签名；
4. 有 CI 的仓已盯到终态；无 CI 的仓本地检查全绿；
5. 该推送的已推送、该合并的已合并，临时资源已清理。

**通用性说明**：本节为账号级通用条款，适用于所有 `delivery` 类型；§15.3 的条款裁剪只针对 §1–§15，不裁剪本节。

### 17.1 清理

- 删除本次产生的临时脚本、调试输出、截图、日志、缓存、一次性数据；确需保留的交付物放 `docs/` 或用户指定目录。
- 不删除用户未提交的 WIP、无关文件、他人分支；发现时保持原样并在汇报中列出。
- 停止本次启动的后台进程 / 本地服务器 / 文件监听，释放端口。
- 检查生成物与依赖目录（`node_modules/`、`.venv/`、`dist/`、模型权重等）未被误跟踪。
- 检查密钥、token、口令、机器绝对路径不入库；有 gitleaks 的仓跑一次。
- 归档 / 备份 / 本地上下文按 §7、§9、§13.1 分流，不把 `local/` 或 `.qoder/` 带进提交。

### 17.2 分批提交

- 用 `git add -- <显式路径>`，禁止 `git add -A` / `git add .`；提交前 `git diff --cached` 核对。
- 按逻辑单元分批：代码、测试、文档、治理台账各自成批；每批可独立回滚、独立说明。
- 每批一个 Conventional Commits 主题，正文写「为什么」；必须 `git commit -s`，身份用 noreply。
- 不把无关改动混进同一批；不改写已推送的提交；不 force push。
- 每批提交前跑该批相关的最小检查；全部批次完成后再跑一次全量检查。
- 推送前确认目标分支与远端一致；按以下策略选择直推或 PR：
  - **作者账号 + 未检测到多 agent + 本地预检全绿 + 该仓 `enforce_admins=false`（或未受保护）**：默认直推当前分支，包括 `main`；直推仍须 DCO、`pre-push`、CI 盯终态，GitHub 若记为 bypass 需如实留痕。
  - **作者账号 + 检测到多 agent**：自动开分支 + PR（见 §17.5）。
  - **非作者协作者**：分支 + PR + 必需检查 + 审批。
  - **`enforce_admins=true` 或平台拒绝直推**：分支 + PR。

### 17.3 CI 收敛

**顺序固定（2026-10-23）**：先 commit 使工作区干净 → 再 push 触发 CI → 盯到绿色；失败时先在本地复现 / 修复，再 commit、再 push，循环直到绿色。禁止在工作区未提交时 push，禁止用 `--no-verify` 绕过。

**有 CI（存在 `.github/workflows/` 或平台等价配置）**：

1. push 后立即记录 run id，用 `gh run list` / `gh run view` 或 PR checks 盯到 `completed`；
2. 不以 `gh run watch` 的退出码单独作为结论，必须读 `conclusion` 与失败日志；
3. 失败先归类：代码 / 测试 / 配置 / 外部依赖（账单、权限、网络）。代码类当场修，补提交再推；同一失败签名第二次出现禁止同方向重试，按 §7.4 记录；
4. 外部阻塞不绕过：不用 `--no-verify`、不关检查、不删工作流；如实记录阻塞点、证据与需要谁处理；
5. 合并后复核默认分支的 CI 终态；红则继续修，不把红留在 main。

**无 CI**：

1. 按 README / `docs/release-governance.md` 的命令跑构建、测试、lint；没有成文命令时，至少跑一次可复现的冒烟验证并记录命令与结果；
2. 失败按「复现 → 定位 → 最小修复 → 重跑」闭环；不跳过、不伪造通过；
3. 修复后重新提交（仍按 §17.2 分批）并推送；无远端的本地仓至少保证工作区干净、提交完整。

### 17.4 收尾汇报

最终回复必须给出：改了哪些文件、分了几批提交（列出 commit）、跑了哪些检查及结果、CI 终态、未解决项与风险。禁止用「应该没问题」「大概通过」代替证据；未完成就写未完成。

**可直接复制的自检块**：

```markdown
## 任务收尾自检
- [ ] `git status` 仅含本次改动，临时产物已清理
- [ ] 后台进程 / 本地服务已停止
- [ ] 提交按逻辑分批，显式路径，`-s` 签名
- [ ] 本地构建 / 测试 / lint 通过（记录命令）
- [ ] 有 CI：已盯到终态；无 CI：本地检查全绿
- [ ] 失败已修复，或如实记录外部阻塞
- [ ] 需要推送 / 合并的已完成，分支已清理
```

### 17.5 多 Agent 并发与开工前工作区判定（2026-10-23 新增）

**开工前四查（每个仓开始任务前必做）**：

1. `git fetch` + `git status --short` + `git log --oneline -5` + `git rev-list --left-right --count origin/main...HEAD`；
2. `git worktree list --porcelain`：同一仓多个工作区即多 agent 迹象；
3. `.git/agent-session.lock`：存在且心跳在 10 分钟内，视为有活跃会话；
4. 对 dirty 文件取 `LastWriteTime`，与当前时间比较：≤10 分钟 = 高度活跃；10–30 分钟 = 不确定，继续查锁/进程/近期提交；>30 分钟 = 大概率空闲。

**判定矩阵**：

| 工作区 | 其他 agent | 动作 |
|---|---|---|
| 干净 | 无 | 直接开始 |
| 干净 | 有 | 暂缓，或开独立分支 + PR |
| 不干净 | 有 | 暂缓 / 开分支 + PR；不碰当前工作树 |
| 不干净 | 无（mtime 久远 / 无锁） | 先解决遗留：逐项确认归属；能独立提交的单独提交；不能确认的保留并报告；禁止 reset / stash / 覆盖 |
| 不干净 | 不确定 | 按「有 agent」处理，暂缓或开分支 + PR |

**判定口径**：

- mtime 只是线索，必须与 worktree、锁、近期提交、远端分支组合判断；单看 mtime 不下结论。
- 活跃阈值默认 10 / 30 分钟；项目可调整，但必须在报告中写明实际阈值。
- 发现陌生提交或 `git status` 突然干净：先 `git log` / `git reflog` 取证，不覆盖、不 reset、不 force push。
- 遗留处理：只提交本次任务相关文件；无关 WIP 保持原样并在报告中列出；不得删除、stash 或 reset 用户改动。
- 锁过期：>30 分钟且进程不存在，核对后清理；活锁不删。

**处理**：

- **未检测到其他 agent**：原子获取 `.git/agent-session.lock`（session id / pid / 开始时间 / 心跳），按 §17.2 直推；收尾释放锁。
- **检测到**：不加共享锁，立即从当前 HEAD 开 `agent/<session>/<task>-<yyyymmddHHMM>`，在该分支提交并推送，开 PR；不碰 `main`。
- **共享文件**：`AGENTS.md`、根 README、`desired-state.json`、治理文档即使分支不同也要串行改；后到者等合并后 rebase。
- **收尾**：合并后删除分支与 worktree，释放锁；跑一次全量审计。

## 18. Markdown 文档健康规范（2026-10-23 新增）

**目标**：文档不仅要存在，还要能从正确入口被找到、链接可解析、副本不漂移、状态与平台一致。

**适用范围**：所有 tracked Markdown（README、`docs/**`、治理文档、模板、Issue / PR 模板）与本地 `AGENTS.md`。`local/` 与 `.qoder/` 属本地内容，不纳入 tracked 入链检查；被 tracked 文档引用时必须标注「本地文档，未随仓库发布」。

**与既有条款的关系**：文档放在哪里仍由 §7、§8、§12.4 决定；§18 只检查可发现性与一致性，不重新定义分流。

### 18.1 六项必查

| 项 | 要求 | 判红条件 |
|---|---|---|
| 入链 | 每个 tracked Markdown 至少有一个 tracked 入口链接（根 README、docs 索引、治理索引之一）；本地 `AGENTS.md` 可作本地入口，但不计入 tracked 入链 | 无入链的孤儿文档 |
| 路径 | 相对链接可解析；大小写与实际文件名一致 | 死链、迁移后旧路径、未标注的 `local/` 链接 |
| 命名 | 每个仓只有一个根 `AGENTS.md`（本地、不入库）；拆分文件统一 `local/agents/<module\|task>.md`；公开契约统一 `docs/agent-contract.md` | 同一内容两个名字，或与 §7.5 冲突 |
| 快照 | 历史文档中的计数、版本、状态必须带「截至 YYYY-MM-DD」，或改为指向 `desired-state.json` 等单一来源 | 无日期且与现状不符的计数 |
| 状态 | `archived` / WIP / 迁移中 / 已取代 必须与平台、`desired-state.json`、ADR 状态联动 | 归档恢复后声明未移除、WIP 无期限、旧 ADR 未标 Superseded |
| 执行件 | 规范变更时同步更新脚本注释、错误提示、模板与检查逻辑中的旧路径 / 旧条款 / 旧计数 | 规范与脚本提示冲突 |

### 18.2 编码与渲染

- 统一 LF；除确需 BOM 的文件外不带 BOM；禁止 CRLF 造成全文件 diff。
- 中文标题锚点易碎：跨文档引用优先链接文件，不依赖 `#中文标题`；必须用锚点时，改标题须同批改所有引用。
- 单文件超过 256 KB 或表格列数超过 8 时，拆分为子文档并在索引中登记。
- 嵌套代码围栏的外层反引号数量必须多于内层，避免渲染截断。

### 18.3 审计方式

- 首次全仓审查用只读脚本或手工清单完成，输出「孤儿、死链、旧路径、硬编码快照、状态残留、编码问题」六类报告。
- 本节暂不绑定新的 CI 门禁；待首次审查收敛后，再按 `delivery` 分档决定哪些检查升级为阻断。
- 与现有执行件分工：`self-purify.yml` 查本地治理文档是否误入库，`audit-drift.py` 查期望状态与平台漂移，§18 查文档自身是否可用。
- `AGENTS.md` 相关审查：按 §7 检查“是否只有一个本地根文件、是否被误跟踪、拆分文件标注是否完整”，不把本地文件缺失判为违规。
- **README 专项**：根 README 的站内 / 站外链接、图片 / GIF / 视频、badges、Topics、Release 与许可证状态，按 §8 的对外更新触发复核；死链、失效 badge、过时版本或状态判红。
