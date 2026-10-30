# 治理分档与例外记录（GOVERNANCE-EXCLUSIONS）

> **本文件定位**：治理分档与例外记录的**正式载体**，承载于规范仓（2026-10-19 由本地根目录移入，随仓版本管理）。
> **权威条款**：`REPOSITORY_GUIDELINES.md` §15（治理分档）与 §4（命名台账）。
> **最后更新**：2026-10-30（定稿「远程优先、本地最少化」：公开仓 Actions 为免费额度，`schedule` 周检/月度 cron 恢复并与 `workflow_dispatch` 并存，§五载体表同步；`RELEASE_GOVERNANCE_TEMPLATE.md` 自仓根迁入 `governance/templates/`（在途 WIP 前置已消除），§五路径同步；新增 `MiniMax-H3-Lite-KeyBackup`、口令入库例外与 §十 私有资产备份仓的本地上下文例外见 2026-10-29 记录；README 展示图例外见 2026-10-25 记录；self-purify 翻转与 SeedVR2-Lite 本地治理目录公开例外见 2026-10-24 记录）
> **同步规则（改一处即改五处）**：
> 1. 规范仓 `REPOSITORY_GUIDELINES.md` 的 §15 与 §4
> 2. 校验脚本 `check-repo-registry.sh` 的 `EXCLUDED_FROM_REGISTRY`（8 项备份仓）
> 3. 校验脚本 `check-release-standard.sh` 的 `EXCLUDED_FROM_RELEASE_STANDARD`（37 项非 release 仓，48 − 11）
> 4. `governance/README.md` 与根 `README.md` 的索引
> 5. 本文件

---

## 零、现行口径（2026-10-22 起，ADR-0006）

**本文件自 2026-10-22 起是「治理分档与例外记录」，不再是「整部规范不适用」的白名单。** 现行规则：

1. **`delivery=backup` 的 8 个仓**（密钥 / 资产备份仓）整部规范不适用，只按 §3 的 `<项目名>-KeyBackup` 结构、`SHA256SUMS.txt` 与轮换更新要求管理；不进 §4 台账，不参与 §1 命名与 §10 审计。
2. **其余 40 个仓**按 §15 的 `delivery × lifecycle` 派生适用条款；`lifecycle` 只决定变更许可与审计频率，不改变条款范围。
3. **命名例外**（品牌 / 系统保留名 / 已登记债务）见 §4「例外名」表；新增例外须先落 ADR。
4. **`rewq` 的硬约束收窄**：`.gitignore` 必须排除 `ssh-backup/`、`.ssh/` 与 `*.pem` / `*.key` 等私钥；正常提交与推送不受限制（§15.5）。

> 下面第一至五节是 2026-10-18 至 10-21 的四轮豁免**历史原文**，仅作留痕；「29 项不适用整部规范」的语义**已被 ADR-0006 取代**，不再作为执行依据。

---

## 一、旧豁免语义（2026-10-19 / 10-21，已被 ADR-0006 取代）

**清单内 29 个仓库不适用整个 `REPOSITORY_GUIDELINES.md`（§1-§14）**——升级前仅豁免 §10（发布规范）；2026-10-21 起明确 §12（结构）/§13（路径）/§14（硬编码）同样不适用。

| 维度 | 升级前（2026-10-18） | 升级后（2026-10-19） |
|---|---|---|
| §10 发布/分发 | 部分不适用 | **不适用**（全部 29 项） |
| §1 命名 / §4 台账 | 部分适用（用户点名仓仍在台账内） | **不适用**（点名仓已移出台账，`EXCLUDED_FROM_REGISTRY` 25 项） |
| §2 分支保护 | 逐仓实测时一并测量 | **无需保护考量**（实测时均无保护，保持现状） |
| §7/§8 AGENTS.md / README | 私有仓按上传制 | **不受上传制约束**；此前已完成/已存在的上传**一律保留** |
| §3 密钥备份 / §5-§6 / §9 / §11 | 按适用范围执行 | 不适用 |

**不变的边界**：

