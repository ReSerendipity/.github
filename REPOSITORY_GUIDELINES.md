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

## 2. 分支规范（Branch Convention）

- 所有仓库默认分支统一为 **`main`**（不使用 `master`）。**2026-10-19 起全账号达成**：最后一个 `master`（`ComfyUI-BatchPromptLoader`）已迁移（同 commit 建 `main` → PATCH 默认分支 → 删 `master`，workflow 无 `master` 硬编码，文档引用随 PR #5 同步）。
- `main` 分支受保护 —— **逐仓实测已完成（2026-10-19，41 仓全量，取数口径见下，零无法判定）**：
  - 本仓 `.github`：2026-10-17 此前实测为 `404 Branch not protected` + `rulesets: []`（即毫无保护），现已配置经典分支保护并回读确认 `protected=true`，必需检查为 `Workflow lint (actionlint + YAML)`、`DCO sign-off (Signed-off-by)`、`Reusable workflow smoke (self-purify) / 自净化核心规则（阻断）`、`Repository registry (§4 vs GitHub)` **四项**（第四项 2026-10-18 新增，见 §4），且禁止 force push 与删除分支。
  - **`enforce_admins=false`，这是有意的**：本账号是个人账号，若设为 true 会连账号本人都无法直推 `main`，与下面第一条既有约定冲突。代价必须写明白——**保护不约束账号本人**，本人仍可绕过上述四项；对非管理员协作者与 force-push/删除操作才是真约束。要让它也约束本人，需同时改写本节，属单独决定。
  - **账号本人（Doro / ReSerendipity）可直接推送**，跳过 PR 流程；
  - **其他协作者一律走 Pull Request**，不得直接推送 `main`。
  - **实测结果（2026-10-19）**：**11 仓 `protected=true`**——`.github`、`ComfyUI-Experiment-Toolbox`、`DraftPeek`、`GalgameShell`、`Github-Repo-Scan`、`Image-DuoModel`、`MiniMax-H3-Lite`、`ReSerendipity`、`SeedVR2-Lite`、`SpiritPal`、`TTS-MultiModel`（恰为有活跃 CI / 发布链的仓 + 规范仓自身）；**其余 30 仓 `protected=false`**。其中 23 仓属排除清单（2026-10-19 豁免升级：不适用整个规范，**无需保护考量**），故**待立项候选实为 7 仓**：`Agent-Knowledge`、`Card-Studio`、`Health-Info-Card`、`Image-Scrapers`、`Lineart-Painter`、`Nekogal-DL`、`Prompt-Library`。是否批量配置保护（同 `enforce_admins=false` 口径）属**待立项决定**，未配置前 GitHub 侧不会拦截直推 `main`。
  - 取数口径：公开仓返 404/空数组＝确无保护；私有仓在免费档下这两个请求返 403＝**无法判定**，不得据此写「未保护」。已配置后再判，须看 `branches/main` 的 `protected` 与 protection 回读的 `contexts` 数量，别只看有没有 404。本轮用 `GET /repos/<owner>/<repo>/branches/<default>` 的 `protected` 字段（认证态），41 仓全部返回明确布尔值，零 403。
