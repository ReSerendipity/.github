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

遗留 commit 可使用 `git commit --amend -s` 补上。DCO 是自动校验的（未经签名的提交会把对应 PR 标红）。

## 许可

- 项目代码以 **Apache-2.0** 授权（以各仓库 `LICENSE` 为准），您提交即表示同意在该许可下授权您的贡献。
- 模型权重与第三方组件的许可以各仓库 `NOTICE`、`THIRD_PARTY_NOTICES.md` 或合规文档为准，请在使用或分发前核对。

## 治理与规范

- `AGENTS.md`（如存在于仓库工作区）是面向 AI 辅助开发的操作约定，通常仅本地保留、不随仓库分发；人工贡献者可忽略。
- 行为准则见 `CODE_OF_CONDUCT.md`；安全披露见 `SECURITY.md`（请勿公开提交安全漏洞）；支持渠道见 `SUPPORT.md`。
- 若目标仓库存在项目定制版上述文件，以定制版为准。

再次感谢您参与——社区的每一份贡献都在让这个生态更好。