- **已交付产物一律保留**：17 个点名仓的 `docs/release-governance.md`、根级 `CHANGELOG.md`、发布链改动、AGENTS.md 上传——**不删除、不回滚**。豁免只表示"不再要求、不再审计"；将来要撤销产物属单独决定。
- **仓库本体不动**：豁免≠删除；所有仓仍在 GitHub 上，可见性不变。
- **`rewq` 绝对例外**：内含服务器密钥与 SSH 备份，**任何新增内容不上传**；冻结于本地，仅保留本地 git 管理（§7 条款同步记载）。（**已被 ADR-0006 取代**：自 2026-10-22 起 rewq 仅受 `.gitignore` 私钥排除约束，正常提交与推送不受限；见 §零 第 4 条。）

---

## 二、豁免清单（29 项）

### 1. 密钥 / 资产备份仓（8 个）

按 §3 属备份仓，无发布链、无版本位；**均不在 §4 台账内**。此类仓**按性质即须豁免**（2026-10-20 用户裁决：密钥/资产备份仓不需要按规范管理），不逐仓审批。

| 仓 | 私有 | 说明 |
|---|---|---|
| `DraftPeek-KeyBackup` | ✅ | §3 模式原型；仅含 `.enc.7z` + SHA256SUMS + README |
| `Image-DuoModel-KeyBackup` | ✅ | 2026-10-19 由 `Image-MultiModel-KeyBackup` 改名（随父仓 `Image-DuoModel` 对齐 §3 模式） |
| `SeedVR2-Lite-KeyBackup` | ✅ | 同结构 |
| `TTS-MultiModel-KeyBackup` | ✅ | 同结构 |
| `Android-IconAutoArrange-KeyBackup` | ✅ | 2026-10-18 补录（此前误记为"4 个 `*-KeyBackup`"） |
| `Android-IconAutoArrange-Assets-Backup` | ✅ | 内含加密签名密钥的**口令台账** + PoC 运行时 APK（口令入库例外，风险见下） |
| `SpiritPal-KeyBackup` | ✅ | 2026-10-20 补录（按 §3 模式新建于 2026-10-20，此前遗漏未入清单） |
| `MiniMax-H3-Lite-KeyBackup` | ✅ | 2026-10-29 新建；old/new 两组 Ed25519 清单签名密钥，7z AES-256 + `-mhe=on`；含 `backup-passwords.txt`（口令入库例外，风险见下） |

> **口令入库例外（2026-10-29）**：`Android-IconAutoArrange-Assets-Backup` 与 `MiniMax-H3-Lite-KeyBackup` 按 owner 决定在私有仓保存 `backup-passwords.txt`。这放弃了“加密包被单独泄漏”以外的全部防护：账号失守时加密等同失效；两仓 README 均写明该风险。

### 2. 网站仓（4 个，均私有）

`Website-Genshin-Impact`、`Website-Honkai-Star-Rail`、`Website-Wuthering-Waves`、`Website-Zenless-Zone-Zero`。
这些仓历史 `AGENTS.md` 体积（43634/58432/66226/20462 字节，2026-10-19 复核）；按 §7 目标原应迁移为本地不入库文件，曾列入 §7.1 的 26 仓迁移欠账（归档仓另计），不因本节豁免而跳过。截至 2026-10-29 复核，四仓均已完成迁移，`AGENTS.md` 已不在 GitHub 跟踪；§7.1 的非归档仓迁移欠账已清零（`GalgameShell`、`Prompt-Library` 经现场核对已取消跟踪）。

### 3. 非台账副本（1 个，私有）

`rewq`——**冻结仓**（见上）。默认分支 `main` @ `baae7dd`（2026-10-16），内容含 `ssh-backup/`、`服务器信息备忘.md`、`push.sh`。

### 4. 用户点名豁免（13 个，三轮）