- 功能开发使用独立分支（`feat/*`、`fix/*`、`ci/*`、`chore/*`），完成后合入 `main`。
- **合并后自动删除源分支（2026-10-20 新增）**：所有仓库必须将 GitHub 仓库级开关 **`delete_branch_on_merge` 设为 `true`**——PR 合并后由 GitHub 自动删除 head 分支，不依赖合并者手动加 `--delete-branch`（该参数易被遗漏，实测曾导致 13 仓积压 23 条已合并分支）。
  - 开关为**仓库级设置**，不是分支保护字段：`PATCH /repos/<owner>/<repo>` 的 `delete_branch_on_merge`。取数口径：`GET /repos/<owner>/<repo>` 的 `delete_branch_on_merge` 字段。
  - **不得删除的分支**：默认分支 `main`、Pages 部署目标 `gh-pages`、release-please 工作分支 `release-please--branches--main`（合并后由机器人自行重建，删除属正常行为）、以及刻意命名的归档/备份本地分支（`archive/*DO-NOT-PUSH*`、`backup/*`）——这些是**保留对象**，不是"漏删"。
  - **清理判据**：squash 合并会使分支不再是 `main` 的祖先，`git merge-base --is-ancestor` **不可作为判断依据**；应以其**关联 PR 状态为 `MERGED`** 为准。
  - 存量清理：开关开启后，已合并的残留分支需一次性清理（2026-10-20 已执行：13 管辖仓 23 条 + `.github` 12 条）。
  - 排除清单（`GOVERNANCE-EXCLUSIONS.md` 23 项）不适用本规范，不强制开启；已开启的一律保留。
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

## 4. 现网仓库命名对照（2026-10-16 更新）

### 保留名（品牌/专有词，5 个）

| 仓库 | 可见性 |
|---|---|
| SpiritPal | public |
| GalgameShell | public |
| DraftPeek | public |
| ReSerendipity | public |
| .github | public |

### 短横线命名（17 个）

| 仓库 | 可见性 |
|---|---|
| Image-DuoModel | public |
| TTS-MultiModel | public |
| SeedVR2-Lite | public |
| MiniMax-H3-Lite | public |
| ComfyUI-Experiment-Toolbox | public |
| Github-Repo-Scan | public |
| Health-Info-Card | public |
| Lineart-Painter | public |
| Card-Studio | public |
| Website-Genshin-Impact | private |
| Website-Honkai-Star-Rail | private |
| Website-Wuthering-Waves | private |
| Website-Zenless-Zone-Zero | private |
| Image-Scrapers | private |
| Nekogal-DL | private |
| Agent-Knowledge | private |
| Prompt-Library | private |

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
> 2026-10-19 变更（**豁免升级**，用户裁决）：**排除清单 17 项由「不适用 §10」升级为「不适用整个 REPOSITORY_GUIDELINES.md（§1-§11）」**。据此从本表移除 10 行：`Unity`（保留名）、`Multi-Tracker`、`Unfading-Wall`、`ComfyUI-BatchPromptLoader`、`Bilibili-Follow-Manager`、`Hugging-Face`（用户点名豁免 6 个中的 5 个短横线名）与 4 个 `*-KeyBackup`；保留名 6→5、短横线 32→23，全表 38→28 行。被移除仓不再参与 §1 命名校验与差集 B/C（脚本 `EXCLUDED_FROM_REGISTRY` 扩至 13 项），其存在与豁免语义由脚本声明与本仓 `GOVERNANCE-EXCLUSIONS.md` 承载。**已交付产物（发布文档、CHANGELOG、流水线）一律保留。**
>
> 2026-10-19 变更（**第二轮豁免**，用户裁决）：`Mooncake-Deconstruction`、`Offer-Landing-Kit`、`Android-IconAutoArrange`、`Free-Model-Probe`、`ChatGPT-Timezone-Fix`、`RTX-VSR-Lite` 六仓加入豁免清单（共 23 项）。本表再移除 6 行：短横线 23→17，全表 28→22 行；脚本 `EXCLUDED_FROM_REGISTRY` 扩至 19 项。
>
> 2026-10-18 追加：**备份仓 / 非台账副本不进本对照表**——`rewq`（非台账副本）、`Android-IconAutoArrange-Assets-Backup`（资源备份仓）、`Android-IconAutoArrange-KeyBackup`（密钥备份仓）三者未登记于此（2026-10-19 起表内也不再有任何 `*-KeyBackup` 行，本原则完全成立）。**豁免语义（2026-10-19 两轮升级后）**：排除清单 23 项整体豁免整个规范；脚本 `EXCLUDED_FROM_REGISTRY`（19 项）承载「台账 + 命名」维度的豁免载体——两者同源，不可只改一处。
>
> 2026-10-18 新增：本节对照表已从「本地命令手工跑」改为**远端 CI 门禁**——`ci.yml` 的 `repo-registry` 作业在任何 PR 与本仓推送时自动对账，并挂 `schedule` 周检（周一 03:00 UTC），覆盖「本仓无改动、台账却被外部动作改漂移」的场景。脚本与退出码口径不变（1=有差集，2=无法判定，两者都判红），本机不再需要跑它。该作业同时是 `main` 的必需检查之一（见 §2）。

