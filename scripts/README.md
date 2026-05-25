# Installation Scripts

These scripts make it easy and **safe** to add the Karpathy Behavioral Guidelines to an existing project — even if you already have a complex `AGENTS.md`.

## Safety Guarantees

Both scripts are designed with safety first:

- **Always creates timestamped backups** before touching any file.
  - Backups go into `.karpathy-backups/YYYYMMDD-HHMMSS-...`
- Never overwrites an existing Karpathy section (detected via `<!-- BEGIN karpathy-guidelines -->` markers).
- Idempotent — safe to run multiple times.
- Works whether or not you're inside a git repository.

## Recommended Usage (One-Liner)

### Bash / zsh / Git Bash / WSL (Linux & macOS)

```bash
bash <(curl -sL https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.sh)
```

### PowerShell (Windows, macOS, Linux)

```powershell
iwr -useb https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.ps1 | iex
```

## What the Scripts Do

1. Ask which coding agents you use:
   - Grok Build
   - Claude Code
   - Cursor
   - GitHub Copilot

2. Create or update `AGENTS.md`:
   - If the file doesn't exist → creates a minimal one with the guidelines appended.
   - If it exists → appends the demarcated Karpathy section (unless already present).

3. Creates thin reference files for the agents you selected:
   - `CLAUDE.md`
   - `.github/copilot-instructions.md`
   - `.cursor/rules/karpathy-guidelines.mdc` (the stronger Cursor format)

4. Backs up every file it modifies with a timestamp.

## After Running the Script

```bash
# Review what changed
git status
git diff AGENTS.md

# Stage and commit (recommended)
git add AGENTS.md CLAUDE.md .github .cursor 2>/dev/null || true
git commit -m "docs: add Karpathy behavioral guidelines for coding agents"
```

## Manual / Offline Usage

If you already cloned this repo:

```bash
# From inside your project
/path/to/ca-karpathy-guidelines/scripts/install.sh

# or on Windows
pwsh /path/to/ca-karpathy-guidelines/scripts/install.ps1
```

## How It Detects Existing Guidelines

The scripts look for this marker:

```markdown
<!-- BEGIN karpathy-guidelines -->
```

If this comment exists anywhere in the target file, the script will refuse to append again. This prevents duplication even if you have custom headings.

## Advanced: Running Non-Interactively

Currently the scripts are interactive (they ask which agents you use). Non-interactive flags may be added in the future.

For now, you can still use them in CI or automation by pre-creating the files you need and running the script (it will skip files that already have the markers).

## Contributing

Improvements to cross-platform behavior, better Windows support, or additional agent shims are very welcome.

See the main [README](../README.md) for the overall philosophy of this project.