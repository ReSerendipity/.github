# Security Policy

> 本文件是 ReSerendipity 组织的默认安全披露策略。**若目标仓库带有自己的 `SECURITY.md`，以仓库版本为准。**

## Supported Versions

各仓库在各自的 `SECURITY.md` 中列明受支持版本。默认规则：

- 仅最新的稳定发布版与 `main` 分支接收安全修复；
- 历史版本（前代 `1.x` 等）通常不再维护，请升级到最新版本。

## Reporting a Vulnerability

请**不要**在公开 Issue 或 Discussions 中披露安全漏洞。请通过以下任一方式私下报告：

- 向仓库维护者在 GitHub 上的公开联系方式发送邮件（主题以 `[SECURITY]` 开头）；
- 使用 GitHub 的 **Private vulnerability report** 功能（仓库 → Security → Report a vulnerability）。

报告请尽量包含：

1. 漏洞类型与影响范围
2. 受影响的版本
3. 最小复现步骤（PoC 优先）
4. 影响评估与建议的缓解/修复方案

## Response Time

- 确认收到报告：**48 小时内**
- 初步评估与修复计划：**5 个工作日内**
- 严重（Critical/High）漏洞：优先修复并尽快发布补丁

修复将合入 `main` 并在发布说明中提及；在补丁发布前，我们默认不公开漏洞细节（负责任披露）。

## Security Features

各仓库的安全设计（如路径守卫、鉴权、完整性校验、密钥扫描等）详见其自身 `SECURITY.md` 或 README 中的安全相关章节。