## 5. 变更流程

- 重命名仓库：先改远程（`gh repo rename`，旧名保留重定向），再同步本地目录与 remote URL，详细步骤见 §6。
- 本地目录被占用（进程/Agent 活动）时不强行改名，等待释放后处理。
- 本规范变更需同步更新 `.github` 仓库中的本文件与 README 索引。

## 6. 本地目录与远程仓库一致性（2026-10-13 新增）

- 本地克隆目录名必须与远程仓库名**逐字符一致**（含大小写）：远程 `Image-Scrapers` ↔ 本地 `Image-Scrapers`。
- 远程重命名后本地同步三步：
  1. `gh repo rename <新名> -R <owner>/<旧名>`（GitHub 旧名自动重定向，外链不断）；
  2. 本地更新 remote URL：`git remote set-url origin https://github.com/<owner>/<新名>.git`；
  3. 本地目录改名（Windows 文件系统大小写不敏感，须两段式：`mv Old Old.__tmp__ && mv Old.__tmp__ New`）。
- 重命名后仓库内引用旧名的位置需同步更新：文档（README）、`.github/CODEOWNERS`、hooks、CI 配置。
- 已知历史偏差（2026-10-13 已全部对齐）：`image-scrapers`→`Image-Scrapers`、`MiniMax-H3-lite`→`MiniMax-H3-Lite`、`SeedVR2-lite`→`SeedVR2-Lite`（仅本地）；`prompt-library`→`Prompt-Library`、`agent-knowledge`→`Agent-Knowledge`（远程 + 本地）。
- 2026-10-17 追加对齐：远程 `Image-MultiModel` 经 `Image-duoModel` 两次改名后定为 `Image-DuoModel`；本机克隆目录与 remote URL 已按本节三步同步为 `Image-DuoModel`。

## 7. AGENTS.md 仅本地保留（2026-10-13 新增；2026-10-19 按可见性分流）

**本节适用范围：公开仓库。私有仓库走下方「私有仓例外」。**

