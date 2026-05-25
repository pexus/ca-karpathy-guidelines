<#
.SYNOPSIS
    ca-karpathy-guidelines installer for PowerShell (Windows, macOS, Linux)

.DESCRIPTION
    Safely appends the Karpathy Behavioral Guidelines into an existing (or new)
    AGENTS.md file and creates thin reference files for chosen coding agents.

    Always creates timestamped backups before modifying any files.

.USAGE
    From PowerShell:
        iwr -useb https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.ps1 | iex

    Or locally:
        .\scripts\install.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$RepoRawUrl = "https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main"
$GuidelinesUrl = "$RepoRawUrl/karpathy-guidelines.md"
$BackupDir = ".karpathy-backups"

function Write-Info    { Write-Host "[INFO]  " -ForegroundColor Cyan -NoNewline; Write-Host $args }
function Write-Success { Write-Host "[OK]    " -ForegroundColor Green -NoNewline; Write-Host $args }
function Write-Warn    { Write-Host "[WARN]  " -ForegroundColor Yellow -NoNewline; Write-Host $args }
function Write-Error2  { Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host $args }

# --- Safety Checks ----------------------------------------------------------------

if (-not (Test-Path .git -PathType Container)) {
    Write-Warn "This directory does not appear to be a git repository."
    $continue = Read-Host "Continue anyway? [y/N]"
    if ($continue -notmatch '^[Yy]') {
        Write-Info "Aborted by user."
        exit 0
    }
}

# Create backup directory
New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupPrefix = Join-Path $BackupDir $Timestamp

Write-Info "Backup directory: $BackupPrefix"

# --- Download Guidelines ------------------------------------------------------------

Write-Info "Fetching latest karpathy-guidelines.md ..."

try {
    $GuidelinesContent = Invoke-RestMethod -Uri $GuidelinesUrl -ErrorAction Stop
} catch {
    Write-Error2 "Failed to download guidelines from GitHub."
    Write-Error2 "Please check your internet connection."
    exit 1
}

# Extract the demarcated section using regex
$pattern = '(?s)<!-- BEGIN karpathy-guidelines -->.*?<!-- END karpathy-guidelines -->'
$GuidelinesSection = [regex]::Match($GuidelinesContent, $pattern).Value

if ([string]::IsNullOrWhiteSpace($GuidelinesSection)) {
    Write-Error2 "Could not extract the demarcated guidelines section."
    exit 1
}

# --- Helper Functions ---------------------------------------------------------------

function Backup-File {
    param([string]$Path)
    if (Test-Path $Path -PathType Leaf) {
        $fileName = Split-Path $Path -Leaf
        $backupPath = "$BackupPrefix-$fileName"
        Copy-Item $Path $backupPath -Force
        Write-Success "Backed up: $Path → $backupPath"
        return $backupPath
    }
    return $null
}

function Has-KarpathySection {
    param([string]$Path)
    if (Test-Path $Path) {
        return (Select-String -Path $Path -Pattern "BEGIN karpathy-guidelines" -Quiet)
    }
    return $false
}

function Append-ToFile {
    param(
        [string]$Path,
        [string]$Content,
        [string]$Heading = "Karpathy Behavioral Guidelines"
    )

    if (-not (Test-Path $Path)) {
        $dir = Split-Path $Path -Parent
        if ($dir) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        @"
# $(Split-Path $Path -Leaf)

This file contains instructions for coding agents working in this project.

"@ | Set-Content -Path $Path -Encoding UTF8
        Write-Info "Created new file: $Path"
    }

    if (Has-KarpathySection -Path $Path) {
        Write-Warn "$Path already contains the Karpathy guidelines. Skipping."
        return
    }

    $appendText = @"


## $Heading

$Content

"@

    Add-Content -Path $Path -Value $appendText -Encoding UTF8
    Write-Success "Appended Karpathy guidelines to $Path"
}

function Create-ThinReference {
    param(
        [string]$Path,
        [string]$Target,
        [string]$AgentName
    )

    $dir = Split-Path $Path -Parent
    if ($dir) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    if (Test-Path $Path) {
        if (Select-String -Path $Path -Pattern "karpathy" -Quiet) {
            Write-Warn "$Path already references Karpathy guidelines. Skipping."
            return
        }
        Backup-File -Path $Path | Out-Null
    }

    $content = @"
# $(Split-Path $Path -Leaf)

This project uses the Karpathy Behavioral Guidelines for coding agents.

**Please follow the demarcated "Karpathy Behavioral Guidelines" section in [$Target](./$Target).**

The pure guidelines are also available in ``karpathy-guidelines.md`` at the root of this repository.

These rules apply when using $AgentName.
"@

    Set-Content -Path $Path -Value $content -Encoding UTF8
    Write-Success "Created/updated thin reference: $Path"
}

