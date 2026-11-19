# 归档：四轮豁免历史原文（§一 / §二）

> 归档日：2026-11-19｜原路径：`governance/GOVERNANCE-EXCLUSIONS.md` §一–§二（原文行 34–114）
> 一句话结论：2026-10-18～10-21 的四轮豁免语义与 29 项清单，已被 ADR-0006 两轴模型取代，仅作留痕。
> 正文未改，逐字搬运。

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