- **公开仓**的 `AGENTS.md` 及其家族（模块级 `AGENTS.md`、`local/agents/**`、`FIX_LOG.md`、`LOCAL_RULES.md`）是 AI 辅助开发的**本地维护者上下文**，**不入库、不上传**。（2026-10-19：agent 家族目录由 `docs/agents/` 迁至 `local/agents/`，随 §13.1 的 `local/` 容器统一承载；已跟踪的 `docs/agents/**` 在迁移批次中同步 `git rm --cached`。）
- `.gitignore` 规则：`AGENTS.md`（无斜线模式，匹配任意深度子目录）。
- 误入库后的恢复流程：`git rm --cached <file>` + `.gitignore` 补规则 + commit + push（本地文件保留）。
- fresh clone / CI / 协作者环境中不存在 `AGENTS.md` 属**预期行为**；随仓库分发的 agent 权威入口为根 `README.md` 与 `.github/**`。
- 口径统一基线：DraftPeek / SeedVR2-Lite / SpiritPal / TTS-MultiModel / Image-DuoModel / MiniMax-H3-Lite 长期执行；GalgameShell / Github-Repo-Scan / Image-Scrapers / Prompt-Library 的历史误入库已于 2026-10-13 清除（后两仓现为私有，2026-10-19 起按下方例外转为**上传制**）。
- **行数上限：300 行（仅约束公开仓入库内容）**（2026-10-17 定）。数值不是拍来的，取自本机 14 个根级第一方 `AGENTS.md` 的实测分布：`min=21 median=90.5 p90=163 max=724`，其中 13 个 ≤300、合规簇最大 257 —— 300 因此不会追溯性地把既有文件全判红，又仍是真实约束。
  执行载体：`.github/scripts/check-agents-md-size.sh`（本地命令，非 CI —— 按本条规则公开仓的 `AGENTS.md` 不入库，CI 检出里根本没有该文件，放进 CI 只会是空跑闸）。
  调用：`bash .github/scripts/check-agents-md-size.sh --root <仓库目录>`；要挂成本地钩子由**各仓自行**把它写进自己的 `.git/hooks/pre-commit`（本 `.github` 仓没有 `AGENTS.md`，在此装钩子永远不触发，故本仓不预置）。
  扫描口径：只算活动文件，自动排除归档/备份副本、生成目录，以及**嵌套 git 仓**（其内容归那个仓自己判，`--include-nested` 可显式纳入）。
  现存欠账（2026-10-19 更新）：`MiniMax-H3-Lite/comfy_kernel/AGENTS.md` 361 行、`Image-DuoModel/comfy_kernel/AGENTS.md` 386 行（均为公开仓，欠账保留；后者由 2026-10-19 文档审查补登记，此前漏记）。原 `Prompt-Library/AGENTS.md` 724 行一条已随私有仓例外**改判豁免**（私有仓不受 300 行上限约束）。

**私有仓例外（2026-10-19 新增）**：

- 私有仓**不适用**"仅本地保留"——相反，**要求尽可能把本地维护者上下文上传入库**作为备份，包括但不限于：根/模块级 `AGENTS.md`、`local/agents/**`、`local/README.internal.md`、`FIX_LOG.md`、`LOCAL_RULES.md`（存在哪些传哪些；确实没有的如实记录"无可上传"，不编造）。
- 上传方式：调整各仓 `.gitignore` 中对应忽略规则（移除或加白名单），走分支 + PR 合入默认分支。
- 私有仓的 `AGENTS.md` **不受 300 行上限约束**（上传属备份性质，该上限只约束公开仓的入库质量）。
- **绝对例外 `rewq`**：内含服务器密钥与 SSH 备份，**任何新增内容不上传**；该仓冻结于本地，仅保留本地 git 管理，不新推（2026-10-19 裁决）。
- **豁免仓不在本要求范围内（2026-10-19）**：排除清单 23 项已升级为不适用整个规范（见 §10），故清单内私有仓（`Bilibili-Follow-Manager`、`Hugging-Face`、`Unity`、4 个网站仓、6 个备份仓）**不受本上传制约束**；此前已完成/已存在的上传一律保留。

## 8. README 双版本制度（2026-10-13 新增；2026-10-19 按可见性分流）

**本节适用范围：公开仓库。私有仓见下方例外。**

每个仓库有且仅有两份 README，分工如下：

| 文件 | 定位 | 是否入库（公开仓） |
|---|---|---|
| 根目录 `README.md` | **对外展示版**：这是什么、怎么用、怎么参与，面向 GitHub 访客 | 入库、GitHub 渲染 |
| `local/README.internal.md` | **对内维护者说明**：本地环境约定、部署细节、内部字段引用、实验产物清单、维护者备忘 | **不入库**（§13.1 `local/` 容器整体 ignore；2026-10-19 由 `docs/README.internal.md` 迁位） |

规则：

