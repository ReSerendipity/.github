# 治理豁免清单（GOVERNANCE-EXCLUSIONS）

> **本文件定位**：治理豁免清单的**正式记录**，承载于本规范仓（2026-10-19 由本地根目录移入，随仓版本管理）。
> **权威条款**：`REPOSITORY_GUIDELINES.md`（§10 范围声明 / §4 变更记录）。
> **最后更新**：2026-10-19（豁免升级：清单仓不适用**整部规范**）
> **同步规则（改一处即改五处）**：
> 1. 规范仓 `REPOSITORY_GUIDELINES.md` §10 范围声明的排除清单
> 2. 规范仓 §4 台账表（豁免仓**不登记**）与 §4 补充说明
> 3. 校验脚本 `check-repo-registry.sh` 的 `EXCLUDED_FROM_REGISTRY`（13 项台账载体）
> 4. 校验脚本 `check-release-standard.sh` 的 `EXCLUDED_FROM_RELEASE_STANDARD`（17 项审计载体）
> 5. 本文件

---

## 一、豁免语义（2026-10-19 升级，用户裁决）

**清单内 17 个仓库不适用整个 `REPOSITORY_GUIDELINES.md`（§1-§11）**——升级前仅豁免 §10（发布规范）。

| 维度 | 升级前（2026-10-18） | 升级后（2026-10-19） |
|---|---|---|
| §10 发布/分发 | 不适用 | 不适用（不变） |
| §1 命名 / §4 台账 | 部分适用（6 个用户点名仓仍在台账内、命名受约束） | **不适用**（6 仓已移出台账，`EXCLUDED_FROM_REGISTRY` 扩至 13 项） |
| §2 分支保护 | 逐仓实测时一并测量 | **无需保护考量**（实测时其中 17 仓均无保护，保持现状） |
| §7/§8 AGENTS.md / README | 私有仓按上传制 | **不受上传制约束**；此前已完成/已存在的上传**一律保留** |
| §3 密钥备份 / §5-§6 / §9 / §11 | 按适用范围执行 | 不适用 |

**不变的边界**：

- **已交付产物一律保留**：29 仓（含清单内 6 仓）的 `docs/release-governance.md`、根级 `CHANGELOG.md`、发布链改动、AGENTS.md 上传——**不删除、不回滚**。豁免只表示"不再要求、不再审计"；将来要撤销产物属单独决定。
- **仓库本体不动**：豁免≠删除；所有仓仍在 GitHub 上，可见性不变。
- **`rewq` 绝对例外**：内含服务器密钥与 SSH 备份，**任何新增内容不上传**；冻结于本地，仅保留本地 git 管理（§7 条款同步记载）。

---

## 二、豁免清单（17 项）

### 1. 密钥 / 资产备份仓（6 个）

按 §3 属备份仓，无发布链、无版本位；**均不在 §4 台账内**。

| 仓 | 私有 | 说明 |
|---|---|---|
| `DraftPeek-KeyBackup` | ✅ | §3 模式原型；仅含 `.enc.7z` + SHA256SUMS + README |
| `Image-DuoModel-KeyBackup` | ✅ | 2026-10-19 由 `Image-MultiModel-KeyBackup` 改名（随父仓 `Image-DuoModel` 对齐 §3 模式） |
| `SeedVR2-Lite-KeyBackup` | ✅ | 同结构 |
| `TTS-MultiModel-KeyBackup` | ✅ | 同结构 |
| `Android-IconAutoArrange-KeyBackup` | ✅ | 2026-10-18 补录（此前误记为"4 个 `*-KeyBackup`"） |
| `Android-IconAutoArrange-Assets-Backup` | ✅ | 内含加密签名密钥的**口令台账** + PoC 运行时 APK |

### 2. 网站仓（4 个，均私有）

`Website-Genshin-Impact`、`Website-Honkai-Star-Rail`、`Website-Wuthering-Waves`、`Website-Zenless-Zone-Zero`。
根 `AGENTS.md` 早已入库（43634/58432/66226/20462 字节，2026-10-19 复核）。

### 3. 非台账副本（1 个，私有）

`rewq`——**冻结仓**（见上）。默认分支 `main` @ `baae7dd`（2026-10-16），内容含 `ssh-backup/`、`服务器信息备忘.md`、`push.sh`。

