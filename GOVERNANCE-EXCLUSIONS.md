# 治理豁免清单（GOVERNANCE-EXCLUSIONS）

> **本文件定位**：治理豁免清单的**正式记录**，承载于本规范仓（2026-10-19 由本地根目录移入，随仓版本管理）。
> **权威条款**：`REPOSITORY_GUIDELINES.md`（§10 范围声明 / §4 变更记录）。
> **最后更新**：2026-10-20（第三轮点名 +1、备份仓补录 +1，清单共 25 项；豁免 = 不适用整部规范）
> **同步规则（改一处即改五处）**：
> 1. 规范仓 `REPOSITORY_GUIDELINES.md` §10 范围声明的排除清单
> 2. 规范仓 §4 台账表（豁免仓**不登记**）与 §4 变更记录
> 3. 校验脚本 `check-repo-registry.sh` 的 `EXCLUDED_FROM_REGISTRY`（21 项台账载体）
> 4. 校验脚本 `check-release-standard.sh` 的 `EXCLUDED_FROM_RELEASE_STANDARD`（25 项审计载体）
> 5. 本文件

---

## 一、豁免语义（2026-10-19，用户两轮裁决）

**清单内 25 个仓库不适用整个 `REPOSITORY_GUIDELINES.md`（§1-§11）**——升级前仅豁免 §10（发布规范）。

| 维度 | 升级前（2026-10-18） | 升级后（2026-10-19） |
|---|---|---|
| §10 发布/分发 | 部分不适用 | **不适用**（全部 25 项） |
| §1 命名 / §4 台账 | 部分适用（用户点名仓仍在台账内） | **不适用**（点名仓已移出台账，`EXCLUDED_FROM_REGISTRY` 21 项） |
| §2 分支保护 | 逐仓实测时一并测量 | **无需保护考量**（实测时均无保护，保持现状） |
| §7/§8 AGENTS.md / README | 私有仓按上传制 | **不受上传制约束**；此前已完成/已存在的上传**一律保留** |
| §3 密钥备份 / §5-§6 / §9 / §11 | 按适用范围执行 | 不适用 |

**不变的边界**：

- **已交付产物一律保留**：29 仓（含清单内 12 个点名仓）的 `docs/release-governance.md`、根级 `CHANGELOG.md`、发布链改动、AGENTS.md 上传——**不删除、不回滚**。豁免只表示"不再要求、不再审计"；将来要撤销产物属单独决定。
- **仓库本体不动**：豁免≠删除；所有仓仍在 GitHub 上，可见性不变。
- **`rewq` 绝对例外**：内含服务器密钥与 SSH 备份，**任何新增内容不上传**；冻结于本地，仅保留本地 git 管理（§7 条款同步记载）。

---

## 二、豁免清单（25 项）

### 1. 密钥 / 资产备份仓（7 个）

按 §3 属备份仓，无发布链、无版本位；**均不在 §4 台账内**。此类仓**按性质即须豁免**（2026-10-20 用户裁决：密钥/资产备份仓不需要按规范管理），不逐仓审批。

| 仓 | 私有 | 说明 |
|---|---|---|
| `DraftPeek-KeyBackup` | ✅ | §3 模式原型；仅含 `.enc.7z` + SHA256SUMS + README |
| `Image-DuoModel-KeyBackup` | ✅ | 2026-10-19 由 `Image-MultiModel-KeyBackup` 改名（随父仓 `Image-DuoModel` 对齐 §3 模式） |
| `SeedVR2-Lite-KeyBackup` | ✅ | 同结构 |
| `TTS-MultiModel-KeyBackup` | ✅ | 同结构 |
| `Android-IconAutoArrange-KeyBackup` | ✅ | 2026-10-18 补录（此前误记为"4 个 `*-KeyBackup`"） |
| `Android-IconAutoArrange-Assets-Backup` | ✅ | 内含加密签名密钥的**口令台账** + PoC 运行时 APK |
| `SpiritPal-KeyBackup` | ✅ | 2026-10-20 补录（按 §3 模式新建于 2026-10-20，此前遗漏未入清单） |

