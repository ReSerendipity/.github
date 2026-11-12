# REVISION_LOG（自进化修订记录）

> 本文件由自进化协议维护：每次更新根 `AGENTS.md` 后追加一行，不删不改历史行。
> 路径优先 `local/agents/REVISION_LOG.md`；存量 `docs/agents/REVISION_LOG.md` 视为历史分片。
> 顶部「自进化版本」必须与最后一行版本对应；有 `scripts/check_revision_log.py` 的仓继续用机械闸。

| 自进化版本 | 日期 | 触发原因 | 更新内容摘要 | 对应项目版本 | 已校验 |
| :---: | ---------- | --- | --- | :---: | :-: |
| v1.0 | YYYY-MM-DD | 初始化台账 | 建立 GOTCHAS / REVISION_LOG 标准表头 | 当前版本 | — |
| v1.1 | 2026-10-30 | 安装自进化铁律与 pre-push 台账闸 | 根 AGENTS 增补铁律/交付勾选项；新增 `check-ledger-append.ps1` / `install-ledger-gate.ps1`；16 仓安装本地 hook | — | ✅ |
| v1.2 | 2026-10-31 | 大台账迁移完成 + 校验口径修正 | 4 仓 8 份旧格式台账全量重构为标准 6 列表（DraftPeek 24 / TTS 144 / SpiritPal 113 / IMDM 66，含 mbcs→UTF-8 乱码反解，`?` 计数 3554/1379）；新增 ADR-0013 并更新 decisions/README 索引；§7.4.4 增「格式迁移与无损校验」条；GOTCHAS 追加 #4/#5/#6；4 仓 `.ledger-baseline.json` 刷新到迁移后行数 | — | ✅ |
| v1.3 | 2026-10-31 | §17.5 补执行件与跨机边界（ADR-0014） | AGENTS §1.3 增并发判定命令、§4 增脚本命令；新增 ADR-0014 与 `check-agent-session.sh`（四查判定 + 锁 acquire/release）；§17.5 增「跨机边界」并改 §17.2 指向；反例测试 +11 例、CI negative-tests 增冒烟；governance/README 与根 README 的 ADR 范围更新到 0014；GOTCHAS 追加 #7；基线刷新 | — | ✅ |
| v1.4 | 2026-10-31 | 修复并发判定 stat-only 假阳性（PR #74） | dirty 判据改为 `git diff --name-only HEAD` + 未跟踪文件；反例测试再 +2（共 29 例）；§17.5 执行件说明同步；GOTCHAS 追加 #8；基线刷新 | — | ✅ |
| v1.5 | 2026-10-31 | 接入新仓 Object-Atlas 并完成登记 | 本地目录与远端名按 §1 校正为 `Object-Atlas`；新仓补 README / CHANGELOG / docs / AGENTS / 台账 / hook，`.qoder`、`dist`、`local` 移出入库；desired-state 48 → 49、登记仓 40 → 41、Train Case 32 → 33、active 12 → 13、service 11 → 12、私有仓 21 → 22；§4 / §1.4 / §15.6 / GOVERNANCE-EXCLUSIONS / governance/README / 根 README（中英）与展示图 r5/r4 同步；两份排除数组同步（§10 排除 37 → 38）；GOTCHAS 追加 #9 | — | ✅ |
| v1.6 | 2026-11-01 | 补登记 Subject-Courseware-Studio 与 VOSR2-Lite-KeyBackup | 两仓均已在远端存在但未登记（GOTCHAS #9 场景）：Subject 定为 content / active / none，补 README 定位、dbom=true 与本地台账闸；VOSR2 定为 backup / maintenance / key-only（仅 §3，README + SHA256SUMS + 加密包齐全）。计数 49 → 51、登记仓 41 → 42、Train Case 33 → 34、备份仓 8 → 9、active 13 → 14、maintenance 24 → 25、content 3 → 4、私有仓 22 → 24；§4 / §1.4 / §15.6 / GOVERNANCE-EXCLUSIONS / governance/README / 根 README（中英）与展示图 r6/r5 同步；排除数组 registry 8 → 9、release 38 → 40 | — | ✅ |
| v1.7 | 2026-11-01 | 未登记仓自动检测 + 自主提交推送口径（ADR-0015） | `audit-drift.py` 增远程差集与 `AUDIT_DRIFT_REMOTE_NAMES` 离线判据；`drift-audit.yml` 与 §20.4 私有仓计数 21 → 24、覆盖 48 → 51；§17 增「自主收口」，§17.2 / §17.3 增自主提交、合并与 CI 监控条款；新增 ADR-0015 与索引/范围/展示图 r7；AGENTS §6 增自主收口一行；GOTCHAS 追加 #11 | — | ✅ |
| v1.8 | 2026-11-03 | §12.5 通用工程件覆盖（四件厂商中立标配）+ AGENTS 计数校正 | 新增 §12.5 与 §12.1 三条位置约定及 `.github/scripts/` 例外；`governance/templates/` 增 4 份模板；`scaffold-repo.sh` 按 visibility/delivery 生成；`audit-drift.py` 增 4 类文件存在性分档；`GOVERNANCE-EXCLUSIONS.md` 增 §十一（私有 dependabot 13 仓 + ARCHITECTURE 8 仓豁免，含安全取舍声明）；本仓补 `.editorconfig` / `.github/CODEOWNERS` / `.github/dependabot.yml` / `ARCHITECTURE.md`；AGENTS 51 → 53 并补模板索引行；GOTCHAS 追加 #16–#18 | — | ✅ |
| v2.0 | 2026-11-07 | 账号级新增仓登记与命名裁决（ADR-0017） | 补登记 `Prompt-Provenance`（private/tool/active/none）、`Superagent-Demo`（原 `superagent-demo` 远程改名，private/tool/active/none）、`Junction-Scanner`（原 `JunctionScanner` 远程改名，public/tool/archived/none）；`dsh-superagent` 由 Train Case 转 §4「例外名」（上游生态名）；`Offer-Landing-Kit`、`Unity` 远程 404 移出台账并留痕；台账 44 → 45 行（例外名维持 8，dsh-superagent 顶替 Unity；Train Case 36 → 37）、账号 54 → 55、active 16 → 18、maintenance 26 → 25、archived 12 不变、service 13 → 12、tool 14 → 16、私有仓 26 → 28；§1.4 / §4 / §15.6 / GOVERNANCE-EXCLUSIONS（release 豁免 43 → 44）/ governance/README / 根 README 中英与展示图 `-20261107-r10/-r8` 同步；新增 ADR-0017 与索引 | — | ✅ |