| 轮次 | 仓 | 可见性 |
|---|---|---|
| 第一轮（2026-10-18） | `ComfyUI-BatchPromptLoader` | public（默认分支 2026-10-19 起为 `main`） |
| 第一轮（2026-10-18） | `Multi-Tracker` | public |
| 第一轮（2026-10-18） | `Unfading-Wall` | public |
| 第一轮（2026-10-18） | `Bilibili-Follow-Manager` | private |
| 第一轮（2026-10-18） | `Hugging-Face` | private |
| 第一轮（2026-10-18） | `Unity` | private |
| 第二轮（2026-10-19） | `Mooncake-Deconstruction` | public |
| 第二轮（2026-10-19） | `Offer-Landing-Kit` | public |
| 第二轮（2026-10-19） | `Android-IconAutoArrange` | public |
| 第二轮（2026-10-19） | `Free-Model-Probe` | public |
| 第二轮（2026-10-19） | `ChatGPT-Timezone-Fix` | public |
| 第二轮（2026-10-19） | `RTX-VSR-Lite` | public |
| 第三轮（2026-10-20） | `Code-Time-Machine-1024` | public（TRAE 1024Builder 展示站；分段 `1024` 以数字开头，不合 §1 Train Case，因整体豁免不作整改；撤销豁免前须先改名为合规写法并补登 §4 台账） |

> 这些仓此前已落地的产物（发布文档 / CHANGELOG / 流水线 / AGENTS.md）**全部保留**；
> 历史收敛记录见规范仓 §10.6。

### 5. 用户点名豁免（第四轮，2026-10-21，4 个）

| 仓 | 可见性 | 理由 |
|---|---|---|
| `p0-murder-mystery` | public | 用户点名豁免；无豁免前置条件（当时不在 §4 台账内） |
| `Health-Info-Card` | public | 用户点名豁免；原登记于 §4 短横线命名表，随本轮移出 |
| `Lineart-Painter` | public | 用户点名豁免；原登记于 §4 短横线命名表，随本轮移出 |
| `Card-Studio` | public | 用户点名豁免；原登记于 §4 短横线命名表，随本轮移出 |

> 本轮四仓均为 public，**无豁免前置条件**（不依赖备份仓性质、不依赖可见性），语义沿用
> 2026-10-19 裁决：不适用整部 `REPOSITORY_GUIDELINES.md`（§1-§14），已交付产物一律保留。

---

## 三、脚本载体对照（豁免的可执行形态）

| 脚本 | 清单名 | 项数 | 覆盖维度 |
|---|---|---|---|
| `check-repo-registry.sh` | `EXCLUDED_FROM_REGISTRY` | **8** | 差集 B/C 只看备份仓；其余 40 仓全部参与 §1 命名校验 |
| `check-release-standard.sh` | `EXCLUDED_FROM_RELEASE_STANDARD` | **37** | §10 收敛审计只覆盖 11 个 `release` 仓（48 − 11 = 37） |

> 如某备份仓**转为公开**，仍需保留在 `EXCLUDED_FROM_REGISTRY`（否则差集 B/C 报红）——脚本注释已写明。

---

## 四、账号仓总览（2026-10-29 复核，共 48 个）

| 分组 | 数量 | 说明 |
|---|---|---|
| **§4 登记（含规范仓）** | 40 | 按 §15 派生适用条款；命名例外见 §4 |
| **备份仓** | 8 | `delivery=backup`，只按 §3 管理，不进 §4 |
| 合计 | 48 | `gh repo list ReSerendipity` 实测 48 个，零差额 |

### §4 台账现状（2026-10-24 复核）

- 台账登记 **40 条**（例外名 8 + Train Case 32），覆盖全部非 `backup` 仓。
- 台账之外的备份仓 **8 个**，全部在 `EXCLUDED_FROM_REGISTRY` 显式声明。
- 合并前 `check-repo-registry.sh` 与 `check-governance-consistency.sh` 必须 `rc=0`。

### 分支保护实测（2026-10-19，41 仓全量，零无法判定）

