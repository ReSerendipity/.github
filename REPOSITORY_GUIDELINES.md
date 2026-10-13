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

- 所有仓库默认分支统一为 **`main`**（不使用 `master`）。
- `main` 分支受保护：
  - **账号本人（Doro / ReSerendipity）可直接推送**，跳过 PR 流程；
  - **其他协作者一律走 Pull Request**，不得直接推送 `main`。
- 功能开发使用独立分支（`feat/*`、`fix/*`、`ci/*`、`chore/*`），完成后合入 `main`。
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

## 4. 现网仓库命名对照（2026-10-13 更新）

### 保留名（品牌/专有词，6 个）

| 仓库 | 可见性 |
|---|---|
| Unity | private |
| SpiritPal | public |
| GalgameShell | public |
| DraftPeek | public |
| ReSerendipity | public |
| .github | public |

### 短横线命名（27 个）

| 仓库 | 可见性 |
|---|---|
| Image-MultiModel | public |
| TTS-MultiModel | public |
| SeedVR2-Lite | public |
| RTX-VSR-Lite | public |
| MiniMax-H3-Lite | public |
| ComfyUI-Experiment-Toolbox | public |
| Github-Repo-Scan | public |
| Health-Info-Card | public |
| Multi-Tracker | public |
| Unfading-Wall | public |
| Lineart-Painter | public |
| Card-Studio | public |
| ComfyUI-BatchPromptLoader | public |
| Mooncake-Deconstruction | public |
| Offer-Landing-Kit | public |
| Bilibili-Follow-Manager | private |
| Hugging-Face | private |
| Image-Scrapers | private |
| Nekogal-DL | private |
| Website-Genshin-Impact | private |
| Website-Honkai-Star-Rail | private |
| Website-Wuthering-Waves | private |
| Website-Zenless-Zone-Zero | private |
| DraftPeek-KeyBackup | private |
| Image-MultiModel-KeyBackup | private |
| SeedVR2-Lite-KeyBackup | private |
| TTS-MultiModel-KeyBackup | private |
| Agent-Knowledge | private |
| Prompt-Library | private |

> 2026-10-13 变更：`agent-knowledge` → `Agent-Knowledge`、`prompt-library` → `Prompt-Library`（远程 + 本地均已改名，旧名保留重定向）。

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

## 7. AGENTS.md 仅本地保留（2026-10-13 新增）

- 所有仓库的 `AGENTS.md` 及其家族（模块级 `AGENTS.md`、`docs/agents/**`、`FIX_LOG.md`、`LOCAL_RULES.md`）是 AI 辅助开发的**本地维护者上下文**，**不入库、不上传**。
- `.gitignore` 规则：`AGENTS.md`（无斜线模式，匹配任意深度子目录）。
- 误入库后的恢复流程：`git rm --cached <file>` + `.gitignore` 补规则 + commit + push（本地文件保留）。
- fresh clone / CI / 协作者环境中不存在 `AGENTS.md` 属**预期行为**；随仓库分发的 agent 权威入口为根 `README.md` 与 `.github/**`。
- 口径统一基线：DraftPeek / SeedVR2-Lite / SpiritPal / TTS-MultiModel / Image-MultiModel / MiniMax-H3-Lite 长期执行；GalgameShell / Github-Repo-Scan / Image-Scrapers / Prompt-Library 的历史误入库已于 2026-10-13 清除。

## 8. README 双版本制度（2026-10-13 新增）

每个仓库有且仅有两份 README，分工如下：

| 文件 | 定位 | 是否入库 |
|---|---|---|
| 根目录 `README.md` | **对外展示版**：这是什么、怎么用、怎么参与，面向 GitHub 访客 | 入库、GitHub 渲染 |
| `docs/README.internal.md` | **对内维护者说明**：本地环境约定、部署细节、内部字段引用、实验产物清单、维护者备忘 | **不入库**（.gitignore 排除） |

规则：

- 分流判据：**陌生用户读了能否行动**——能行动的写根 `README.md`；不能行动的一律进内部版，不得写回根 README。
- 内部版位置统一小写 `docs/README.internal.md`，**禁用** `DOCS/`（大写）变体；历史不一致仓 2026-10-13 已迁移（GalgameShell / Github-Repo-Scan）。
- 内部版不入库；已误入库的按 §7 恢复流程处理。
- 根 README 中的仓库链接与远程 URL 必须与实际仓库名大小写一致（例：Github-Repo-Scan 不得写 `github-repo-scan`）。

## 9. 本地产物与依赖不进库（2026-10-13 新增）

- 本地 agent 工作目录一律 ignore：`.qoder/`、`.workbuddy/`、`.workbuddy-ai/`、`.trae/`、`.zcode/` 等。
- `node_modules/` 等依赖目录默认不入库；**例外**：私有仓可显式声明「全量备份」策略将依赖纳入版本管理（如 `Image-Scrapers`，其 `.gitignore` 注释中的策略记录为权威依据）。
- 注意：`.gitignore` 规则对**已跟踪**文件无效——事后添加 ignore 规则不会取消跟踪；真实排除须 `git rm -r --cached`，但若该跟踪本身是仓级既定策略，应保持跟踪。
- 运行时日志与扫描快照（`*.log`、`server.log`、`scan_run*.txt` 等）不入库，已有约定以各仓 ADR 为准。
