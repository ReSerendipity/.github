# ReSerendipity .github

本仓库承载 ReSerendipity 账号的**默认社区健康文件**（default community health files）。

> 这里是治理文件仓库，不是个人主页。个人主页介绍请查看 [ReSerendipity/ReSerendipity](https://github.com/ReSerendipity/ReSerendipity)。

当某个下属仓库没有自带对应文件时，GitHub 会自动回退使用本仓库中的默认版本：

| 文件 | 作用 |
|---|---|
| `CODE_OF_CONDUCT.md` | 社区行为准则（Contributor Covenant 2.1） |
| `CONTRIBUTING.md` | 贡献指南（Conventional Commits + DCO） |
| `SECURITY.md` | 安全披露策略（默认版；各仓库自带版本优先） |
| `SUPPORT.md` | 支持渠道说明 |
| `REPOSITORY_GUIDELINES.md` | **仓库治理规范**：命名（Train Case + 短横线）、分支（main + 保护规则）、密钥备份模式、现网命名对照 |
| `.github/ISSUE_TEMPLATE/` | 通用 Issue 表单（Bug / 功能 / 提问；各仓库自带定制表单优先） |
| `.github/PULL_REQUEST_TEMPLATE.md` | 通用 Pull Request 检查清单 |

使用规则：

- 默认文件**只在其所属仓库未定义同名文件时生效**（查找优先级：`仓库 .github/` → `仓库根目录` → `仓库 docs/` → 本组织默认）。
- 需要项目定制的仓库（如专属许可说明、安全设计、模型合规条目）应自行提供同名文件覆盖默认。
- 本仓库本身不承载任何项目代码。
- 主页简介由同名仓库 `ReSerendipity/ReSerendipity` 承载。本账号是个人账号，`profile/README.md` 属组织账号（Organization）专属机制，在个人账号下不会渲染，因此本仓库不保留该文件。

治理约定细节见 `REPOSITORY_GUIDELINES.md`（命名/分支/密钥备份规范）、`CONTRIBUTING.md`、`CODE_OF_CONDUCT.md`、`SECURITY.md`、`SUPPORT.md`。

## 复用工作流

`.github/workflows/` 中的家族复用工作流由各仓通过 `workflow_call` 接入。调用方应引用已审阅的提交 SHA，而不是会漂移的 `@main`。`self-purify.yml` 默认维持非阻断兼容模式；调用仓完成规则核查后，可设置 `enforce_critical_checks: true`，将“本地治理文档不得被 git 跟踪”作为独立阻断门禁，其余健康检查仍保持告警性质。

## 维护原则

- 默认文件保持通用，不写入某个项目独有的运行步骤或模型说明。
- 项目需要例外规则时，应在项目仓库提供同名文件覆盖默认版本。
- 涉及安全、许可证和第三方模型的内容，优先链接到项目自己的合规文档。
- 只把稳定、可长期维护的约定放入默认文件，避免让所有仓库继承实验性规则。