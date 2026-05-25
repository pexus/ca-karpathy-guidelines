<#
.SYNOPSIS
    Verify that Karpathy Behavioral Guidelines are properly installed in the project.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$ok = 0
$fail = 0

function Test-Check {
    param(
        [string]$Name,
        [scriptblock]$Condition
    )
    if (& $Condition) {
        Write-Host "  " -NoNewline
        Write-Host "✓ " -ForegroundColor Green -NoNewline
        Write-Host $Name
        $script:ok++
    } else {
        Write-Host "  " -NoNewline
        Write-Host "✗ " -ForegroundColor Red -NoNewline
        Write-Host $Name
        $script:fail++
    }
}

Write-Host ""
Write-Host "=== Karpathy Guidelines Verification ===" -ForegroundColor Cyan
Write-Host ""

Test-Check "AGENTS.md exists" { Test-Path "AGENTS.md" }
Test-Check "Karpathy section present in AGENTS.md" { 
    (Test-Path "AGENTS.md") -and (Select-String -Path "AGENTS.md" -Pattern "BEGIN karpathy-guidelines" -Quiet)
}

# Optional files
if (Test-Path "CLAUDE.md") {
    Test-Check "CLAUDE.md references Karpathy" { Select-String -Path "CLAUDE.md" -Pattern "karpathy" -Quiet }
} else {
    Write-Host "  " -NoNewline
    Write-Host "○ " -ForegroundColor Yellow -NoNewline
    Write-Host "CLAUDE.md (not present)"
}

if (Test-Path ".github/copilot-instructions.md") {
    Test-Check "copilot-instructions.md references Karpathy" { 
        Select-String -Path ".github/copilot-instructions.md" -Pattern "karpathy" -Quiet 
    }
} else {
    Write-Host "  " -NoNewline
    Write-Host "○ " -ForegroundColor Yellow -NoNewline
    Write-Host ".github/copilot-instructions.md (not present)"
}

if (Test-Path ".cursor/rules/karpathy-guidelines.mdc") {
    Test-Check "Cursor .mdc rule exists" { Test-Path ".cursor/rules/karpathy-guidelines.mdc" }
} else {
    Write-Host "  " -NoNewline
    Write-Host "○ " -ForegroundColor Yellow -NoNewline
    Write-Host ".cursor/rules/karpathy-guidelines.mdc (not present)"
}

Write-Host ""
if ($fail -eq 0) {
    Write-Host "All critical checks passed." -ForegroundColor Green
    exit 0
} else {
    Write-Host "$fail check(s) failed." -ForegroundColor Red
    Write-Host "Run the installer to fix the issues." -ForegroundColor Yellow
    exit 1
}
