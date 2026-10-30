# ReSerendipity .github

> **治理枢纽（Governance Hub）**：承载 ReSerendipity 账号的治理规范、默认社区健康文件与家族复用工作流。这不是个人主页——个人主页介绍见 [ReSerendipity/ReSerendipity](https://github.com/ReSerendipity/ReSerendipity)。

![CI](https://github.com/ReSerendipity/.github/actions/workflows/ci.yml/badge.svg)
![Last commit](https://img.shields.io/github/last-commit/ReSerendipity/.github)
![PRs welcome](https://img.shields.io/badge/PRs%20welcome-brightgreen)
![Governance](https://img.shields.io/badge/governance-REPOSITORY_GUIDELINES_%C2%A71%E2%80%93%C2%A720-6e40c9)
![Governed repos](https://img.shields.io/badge/governed%20repos-48-1a7f37)

[中文](#中文) | [English](#english)

---

## 中文

### 项目简介

本仓库是 ReSerendipity 账号的**治理枢纽**，对外提供三类资产：

1. **治理规范单一事实来源**：`governance/` 目录承载 `REPOSITORY_GUIDELINES.md`（§1–§20）、48 仓期望状态 `desired-state.json`、ADR 决策记录与模板；账号内 48 个仓库（截至 2026-10-29）以本目录为唯一权威口径。
2. **默认社区健康文件**：`CODE_OF_CONDUCT.md`、`CONTRIBUTING.md`、`SECURITY.md`、`SUPPORT.md` 与 Issue / PR 模板。当某个下属仓库没有自带同名文件时，GitHub 自动回退使用本仓库的默认版本。
3. **家族复用工作流与校验脚本**：`self-purify.yml`（自净化，默认阻断）、`python-quality-baseline.yml`（质量底线）由各仓以 `workflow_call` 接入；`check-repo-registry.sh`、`check-governance-consistency.sh`、`check-release-standard.sh`、`check-signoff.sh` 等脚本将治理条款变成可复跑的只读门禁。

本仓自身不承载任何项目代码。该账号是个人账号，`profile/README.md` 属组织账号（Organization）专属机制，个人账号下不会渲染，因此本仓库不保留该文件。

### 核心特性

- **单一事实来源**：治理正文只在 `governance/`，各仓不复制、只引用；适用条款由 `desired-state.json` 的 `lifecycle × delivery` 派生（§15，两轴模型，ADR-0006）。
- **48 仓声明式分档**：40 个台账登记仓（命名例外 8 + Train Case 32，§4）+ 8 个密钥/资产备份仓（仅 §3）；`audit-drift.py` 按周检 schedule、手动触发与命中期望状态的 PR 对账期望状态与 GitHub 平台状态（Actions 默认令牌对 21 个私有仓记 `UNVERIFIABLE`，完整核对可用 owner 凭据本地跑，或配置 `GOVERNANCE_READ_PAT` 只读 Secret 后周检远程全覆盖，见 §20.4）。
- **CI 门禁 + 周检**：本仓 `ci.yml` 六个常驻作业 + 一个手动冒烟作业（Workflow lint / DCO sign-off / self-purify 冒烟 / §4 台账 + 期望状态一致性（公开子集）/ 门禁反例测试 / §10 发布标准审计 + python-quality 底线冒烟（仅派发））；另有治理漂移审计与 OSSF Scorecard 周检——2026-10-30 定稿「远程优先、本地最少化」并成文为 §20（ADR-0010）：公开仓 Actions 走免费额度，`schedule` 与 `workflow_dispatch` 并存，本地不承载定期任务。
- **家族复用工作流**：`self-purify.yml` 自 2026-10-24 起把「本地治理文档不得被 git 跟踪」设为默认阻断；`python-quality-baseline.yml` 统一覆盖率与 mypy ratchet 质量底线（Image-DuoModel、TTS-MultiModel、SeedVR2-Lite、MiniMax-H3-Lite 试点接入；2026-10-30 起本仓 `ci.yml` 以 `fixtures/py_smoke` 样例包挂 `workflow_dispatch` 冒烟载体）。
- **README 双版本与本地 AGENTS.md 制度**：根 `README.md` 对外（§8），`local/README.internal.md` 对内且不入库；根 `AGENTS.md` 单一本地文件（不入库、≤300 行，§7），公开契约入口是 `docs/agent-contract.md`。
- **发布/分发统一规范**：§10 覆盖 release / package / deployment，远端优先、tag 驱动、资产附 `SHA256SUMS.txt`，镜像扫描 Trivy 默认阻断。

### 展示

**① 治理架构：政策源 → 执行层 → 48 仓**

<img src="https://gcore.jsdelivr.net/gh/ReSerendipity/.github@main/docs/assets/readme-govgithub-1-20261030-r4.svg" alt="治理架构：政策源 → 执行层 → 48 仓" width="880">

三层关系：`governance/` 是政策单一事实来源；`.github/workflows` 与 `.github/scripts` 是执行层（CI 门禁、周检审计、只读校验脚本、默认健康文件）；账号下 48 个仓库按 `delivery × lifecycle` 派生适用条款，通过一行治理引用与 `docs/agent-contract.md` 接入。右侧虚线回路表示周检漂移审计把平台状态（新建/改名/删除仓库）对账回填政策源。

**② 变更门禁流程：开工四查 → 分支/PR → CI → 合并 → 周检**

<img src="https://gcore.jsdelivr.net/gh/ReSerendipity/.github@main/docs/assets/readme-govgithub-2-20261030-r2.svg" alt="变更门禁流程：开工四查 → 分支/PR → CI → 合并 → 周检" width="880">

依据 `REPOSITORY_GUIDELINES.md` §17：每个任务开工前先做四查（fetch/status/log/rev-list、worktree、会话锁、dirty 文件活跃度）；提交按 §17.2 分批、显式路径、`git commit -s`（DCO）；CI 门禁五查 + 漂移审计；合并后 `delete_branch_on_merge` 自动清理；周一 03:00/04:00/05:00 UTC 三班周检（2026-10-30 定稿：远程免费额度优先、本地最少化，另均可手动派发）。CI 失败按 §17.3 闭环修复，禁止 `--no-verify` 绕过。

**③ 48 仓治理分档矩阵：lifecycle × delivery**

<img src="https://gcore.jsdelivr.net/gh/ReSerendipity/.github@main/docs/assets/readme-govgithub-3-20261030-r3.svg" alt="48 仓治理分档矩阵：lifecycle × delivery" width="880">

lifecycle（active 12 / maintenance 24 / archived 12）决定变更许可与审计频率；delivery（policy 1 / release 11 / library 1 / service 11 / tool 13 / content 3 / backup 8）决定适用条款。逐仓定位以 `governance/desired-state.json` 为唯一事实来源。

### 快速开始（使用与校验）

> 本仓库是治理枢纽说明，不是可安装的项目主页——没有安装步骤，只有**接入方式**与**校验命令**。

1. **环境准备**：Git（任意现代版本）、Bash、Python 3；建议安装 [GitHub CLI `gh`](https://cli.github.com/)（脚本只读 GET 走认证态可免限流）。
2. **各仓接入**（推荐方式）：在仓库根 `README.md` 只放一行引用，不复制正文：

   ```markdown
   > 治理规范：[ReSerendipity/.github/governance](https://github.com/ReSerendipity/.github/tree/main/governance)
   ```

3. **本地校验**（只读、不产生任何远端写入）：

   ```bash
   git clone https://github.com/ReSerendipity/.github.git
   cd .github
   bash .github/scripts/check-repo-registry.sh        # §4 台账 vs GitHub 现网
   bash .github/scripts/check-governance-consistency.sh  # 期望状态内部一致
   ```

4. **最小验证**：两个脚本均以退出码 `0` 结束（`echo $?` 输出 0）即通过；`1` = 存在差集/不一致，`2` = 取数无法判定（网络/凭据/限流）。

### 系统要求与兼容性

- 本仓 CI 运行于 `ubuntu-24.04` runner；工作流与脚本均按 Linux 路径编写。
- 校验脚本只依赖 Bash / Python 3 标准库 + `gh` CLI；全部只发 GitHub `GET` 请求。
- 本地 `pre-push` 钩子模板（`.github/scripts/templates/pre-push`）为 POSIX sh 实现，可挂入任意 git 仓库；提供 `SKIP_GOVERNANCE_HOOKS=1` 逃生阀。
- 文档与脚本统一 LF、UTF-8；中文与英文并存，无 BOM。

### 使用示例

新建仓库（生成 README 含治理引用、CHANGELOG、`docs/release-governance.md`、`.gitignore`、`.githooks/pre-push`，并设置 `core.hooksPath`）：

```bash
bash .github/scripts/scaffold-repo.sh <Repo-Name> [--private|--public] [--delivery release|service|tool|content] [--create-remote]
```

提交前自查 DCO（区间语义为 `base..head`）：

```bash
bash .github/scripts/check-signoff.sh <base-sha> <head-sha>
```

本地检查 AGENTS.md 行数上限（§7，默认 300 行）：

```bash
bash .github/scripts/check-agents-md-size.sh --root <仓库目录>
```

### 默认社区健康文件（自动回退）

当某个下属仓库没有自带同名文件时，GitHub 自动回退使用本仓库的默认版本：

| 文件 | 作用 |
|---|---|
| `CODE_OF_CONDUCT.md` | 社区行为准则（Contributor Covenant 2.1） |
| `CONTRIBUTING.md` | 贡献指南（Conventional Commits + DCO） |
| `SECURITY.md` | 安全披露策略（默认版；各仓自带版本优先） |
| `SUPPORT.md` | 支持渠道说明 |
| `governance/REPOSITORY_GUIDELINES.md` | 仓库治理规范 §1–§20（命名/分支/密钥备份/两轴分档/发布分发/路径/归档/文档健康/依赖升级/CI 远程化等） |
| `governance/GOVERNANCE-EXCLUSIONS.md` | 治理分档与例外登记（8 备份仓豁免、命名例外等） |
| `governance/desired-state.json` | 48 仓声明式期望状态；漂移审计与一致性检查的数据源 |
| `governance/decisions/` | ADR-0001~0010 决策记录 |
| `governance/templates/` | `agent-contract.md` 与 `AGENTS.slim.md` 唯一模板 |
| `.github/ISSUE_TEMPLATE/` | 通用 Issue 表单（Bug / 功能 / 提问；各仓自带表单优先） |
| [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md) | 通用 PR 检查清单 |

**查找优先级**：`仓库 .github/` → `仓库根目录` → `仓库 docs/` → 本组织默认。需要项目定制（专属许可、安全设计、模型合规条目）的仓库应自行提供同名文件覆盖默认版本。

**复用工作流**：`.github/workflows/` 中的家族复用工作流由各仓通过 `workflow_call` 接入，调用方应引用已审阅的提交 SHA（如 `desired-state.json` 中登记的 `pinned_ref`），而不是会漂移的 `@main`。`self-purify.yml` 自 2026-10-24 起默认阻断「本地治理文档不得被 git 跟踪」，已登记的例外仓可显式传 `enforce_critical_checks: false`。本仓自身另有六个常驻 CI 作业 + 一个手动冒烟作业（见「核心特性」）；治理漂移审计另由独立工作流承担，其在 Actions 中对私有仓只能记 `UNVERIFIABLE`，完整 48 仓核对需本地 owner 凭据。

### 维护原则

- 默认文件保持通用，不写入某个项目独有的运行步骤或模型说明。
- 项目需要例外规则时，应在项目仓库提供同名文件覆盖默认版本。
- 涉及安全、许可证和第三方模型的内容，优先链接到项目自己的合规文档。
- 只把稳定、可长期维护的约定放入默认文件，避免让所有仓库继承实验性规则。

### FAQ

1. **这个仓库为什么没有 LICENSE？** 按 §11 许可证规范，`.github`（治理规范仓）与 `ReSerendipity`（profile 仓）等「内容即文档/身份」的仓库不需要许可证；新建的公开代码仓库默认 Apache-2.0。本仓因此不加 license 徽章。
2. **这个仓库是个人主页吗？** 不是。它是治理枢纽；个人主页由同名仓库 `ReSerendipity/ReSerendipity` 承载。
3. **各仓怎么引用治理规范？** 一行引用即可（见「快速开始」第 2 步），不复制正文，避免多副本漂移；需要沉淀的细节拆到 `local/agents/**`。
4. **`AGENTS.md` 为什么不入库？** §7 规定根 `AGENTS.md` 是单一本地维护者上下文（≤300 行），公开可分发入口是 `docs/agent-contract.md`（逐字节复制模板）；fresh clone / CI 检出中没有 `AGENTS.md` 属预期。
5. **私有仓为什么没有服务器侧分支保护？** GitHub Free 计划对私有仓的 rulesets 与经典分支保护 API 返回 403（ADR-0004，平台能力缺口而非欠账）；替代控制是各仓本地 `.githooks/pre-push` 与本地预检脚本。

### 文档与治理

- 治理正文：[`governance/REPOSITORY_GUIDELINES.md`](governance/REPOSITORY_GUIDELINES.md)（§1–§20）
- 分档与例外：[`governance/GOVERNANCE-EXCLUSIONS.md`](governance/GOVERNANCE-EXCLUSIONS.md)
- 期望状态：[`governance/desired-state.json`](governance/desired-state.json)（48 仓逐仓定位）
- 决策记录：[`governance/decisions/`](governance/decisions/)（ADR-0001~0010）
- 治理手册索引：[`governance/README.md`](governance/README.md)
- Agent 契约：[`docs/agent-contract.md`](docs/agent-contract.md)
- 发布文档模板：[`governance/templates/RELEASE_GOVERNANCE_TEMPLATE.md`](governance/templates/RELEASE_GOVERNANCE_TEMPLATE.md)

### 贡献 / 安全 / 支持

- **贡献**：[`CONTRIBUTING.md`](CONTRIBUTING.md)——Conventional Commits + DCO（每个 commit 必须 `Signed-off-by`）；非管理员协作者一律走分支 + PR。
- **安全**：[`SECURITY.md`](SECURITY.md)——请通过私有渠道报告漏洞（Private vulnerability report 或 `[SECURITY]` 主题邮件），48 小时内确认；主力仓库已启用 Dependabot、CodeQL、gitleaks 等自动化扫描。
- **支持**：[`SUPPORT.md`](SUPPORT.md)——Discussions 通用问答、Issues 提交可复现的 Bug 与功能建议。
- **行为准则**：[`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md)（Contributor Covenant 2.1）。

### 许可证

本仓库是治理/身份内容仓，按 §11 不携带 LICENSE 文件（参见上方 FAQ）。账号内各项目代码的许可以各仓库自己的 `LICENSE` 为准（默认 Apache-2.0），模型权重与第三方组件的许可以各仓库 `NOTICE` / `THIRD_PARTY_NOTICES.md` 或合规文档为准。

---

## English

### About

This repository is the **governance hub** of the ReSerendipity account. It provides three kinds of assets:

1. **Single source of truth for governance policy**: `governance/` holds `REPOSITORY_GUIDELINES.md` (§1–§20), the desired-state manifest of 48 repositories (`desired-state.json`), ADR decision records and templates. All 48 repositories (as of 2026-10-29) defer to this directory.
2. **Default community health files**: `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md` plus Issue/PR templates. GitHub automatically falls back to these defaults when a downstream repository does not ship its own copy.
3. **Family reusable workflows and gate scripts**: `self-purify.yml` (default-blocking self-cleanliness check) and `python-quality-baseline.yml` (quality floor) are consumed by other repos via `workflow_call`; `check-repo-registry.sh`, `check-governance-consistency.sh`, `check-release-standard.sh`, `check-signoff.sh` turn policy clauses into repeatable read-only gates.

This repository hosts no project code. The account is a personal account, so `profile/README.md` (an organization-only mechanism) is intentionally not present.

### Key Features

- **Single source of truth**: policy text lives only in `governance/`; other repos reference, never copy. Applicable clauses are derived from the `lifecycle × delivery` model in `desired-state.json` (§15, two-axis profiling, ADR-0006).
- **Declarative tiering of 48 repos**: 40 ledger-registered repos (8 exception names + 32 Train Case, §4) plus 8 key/asset backup repos (§3 only); `audit-drift.py` reconciles desired state against the live GitHub platform weekly (plus manual dispatch and PRs touching the manifest) — Actions' default token marks the 21 private repos `UNVERIFIABLE`; run locally with owner credentials for full coverage, or configure the read-only `GOVERNANCE_READ_PAT` secret so the weekly audit covers all 48 repos remotely (§20.4).
- **CI gates + weekly audits**: this repo's `ci.yml` runs six standing jobs (workflow lint / DCO sign-off / self-purify smoke / §4 registry + desired-state consistency (public subset) / gate negative tests / §10 release-standard audit) plus one manual-dispatch smoke job (python-quality baseline on a fixture package), with a separate drift audit and an OSSF Scorecard weekly scan. Per the 2026-10-30 decision codified as §20 / ADR-0010 (remote-first, minimal-local): this public repo runs on free Actions minutes, so `schedule` and `workflow_dispatch` coexist and no recurring work is placed on the local machine.
- **Family reusable workflows**: `self-purify.yml` has, since 2026-10-24, made "local governance documents must not be git-tracked" a default blocking rule; `python-quality-baseline.yml` unifies coverage and mypy ratchet baselines (piloted in Image-DuoModel, TTS-MultiModel, SeedVR2-Lite, MiniMax-H3-Lite).
- **Dual README + local-only `AGENTS.md`**: root `README.md` is the public-facing version (§8); `local/README.internal.md` is maintainer-only and never committed. A single root `AGENTS.md` stays local (≤300 lines, §7); the public entry point is `docs/agent-contract.md`.
- **Unified release/distribution policy**: §10 covers release/package/deployment — remote-first builds, tag-driven releases, `SHA256SUMS.txt` assets, and Trivy image scanning that blocks by default.

### Showcase

**① Governance architecture: policy source → execution layer → 48 repos**

<img src="https://gcore.jsdelivr.net/gh/ReSerendipity/.github@main/docs/assets/readme-govgithub-1-20261030-r4.svg" alt="Governance architecture: policy source → execution layer → 48 repos" width="880">

`governance/` is the policy source of truth; `.github/workflows` and `.github/scripts` are the execution layer (CI gates, weekly audits, read-only checks, default health files); the 48 account repositories derive applicable clauses from `delivery × lifecycle` and connect through a one-line governance reference and `docs/agent-contract.md`. The dashed loop on the right shows the weekly drift audit feeding platform changes (repo created/renamed/deleted) back into the ledger.

**② Change gate flow: pre-work checks → branch/PR → CI → merge → weekly audits**

<img src="https://gcore.jsdelivr.net/gh/ReSerendipity/.github@main/docs/assets/readme-govgithub-2-20261030-r2.svg" alt="Change gate flow: pre-work checks → branch/PR → CI → merge → weekly audits" width="880">

Per `REPOSITORY_GUIDELINES.md` §17: four pre-work checks before any task (fetch/status/log/rev-list, worktree list, session lock, dirty-file activity); batched commits with explicit paths and `git commit -s` (DCO, §17.2); CI gates plus drift audit; auto branch cleanup via `delete_branch_on_merge`; three weekly audits on Monday 03:00/04:00/05:00 UTC (per the 2026-10-30 remote-first decision, manual dispatch is also available and nothing recurring runs on the local machine). CI failures follow the §17.3 loop — reproduce locally, fix minimally, recommit, re-push; `--no-verify` bypass is forbidden.

**③ 48-repo tiering matrix: lifecycle × delivery**

<img src="https://gcore.jsdelivr.net/gh/ReSerendipity/.github@main/docs/assets/readme-govgithub-3-20261030-r3.svg" alt="48-repo tiering matrix: lifecycle × delivery" width="880">

Lifecycle (active 12 / maintenance 24 / archived 12) decides change permission and audit cadence; delivery (policy 1 / release 11 / library 1 / service 11 / tool 13 / content 3 / backup 8) decides which clauses apply. Per-repo positioning is authoritative only in `governance/desired-state.json`.

### Quick Start (usage & verification)

> This is a governance-hub description, not an installable project homepage — there is no install step, only **how to reference** it and **how to verify**.

1. **Environment**: any modern Git, Bash, Python 3; [GitHub CLI `gh`](https://cli.github.com/) recommended (authenticated read-only GETs avoid rate limits).
2. **Reference from a repo** (recommended): put a single line in the repo root `README.md`, do not copy policy text:

   ```markdown
   > 治理规范：[ReSerendipity/.github/governance](https://github.com/ReSerendipity/.github/tree/main/governance)
   ```

3. **Local verification** (read-only; no remote writes):

   ```bash
   git clone https://github.com/ReSerendipity/.github.git
   cd .github
   bash .github/scripts/check-repo-registry.sh            # §4 ledger vs live GitHub
   bash .github/scripts/check-governance-consistency.sh   # desired-state internal consistency
   ```

4. **Minimal verification**: both scripts exit `0` (`echo $?` → 0) on success; `1` = a gap/inconsistency exists; `2` = cannot determine (network/credentials/rate limit).

### System Requirements & Compatibility

- CI runs on `ubuntu-24.04` runners; workflows and scripts follow Linux paths.
- Gate scripts depend only on Bash / Python 3 stdlib + `gh` CLI and issue GitHub `GET` requests only.
- The local `pre-push` hook template (`.github/scripts/templates/pre-push`) is a POSIX sh implementation for any git repo, with a `SKIP_GOVERNANCE_HOOKS=1` escape hatch.
- Documents and scripts use LF, UTF-8, no BOM; Chinese and English coexist.

### Usage Examples

Scaffold a new repository (generates a README with the governance reference, CHANGELOG, `docs/release-governance.md`, `.gitignore`, `.githooks/pre-push`, and sets `core.hooksPath`):

```bash
bash .github/scripts/scaffold-repo.sh <Repo-Name> [--private|--public] [--delivery release|service|tool|content] [--create-remote]
```

Self-check DCO before pushing (range semantics `base..head`):

```bash
bash .github/scripts/check-signoff.sh <base-sha> <head-sha>
```

Check the `AGENTS.md` line limit locally (§7, default 300 lines):

```bash
bash .github/scripts/check-agents-md-size.sh --root <repository-directory>
```

### Default Community Health Files (fallback)

When a downstream repository does not ship its own file of the same name, GitHub falls back to these defaults:

| File | Purpose |
|---|---|
| `CODE_OF_CONDUCT.md` | Code of conduct (Contributor Covenant 2.1) |
| `CONTRIBUTING.md` | Contribution guide (Conventional Commits + DCO) |
| `SECURITY.md` | Security disclosure policy (default; repo-local version wins) |
| `SUPPORT.md` | Support channels |
| `governance/REPOSITORY_GUIDELINES.md` | Repository governance §1–§20 (naming/branching/secret backup/tiering/release-layout/archive/docs-health/dependency-upgrades/CI-remote-first) |
| `governance/GOVERNANCE-EXCLUSIONS.md` | Tiering & exception registry (8 backup-repo exemptions, naming exceptions, etc.) |
| `governance/desired-state.json` | Declarative desired state for 48 repos; data source for drift audit and consistency checks |
| `governance/decisions/` | ADR-0001~0010 decision records |
| `governance/templates/` | Sole templates for `agent-contract.md` and `AGENTS.slim.md` |
| `.github/ISSUE_TEMPLATE/` | Generic issue forms (Bug / feature / question; repo-local forms win) |
| [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md) | Generic pull request checklist |

**Lookup priority**: `repo .github/` → `repo root` → `repo docs/` → org default. Repositories that need customization (per-repo licensing, security design, model-compliance notes) should ship their own same-named files.

**Reusable workflows**: family workflows in `.github/workflows/` are consumed via `workflow_call`; callers must pin a reviewed commit SHA (e.g. the `pinned_ref` registered in `desired-state.json`) rather than a drifting `@main`. Since 2026-10-24, `self-purify.yml` blocks by default on any git-tracked `AGENTS.md`; registered exception repos may pass `enforce_critical_checks: false` explicitly. This repo itself runs six standing CI jobs plus one manual smoke job (see Key Features); the governance drift audit runs as a separate workflow and marks private repos `UNVERIFIABLE` under the default Actions token — use owner credentials locally for full 48-repo coverage.

### Maintenance Principles

- Default files stay generic; no project-specific run steps or model notes go into them.
- Repos that need exceptions ship same-named files that override the default version.
- Security, license and third-party-model matters link to each project's own compliance docs.
- Only stable, long-term conventions enter the default files, so experimental rules are not inherited by every repo.

### FAQ

1. **Why is there no LICENSE here?** Under §11, content-as-document/identity repos such as `.github` (governance) and `ReSerendipity` (profile) need no license; new public code repos default to Apache-2.0. Hence no license badge here.
2. **Is this the personal homepage?** No. It is the governance hub; the homepage lives in `ReSerendipity/ReSerendipity`.
3. **How do downstream repos reference the policy?** A single one-line reference (see Quick Start, step 2) — never copy the body, avoiding multi-copy drift; details go into `local/agents/**`.
4. **Why is `AGENTS.md` not committed?** §7 keeps a single root `AGENTS.md` as local maintainer context (≤300 lines); the public entry point is `docs/agent-contract.md` (byte-identical to the template). Fresh clones and CI checkouts are expected not to contain `AGENTS.md`.
5. **Why no server-side branch protection for private repos?** GitHub Free returns 403 for rulesets and classic protection on private repos (ADR-0004: a platform capability gap, not an outstanding debt); the substitute controls are per-repo local `.githooks/pre-push` and local pre-flight scripts.

### Documentation & Governance

- Policy text: [`governance/REPOSITORY_GUIDELINES.md`](governance/REPOSITORY_GUIDELINES.md) (§1–§20)
- Tiering & exceptions: [`governance/GOVERNANCE-EXCLUSIONS.md`](governance/GOVERNANCE-EXCLUSIONS.md)
- Desired state: [`governance/desired-state.json`](governance/desired-state.json) (per-repo positioning of all 48 repos)
- Decision records: [`governance/decisions/`](governance/decisions/) (ADR-0001~0010)
- Governance handbook index: [`governance/README.md`](governance/README.md)
- Agent contract: [`docs/agent-contract.md`](docs/agent-contract.md)
- Release document template: [`governance/templates/RELEASE_GOVERNANCE_TEMPLATE.md`](governance/templates/RELEASE_GOVERNANCE_TEMPLATE.md)

### Contributing / Security / Support

- **Contributing**: see [`CONTRIBUTING.md`](CONTRIBUTING.md) — Conventional Commits + DCO (`Signed-off-by` on every commit); non-admin collaborators must use branch + PR.
- **Security**: see [`SECURITY.md`](SECURITY.md) — report privately (Private vulnerability report or `[SECURITY]`-prefixed email); acknowledgement within 48 hours; main repos run Dependabot, CodeQL and gitleaks.
- **Support**: see [`SUPPORT.md`](SUPPORT.md) — Discussions for general questions, Issues for reproducible bugs and feature requests.
- **Code of conduct**: see [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md) (Contributor Covenant 2.1).

### License

This repository is a governance/identity content repository and, per §11, ships no LICENSE file (see FAQ above). Licensing of project code in other repos is governed by each repo's own `LICENSE` (Apache-2.0 by default); model weights and third-party components are governed by each repo's `NOTICE` / `THIRD_PARTY_NOTICES.md` or compliance docs.
