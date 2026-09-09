# ReSerendipity .github

本仓库承载 ReSerendipity 组织的**默认社区健康文件**（default community health files）。

当某个下属仓库没有自带对应文件时，GitHub 会自动回退使用本仓库中的默认版本：

| 文件 | 作用 |
|---|---|
| `CODE_OF_CONDUCT.md` | 社区行为准则（Contributor Covenant 2.1） |
| `CONTRIBUTING.md` | 贡献指南（Conventional Commits + DCO） |
| `SECURITY.md` | 安全披露策略（默认版；各仓库自带版本优先） |
| `SUPPORT.md` | 支持渠道说明 |
| `.github/ISSUE_TEMPLATE/` | 通用 Issue 表单（Bug / 功能 / 提问；各仓库自带定制表单优先） |

使用规则：

- 默认文件**只在其所属仓库未定义同名文件时生效**（查找优先级：`仓库 .github/` → `仓库根目录` → `仓库 docs/` → 本组织默认）。
- 需要项目定制的仓库（如专属许可说明、安全设计、模型合规条目）应自行提供同名文件覆盖默认。
- 本仓库本身不承载任何项目代码。
- 主页简介由同名仓库 `ReSerendipity/ReSerendipity` 承载。`profile/README.md` 属组织账号（Organization）专属机制，在个人账号下不渲染，故本仓库不保留该文件。

治理约定细节见 `CONTRIBUTING.md`、`CODE_OF_CONDUCT.md`、`SECURITY.md`、`SUPPORT.md`。