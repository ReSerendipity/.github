# ADR-0016：账号级口令保险库的命名例外

- **状态**：Accepted
- **日期**：2026-11-03
- **决策者**：Doro（ReSerendipity，账号所有者）
- **相关**：§1（命名）、§3（密钥备份）、§15（两轴分档）、`GOVERNANCE-EXCLUSIONS.md` §零、ADR-0006

## 背景

2026-11-02 新建私有仓 `KeyBackup-Passwords`，用途是集中离线备份所有 `*-KeyBackup` 加密包的 AES-256 主口令（README 自述 + 仓内 `key-backup-passwords.txt` + `SHA256SUMS.txt`）。

它不符合 §3 的固定命名格式 `<项目名>-KeyBackup`：该仓不对应任何单一项目，而是账号级口令保险库；`KeyBackup` 是类别前缀，`Passwords` 才是内容。

不登记会持续触发漂移审计（`audit-drift.py` 判 DRIFT）与定时 CI 红；改名则会破坏刚建立的口令台账路径与已写出的备份说明。

## 决策

1. **保留现名 `KeyBackup-Passwords`**，作为 §1 的**命名例外**登记进 §4「例外名」之外的备份分组（`delivery=backup`，不进 §4 台账）。
2. 定位：`visibility=private`、`delivery=backup`、`distribution=none`、`lifecycle=maintenance`、`backup=key-only`，写入 `governance/desired-state.json`。
3. 管理口径按 §3：只要求 `SHA256SUMS.txt`、轮换更新与私有可见性；不参与 §1 命名校验与 §10 发布审计。
4. **口令入库风险显式接受**：仓内 `key-backup-passwords.txt` 为明文口令台账。该决定沿用既有先例（`Android-IconAutoArrange-Assets-Backup`、`MiniMax-H3-Lite-KeyBackup`），风险表述见 `GOVERNANCE-EXCLUSIONS.md` §一「口令入库例外」：账号失守时加密包等同失效。
5. 清单联动：`EXCLUDED_FROM_REGISTRY` 9→10、`EXCLUDED_FROM_RELEASE_STANDARD` 40→42（另含同时新增的非发布仓 `DormitoryNotes-Godot`）、备份仓总数 9→10、全账号 51→53。

## 后果

- **代价**：又一个明文口令载体；`<项目名>-KeyBackup` 的命名一致性被打破，读表的人需要知道这是账号级例外。
- **收益**：口令保险库有确定归属（私有备份仓），漂移审计可解释该仓存在，不必为命名美观再搬一次家。
- 将来若要恢复命名一致性，需新 ADR 覆盖本篇，并同步改名、本地目录、remote URL 与全部引用。

## 不采用的方案

1. **改名为 `Account-KeyBackup`**：更符合 §3 格式，但会打断刚建立的备份路径与说明，且 `Account` 作为「项目名」语义牵强。
2. **不登记、只在本文档口头说明**：`audit-drift.py` 会把未登记仓判 DRIFT，定时门禁长期红，违反「检查必须有载体」。
3. **并入某个现有 `*-KeyBackup`**：口径上属于跨项目口令，混入单项目备份会扩大单仓失守的影响面。
