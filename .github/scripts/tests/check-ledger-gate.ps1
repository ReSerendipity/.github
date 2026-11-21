# check-ledger-gate.ps1 — 台账门禁反例测试（正例必须绿、负例必须红）
#
# 覆盖 check-ledger-append.ps1 的四条核心语义：
#   T1 首次运行：基线不存在 → 初始化并 rc=0
#   T2 代码变更未补 GOTCHAS 行 → rc=1
#   T3 代码变更 + GOTCHAS 新增行（同一提交）→ rc=0
#   T4 提交信息含 [skip-ledger] → 代码变更也可 rc=0
#   T5 AGENTS.md 变更未补 REVISION_LOG 行 → rc=1
#   T6 AGENTS.md 变更 + REVISION_LOG 新增行 → rc=0
#
# 用法：pwsh -NoProfile -File .github/scripts/tests/check-ledger-gate.ps1
# 退出码：0=全部符合预期；1=有用例不符合；2=环境不可用。
set-strictmode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Gate = Join-Path (Split-Path -Parent $ScriptDir) 'check-ledger-append.ps1'
$Pwsh = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
$Git = (Get-Command git -ErrorAction SilentlyContinue).Source
if (-not (Test-Path -LiteralPath $Gate)) { Write-Error "找不到 $Gate"; exit 2 }
if (-not $Pwsh -or -not $Git) { Write-Error '需要 pwsh 与 git'; exit 2 }

$Tmp = Join-Path ([IO.Path]::GetTempPath()) ("ledger-gate-test-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $Tmp -Force | Out-Null
$PASS = 0
$FAIL = 0

function Invoke-Git([string[]]$GitArgs) {
    & $Git -C $Tmp @GitArgs 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "git $($GitArgs -join ' ') 失败：rc=$LASTEXITCODE" }
}

function Invoke-Gate {
    & $Pwsh -NoProfile -File $Gate -Root $Tmp -Enforce 2>&1 | Out-Null
    return $LASTEXITCODE
}

function Add-Line([string]$Path, [string]$Line) {
    Add-Content -LiteralPath $Path -Value $Line -Encoding utf8NoBOM
}

function Check([string]$Name, [int]$Expected, [int]$Actual) {
    if ($Actual -eq $Expected) {
        Write-Host ("PASS  {0,-28} rc={1}" -f $Name, $Actual)
        $script:PASS++
    } else {
        Write-Host ("FAIL  {0,-28} 期望 rc={1}，实际 rc={2}" -f $Name, $Expected, $Actual) -ForegroundColor Red
        $script:FAIL++
    }
}

try {
    Invoke-Git @('init','-q')
    Invoke-Git @('config','user.email','ledger-test@example.com')
    Invoke-Git @('config','user.name','Ledger Test')

    New-Item -ItemType Directory -Path (Join-Path $Tmp 'local/agents') -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $Tmp 'AGENTS.md') -Value '# AGENTS' -Encoding utf8NoBOM
    Set-Content -LiteralPath (Join-Path $Tmp 'local/agents/GOTCHAS.md') -Value '| # | 坑 |' -Encoding utf8NoBOM
    Set-Content -LiteralPath (Join-Path $Tmp 'local/agents/REVISION_LOG.md') -Value '| 1 | init |' -Encoding utf8NoBOM
    Invoke-Git @('add','-A')
    Invoke-Git @('commit','-q','-m','init')

    Check 'T1 首次初始化基线' 0 (Invoke-Gate)

    Set-Content -LiteralPath (Join-Path $Tmp 'tool.py') -Value 'print(1)' -Encoding utf8NoBOM
    Invoke-Git @('add','-A')
    Invoke-Git @('commit','-q','-m','feat: code only')
    Check 'T2 代码变更缺 GOTCHAS' 1 (Invoke-Gate)

    Add-Line (Join-Path $Tmp 'local/agents/GOTCHAS.md') '| 2 | 新增坑 |'
    Set-Content -LiteralPath (Join-Path $Tmp 'tool2.py') -Value 'print(2)' -Encoding utf8NoBOM
    Invoke-Git @('add','-A')
    Invoke-Git @('commit','-q','-m','feat: code + gotcha')
    Check 'T3 代码 + GOTCHAS' 0 (Invoke-Gate)

    Set-Content -LiteralPath (Join-Path $Tmp 'tool3.py') -Value 'print(3)' -Encoding utf8NoBOM
    Invoke-Git @('add','-A')
    Invoke-Git @('commit','-q','-m','feat: code [skip-ledger]')
    Check 'T4 skip-ledger 逃生阀' 0 (Invoke-Gate)

    Add-Line (Join-Path $Tmp 'AGENTS.md') '# 变更'
    Invoke-Git @('add','-A')
    Invoke-Git @('commit','-q','-m','docs: agents')
    Check 'T5 AGENTS 缺 REVISION' 1 (Invoke-Gate)

    Add-Line (Join-Path $Tmp 'local/agents/REVISION_LOG.md') '| 2 | agents |'
    Invoke-Git @('add','-A')
    Invoke-Git @('commit','-q','-m','docs: revision')
    Check 'T6 AGENTS + REVISION' 0 (Invoke-Gate)
} finally {
    Remove-Item -LiteralPath $Tmp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "结果：PASS=$PASS FAIL=$FAIL"
if ($FAIL -gt 0) { exit 1 }
exit 0
