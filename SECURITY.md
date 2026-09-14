# 安全政策 / Security Policy

> 本文件是 ReSerendipity 组织的默认安全披露策略。**若目标仓库带有自己的 `SECURITY.md`，以仓库版本为准。**
> This is the org-wide default security disclosure policy. If a repository ships its own `SECURITY.md`, that version takes precedence.

## 支持的版本 / Supported Versions

各仓库在各自的 `SECURITY.md` 中列明受支持版本。默认规则：

| 版本 / Version | 支持情况 / Supported |
| --- | --- |
| 最新稳定发布版 / latest stable release | ✅ |
| `main` 分支 / main branch | ✅ |
| 历史版本（前代 `1.x` 等）/ older releases | ❌ 请升级 / please upgrade |

- 仅最新的稳定发布版与 `main` 分支接收安全修复；
- 历史版本通常不再维护，请升级到最新版本。

## 报告漏洞 / Reporting a Vulnerability

请**不要**在公开 Issue、Pull Request 或 Discussions 中披露安全漏洞。
Please do **not** report security vulnerabilities through public issues, pull requests, or discussions.

请通过以下任一方式私下报告 / report privately via either channel:

- 向仓库维护者在 GitHub 上的公开联系方式发送邮件（主题以 `[SECURITY]` 开头，组织备用邮箱：`ReSerendipity@outlook.com`）；
- 使用 GitHub 的 **Private vulnerability report** 功能（仓库 → Security → Report a vulnerability，推荐，支持私密讨论与 CVE 跟踪）。

报告请尽量包含 / please include:

1. 漏洞类型与影响范围 / vulnerability type and impact scope
2. 受影响的版本或 commit / affected version or commit
3. 最小复现步骤（PoC 优先）/ minimal reproduction steps (PoC preferred)
4. 影响评估与建议的缓解/修复方案 / impact assessment and suggested mitigation or fix
5. 已知的临时缓解方式 / any known workarounds

## 响应时间 / Response Time

- 确认收到报告：**48 小时内** / acknowledgement within **48 hours**
- 初步评估与修复计划：**5 个工作日内** / initial assessment within **5 business days**
- 严重（Critical/High）漏洞：优先修复并尽快发布补丁 / Critical and High issues are prioritized

修复将合入 `main` 并在发布说明中提及；在补丁发布前，我们默认不公开漏洞细节（负责任披露）。
Fixes land on `main` and are noted in release notes; details stay private until the patch ships (responsible disclosure).

## 范围与威胁模型 / Scope & Threat Model

本组织项目以「**本地 / 自部署工具**」为主（桌面应用、本地 Web 服务、CLI），默认威胁模型为**本机或可信内网环境**：

- 默认仅绑定本机回环地址、需要本机用户权限即可触达的问题，**一般不视为安全漏洞**，欢迎以公开 Issue 形式提出改进；
- 能被**远程非认证攻击者**利用、或默认配置即暴露到非本机网络的问题，均在受理范围内；
- 通过修改本地配置把服务暴露到不可信网络后产生的问题，报告时请一并说明部署方式。

Most projects here are local-first / self-hosted tools. Loopback-only or local-privilege issues are generally out of scope unless a default configuration exposes them to untrusted networks.

## 供应链与依赖 / Supply Chain

主力仓库启用了 Dependabot、CodeQL、gitleaks 等自动化扫描。依赖与构建链问题（恶意版本、依赖投毒、GitHub Action 供应链）同样适用本政策，请走上述私有渠道报告。

Dependency and build-chain issues (compromised packages, dependency confusion, action supply-chain) follow the same policy — report privately.

## 安全特性 / Security Features

各仓库的安全设计（如路径守卫、鉴权、完整性校验、密钥扫描等）详见其自身 `SECURITY.md` 或 README 中的安全相关章节。
Per-repo security design (path guards, auth, integrity checks, secret scanning) is documented in each repository's `SECURITY.md` or README.
