# Contributing to ReSerendipity Projects

感谢您考虑为 ReSerendipity 旗下的开源项目贡献代码或文档！

## 参与方式

- **提交 Bug / 功能建议**：使用对应仓库的 Issue 表单模板（Bug 报告 / 功能请求 / 提问）。
- **提交代码**：Fork → 功能分支 → Commit → Pull Request。
- **改进文档**：修正错误、补充示例、完善翻译。
- **参与讨论**：使用仓库的 Discussions。

提交 PR 前请先阅读对应仓库的 README（快速开始 / 架构说明），并遵循其 CI 要求。

## 代码提交约定

### Conventional Commits

提交信息使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式：

```
<type>(<scope>): <subject>
```

- `type`：`feat` / `fix` / `docs` / `refactor` / `perf` / `test` / `chore` / `ci` / `security`
- PR 标题遵循同一格式；描述请包含：背景、改动内容、测试情况。

### DCO（Developer Certificate of Origin）

本组织要求所有贡献者签署开发者原创证书。每个 commit 必须包含 `Signed-off-by` 标记：

```bash
git commit -s
```

遗留 commit 可使用 `git commit --amend -s` 补上。

自动校验的**实际覆盖范围**（2026-10-17 现网核对）：

- 本仓库：`.github/workflows/ci.yml` 的 `signoff` 作业检查本次引入的提交区间，未签名的提交会把 PR 标红，直推 `main` 同样变红。
- 账号内其它仓库：**不是**靠继承本文件获得检查——默认健康文件只带文字、不带作业。各消费仓各自维护一份
  `.github/workflows/dco.yml`（`pull_request` 触发，按**每个提交自己的作者邮箱**豁免机器提交），
  与本仓的 `.github/scripts/check-signoff.sh` 是**两套独立实现**。因此改签名规则时必须两边一起核口径，
  否则会出现同一句承诺、两种判定。
- 本仓库的 `main` 已启用分支保护并要求 `Workflow lint`、`DCO sign-off`、`Reusable workflow smoke / 自净化核心规则（阻断）`
  三项检查通过；但 `enforce_admins` 为关闭状态，即**账号本人仍可直推并绕过这三项**（与 §2「本人可直推」一致）。

本地自查（推送前）：`bash .github/scripts/check-signoff.sh <base> <head>`，退出码非 0 即有缺签名的提交。

## 许可

- 项目代码以 **Apache-2.0** 授权（以各仓库 `LICENSE` 为准），您提交即表示同意在该许可下授权您的贡献。
- 模型权重与第三方组件的许可以各仓库 `NOTICE`、`THIRD_PARTY_NOTICES.md` 或合规文档为准，请在使用或分发前核对。

## 治理与规范

- `AGENTS.md`（如存在于仓库工作区）是面向 AI 辅助开发的操作约定，通常仅本地保留、不随仓库分发；人工贡献者可忽略。
- 行为准则见 `CODE_OF_CONDUCT.md`；安全披露见 `SECURITY.md`（请勿公开提交安全漏洞）；支持渠道见 `SUPPORT.md`。
- 若目标仓库存在项目定制版上述文件，以定制版为准。

再次感谢您参与——社区的每一份贡献都在让这个生态更好。