### 2. 网站仓（4 个，均私有）

`Website-Genshin-Impact`、`Website-Honkai-Star-Rail`、`Website-Wuthering-Waves`、`Website-Zenless-Zone-Zero`。
根 `AGENTS.md` 早已入库（43634/58432/66226/20462 字节，2026-10-19 复核）。

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

---

## 三、脚本载体对照（豁免的可执行形态）

| 脚本 | 清单名 | 项数 | 覆盖维度 |
|---|---|---|---|
| `check-repo-registry.sh` | `EXCLUDED_FROM_REGISTRY` | **21** | §4 台账差集 B/C + §1 命名校验（25 − 4 个私有网站仓〔公开端点不可见、固有覆盖〕= 21） |
| `check-release-standard.sh` | `EXCLUDED_FROM_RELEASE_STANDARD` | **25** | §10 收敛审计（全量豁免） |

> 如某豁免仓**转为公开**，需把它补进 `EXCLUDED_FROM_REGISTRY`（否则差集 B/C 报红）——脚本注释已写明。

---

## 四、账号仓总览（2026-10-20 实测，共 43 个）

| 分组 | 数量 | 说明 |
|---|---|---|
| **规范管辖中** | 17 | 受整部规范约束（§1-§11）；均有发布文档 + 根级 CHANGELOG（历史产物保留） |
| **豁免（清单 25 项）** | 25 | 不适用整部规范；产物保留 |
| **规范仓自身** | 1 | `.github`（规范由本仓承载，不属被管辖对象） |

合计 17 + 25 + 1 = **43**（`gh repo list ReSerendipity` 实测 43 个，零差额）。

### §4 台账现状（2026-10-19 两轮豁免后）

- 台账登记 **22 条**（保留名 5 + 短横线 17）——只含管辖中的仓。
- 远程有而表里无的 **21 个**，全部在 `EXCLUDED_FROM_REGISTRY` 显式声明。
- `check-repo-registry.sh` 本地实测（2026-10-19）：`clean：§4 对照表与远程一致`。

### 分支保护实测（2026-10-19，41 仓全量，零无法判定）

- `protected=true`（11）：`.github`、ComfyUI-Experiment-Toolbox、DraftPeek、GalgameShell、Github-Repo-Scan、Image-DuoModel、MiniMax-H3-Lite、ReSerendipity、SeedVR2-Lite、SpiritPal、TTS-MultiModel。
- `protected=false`（30）：其中 23 仓属本豁免清单（2026-10-19 实测口径；清单现为 25 项，无需考量）；**待立项候选 7 仓**：Agent-Knowledge、Card-Studio、Health-Info-Card、Image-Scrapers、Lineart-Painter、Nekogal-DL、Prompt-Library。

---

## 五、规范仓自身的强制载体（供对照）

| 载体 | 强制的条款 | 性质 |
|---|---|---|
| `ci.yml` 五项检查（`Workflow lint` / `DCO sign-off` / `self-purify（阻断）` / `Repository registry` / `Release standard audit`） | §1 / §2 / §4 / §7-§8 / 提交签名 / §10 周检审计 | 硬门禁 + 周检 |
| `.github/scripts/check-repo-registry.sh` | §4 台账 + §1 命名 + 台账豁免声明（21 项） | CI + 周检 |
| `.github/scripts/check-release-standard.sh` | §10 收敛核验（豁免 25 项） | 周检审计（2026-10-19 挂入 `ci.yml` schedule） |
| `.github/scripts/check-agents-md-size.sh` | §7 的 300 行上限（仅公开仓） | 本地命令 |
| `RELEASE_GOVERNANCE_TEMPLATE.md` | §10 下发模板 | 模板 |