- 分流判据：**陌生用户读了能否行动**——能行动的写根 `README.md`；不能行动的一律进内部版，不得写回根 README。
- 内部版位置统一 `local/README.internal.md`（§13.1 `local/` 容器）；历史形态 `docs/README.internal.md` 与大写 `DOCS/` 变体均为旧位（`DOCS/` 历史 2026-10-13 已迁移 GalgameShell / Github-Repo-Scan；`docs/` 前缀 2026-10-19 起统一迁 `local/`）。
- 内部版不入库；已误入库的按 §7 恢复流程处理。
- 根 README 中的仓库链接与远程 URL 必须与实际仓库名大小写一致（例：Github-Repo-Scan 不得写 `github-repo-scan`）。
- **私有仓例外（2026-10-19 新增）**：私有仓不强制双版本分流，`local/README.internal.md` **应当入库**（与 §7 私有仓例外同理——尽可能上传作备份）；分流判据在私有仓仅作编写建议，不作入库闸。

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
> **2026-10-19 豁免升级（用户裁决）**：下方排除清单由「不适用 §10」升级为「不适用整个 REPOSITORY_GUIDELINES.md（§1-§11）」——不再要求、不再审计本规范任何章节（含 §1 命名、§2 保护、§4 台账、§7/§8、§10）；同日**第二轮点名**再增 6 仓，清单共 **23 项**。台账/命名维度的执行载体见 §4 的 2026-10-19 变更记录与脚本 `EXCLUDED_FROM_REGISTRY`（19 项）。已交付产物（发布文档、CHANGELOG、流水线、AGENTS.md 上传）**一律保留**。
>
> 下发方式：**逐仓开分支 + 开 PR + 合并**（不直推默认分支）；文档一律以本仓 `RELEASE_GOVERNANCE_TEMPLATE.md` 为结构、以本节为公共条款，只填本仓特有项，不得改写公共条款。
>
> **排除清单（2026-10-19 豁免升级：整部规范不适用，共 23 项，逐条留痕）**：
>
> - **密钥 / 资产备份仓（6 个，按 §3 属备份仓、无发布链）**：`DraftPeek-KeyBackup`、`Image-DuoModel-KeyBackup`（2026-10-19 前名 `Image-MultiModel-KeyBackup`，随父仓改名跟进）、`SeedVR2-Lite-KeyBackup`、`TTS-MultiModel-KeyBackup`、`Android-IconAutoArrange-KeyBackup`（2026-10-18 补录，此前误记为"4 个"）、`Android-IconAutoArrange-Assets-Backup`（内含加密签名密钥的口令台账与 PoC APK）。
> - **网站仓（4 个）**：`Website-Genshin-Impact`、`Website-Honkai-Star-Rail`、`Website-Wuthering-Waves`、`Website-Zenless-Zone-Zero`。
> - **非 §4 台账副本（1 个）**：`rewq`。
> - **用户点名豁免（6 个，2026-10-18）**：`ComfyUI-BatchPromptLoader`、`Multi-Tracker`、`Bilibili-Follow-Manager`、`Hugging-Face`、`Unfading-Wall`、`Unity`。
> - **用户点名豁免（第二轮，6 个，2026-10-19）**：`Mooncake-Deconstruction`、`Offer-Landing-Kit`、`Android-IconAutoArrange`、`Free-Model-Probe`、`ChatGPT-Timezone-Fix`、`RTX-VSR-Lite`。
>   **语义边界（重要）**：豁免**只表示"不再要求、不再审计 §10"**；这些仓此前已落地的 `docs/release-governance.md`、根级 `CHANGELOG.md` 与发布链改动**一律保留、不删除、不回滚**。若将来要撤销这些产物，属单独决定。
>
> 维护规则：本清单与 §4 台账表、`check-repo-registry.sh` 的 `EXCLUDED_FROM_REGISTRY`、`check-release-standard.sh` 的 `EXCLUDED_FROM_RELEASE_STANDARD`、以及本仓根 `GOVERNANCE-EXCLUSIONS.md` **五处同步修改**。

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

## 13. 路径规范（Path Convention，2026-10-19 新增）

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