# --- User Interaction ---------------------------------------------------------------

Write-Host ""
Write-Info "=== Karpathy Guidelines Installer (PowerShell) ==="
Write-Host ""

$AgentsFile = "AGENTS.md"

if (Test-Path $AgentsFile) {
    Write-Info "Found existing $AgentsFile"
} else {
    Write-Info "No $AgentsFile found in current directory."
}

Write-Host ""
Write-Info "Which coding agents / environments do you use in this project?"
Write-Host "Enter numbers separated by commas or spaces (e.g. 1,3,4), or 'a' for all:"
Write-Host ""
Write-Host "  1) Grok Build"
Write-Host "  2) Claude Code"
Write-Host "  3) Cursor"
Write-Host "  4) GitHub Copilot"
Write-Host "  5) None / I'll configure later"
Write-Host ""

$input = Read-Host "Your choice"

$selectedGrok = $false
$selectedClaude = $false
$selectedCursor = $false
$selectedCopilot = $false

$choices = $input -split '[, ]+' | Where-Object { $_ -ne '' }

if ($choices -contains 'a' -or $choices -contains 'A') {
    $selectedGrok = $true
    $selectedClaude = $true
    $selectedCursor = $true
    $selectedCopilot = $true
} else {
    foreach ($c in $choices) {
        switch ($c) {
            '1' { $selectedGrok = $true }
            '2' { $selectedClaude = $true }
            '3' { $selectedCursor = $true }
            '4' { $selectedCopilot = $true }
            '5' { } # none
            default { Write-Warn "Unknown option: $c" }
        }
    }
}

# --- Main Execution -----------------------------------------------------------------

Write-Host ""
Write-Info "Starting installation..."

# Backup and append to AGENTS.md
if (Test-Path $AgentsFile) {
    Backup-File -Path $AgentsFile | Out-Null
}

if (Has-KarpathySection -Path $AgentsFile) {
    Write-Warn "$AgentsFile already contains the Karpathy section."
} else {
    Append-ToFile -Path $AgentsFile -Content $GuidelinesSection -Heading "Karpathy Behavioral Guidelines"
}

# Thin references
if ($selectedClaude) {
    Create-ThinReference -Path "CLAUDE.md" -Target "AGENTS.md" -AgentName "Claude Code"
}

if ($selectedCopilot) {
    Create-ThinReference -Path ".github/copilot-instructions.md" -Target "AGENTS.md" -AgentName "GitHub Copilot"
}

if ($selectedCursor) {
    $cursorRule = ".cursor/rules/karpathy-guidelines.mdc"
    $cursorDir = Split-Path $cursorRule -Parent

    if (Test-Path $cursorRule) {
        if (Select-String -Path $cursorRule -Pattern "karpathy" -Quiet) {
            Write-Warn "$cursorRule already contains Karpathy content. Skipping."
        } else {
            Backup-File -Path $cursorRule | Out-Null
        }
    }

    New-Item -ItemType Directory -Path $cursorDir -Force | Out-Null

    try {
        $mdcUrl = "$RepoRawUrl/.cursor/rules/karpathy-guidelines.mdc"
        $mdcContent = Invoke-RestMethod -Uri $mdcUrl -ErrorAction Stop
        Set-Content -Path $cursorRule -Value $mdcContent -Encoding UTF8
        Write-Success "Installed Cursor rule: $cursorRule"
    } catch {
        Write-Warn "Could not download Cursor .mdc file. You can add it manually later."
    }
}

# --- Summary ------------------------------------------------------------------------

Write-Host ""
Write-Success "Installation complete!"
Write-Host ""
Write-Info "Backups saved in: $BackupDir\"
Write-Host ""

if (Test-Path .git) {
    Write-Host "Suggested next steps:"
    Write-Host "  git status"
    Write-Host "  git diff $AgentsFile"
    Write-Host '  git add $AgentsFile CLAUDE.md .github .cursor 2>$null'
    Write-Host '  git commit -m "docs: add Karpathy behavioral guidelines for coding agents"'
}

Write-Host ""
Write-Info "You can safely re-run this script. It will not duplicate existing sections."
Write-Host ""

if (Test-Path $AgentsFile) {
    Write-Info "The Karpathy section is demarcated in $AgentsFile using:"
    Write-Host "    <!-- BEGIN karpathy-guidelines -->"
    Write-Host "    ... content ..."
    Write-Host "    <!-- END karpathy-guidelines -->"
}
