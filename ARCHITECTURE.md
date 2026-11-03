# 架构 — .github（治理规范仓）

> 治理定位：`delivery=policy`、`lifecycle=active`、`distribution=none`（`governance/desired-state.json`）。
> 本文件只描述**本仓内部结构**；对账号下其他仓的规范见 `governance/REPOSITORY_GUIDELINES.md`。

## 1. 定位

本仓是 `ReSerendipity` 账号 53 个仓库的**治理单一事实来源**。它不承载业务代码、不产出可分发制品、没有 release 链；它的「产品」是规则正文、机器可读期望状态、可执行校验脚本与复用模板。

## 2. 组件与依赖方向

```text
                 ┌──────────────────────────────┐
                 │ governance/desired-state.json │  ← 唯一机器可读事实源（53 仓两轴定位）
                 └──────────────┬───────────────┘
                                │ 被读取
        ┌───────────────────────┼────────────────────────┐
        ▼                       ▼                        ▼
 governance/REPOSITORY_    governance/              governance/
 GUIDELINES.md（§1–§20）    GOVERNANCE-EXCLUSIONS.md  decisions/（16 份 ADR）
 （人读权威正文）            （例外登记）              （规则变更依据）
        │                       │                        │
        └───────────┬───────────┴────────────┬───────────┘
                    ▼                        ▼
        .github/scripts/*（校验器）   .github/workflows/*（CI 载体）
                    │                        │
                    └──────────┬─────────────┘
                               ▼
                    退出码纪律 0/1/2 → 门禁与周检
```

依赖方向是**单向**的：`desired-state.json` 与规范正文是上游；脚本只读不写；工作流只调用脚本。任何脚本都不得反向修改治理文档。

| 层 | 目录 | 职责 | 是否入库 |
|---|---|---|---|
| 事实层 | `governance/desired-state.json` | 53 仓的 visibility / delivery / lifecycle / distribution / risk | 是 |
| 规则层 | `governance/REPOSITORY_GUIDELINES.md`、`governance/decisions/` | 人读正文与 ADR 决策依据 | 是 |
| 例外层 | `governance/GOVERNANCE-EXCLUSIONS.md` | 例外与豁免登记，避免规则正文里堆条件 | 是 |
| 执行层 | `.github/scripts/`、`.github/workflows/` | 校验器（Bash/Python）与 CI 触发 | 是 |
| 分发层 | `governance/templates/`、`.github/scripts/scaffold-repo.sh` | 把规则变成可复制的骨架 | 是 |
| 展示层 | `README.md`、`docs/assets/*.svg` | 对外说明与架构图 | 是 |
| 私有层 | `local/` | 本机上下文、踩坑台账、pre-push 钩子 | **否**（§13.1 唯一 ignore 容器） |

## 3. 数据流

1. **声明 → 校验**：`desired-state.json` 被 `check-governance-consistency.sh`、`check-repo-registry.sh`、`check-release-standard.sh`、`audit-drift.py` 读取，与 GitHub 远端实际状态对账。
2. **正文 → 计数**：规范正文、根 README、分档矩阵 SVG 里的硬编码计数由 `check-governance-consistency.sh` 与 JSON 比对，防止多处漂移。
3. **模板 → 下游**：`governance/templates/*` 由 `scaffold-repo.sh` 复制到新仓；`agent-contract.md` 的仓内副本由 `audit-drift.py` 逐字节比对。
4. **改动 → 闸门**：推送 `main` 触发 `ci.yml`（actionlint + DCO + 自净化 + 仓台账）与 `drift-audit.yml`（周检）；本地 pre-push 由 `local/hooks/pre-push` 承担台账闸。

## 4. 外部依赖

| 依赖 | 用途 | 缺失时行为 |
|---|---|---|
| `gh` CLI | 只读 GitHub API（仓清单、元数据、保护设置） | 脚本 `exit 2`（无法判定，失败关闭） |
| Bash + GNU coreutils | 门禁脚本 | Windows `sort.exe` 顶替会被入口守卫纠正 |
| Python 3 | `audit-drift.py`、JSON 解析、反例测试 | `exit 2` |
| `actionlint` | workflow 静态检查 | CI 该步失败 |
| GitHub Actions | 检查的远端载体（§20） | 仅剩本地门禁，覆盖下降 |

## 5. 边界与非目标

- **不承载业务代码**：任何需要发布、部署、运行时服务的产物都不进本仓。
- **不产出制品**：无 release / package / ghcr / Pages（§10 不适用，`distribution=none`）。
- **不复制下游仓内容**：下游仓只保留一行治理引用，正文只在本仓（§7.1 / §13.1）。
- **不做平台替代**：私有仓缺分支保护属 GitHub Free 平台缺口（ADR-0004），本仓只登记，不改造成替代方案。
- **`local/` 永不入库**：本机路径、账号细节、失败细节不出现在公开面。

## 6. 变更影响面

| 改什么 | 必须同步 | 由谁校验 |
|---|---|---|
| `desired-state.json` 增删仓 | §4 台账、两份排除数组、`governance/README.md`、`GOVERNANCE-EXCLUSIONS.md` | `check-governance-consistency.sh` |
| 规范条款 | 先提 ADR；计数类改动同步正文/README/SVG | `audit-drift.py` + 一致性脚本 |
| 模板 | 下游仓副本（`docs/agent-contract.md`）与 `scaffold-repo.sh` | `audit-drift.py` |
| 门禁脚本 | 反例测试夹具 | `run-negative-tests.sh` |
| 工作流 | actionlint 与必检清单 | `ci.yml` |
