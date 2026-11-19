# 归档：§10.6 发布规范收敛实证（2026-10-18）

> 归档日：2026-11-19｜原路径：`governance/REPOSITORY_GUIDELINES.md` §10.6（原文行 590–606、614–616）
> 一句话结论：29 仓发布规范收敛的逐项落地证据（标准下发 / 镜像 tag / GPG 删除 / draft 化 / SBOM 等），以及「非欠账说明」留痕。
> 正文未改，逐字搬运。

---

**已收敛（均经远端复核）**

| 项 | 结果 | 落地证据 |
|---|---|---|
| 标准下发 | 29 仓默认分支均有本地化 `docs/release-governance.md`；2026-10-29 复核：全部含「远端优先」或其英文等价「Remote-first」标记（`Health-Info-Card` 为英文版） | 见 §10 范围声明；逐仓开分支 + PR 合并，排除 10 项已逐条留痕 |
| 发布总纲统一 | 各仓文档以 `RELEASE_GOVERNANCE_TEMPLATE.md` 为结构、以本节为公共条款 | DraftPeek 原 `docs/VERSIONING.md` 已收敛为指向 `release-governance.md` 的迁移指针（184 行 → 3 行） |
| 镜像 tag | **账号内已无仓启用 floating `latest`** | TTS-MultiModel `docker-publish.yml` 的 `type=raw,value=latest` 行已删（PR #190） |
| 镜像扫描 | TTS 与 SeedVR2 的 `docker-publish.yml` 均转阻断（`exit-code: '1'`） | SeedVR2-Lite PR #164；转阻断前实测该镜像零发现，故未建豁免条目 |
| GPG 分离签名 | 6 仓的 `gpg-signed-release.yml` 已**全部删除并合并** | SpiritPal #146 / MiniMax-H3-Lite #95 / DraftPeek #131 / Image-DuoModel #129 / SeedVR2-Lite #164 / TTS-MultiModel #190 |
| 发布链最小修正 | 4 仓补上远端 SHA256SUMS 生成与挂载 | GalgameShell #10 / Health-Info-Card #3 / RTX-VSR-Lite #9 / ComfyUI-Experiment-Toolbox #2 —— 均只动 `release.yml` / `build-firmware.yml`，符合 §10.1 |
| 根级 `CHANGELOG.md` | **29 仓全部建立**（Keep a Changelog）：Unity 由既有 `docs/CHANGELOG.md` 搬迁至根级并留指针、`Health-Info-Card` 按本仓惯例双语配对（`CHANGELOG.md` + `CHANGELOG.zh_CN.md`）；无 tag / Release 的仓仅含 `[Unreleased]` 并如实注明，未编造版本号与日期 | 21 单 PR：#2 Unity / #11 GalgameShell / #6 ReSerendipity / #3 ComfyUI-Experiment-Toolbox / #4 Github-Repo-Scan / #7 Lineart-Painter / #2 Unfading-Wall / #9 Multi-Tracker / #4 Health-Info-Card / #6 Card-Studio / #4 Mooncake-Deconstruction / #2 Offer-Landing-Kit / #3 Android-IconAutoArrange / #4 Free-Model-Probe / #2 ChatGPT-Timezone-Fix / #2 Bilibili-Follow-Manager / #2 Hugging-Face / #2 Nekogal-DL / #2 Agent-Knowledge / #2 Prompt-Library / #3 ComfyUI-BatchPromptLoader。有 tag 的 5 仓版本段日期逐仓与真实 tag 提交/发布时间核对一致 |

| 镜像扫描双口径 | MiniMax-H3-Lite 的 `docker-scan.yml` 已由观察模式转**阻断**（`--exit-code 1`），与仓内 `trivy.yml` / `docker-gate.yml` 同口径 | PR #98 |
| SBOM / provenance | SeedVR2 用 buildx 内联字段；MiniMax-H3-Lite `ghcr.yml` 补 `provenance: true` + `sbom: true`；TTS 改用 `actions/attest-sbom` + `attest-build-provenance` 绑定**已推送 digest**（机制说明见剩余欠账表） | PR #98 / TTS #191 |
| 版本自动化 | Image-DuoModel 已**恢复 release-please 自动**（`release-type: simple`；`version.txt` 自动改写、`config.yaml` 人工补齐，与 TTS 口径统一） | PR #130 |
| 发布链 draft 化 | Multi-Tracker / Lineart-Painter / ComfyUI-BatchPromptLoader 三条链改为 **draft + 远端资产（含 `SHA256SUMS.txt`）**，人工审核后 published | PR #10 / #8 / #4 |
| 无发布链仓补链 | `Android-IconAutoArrange`（APK，runner 内手搓构建）与 `ChatGPT-Timezone-Fix`（MV3 扩展 zip）已补 tag 驱动 `release.yml` | PR #4 / #3 |

**非欠账说明（列出仅为留痕，不构成待办）**
**明确不补链的仓**：`Offer-Landing-Kit`（静态单文件站：无构建步骤、无打包脚本、无版本位，对外分发即 Pages 线上站点，已满足 §10.4 远端部署）、`Hugging-Face`（无 `.github/`、无构建产物）、`Unity`（Unity 工程需 Unity 授权，托管 runner 无法构建）——不补空链；待这些仓真正产生需版本化分发的产物时再立项。
**TTS 镜像 attestation 机制**：TTS 因「先构建不推送 → 扫描 → 再推送」结构，无法用 buildx 内联 `provenance: true`（docker exporter 不承载 attestation），已改用官方 attest-action 绑定已推送 digest；属机制等价替代，非欠账。
