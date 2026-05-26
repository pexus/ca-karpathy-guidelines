<#
.SYNOPSIS
    Karpathy Guidelines Installer (v2) - PowerShell edition

.DESCRIPTION
    Safely installs or UPDATES the Karpathy Behavioral Guidelines.
    - Always creates timestamped backups
    - Replaces existing demarcated section (supports updating old versions)
    - Supports interactive and non-interactive mode

.EXAMPLE
    # Interactive
    iwr -useb https://.../install.ps1 | iex

    # Non-interactive
    iwr -useb https://.../install.ps1 | iex -Args "--agents", "grok,claude,cursor"
#>

[CmdletBinding()]
param(
    [string]$Agents,
    [switch]$Yes
)

$ErrorActionPreference = 'Stop'
$RepoRawUrl = "https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main"
$GuidelinesUrl = "$RepoRawUrl/karpathy-guidelines.md"
$CursorMdcUrl = "$RepoRawUrl/.cursor/rules/karpathy-guidelines.mdc"
$BackupDir = ".agents-backups"

function Write-Info    { Write-Host "[INFO]  " -NoNewline -ForegroundColor Cyan; Write-Host $args }
function Write-Success { Write-Host "[OK]    " -NoNewline -ForegroundColor Green; Write-Host $args }
function Write-Warn    { Write-Host "[WARN]  " -NoNewline -ForegroundColor Yellow; Write-Host $args }
function Write-Error2  { Write-Host "[ERROR] " -NoNewline -ForegroundColor Red; Write-Host $args }

# --- Argument Handling -----------------------------------------------------------
$NonInteractive = $false
if ($Agents) { $NonInteractive = $true }

# --- Safety & Backup Strategy ----------------------------------------------------
$IsGitRepo = $false
try {
    git rev-parse --is-inside-work-tree 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) { $IsGitRepo = $true }
} catch {}

$UseFileBackups = -not $IsGitRepo

if ($IsGitRepo) {
    Write-Info "Git repository detected — relying on git for file recovery. No separate backups will be created."
} else {
    Write-Warn "This directory does not appear to be a git repository."
    if (-not $Yes) {
        $ans = Read-Host "Continue anyway? [y/N]"
        if ($ans -notmatch '^[Yy]') { exit 0 }
    }

    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
    $Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $BackupPrefix = Join-Path $BackupDir $Timestamp
    Write-Info "Backups will be saved to: $BackupPrefix"
}

# --- Download --------------------------------------------------------------------
Write-Info "Fetching latest guidelines..."

try {
    $GuidelinesContent = Invoke-RestMethod -Uri $GuidelinesUrl
} catch {
    Write-Error2 "Failed to download guidelines."
    exit 1
}

$pattern = '(?s)<!-- BEGIN karpathy-guidelines -->.*?<!-- END karpathy-guidelines -->'
$GuidelinesSection = [regex]::Match($GuidelinesContent, $pattern).Value

if (-not $GuidelinesSection) {
    Write-Error2 "Could not extract demarcated section."
    exit 1
}

# --- Core Function: Replace or Append (Idempotent + Updatable) -------------------
function Backup-File {
    param([string]$Path)

    if (-not $UseFileBackups) {
        return
    }

    if (Test-Path $Path -PathType Leaf) {
        $backup = "$BackupPrefix-$(Split-Path $Path -Leaf)"
        Copy-Item $Path $backup -Force
        Write-Success "Backed up: $Path"
    }
}

function Upsert-KarpathySection {
    param(
        [string]$Path,
        [string]$NewContent,
        [string]$Heading = "Karpathy Behavioral Guidelines"
    )

    Backup-File -Path $Path

    if (-not (Test-Path $Path)) {
        $dir = Split-Path $Path -Parent
        if ($dir) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        @"
# $(Split-Path $Path -Leaf)

This file contains instructions for coding agents.

"@ | Set-Content -Path $Path -Encoding UTF8
        Write-Info "Created $Path"
    }

    $content = Get-Content $Path -Raw

    if ($content -match 'BEGIN karpathy-guidelines') {
        # Replace existing block (this is the key improvement)
        $replacement = "## $Heading`r`n`r`n$NewContent`r`n"
        $newContent = [regex]::Replace(
            $content,
            '(?s)## Karpathy Behavioral Guidelines.*?<!-- END karpathy-guidelines -->',
            $replacement,
            'IgnoreCase'
        )

        # Fallback if the heading was different
        if ($newContent -eq $content) {
            $newContent = [regex]::Replace(
                $content,
                '(?s)<!-- BEGIN karpathy-guidelines -->.*?<!-- END karpathy-guidelines -->',
                $NewContent
            )
        }

        Set-Content -Path $Path -Value $newContent -Encoding UTF8 -NoNewline
        Write-Success "Updated existing Karpathy section in $Path (replaced with latest version)"
    } else {
        # Append
        $append = "`r`n`r`n## $Heading`r`n`r`n$NewContent`r`n"
        Add-Content -Path $Path -Value $append -Encoding UTF8
        Write-Success "Appended Karpathy guidelines to $Path"
    }
}

