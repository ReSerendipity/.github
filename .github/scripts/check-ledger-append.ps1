param(
  [string]$Root = (Get-Location).Path,
  [switch]$Enforce
)

$ErrorActionPreference = 'Stop'

function Resolve-Ledger([string]$repo, [string]$name) {
  $local = Join-Path $repo "local/agents/$name"
  if (Test-Path -LiteralPath $local) { return $local }
  $docs = Join-Path $repo "docs/agents/$name"
  if (Test-Path -LiteralPath $docs) { return $docs }
  return $null
}

$agents = Join-Path $Root 'AGENTS.md'
$gotchas = Resolve-Ledger $Root 'GOTCHAS.md'
$revision = Resolve-Ledger $Root 'REVISION_LOG.md'
if (-not $gotchas -or -not $revision) {
  Write-Host "ledger-gate: 台账缺失，跳过（$Root）"
  exit 0
}

$basePath = Join-Path $Root 'local/agents/.ledger-baseline.json'
if (-not (Test-Path -LiteralPath $basePath)) {
  $init = [ordered]@{
    gotchasLines = (Get-Content -LiteralPath $gotchas).Count
    revisionLines = (Get-Content -LiteralPath $revision).Count
    agentsHash = if (Test-Path -LiteralPath $agents) { (Get-FileHash -LiteralPath $agents -Algorithm SHA256).Hash } else { '' }
    updatedAt = (Get-Date).ToString('o')
  }
  $init | ConvertTo-Json | Set-Content -LiteralPath $basePath -Encoding UTF8
  Write-Host "ledger-gate: 已初始化基线（$Root）"
  exit 0
}

$base = Get-Content -LiteralPath $basePath -Raw | ConvertFrom-Json
$curGotchas = (Get-Content -LiteralPath $gotchas).Count
$curRevision = (Get-Content -LiteralPath $revision).Count
$curAgentsHash = if (Test-Path -LiteralPath $agents) { (Get-FileHash -LiteralPath $agents -Algorithm SHA256).Hash } else { '' }

$upstream = (git -C $Root rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null)
if ($upstream) {
  $changed = @(git -C $Root diff --name-only "$upstream..HEAD" 2>$null)
} else {
  $changed = @(git -C $Root show --name-only --pretty=format: HEAD 2>$null)
}
$codeChanged = $false
foreach ($f in $changed) {
  if ($f -and $f -notmatch '\.md$' -and $f -notmatch '^(docs|local)/') { $codeChanged = $true }
}
$msg = (git -C $Root log -1 --pretty=%B 2>$null) -join "`n"
$override = $msg -match '\[skip-ledger\]|本次无踩坑|无踩坑'

$gotchasAdded = $curGotchas -gt [int]$base.gotchasLines
$revisionAdded = $curRevision -gt [int]$base.revisionLines
$agentsChanged = $curAgentsHash -ne [string]$base.agentsHash

$fail = @()
if ($codeChanged -and -not $gotchasAdded -and -not $override) {
  $fail += '代码/配置/脚本变更，但 GOTCHAS 未新增行'
}
if ($agentsChanged -and -not $revisionAdded -and -not $override) {
  $fail += 'AGENTS.md 已变更，但 REVISION_LOG 未新增行'
}

if ($fail.Count -gt 0) {
  Write-Host "ledger-gate FAIL: $Root"
  foreach ($f in $fail) { Write-Host "  - $f" }
  Write-Host '  补救：追加台账行；或在提交信息写 [skip-ledger] / 本次无踩坑。'
  if ($Enforce) { exit 1 } else { exit 0 }
}

$next = [ordered]@{
  gotchasLines = $curGotchas
  revisionLines = $curRevision
  agentsHash = $curAgentsHash
  updatedAt = (Get-Date).ToString('o')
}
$next | ConvertTo-Json | Set-Content -LiteralPath $basePath -Encoding UTF8
Write-Host "ledger-gate OK: $Root"
exit 0
