# 发布治理

> 本文件由 `RELEASE_GOVERNANCE_TEMPLATE.md` 复制。远端优先：构建、打包、签名、扫描、上传、推送一律在 GitHub Actions 完成。

## 版本与发布

- 版本号 SemVer；CHANGELOG 遵循 Keep a Changelog。
- tag 驱动：`v*` 触发发布链；Release 资产附 `SHA256SUMS.txt`。
