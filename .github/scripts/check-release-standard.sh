#!/usr/bin/env bash
# §10 发布/分发统一规范的收敛核验（依据 REPOSITORY_GUIDELINES.md §10）。
#
# 为什么需要它：§10.6 的差异清单此前只能"靠人记着逐仓看"，"收敛到哪一步"没有任何
# 可复跑判据——这正是上一轮刚治过的病（检查必须有载体，否则就退化成靠记性）。
# 本脚本把 §10 中**可机器判定**的条款做成审计载体，输出两类结果：
#   FAIL = 与已裁决口径冲突（必须改）；
#   WARN = 未采用推荐口径（可接受，但应在仓内文档说明理由）。
#
# 定位说明（重要）：它**不是**每 PR 的必需门禁——收敛完成前必然大面积 FAIL，
# 挂上去只会常红，而"常红的门禁等于没有门禁"。定位是**审计 + 收敛进度对账**；
# 收敛完成后才谈是否挂远端、以什么范围挂。
#
# 只读：不发网络请求，不写任何文件。
#
# 用法：
#   bash .github/scripts/check-release-standard.sh --root <单仓目录>
#   bash .github/scripts/check-release-standard.sh --repos-dir <父目录> [--skip <名字>]...
# 退出码：
#   0 = clean（无 FAIL；WARN 不影响退出码）
#   1 = 存在 FAIL
#   2 = 入参不可用（目录不存在 / 参数冲突 / 未知参数）
set -uo pipefail

ROOT=''
REPOS_DIR=''
SKIPS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --root)        ROOT=${2:-}; shift 2 ;;
    --root=*)      ROOT=${1#*=}; shift ;;
    --repos-dir)   REPOS_DIR=${2:-}; shift 2 ;;
    --repos-dir=*) REPOS_DIR=${1#*=}; shift ;;
    --skip)        SKIPS+=("${2:-}"); shift 2 ;;
    --skip=*)      SKIPS+=("${1#*=}"); shift ;;
    *) echo "ERROR: 未知参数 '$1'" >&2; exit 2 ;;
  esac
done

if [ -n "$ROOT" ] && [ -n "$REPOS_DIR" ]; then
  echo "ERROR: --root 与 --repos-dir 只能给一个" >&2; exit 2
fi
if [ -z "$ROOT" ] && [ -z "$REPOS_DIR" ]; then
  echo "ERROR: 需要 --root（单仓）或 --repos-dir（多仓）" >&2; exit 2
fi
if [ -n "$ROOT" ] && [ ! -d "$ROOT" ]; then echo "ERROR: 目录不存在：$ROOT" >&2; exit 2; fi
if [ -n "$REPOS_DIR" ] && [ ! -d "$REPOS_DIR" ]; then echo "ERROR: 目录不存在：$REPOS_DIR" >&2; exit 2; fi

TOTAL_FAIL=0
TOTAL_WARN=0

# 在指定目录的 workflow 文件里匹配模式，**跳过注释行**，输出 path:line:content。
# 用 awk 而不是 grep，是为了让"是否注释行"按内容判定，不依赖路径里有没有冒号
# （Windows 下的路径形如 C:/... 本身带冒号，用 grep 输出反推注释会误判）。
scan_workflows() {  # $1=ERE  $2=workflows 目录
  local re="$1" dir="$2" f
  [ -d "$dir" ] || return 0
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    awk -v re="$re" '$0 !~ /^[ \t]*#/ && $0 ~ re { printf "%s:%d:%s\n", FILENAME, NR, $0 }' "$f"
  done <<EOF
$(find "$dir" -type f \( -name '*.yml' -o -name '*.yaml' \) 2>/dev/null | sort)
EOF
}

