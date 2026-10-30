param(
  [string]$Repos = '',
  [string]$GovernanceRoot = 'C:/Users/Doro/APP/repository/.github'
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$repoRoot = 'C:/Users/Doro/APP/repository'
$gateScript = Join-Path $GovernanceRoot '.github/scripts/check-ledger-append.ps1'
$repoList = if ($Repos) { $Repos -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ } } else { @() }

$ironLaw = @'
### 自进化铁律（强制）
- 每次踩坑 / 修 bug 后，必须在 `GOTCHAS.md` 表尾追加一行（日期、场景、现象、正确做法、推荐 `[sig:...]`）；没有新增就不算完成。
- 每次更新根 `AGENTS.md` 后，必须在 `REVISION_LOG.md` 表尾追加一行（版本、日期、触发原因、摘要、项目版本、已校验）。
- 台账路径以第 7 节索引为准；同一仓不得双份活跃副本；不得写密钥 / token / 口令 / 连接串。
'@

$checkLine = '- [ ] 本次若踩坑/修 bug：`GOTCHAS.md` 已追加一行；若更新了本文件：`REVISION_LOG.md` 已追加一行；无踩坑也写明「本次无踩坑」。'

foreach ($name in $repoList) {
  $root = Join-Path $repoRoot $name
  if (-not (Test-Path -LiteralPath $root)) { Write-Host "SKIP 不存在：$name"; continue }

  $agents = Join-Path $root 'AGENTS.md'
  if (Test-Path -LiteralPath $agents) {
    $t = [IO.File]::ReadAllText($agents, [Text.Encoding]::UTF8)
    if (-not $t.Contains('### 自进化铁律（强制）')) {
      $t = $t.Replace('## 4. 常用命令与验证', $ironLaw + "`n`n## 4. 常用命令与验证")
    }
    if (-not $t.Contains($checkLine)) {
      $t = $t.Replace('## 7. 索引', $checkLine + "`n`n## 7. 索引")
    }
    [IO.File]::WriteAllText($agents, $t, $utf8)
  } else {
    Write-Host "SKIP 无根 AGENTS.md：$name"
  }

  $localAgents = Join-Path $root 'local/agents'
  New-Item -ItemType Directory -Force -Path $localAgents | Out-Null
  $gotchas = if (Test-Path -LiteralPath (Join-Path $localAgents 'GOTCHAS.md')) { Join-Path $localAgents 'GOTCHAS.md' } else { Join-Path $root 'docs/agents/GOTCHAS.md' }
  $revision = if (Test-Path -LiteralPath (Join-Path $localAgents 'REVISION_LOG.md')) { Join-Path $localAgents 'REVISION_LOG.md' } else { Join-Path $root 'docs/agents/REVISION_LOG.md' }
  $basePath = Join-Path $localAgents '.ledger-baseline.json'
  if ((Test-Path -LiteralPath $gotchas) -and (Test-Path -LiteralPath $revision) -and -not (Test-Path -LiteralPath $basePath)) {
    [ordered]@{
      gotchasLines = (Get-Content -LiteralPath $gotchas).Count
      revisionLines = (Get-Content -LiteralPath $revision).Count
      agentsHash = if (Test-Path -LiteralPath $agents) { (Get-FileHash -LiteralPath $agents -Algorithm SHA256).Hash } else { '' }
      updatedAt = (Get-Date).ToString('o')
    } | ConvertTo-Json | Set-Content -LiteralPath $basePath -Encoding UTF8
  }

  $hooksDir = Join-Path $root 'local/hooks'
  New-Item -ItemType Directory -Force -Path $hooksDir | Out-Null
  $originFile = Join-Path $hooksDir '.origin'
  $orig = (git -C $root config --get core.hooksPath 2>$null)
  if (-not $orig) { $orig = '.git/hooks' }
  if ($orig -eq 'local/hooks' -or $orig -eq './local/hooks') {
    if (Test-Path -LiteralPath $originFile) { $orig = (Get-Content -LiteralPath $originFile -Raw).Trim() } else { $orig = '.git/hooks' }
  }
  if (-not (Test-Path -LiteralPath $originFile)) { Set-Content -LiteralPath $originFile -Value $orig -Encoding UTF8 }
  $origPath = if ([IO.Path]::IsPathRooted($orig)) { $orig } else { Join-Path $root $orig }
  $origHook = Join-Path $origPath 'pre-push'
  $origHookUnix = $origHook -replace '\\','/'
  $gateScriptUnix = $gateScript -replace '\\','/'
  $rootUnix = $root -replace '\\','/'

  $wrapper = @"
#!/usr/bin/env bash
set -e
ORIG="$origHookUnix"
if [ -f "`$ORIG" ]; then bash "`$ORIG" "`$@" || exit 1; fi
pwsh -NoProfile -ExecutionPolicy Bypass -File "$gateScriptUnix" -Root "$rootUnix" -Enforce
"@
  [IO.File]::WriteAllText((Join-Path $hooksDir 'pre-push'), $wrapper, $utf8)
  git -C $root config core.hooksPath 'local/hooks'

  if ((Test-Path -LiteralPath $gotchas) -and (Test-Path -LiteralPath $revision)) {
    [ordered]@{
      gotchasLines = (Get-Content -LiteralPath $gotchas).Count
      revisionLines = (Get-Content -LiteralPath $revision).Count
      agentsHash = if (Test-Path -LiteralPath $agents) { (Get-FileHash -LiteralPath $agents -Algorithm SHA256).Hash } else { '' }
      updatedAt = (Get-Date).ToString('o')
    } | ConvertTo-Json | Set-Content -LiteralPath $basePath -Encoding UTF8
  }

  Write-Host "INSTALLED $name (origHook=$origHook)"
}
