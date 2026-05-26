# Installation Scripts

These scripts make it **safe and updatable** to add the Karpathy Behavioral Guidelines to any project — even if you already have a complex `AGENTS.md`.

## Key Improvements (v2)

- **True idempotency + updates**: If the guidelines already exist (even an older version), the scripts **replace** the demarcated section instead of appending again.
- **Non-interactive support**: Use `--agents` flag for CI, automation, or scripts.
- **Always creates timestamped backups** before any change.
- **Verify scripts** included for humans and CI pipelines.

---

## Recommended One-Liners

Copy and paste **one line at a time**.

### Bash / zsh / Git Bash / WSL

**Interactive (recommended for first time):**

```bash
bash <(curl -sL https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.sh)
```

**Non-interactive — all four agents (Grok Build, Claude, Cursor, Copilot):**

```bash
curl -sL https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.sh | bash -s -- --agents all --yes
```

**Non-interactive — specific agents only:**

```bash
curl -sL https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.sh | bash -s -- --agents grok,claude,cursor
```

### PowerShell (Windows, macOS, Linux)

**Interactive:**

```powershell
iwr -useb https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.ps1 | iex
```

**Non-interactive — all four agents:**

```powershell
iwr -useb https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.ps1 | iex -Args "--agents","all"
```

**Non-interactive — specific agents:**

```powershell
iwr -useb https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.ps1 | iex -Args "--agents","grok,claude,cursor"
```

### Windows CMD

```cmd
curl -sL https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.bat -o install.bat && install.bat
```

---

## Command Line Options (Bash)

```bash
--agents grok,claude,cursor,copilot,all     # Comma-separated list (use "all" for everything)
--yes, -y                                   # Assume yes to all prompts
--help
```

## Command Line Options (PowerShell)

```powershell
-Agents "grok,claude,cursor"     # Comma-separated. Use "all" to select everything
-Yes                             # Skip confirmation prompts
```

---

## Verify Scripts (Highly Recommended)

After installation (or in CI), run the verifier:

**Bash:**
```bash
bash <(curl -sL https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/verify.sh)
```

**PowerShell:**
```powershell
iwr -useb https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/verify.ps1 | iex
```

The verifier:
- Checks that `AGENTS.md` contains the demarcated Karpathy section
- Reports status of thin reference files
- Exits with code `1` if critical items are missing (useful for CI)

---

## How Replacement Works

The scripts look for these markers:

```markdown
<!-- BEGIN karpathy-guidelines -->
... old content ...
<!-- END karpathy-guidelines -->
```

If found → the **entire block is replaced** with the latest version from the repository.

This means:
- You can safely re-run the installer in the future when guidelines improve.
- No duplicate sections will ever be created.
- Your surrounding project-specific rules in `AGENTS.md` are preserved.

---

## Safety Model

1. Every modified file is backed up to `.karpathy-backups/<timestamp>-filename` **before** any change.
2. The demarcated section is the only thing that ever gets modified by these tools.
3. The scripts are intentionally conservative.

---

## Local / Offline Usage

If you have cloned the repo:

```bash
# From your project root
/path/to/ca-karpathy-guidelines/scripts/install.sh --agents all

# Verify
/path/to/ca-karpathy-guidelines/scripts/verify.sh
```

---

## Future Ideas

- Dry-run / preview mode before making changes
- Ability to target a specific subdirectory’s `AGENTS.md`

Contributions welcome.

See the main [README](../README.md) for philosophy and background.