check_one() {
  local d="$1" name="$2"
  local fails=0 warns=0 hits=''
  echo ""
  echo "== $name  ($d)"

  # ── §10.5 发布文档（路径约定）──────────────────────────────
  if [ ! -f "$d/docs/release-governance.md" ]; then
    echo "   FAIL 缺 docs/release-governance.md（§10.5 路径约定）"
    fails=$((fails+1))
  elif grep -q '远端优先' "$d/docs/release-governance.md"; then
    echo "   ok   docs/release-governance.md（含「远端优先」标记）"
  else
    echo "   WARN docs/release-governance.md 未见「远端优先」标记，可能未按模板收敛"
    warns=$((warns+1))
  fi

  # ── §10.6 GPG 已裁决撤掉 ───────────────────────────────────
  if [ -e "$d/.github/workflows/gpg-signed-release.yml" ]; then
    echo "   FAIL 存在 gpg-signed-release.yml（2026-10-18 裁决撤掉 GPG，应删除/停用）"
    fails=$((fails+1))
  fi

  local wf="$d/.github/workflows"

  # ── §10.3 不得以 floating latest 作发布基线 ────────────────
  hits=$(scan_workflows 'value=latest' "$wf")
  if [ -n "$hits" ]; then
    echo "   FAIL 镜像 tag 仍启用 floating latest（§10.3）："
    printf '%s\n' "$hits" | sed 's/^/        /'
    fails=$((fails+1))
  fi

  # ── §10.4 扫描不得停在报告模式 ─────────────────────────────
  hits=$(scan_workflows "exit-code:[ \t]*[\"']?0" "$wf")
  if [ -n "$hits" ]; then
    echo "   FAIL 存在 Trivy 报告模式 exit-code: 0（§10.4 默认阻断）："
    printf '%s\n' "$hits" | sed 's/^/        /'
    fails=$((fails+1))
  fi

  # ── §10.4 镜像链应开 provenance + sbom（推荐口径 → WARN）───
  if [ -n "$(scan_workflows 'docker/build-push-action' "$wf")" ]; then
    if [ -n "$(scan_workflows 'provenance:[ \t]*true' "$wf")" ] &&
       [ -n "$(scan_workflows 'sbom:[ \t]*true' "$wf")" ]; then
      echo "   ok   镜像链已开 provenance + sbom"
    else
      echo "   WARN 镜像链未同时开 provenance: true 与 sbom: true（§10.4 推荐口径）"
      warns=$((warns+1))
    fi
  fi

  # ── §10.2 CHANGELOG ───────────────────────────────────────
  if [ ! -f "$d/CHANGELOG.md" ]; then
    echo "   FAIL 缺 CHANGELOG.md（§10.2 Keep a Changelog）"
    fails=$((fails+1))
  fi

  TOTAL_FAIL=$((TOTAL_FAIL+fails))
  TOTAL_WARN=$((TOTAL_WARN+warns))
  if [ "$fails" -eq 0 ] && [ "$warns" -eq 0 ]; then
    echo "   clean"
  fi
}

if [ -n "$ROOT" ]; then
  check_one "$ROOT" "$(basename "$ROOT")"
else
  # §10 排除清单（REPOSITORY_GUIDELINES.md §10 范围声明，2026-10-19 同源声明）：
  # 17 项均不适用 §10，不参与本审计。注意 6 个"用户点名豁免"仓虽保留文档产物，
  # 但豁免语义 = 不再要求、不再审计，故同样排除。改清单须三处同步（规范仓 §10、
  # check-repo-registry.sh 的 EXCLUDED_FROM_REGISTRY〔仅其中 7 项台账豁免〕、本声明）。
  EXCLUDED_FROM_RELEASE_STANDARD="DraftPeek-KeyBackup
Image-DuoModel-KeyBackup
SeedVR2-Lite-KeyBackup
TTS-MultiModel-KeyBackup
Android-IconAutoArrange-KeyBackup
Android-IconAutoArrange-Assets-Backup
Website-Genshin-Impact
Website-Honkai-Star-Rail
Website-Wuthering-Waves
Website-Zenless-Zone-Zero
rewq
ComfyUI-BatchPromptLoader
Multi-Tracker
Bilibili-Follow-Manager
Hugging-Face
Unfading-Wall
Unity"
  # 多仓模式：只扫含 .git 的一级子目录。跳过项**逐条显式列出**，不静默吞。
  SKIPPED=()
  SCANNED=0
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    name=$(basename "$d")
    if [ ! -e "$d/.git" ]; then SKIPPED+=("$name（无 .git，非仓库目录）"); continue; fi
    case "$name" in
      *-KeyBackup) SKIPPED+=("$name（§3 密钥备份仓，§10 不适用）"); continue ;;
      .github)     SKIPPED+=("$name（本规范仓自身，§10 由本仓 REPOSITORY_GUIDELINES.md 承载）"); continue ;;
      _*|.*)       SKIPPED+=("$name（下划线/点前缀：归档或本地工具目录，不在发布链范围）"); continue ;;
    esac
    skip=0
    for s in ${SKIPS[@]+"${SKIPS[@]}"}; do [ "$s" = "$name" ] && skip=1; done
    if [ "$skip" -eq 1 ]; then SKIPPED+=("$name（--skip 指定）"); continue; fi
    if printf '%s\n' "$EXCLUDED_FROM_RELEASE_STANDARD" | grep -qx "$name"; then
      SKIPPED+=("$name（§10 排除清单，不适用发布规范审计）"); continue
    fi
    SCANNED=$((SCANNED+1))
    check_one "$d" "$name"
  done <<EOF
$(find "$REPOS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
EOF
  echo ""
  echo "已排除 $(printf '%s\n' "${SKIPPED[@]+"${SKIPPED[@]}"}" | grep -c . || true) 项："
  printf '%s\n' "${SKIPPED[@]+"${SKIPPED[@]}"}" | sed 's/^/  - /'
  echo "实扫 $SCANNED 个仓"
fi

echo ""
echo "=== 汇总：FAIL=$TOTAL_FAIL  WARN=$TOTAL_WARN ==="
if [ "$TOTAL_FAIL" -gt 0 ]; then
  echo "gap：存在与 §10 已裁决口径冲突的项，按上列逐条收敛"
  exit 1
fi
echo "clean：无 FAIL 项"
exit 0