- `protected=true`（11）：`.github`、ComfyUI-Experiment-Toolbox、DraftPeek、GalgameShell、Github-Repo-Scan、Image-DuoModel、MiniMax-H3-Lite、ReSerendipity、SeedVR2-Lite、SpiritPal、TTS-MultiModel。
- `protected=false`（30）：其中 23 仓属本豁免清单（2026-10-19 实测口径；清单现为 29 项，无需考量）；**候选 7 仓**：Agent-Knowledge、Card-Studio、Health-Info-Card、Image-Scrapers、Lineart-Painter、Nekogal-DL、Prompt-Library。（2026-10-21 第四轮豁免后，Card-Studio / Health-Info-Card / Lineart-Painter 已豁免，**候选 4 仓**：Agent-Knowledge、Image-Scrapers、Nekogal-DL、Prompt-Library。**2026-10-29 复核：这 4 仓均为私有仓，按 ADR-0004 属平台能力缺口，待立项项关闭，不再作为保护欠账。**）

---

## 五、规范仓自身的强制载体（供对照）

| 载体 | 强制的条款 | 性质 |
|---|---|---|
| `ci.yml` 六个 CI 作业（`Workflow lint` / `DCO sign-off` / `self-purify（阻断）` / `Repository registry`（含 `check-governance-consistency.sh --public-only`）/ `Governance gates negative tests` / `Release standard audit`） | §1 / §2 / §4 / §7-§8 / 提交签名 / §15 期望状态一致性（公开子集）/ §10 周检审计 | 硬门禁 + 周检（2026-10-30 定稿：远程优先、本地最少化，schedule 与手动并存） |
| `.github/scripts/check-repo-registry.sh` | §4 台账 + §1 命名 + 台账豁免声明（8 项） | CI + 周检 |
| `.github/scripts/check-release-standard.sh` | §10 收敛核验（豁免 37 项） | 周检审计（2026-10-19 挂入 `ci.yml` schedule，2026-10-30 起另可 `workflow_dispatch` 手动派发） |
| `.github/scripts/check-agents-md-size.sh` | §7 的 300 行上限（仅公开仓） | 本地命令 |
| `governance/templates/RELEASE_GOVERNANCE_TEMPLATE.md` | §10 下发模板 | 模板 |

---

## 六、生成物入库例外（按仓登记，2026-10-24）

§9 默认要求构建产物与运行时快照不入库。下列仓因分发或历史决策需要，**登记为例外**；除表内文件外不得新增同类入库：

| 仓库 | 文件 | 理由 | 依据 |
|---|---|---|---|
| `Github-Repo-Scan` | `scan-data.json`、`dashboard.html`、`all_repos_report.txt`、`scan_run*.txt` | 每次扫描的快照随主分支入库以保留可回溯性，接受大 diff | 本仓 `docs/adr/0003-snapshot-committing.md` |
| `P0-Murder-Mystery` | `index.html`、`P0事故剧本杀.html` | `build.py` 生成的单文件游戏；`index.html` 为 Pages legacy 入口，另一份为分享副本 | 本仓 `README.md`「构建与输出」 |
| `SpiritPal` | `src-tauri/binaries/spiritpal-mcp-*`（5 个：4 个 Android triple + 1 个 Windows） | Android `externalBin` 所需的预编译 sidecar；当前无 Android 交叉构建步骤，移除会阻断打包。Windows 副本由 CI 每次重建，待清理 | 本仓 `ci.yml` externalBin 注释 |

> 例外仅限上表；新增生成物入库须先修改本节并说明可验证理由。`Image-DuoModel` 的 `release/build_metadata.json` / `release/sbom.json` 已于 2026-10-24 改为不入库。

---

## 七、本地治理目录公开例外（按仓登记，2026-10-24；2026-10-29 补登 SpiritPal 与家族基线白名单）

§7.1 默认要求 `docs/plans|project|_devarchive|agents|execution` 为本地治理目录、不入库。下列仓已将其中部分目录作为**公开文档层**随仓分发（`docs/DOD.md` 等要求新增模块在模块图登记），经裁决登记为例外：

