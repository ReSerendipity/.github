# 归档：§12.3 存量结构收敛结果（2026-10-19）

> 归档日：2026-11-19｜原路径：`governance/REPOSITORY_GUIDELINES.md` §12.3（原文行 681–694）
> 一句话结论：17 仓根目录散落文档 / 脚本迁移的逐仓 PR 表与收敛后复跑普查，本节欠账当日清零。
> 正文未改，逐字搬运。

---

### 12.3 存量收敛结果（2026-10-19 实测回填）

**批次执行**：17 个管辖仓全部经豆包 agent 并行迁移（本地电脑模式 14 单 + 云电脑模式 3 单），agent 只开 PR、编排方独立验收后合并。

| 仓 | PR | 备注 |
|---|---|---|
| Agent-Knowledge / ComfyUI-Experiment-Toolbox / GalgameShell / Github-Repo-Scan / Image-DuoModel / Image-Scrapers / MiniMax-H3-Lite / Nekogal-DL / Prompt-Library / ReSerendipity / SeedVR2-Lite / SpiritPal / TTS-MultiModel | #4 / #4 / #12 / #5 / #132 / #22 / #99 / #4 / #4 / #7 / #165 / #154 / #192 | 提交全部为迁移 + 修链，纯净通过 |
| Card-Studio | #7 | 含 §7 家族 `git rm --cached`（公开仓 local/ 保留） |
| Health-Info-Card | #5 | 同上（AGENTS/CLAUDE 双语四件） |
| Lineart-Painter | #9 + **#10（补漏）** | 工具脚本 7 个迁 scripts/、应用源码 8 个按语言惯例留根；复跑发现 2 个历史调研报告漏归档，补 PR 归档 `_archive/` |
| DraftPeek | **#133（#132 拆分）** | agent 将本机 14 个未授权 WIP 提交一并打包进 #132，验收查出后拆分：3 个迁移提交 cherry-pick 零冲突重放为 #133 合并，WIP 剥离至本机 `wip/local-20261019` 分支待所有者处置，旧 PR 关闭留痕 |

**复跑普查（收敛后，远端 main）**：14 仓根目录散落清零；4 项**合规保留**如实记录——`ComfyUI-Experiment-Toolbox/run.py`（唯一入口，语言惯例留根）、`Card-Studio/CONTRIBUTING.md`（GitHub 社区健康文件）、`Health-Info-Card` 的 `CHANGELOG.zh_CN.md` / `README.zh_CN.md`（双语配对跟随主文件留根）、`Prompt-Library` 根级 7 个中文规范文档（该仓内容主体即规范条目，属交付物非项目文档）。**本节欠账清零。**