### 4. 用户点名豁免（6 个，2026-10-18 点名 / 2026-10-19 升级）

`Unity`（私有）、`Bilibili-Follow-Manager`（私有）、`Hugging-Face`（私有）、`Multi-Tracker`（公开）、`Unfading-Wall`（公开）、`ComfyUI-BatchPromptLoader`（公开；默认分支 2026-10-19 起为 `main`）。

> 这 6 仓此前已落地的产物（发布文档 / CHANGELOG / 流水线 / AGENTS.md）**全部保留**：
> Bilibili-Follow-Manager 与 Website-Genshin-Impact 的根 `AGENTS.md` 早已入库；
> 其余产物见 §10.6 收敛表。

---

## 三、脚本载体对照（豁免的可执行形态）

| 脚本 | 清单名 | 项数 | 覆盖维度 |
|---|---|---|---|
| `check-repo-registry.sh` | `EXCLUDED_FROM_REGISTRY` | **13** | §4 台账差集 B/C + §1 命名校验（4 个网站仓私有不可见、固有覆盖，故 17−4=13） |
| `check-release-standard.sh` | `EXCLUDED_FROM_RELEASE_STANDARD` | **17** | §10 收敛审计（全量豁免） |

> 如某豁免仓**转为公开**，需把它补进 `EXCLUDED_FROM_REGISTRY`（否则差集 B/C 报红）——脚本注释已写明。

---

## 四、账号仓总览（2026-10-19 实测，共 41 个）

| 分组 | 数量 | 说明 |
|---|---|---|
| **规范管辖中** | 23 | 受整部规范约束（§1-§11）；均有发布文档 + 根级 CHANGELOG（历史产物保留） |
| **豁免（清单 17 项）** | 17 | 不适用整部规范；产物保留 |
| **规范仓自身** | 1 | `.github`（规范由本仓承载，不属被管辖对象） |

合计 23 + 17 + 1 = **41**。

### §4 台账现状（2026-10-19 升级后）

- 台账登记 **28 条**（保留名 5 + 短横线 23）——只含管辖中的仓。
- 远程有而表里无的 **13 个**，全部在 `EXCLUDED_FROM_REGISTRY` 显式声明（17 项豁免中 4 个网站仓私有不可见，固有覆盖）。
- `check-repo-registry.sh` 本地实测（2026-10-19）：`clean：§4 对照表与远程一致`。

### 分支保护实测（2026-10-19，41 仓全量，零无法判定）

- `protected=true`（11）：`.github`、ComfyUI-Experiment-Toolbox、DraftPeek、GalgameShell、Github-Repo-Scan、Image-DuoModel、MiniMax-H3-Lite、ReSerendipity、SeedVR2-Lite、SpiritPal、TTS-MultiModel。
- `protected=false`（30）：其中 17 仓属本豁免清单（无需考量）；**待立项候选 13 仓**：Agent-Knowledge、Android-IconAutoArrange、Card-Studio、ChatGPT-Timezone-Fix、Free-Model-Probe、Health-Info-Card、Image-Scrapers、Lineart-Painter、Mooncake-Deconstruction、Nekogal-DL、Offer-Landing-Kit、Prompt-Library、RTX-VSR-Lite。

---

## 五、规范仓自身的强制载体（供对照）

| 载体 | 强制的条款 | 性质 |
|---|---|---|
| `ci.yml` 五项检查（`Workflow lint` / `DCO sign-off` / `self-purify（阻断）` / `Repository registry` / `Release standard audit`） | §1 / §2 / §4 / §7-§8 / 提交签名 / §10 周检审计 | 硬门禁 + 周检 |
| `.github/scripts/check-repo-registry.sh` | §4 台账 + §1 命名 + 台账豁免声明（13 项） | CI + 周检 |
| `.github/scripts/check-release-standard.sh` | §10 收敛核验（豁免 17 项） | 周检审计（2026-10-19 挂入 `ci.yml` schedule） |
| `.github/scripts/check-agents-md-size.sh` | §7 的 300 行上限（仅公开仓） | 本地命令 |
| `RELEASE_GOVERNANCE_TEMPLATE.md` | §10 下发模板 | 模板 |
