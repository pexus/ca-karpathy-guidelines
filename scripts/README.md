# Installation Scripts

These scripts make it **safe and updatable** to add the Karpathy Behavioral Guidelines to any project — even if you already have a complex `AGENTS.md`.

## Key Improvements (v2)

- **True idempotency + updates**: If the guidelines already exist (even an older version), the scripts **replace** the demarcated section instead of appending again.
- **Non-interactive support**: Use `--agents` flag for CI, automation, or scripts.
- **Improved interactive selection**: Clear menu with explicit "**5) All**" option to easily enable all agents at once.
- Creates timestamped file backups **only when the project is not under git control**.
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

## Interactive Agent Selection

When running the installer interactively (the default one-liner), you will see this menu:

```
Which coding agents / environments do you use in this project?
You can enter multiple numbers separated by space (e.g. 1 3), or choose one of the options below:

  1) Grok Build
  2) Claude Code
  3) Cursor
  4) GitHub Copilot
  5) All (select everything above)
  6) None
```

**Key behaviors:**
- You can select **multiple agents** by typing numbers separated by spaces (example: `1 3 4`).
- Type **`5`** or **`a`** (or `A`) to quickly select **All** four agents.
- Choosing **All** is recommended if you use multiple coding agents, or if you want to proactively create the thin reference files (`CLAUDE.md`, `.github/copilot-instructions.md`, `.cursor/rules/...`) even if those directories don't exist in your project yet.

This makes it easy to set up your project for any combination of the supported agents.

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

- If the project is **under git**, we rely on git history for recovery — no extra backup folder is created.
- If the project is **not** under git, we create timestamped backups in `.agents-backups/<timestamp>-filename` before modifying any files.
- The demarcated Karpathy section is the only thing these scripts ever modify.
- The scripts are intentionally conservative.

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