| 仓库 | 例外路径 | 理由 | 载体 | 解除条件 |
|---|---|---|---|---|
| `SeedVR2-Lite` | `docs/plans/`、`docs/project/` | 部署手册与架构 / 约束 / 模块图 / 上手引导属随仓分发的公开文档，移出会打断仓内引用链 | 本仓 `self-purify.yml` 传 `extra_exempt_regex: '^docs/(plans\|project)/'` | 文档迁出受限目录并更新引用后删除该输入 |
| `SpiritPal` | `docs/execution/` | 执行记录与证据截图按本仓 LOCAL_RULES 定为公开层归档，随仓分发以保留可回溯证据 | 本仓 `self-purify.yml` 传 `extra_exempt_regex: '^docs/execution/'` | 执行记录迁出受限目录并更新引用后删除该输入 |

> 例外由调用仓在自身 workflow 声明，家族基线不放宽；新增同类例外须先登记本节。

### 7.1 家族基线白名单（不按仓登记，2026-10-29）

`self-purify.yml` 的基线正则固定放行以下已审定文件，属全家族例外，不在按仓表中逐仓重复登记：

- `docs/execution/RELEASE_VERIFICATION.md`（§10.5 发布验证产物）
- `docs/execution/执行对照表-桌面分发与安全加固-20260910.md`、`docs/execution/落地执行总结-桌面分发与安全加固-20260910.md`、`docs/execution/依赖与安全跟踪机制-20260911.md`
- `docs/project/KNOWN_GOTCHAS.md`、`docs/project/AI_DEV_SOPS.md`
- `docs/reports/执行对照表-桌面分发与安全加固-20260910.md`、`docs/reports/落地执行总结-桌面分发与安全加固-20260910.md`（当前不在受限目录正则内，保留以防正则扩展）

> 本清单与 `self-purify.yml` 的白名单正则必须同步修改；改一处即视为改全家族门禁。

---

## 八、暂缓项（非豁免，2026-10-24）

- `Website-Genshin-Impact`、`Website-Honkai-Star-Rail`、`Website-Wuthering-Waves`、`Website-Zenless-Zone-Zero`：§8 README 对外装修与 §14 本地路径清理**暂缓**。这是用户明确的暂缓，不是豁免；四仓仍按 `delivery=service` 参与其余条款。解除条件：用户明确要求，或对外可见性变化。
- `Unity`（private / tool / maintenance）：游戏类项目，位于另一台设备，用户 2026-10-24 明确暂缓；`local/README.internal.md` 未补，其余条款保留约束。解除条件：设备可用且用户明确要求。

---

## 九、README 展示图例外（按仓登记，2026-10-25）

§8 要求公开仓根 README 至少 1 张展示图。下列仓无 UI、无可视产物，架构图只会重复正文，经裁决**本轮 README 改造整仓跳过**（不补图，也不改双语 / 徽章），登记以防被视为漏项：

| 仓库 | 豁免范围 | 理由 | 解除条件 |
|---|---|---|---|
| `Website-Site-Toolchain` | 根 README 全部改造项 | 纯 CLI 结构签名门禁工具链，无界面、无产物截图；架构图与正文重复，不产生展示价值 | 出现可视化产物，或用户明确要求改造时 |

> 其余 17 个公开非归档仓仍按 §8 执行（中英双语、展示图、徽章、Topics）。

---

## 十、私有资产备份仓的本地上下文例外（2026-10-29）

§7.1 默认要求 `AGENTS.md` 不入库。`MiniMax-H3-Lite-Local` 是公开仓 `MiniMax-H3-Lite` 的私有资产备份仓，`overlay/local/` 即其备份对象；删除会丢失本地上下文。经复核登记例外：

| 仓库 | 例外路径 | 理由 | 载体 | 解除条件 |
|---|---|---|---|---|
| `MiniMax-H3-Lite-Local` | `overlay/local/`（含 `AGENTS.md`、`agents/**`） | 私有资产备份仓的本职即备份公开仓不入库的本地上下文 | `desired-state.json` 的 `tracked_agents_allow: ["overlay/local/"]`；`audit-drift.py` 按前缀放行 | 该仓不再承担备份职责，或本地上下文迁出 `overlay/local/` |

> 该例外不放宽其他私有仓：未登记 `tracked_agents_allow` 的仓仍按 §7.1 判红。

