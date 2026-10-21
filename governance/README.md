# 治理手册（governance/）

本目录是 ReSerendipity 账号的**政策文档单一事实来源**；`.github` 仍承担默认社区健康文件与复用工作流，两者分工如下。

| 文件 | 作用 | 适用范围 |
|---|---|---|
| `REPOSITORY_GUIDELINES.md` | 治理规范 §1–§14：命名、分支、密钥备份、现网命名台账、变更流程、本地一致性、AGENTS 分流、README 双版本、本地产物、发布分发、许可证、结构、路径、硬编码 | 14 个管辖仓 |
| `GOVERNANCE-EXCLUSIONS.md` | 治理豁免清单：29 项不适用整部规范（备份仓 / 网站仓 / 点名豁免）及脚本载体对照 | 全账号 |
| `RELEASE_GOVERNANCE_TEMPLATE.md`（暂留根目录） | §10 发布文档统一模板；因在途 WIP 暂缓迁入 | 发布型仓 |

## 权威顺序

1. 本目录政策文档 > 各仓 `docs/` > 各仓 `README.md`
2. 平台配置（ruleset、必需检查）是政策的**执行层**，不另行成文
3. 豁免仓以 `GOVERNANCE-EXCLUSIONS.md` 为准：整部规范不适用，已交付产物保留

## 引用方式

各仓根 `README.md` 只放一行：

```markdown
> 治理规范：[ReSerendipity/.github/governance](https://github.com/ReSerendipity/.github/tree/main/governance)
```

**不复制正文**，避免多副本漂移。

## 变更流程

- 改动走分支 + PR + DCO 签名，合并前 `check-repo-registry.sh` 必须 `rc=0`
- 清单类改动需五处同步：本节政策文档、`.github/scripts/check-repo-registry.sh`、`check-release-standard.sh`、根 `README.md` 索引、各仓引用（如涉及）
- 版本记录写在各文件自身的变更段落，不另建 CHANGELOG
