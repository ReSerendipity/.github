# ADR-0018：`dsh-superagent-archive` 的例外名继承与同批四个新增仓入账

- **状态**：Accepted
- **日期**：2026-11-08
- **决策者**：Doro（ReSerendipity，账号所有者）——本轮指示「小红书侧先等，其他的那些完成」，即台账登记与规范件补齐
- **相关**：§1（命名）、§4（命名台账）、§15（两轴分档）、§12.5（通用工程件）、ADR-0017、ADR-0006、ADR-0004

## 背景

2026-11-08 用 owner 凭据对账：`gh repo list ReSerendipity` 实测 **59** 个仓，`governance/desired-state.json` 登记 **55** 个，差集四个仓全部未入账：

| 仓 | 可见性 | 实质 | 原名合规性 |
|---|---|---|---|
| `BookSpine-Wall` | private | 交互式 3D 书脊书墙（单文件 HTML，`video-to-dev-spec` 首跑交付） | 合规 Train Case |
| `MirrorDuo` | private | 双图对比与遮罩工具（单文件 HTML + 素材） | 合规 Train Case（与 `SpiritPal`/`DraftPeek` 同类复合词） |
| `OrbitCube` | private | 三阶魔方 × 九环轨道图双视图玩具（`index.html` + `app.js`，含小红书小工具打包链） | 合规 Train Case |
| `dsh-superagent-archive` | private | `dsh-superagent` 公开基线切换前的旧仓，只读保留 Issue/PR/Release/tag | 全小写，不合 §1，但继承 ADR-0017 的上游生态名依据 |

`dsh-superagent-archive` 的名字是 `dsh-superagent` + `-archive` 后缀，与上游 `deepseek-ai/dsh-superagent-prototype` 的生态命名同源；改名会让「公开基线仓 / 旧档仓」的对照关系断裂，而它已在 `GOVERNANCE-EXCLUSIONS.md` §11.1 以此名登记 dependabot 豁免。

同批复核还发现 §15.6 的计数自 2026-11-07 那次入账后未跟着改（正文仍写「54 仓 / 44 行」，实际已是 55 / 45），属遗留陈旧计数。

## 决策

1. **`BookSpine-Wall`、`MirrorDuo`、`OrbitCube` 按 Train Case 入账**，不新增命名例外。
2. **`dsh-superagent-archive` 进 §4「例外名」表**，例外依据标注「上游生态名派生（继承 `dsh-superagent`，ADR-0017）」——沿用既有依据类型，不新造豁免口径。
3. 定位写入 `desired-state.json`：三仓 `private / tool / none / active / risk=[] / github-only`；`dsh-superagent-archive` 记 `private / tool / none / maintenance / github-only`。
4. **`lifecycle` 不记 `archived`**：§15.2 的判据是「GitHub 已归档」，而该仓 `isArchived=false`。实质只读与平台状态不一致，作为**待所有者裁决项**留档（真归档属平台设置，需另行授权），本轮不代为 archive。
5. **dependabot 私有豁免登记**：三仓补入 `GOVERNANCE-EXCLUSIONS.md` §11.1（13 → 16 仓），理由写明「零运行时依赖、无依赖清单可扫」，并保留「这不是不需要，是放弃自动依赖发现」的显式风险声明。
6. **修正遗留计数**：§4 45 → 49 行（例外名 8 → 9、Train Case 37 → 40）、合计 55 → 59 仓、§15.6 54/44 → 59/49、`README.md` 与 `governance/README.md` 与 `GOVERNANCE-EXCLUSIONS.md` §四 与 `check-repo-registry.sh` 注释同步；私有仓数 28 → 31。

## 后果

- 台账与 GitHub 实测零差额，`check-repo-registry.sh` 与 `check-governance-consistency.sh` 可 `rc=0`。
- **两张分档 SVG 仍标「55 仓」**（`docs/assets/readme-govgithub-1-20261107-r10.svg`、`readme-govgithub-3-20261107-r8.svg`）。按 §8.1「图注与画面一致」与「禁止同名覆盖」，本轮**不改 alt 文本**（alt 描述的是图内实际内容），改图另立新文件名重绘，列为后续项。
- `dsh-superagent-archive` 的只读语义仍靠约定而非平台强制；若所有者选择真 archive，`lifecycle` 需同步改 `archived` 并按 §15.7 走归档流程。
- 三个新入账仓的规范件补齐进度不一致：`OrbitCube` 本轮补齐（`.editorconfig`/`.gitattributes`/`CODEOWNERS`/`agent-contract.md`/`ARCHITECTURE.md`/内版说明/本地 `pre-push`），`BookSpine-Wall` 与 `MirrorDuo` 仍缺 §12.5 四类件，属**已入账未达标**的可见欠账，不借本 ADR 隐匿。
