# 安全政策 / Security Policy

## 支持的版本 / Supported Versions

本组织各仓库均采用「主干滚动开发」模式，安全修复只针对最新主干与最新 Release 发布。

| 版本 / Version | 支持情况 / Supported |
| --- | --- |
| 最新 Release / latest release | ✅ |
| main 分支 / main branch | ✅ |
| 旧 Release / older releases | ❌ 请升级 / please upgrade |

## 报告漏洞 / Reporting a Vulnerability

**请勿在公开 Issue、Pull Request 或 Discussion 中披露安全漏洞。**
**Please do NOT report security vulnerabilities through public issues, pull requests, or discussions.**

首选方式 / Preferred channel：

1. GitHub 私有漏洞报告：仓库页 **Security → Report a vulnerability**（推荐，支持私密讨论与 CVE 跟踪）；
   GitHub private vulnerability reporting via the repo's **Security → Report a vulnerability** (recommended).
2. 备用邮箱 / Fallback email: <ReSerendipity@outlook.com>

报告时请尽量包含 / Please include:

- 受影响的仓库与版本或 commit / affected repo, version or commit;
- 复现步骤或 PoC / reproduction steps or PoC;
- 影响评估（机密性 / 完整性 / 可用性）/ impact assessment (C/I/A);
- 已知的缓解方式 / any known mitigations.

响应目标 / Response targets：

- **48 小时内**确认收到 / acknowledgement within **48 hours**;
- **7 天内**给出初步评估与处理计划 / initial assessment within **7 days**;
- Critical 级别加急修复并尽快发布安全版本；修复发布后进行披露，报告者可选择署名。
  Critical issues are prioritized; disclosure happens after the fix ships, with optional reporter credit.

## 范围与威胁模型 / Scope & Threat Model

本组织项目以「**本地 / 自部署工具**」为主（桌面应用、本地 Web 服务、CLI）。默认威胁模型为**本机或可信内网环境**，因此：

- 默认仅绑定本机回环地址的端口、需要本机用户权限即可触达的问题，**一般不视为安全漏洞**，欢迎以 Issue 形式提出改进；
- 能被**远程非认证攻击者**利用、或默认配置即暴露到非本机网络的问题，均在受理范围内；
- 通过修改本地配置把服务暴露到不可信网络后产生的问题，请一并说明部署方式。

Most projects here are local-first / self-hosted tools. Issues that require local user privileges or loopback-only access are generally out of scope unless a default configuration exposes them to untrusted networks.

## 供应链与依赖 / Supply Chain

主力仓库启用了 Dependabot、CodeQL、gitleaks 等自动化扫描。依赖与构建链问题（恶意版本、投毒、action 供应链）同样适用本政策，请走私有报告渠道。

Dependency and build-chain issues (compromised packages, action supply-chain) follow the same policy — report privately.

## 政策适用 / Policy Coverage

本文件位于组织级 `.github` 仓库，作为全组织默认安全政策生效；个别仓库可用自己的 `SECURITY.md` 覆盖。
This org-level policy applies to every repository unless a repo provides its own `SECURITY.md`.
