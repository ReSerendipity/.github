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

## 4. 现网仓库命名对照（2026-09-29 生效）

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

## 5. 变更流程

- 重命名仓库：先改远程（`gh repo rename`，旧名保留重定向），再同步本地目录与 remote URL。
- 本地目录被占用（进程/Agent 活动）时不强行改名，等待释放后处理。
- 本规范变更需同步更新 `.github` 仓库中的本文件与 README 索引。