# --- Agent Selection -------------------------------------------------------------
function Get-SelectedAgents {
    param([string]$Spec)

    $selected = @{
        Grok = $false
        Claude = $false
        Cursor = $false
        Copilot = $false
    }

    if (-not $Spec) {
        # Interactive
        Write-Host ""
        Write-Info "Which coding agents do you use in this project?"
        Write-Host "You can enter multiple numbers separated by space or comma (e.g. 1 3), or choose one of the options below:"
        Write-Host ""
        Write-Host "  1) Grok Build"
        Write-Host "  2) Claude Code"
        Write-Host "  3) Cursor"
        Write-Host "  4) GitHub Copilot"
        Write-Host "  5) All (select everything above)"
        Write-Host "  6) None"
        Write-Host ""
        $input = Read-Host "Your choice"

        if ($input -match '^[aA5]$') {
            $selected.Grok = $selected.Claude = $selected.Cursor = $selected.Copilot = $true
        } else {
            foreach ($c in ($input -split '[, ]')) {
                switch ($c.Trim()) {
                    '1' { $selected.Grok = $true }
                    '2' { $selected.Claude = $true }
                    '3' { $selected.Cursor = $true }
                    '4' { $selected.Copilot = $true }
                    '5' { $selected.Grok = $selected.Claude = $selected.Cursor = $selected.Copilot = $true }
                }
            }
        }
    } else {
        # Non-interactive
        $lower = $Spec.ToLower()
        if ($lower -eq 'all') {
            $selected.Grok = $selected.Claude = $selected.Cursor = $selected.Copilot = $true
        } else {
            foreach ($p in ($lower -split '[, ]')) {
                switch ($p.Trim()) {
                    { $_ -in 'grok','groq' }   { $selected.Grok = $true }
                    'claude'                  { $selected.Claude = $true }
                    'cursor'                  { $selected.Cursor = $true }
                    { $_ -in 'copilot','github' } { $selected.Copilot = $true }
                }
            }
        }
    }
    return $selected
}

$selected = Get-SelectedAgents -Spec $Agents

# --- Execution -------------------------------------------------------------------
Write-Host ""
Write-Info "Installing / Updating Karpathy Guidelines (safe + updatable mode)..."

$agentsFile = "AGENTS.md"
Upsert-KarpathySection -Path $agentsFile -NewContent $GuidelinesSection

if ($selected.Claude) {
    $path = "CLAUDE.md"
    if ((Test-Path $path) -and (Select-String -Path $path -Pattern "karpathy" -Quiet)) {
        Write-Warn "$path already references Karpathy guidelines."
    } else {
        Backup-File -Path $path
        New-Item -ItemType Directory -Path (Split-Path $path) -Force | Out-Null
        @"
# CLAUDE.md

This project uses the Karpathy Behavioral Guidelines.

**Follow the demarcated section in [AGENTS.md](./AGENTS.md).**
"@ | Set-Content -Path $path -Encoding UTF8
        Write-Success "Created $path"
    }
}

if ($selected.Copilot) {
    $path = ".github/copilot-instructions.md"
    if ((Test-Path $path) -and (Select-String -Path $path -Pattern "karpathy" -Quiet)) {
        Write-Warn "$path already references Karpathy guidelines."
    } else {
        Backup-File -Path $path
        New-Item -ItemType Directory -Path (Split-Path $path) -Force | Out-Null
        @"
# copilot-instructions.md

This project uses the Karpathy Behavioral Guidelines.

**Follow the demarcated section in [AGENTS.md](../../AGENTS.md).**
"@ | Set-Content -Path $path -Encoding UTF8
        Write-Success "Created $path"
    }
}

if ($selected.Cursor) {
    $path = ".cursor/rules/karpathy-guidelines.mdc"
    Backup-File -Path $path
    New-Item -ItemType Directory -Path (Split-Path $path) -Force | Out-Null

    try {
        $mdc = Invoke-RestMethod -Uri $CursorMdcUrl
        Set-Content -Path $path -Value $mdc -Encoding UTF8
        Write-Success "Installed Cursor rule: $path"
    } catch {
        Write-Warn "Failed to download Cursor .mdc file."
    }
}

# --- Summary ---------------------------------------------------------------------
Write-Host ""
Write-Success "Installation complete."
if ($UseFileBackups) {
    Write-Info "Backups saved in: $BackupDir"
} else {
    Write-Info "No file backups created (git repository detected)."
}

if (Test-Path .git) {
    Write-Host ""
    Write-Host "Suggested commands:"
    Write-Host "  git status"
    Write-Host "  git diff $agentsFile"
    Write-Host "  git add $agentsFile CLAUDE.md .github .cursor"
    Write-Host "  git commit -m 'docs: add/update Karpathy behavioral guidelines'"
}

Write-Host ""
Write-Info "The Karpathy section is now demarcated and can be safely updated in the future."
