# ADR-0017：`dsh-superagent` 的上游生态名例外与同批新增仓命名裁决

- **状态**：Accepted
- **日期**：2026-11-07
- **决策者**：Doro（ReSerendipity，账号所有者）
- **相关**：§1（命名）、§6（改名）、§15（两轴分档）、`GOVERNANCE-EXCLUSIONS.md` §四、ADR-0006、ADR-0016

## 背景

2026-11-04 至 11-05 账号新增四个仓，其中三个未登记：

| 仓 | 可见性 | 实质 | 原名合规性 |
|---|---|---|---|
| `dsh-superagent` | private | DeepSeek DSH 超级智能体的 Windows 移植（MIT，含 `docs/`、`tests/`） | 全小写，不合 §1 |
| `superagent-demo` | private | DSH 首单验证的私有试验仓（仅 README） | 全小写，不合 §1 |
| `JunctionScanner` | public（archived） | 单文件 PowerShell 目录联接 GUI 工具 | 复合词连写，不合 §1 |
| `Prompt-Provenance` | private | 提示词溯源工具链 + 证据语料（`tools/*.mjs`、Python、`SKILL.md`） | 合规 |

`dsh-superagent` 的名字直接取自上游 `deepseek-ai/dsh-superagent-prototype`（去掉 `-prototype` 后缀）：全小写是上游生态的既定写法，仓内移植说明、本地目录 `C:\Users\Doro\APP\repository\dsh-superagent` 与命令示例都已按此名写出。改名的收益只是形式统一，代价是与上游失去一眼可对照的对应关系，并要同步改本地目录、remote URL 与文档示例。

另两个仓没有任何外部约束：`superagent-demo` 只有一个 README，`JunctionScanner` 只有三个文件且无本地克隆，改名成本近乎为零。

同批对账发现 `Offer-Landing-Kit`（public / service / archived）与 `Unity`（private / tool / maintenance）在 owner 凭据下 `GET /repos/ReSerendipity/<name>` 均返回 404 且无改名跳转，判定远程已不存在。

## 决策

1. **`dsh-superagent` 保留现名**，作为 §1 的**命名例外**登记，依据标注为「上游生态名」；进 §4「例外名」表，不进 Train Case。
2. 定位写入 `governance/desired-state.json`：`visibility=private`、`delivery=tool`、`distribution=none`、`lifecycle=active`、`risk=[]`、`backup=github-only`（与上一版登记一致）。
3. **`superagent-demo` → `Superagent-Demo`、`JunctionScanner` → `Junction-Scanner`** 远程改名后按 Train Case 入账（`Junction-Scanner` 需先 `archived=false`、改名、再 `archived=true`，保持归档语义）。两仓均无本地克隆，故不涉及 §6 的本地目录与 remote URL 步骤。
4. `Prompt-Provenance` 按合规名直接入账：private / tool / active / none / github-only。
5. 台账 44 → **45 行**（例外名维持 8：`dsh-superagent` 顶替 `Unity`；Train Case 36 → 37：新增 `Prompt-Provenance`、`Superagent-Demo`、`Junction-Scanner`，移出 `Offer-Landing-Kit`、`Unity`）；全账号 54 → **55**；`EXCLUDED_FROM_RELEASE_STANDARD` 43 → 44。
6. 两个 404 仓从 `desired-state.json` 与 §4 台账移除，删除留痕写在 `GOVERNANCE-EXCLUSIONS.md` §四；若日后确认是改名或转移，按 §6 重新入账。

## 后果

- **代价**：例外名仍是 8 条，但 `Unity` 的位置被 `dsh-superagent` 顶替，读表的人需要知道这条例外来自上游约束而非疏漏；`Junction-Scanner` 的改名会产生一条 GitHub 301 跳转记录。
- **收益**：与上游保持可对照的命名，同时把两个无约束仓拉回 Train Case，新增例外只有一条且理由可核。
- **风险**：`superagent-demo` 处于 DSH 首单验证在用状态，改名可能影响验证脚本中写死的仓名；已确认其内容只有一个 README、无自动化引用，风险可接受。

## 不采用的方案

1. **三个全改名（`DSH-Superagent` 等）**：形式最统一，但 `dsh-superagent` 与上游名脱钩，移植说明与本地路径要一并重写，收益不抵成本。
2. **三个全记例外**：例外表会因两个零约束仓膨胀，违背「例外必须有可核理由」。
3. **只登记 `Prompt-Provenance`，其余留待定档**：`check-repo-registry.sh` 差集 B 与 `audit-drift.py` 会持续判 DRIFT，门禁长期红，违反「检查必须有载体」。
