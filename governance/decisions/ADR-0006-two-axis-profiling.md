# ADR-0006：lifecycle × delivery 两轴分档与 44 仓重定位

- 状态：Accepted
- 日期：2026-10-22
- 决策者：ReSerendipity（账号所有者）
- 相关：§15、§4、`governance/desired-state.json`
- 取代：ADR-0002

## 背景

单一 profile 把三件互不相关的事压进一个值：交付形态、维护状态、敏感级别。结果是「active 的静态站」和「active 的桌面应用」被硬塞进同一档，条款只能取并集；而一旦某仓被点名豁免，又变成「全不管」。两次极端的共同原因是**维度缺失**。

市面参考只能借原则，不能借结构：GitHub 只有 `public/private/archived/template/fork` 与二元 `protected`；CNCF 成熟度分项目、OpenSSF Scorecard 只打分、NIST 分系统影响等级。没有现成的「仓库档位」可直接套用。

## 决策

采用**两轴正交模型**：

| 轴 | 取值 | 决定 |
|---|---|---|
| lifecycle | `active` / `maintenance` / `archived` | 变更许可、审计频率、平台要求 |
| delivery | `release` / `library` / `service` / `tool` / `content` / `backup` / `policy` | 适用条款 |
| distribution | `github-release` / `ghcr` / `pages` / `direct-ssh` / `none` | §10 检查子集 |
| risk | `signing-key` / `credentials` | 额外禁止项 |
| backup | `github-only` / `key-only` / `separate-encrypted` | 副本策略 |

要点：

1. **适用条款只由 delivery 决定**，lifecycle 不改变条款范围。active 与 maintenance 的差别只有三处：变更许可、审计频率、平台要求。
2. **archived 由平台强制只读**，审计跳过。
3. 44 仓全部重新定位：active 13 / maintenance 31 / archived 0；delivery 分布 release 10 / service 11 / tool 11 / library 1 / content 3 / backup 7 / policy 1。
4. 原 29 项「整部不适用」白名单**废止**（取代 ADR-0002）：`backup` 仓按性质不适用其余条款，其余 37 仓按 delivery 派生适用条款并登记 §4 台账。
5. 机器可读载体为 `governance/desired-state.json`；`audit-drift.py` 与 `check-governance-consistency.sh` 负责对账。

## 后果

- 优点：条款派生可解释、可审计；新增仓只需填两个轴，不用再讨论「是否豁免」。
- 优点：`maintenance` 不再等于「没人管」——它仍有全量条款，只是允许的变更类型更窄。
- 代价：需要维护 44 行定位数据；填错会把条款套错。缓解：`--only` 单仓复核 + 周检。
- 代价：「有没有偷偷加功能」审计查不出，只能靠提交审查与 PR 约定。
- 代价：原豁免仓回到 §4 台账后，命名与结构要求名义上恢复；已交付产物仍保留，不追溯删除。

## 不采用

- 继续用单一 profile：无法表达交付形态与维护状态的差异，会重复「并集或全弃」。
- 只按可见性分档：public/private 与条款适用无关，私有仓同样需要发布与结构规范。
- 引入第三方评分（Scorecard）作为档位：评分是结果，不是治理输入；本仓只把它作为观测项。
