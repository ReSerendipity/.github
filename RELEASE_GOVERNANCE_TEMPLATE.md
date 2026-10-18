# 发布 / 回滚 规范（本仓本地化模板）

> **来源与权威**：公共条款见 `ReSerendipity/.github` 的 `REPOSITORY_GUIDELINES.md` §10（发布 / 分发统一规范）。
> 本文件是**模板**：各仓复制到自己的 `docs/release-governance.md`，只填**本仓特有**内容，**不得重写或抵触 §10 的公共条款**。
> 占位符 `<...>` 必须逐项替换，替换依据见文末「差异点采集清单」；**禁止留空**，未确定的写「待定（负责人 + 触发条件）」。

---

## 0. 远端优先（根原则，不可改写）

发布链的构建、打包、扫描、上传、推送**全部在 GitHub Actions 远端完成**；本地只做三件事：改版本位、落 CHANGELOG、`git tag` + `git push`。本地不执行打包 / 镜像构建 / 发布上传。

## 1. 版本号规范

- 遵循 **SemVer** `MAJOR.MINOR.PATCH`；预发布用 `-alpha.N` / `-beta.N` / `-rc.N`。
- **唯一权威版本位**：`<版本位文件与字段>`（当前 `<X.Y.Z>`）。
- 必须同步的其它版本位：`<逐项列出；无则写「无」>`
- 版本位漂移由 `<校验入口，例如 tests/test_version_consistency.py::test_all_version_sites_agree>` 钉住——**漂一处即判红**。
- 自动化方式：`<release-please（自动）/ 手动 tag（人工）>`；若用 release-please，须同时列明**哪些位自动、哪些位必须人补**。

## 2. CHANGELOG 管理

- 遵循 **Keep a Changelog**：`Added / Changed / Fixed / Deprecated / Removed / Security`。
- 每次合并 `main` 在 `[Unreleased]` 追加；type 映射 `feat→Added`、`fix→Fixed`、`refactor→Changed`。
- 发版时 `[Unreleased]` → `[VERSION] - YYYY-MM-DD`。

## 3. 发布流程（远端）

1. 确认 `[Unreleased]` 条目完整
2. 同步版本位（见 §1 清单）
3. 本地打 tag 并推送：`git tag v<X.Y.Z>` → `git push origin v<X.Y.Z>`
4. 远端凭 tag 触发 `<release.yml / release-please>` 构建产物
5. 远端建 **draft Release** 并挂资产 → 人工审核后 `published`
6. 盯到终态：`gh run list` 确认绿；红了当场修或 revert 止损

## 4. 分发产物与完整性

| 产物 | 构建位置 | 标签 / 命名 | 完整性手段 |
|---|---|---|---|
| `<wheel / sdist / 容器镜像 / APK / 安装包>` | **远端** | `<不可变 semver + sha；禁 floating latest>` | `SHA256SUMS.txt` + `<Tauri ed25519 .sig>` |

- 容器镜像：推 `ghcr.io`，`packages: write`；tag 取 semver + `sha`，**不得以 `latest` 作发布基线**。
- 镜像发布前须经 Trivy `CRITICAL,HIGH`（`ignore-unfixed`）**阻断**；豁免逐条登记在 `.trivyignore.yaml`（理由 + expiration）。
- 镜像链须开 `provenance: true` + `sbom: true`。
- **不使用 GPG 分离签名**（2026-10-18 裁决）。

## 5. 回滚

- **判定**（满足任一即触发）：`<本仓具体阈值>`
- **执行**：`git revert <bad-commit>`（保历史、可再 forward）；配置回滚 `<...>`；不可变产物按上一版 tag 重推
- **破坏性动作**：重指向 / 删除 tag、移动任何远端 ref → **须仓库所有者单独授权**
- **回滚后验证**：`<健康端点 / smoke 命令>`

## 6. SLA / 错误预算

- 目标可用性 `<99.5%/月>` ⇒ 错误预算 `<≈3.6h/月>`；超出即冻结非紧急发布并复盘。

## 7. 发布前检查清单

- [ ] 版本位全部同步（见 §1 清单）
- [ ] CHANGELOG `[Unreleased]` 已改版本 + 日期
- [ ] `<测试 / 覆盖率门禁命令>` 通过
- [ ] `<lint / format 命令>` 全绿
- [ ] 镜像类仓：Trivy 阻断通过，豁免已在 `.trivyignore.yaml` 登记理由 + expiration
- [ ] 镜像类仓：`provenance: true` + `sbom: true` 已开
- [ ] **本地未产出任何发布交付物**（全部远端构建）

---

## 差异点采集清单（生成时逐项替换）

| 占位符 | 采集来源 | 本仓取值 |
|---|---|---|
| 版本位文件与字段 | 仓内版本声明（`pyproject.toml` / `config.yaml` / `package.json`） | |
| 其它需同步版本位 | `grep -rn` 版本串 | |
| 版本一致性校验入口 | `<repo>/tests/**` | |
| 自动化方式 | `.github/workflows/`（是否有 release-please） | |
| 发布 workflow 文件名 | `.github/workflows/` | |
| 产物形态与标签规则 | 构建 workflow | |
| 完整性手段 | Release 资产清单 | |
| 回滚判定阈值 | 运行手册 / 监控 | |
| 回滚后验证命令 | `tests/smoke` 等 | |
| 技术栈 | `package.json` / `pyproject.toml` / 静态站 | |
| 部署目标 | `deploy/` / Pages workflow | |

## 禁止事项

- 不得重写 §10 的公共条款（远端优先、tag 驱动、版本位一致、不可变标签、扫描阻断、无 GPG）。
- 不得引入 `latest` 作发布基线；不得保留或新建 GPG 签名流程。
- 不得留空占位符，不得编造阈值。
