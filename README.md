# ca-karpathy-guidelines

**Universal behavioral guidelines for coding agents** — inspired by principles popularized by Andrej Karpathy and refined through real-world use across many teams.

These rules help Claude Code, GitHub Copilot, Cursor, Grok Build, Aider, and other agents produce dramatically better results: smaller focused diffs, much less over-engineering, fewer surprise refactors, and more reliable outcomes.

## The Core Problem This Solves

Most coding agents lack consistent "taste." Without explicit guidance they tend to:

- Over-engineer simple requests
- Make unrelated "improvements" while fixing something else
- Hide assumptions instead of surfacing them
- Declare victory without verifiable success criteria

This repository provides a high-signal, **composable** set of behavioral rules that works across all major agents.

---

## Important: `AGENTS.md` Is a Generic, Composable File

`AGENTS.md` (along with `CLAUDE.md`, `.github/copilot-instructions.md`, etc.) is becoming the standard place for **all** instructions to coding agents.

Many projects **already have** an `AGENTS.md` containing:

- Project-specific conventions
- Tech stack rules
- Testing requirements
- Architecture decisions
- Team coding standards

**This is the key challenge** this repository must solve well.

---

## Easiest Way: Use the Installer Script (Recommended for Most People)

We provide safe, cross-platform installer scripts that handle everything for you:

- Detect whether you already have an `AGENTS.md`
- **Always create timestamped backups** before modifying anything
- **Replace** the existing Karpathy section if present (even old versions) — true idempotency + future-proof updates
- Create the proper thin reference files for the agents you actually use
- Support both interactive and non-interactive (`--agents`) usage
- Work on Linux, macOS, Windows, WSL, and Git Bash

After running, you can also run the `verify` script (useful in CI or to check status).

### One-liner installation

**Bash / zsh / Git Bash / WSL:**

```bash
bash <(curl -sL https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.sh)
```

**PowerShell (Windows, macOS, Linux):**

```powershell
iwr -useb https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/install.ps1 | iex
```

The script will interactively ask which agents you use and do the right thing.

Full documentation: [scripts/README.md](./scripts/README.md)

---

## Recommended Approach: Composition Over Replacement

We strongly recommend **appending** these behavioral guidelines into your existing `AGENTS.md` rather than replacing it.

### Option A — Best for Most Teams: Append the Demarcated Section (Recommended)

1. Copy the contents of [`karpathy-guidelines.md`](./karpathy-guidelines.md)
2. Paste it into your existing `AGENTS.md` under a clear heading

The file `karpathy-guidelines.md` is specifically designed for this use case. It contains clean `<!-- BEGIN karpathy-guidelines -->` and `<!-- END karpathy-guidelines -->` markers so you can easily find and update it later.

Example of what your `AGENTS.md` might look like:

```markdown
# AGENTS.md

## Project-Specific Rules
- Use TypeScript strict mode
- All features need Playwright tests
- Prefer server actions for mutations

## Karpathy Behavioral Guidelines
<!-- BEGIN karpathy-guidelines -->
... (paste from karpathy-guidelines.md) ...
<!-- END karpathy-guidelines -->
```

### Option B — Greenfield / New Projects

If you don't have an `AGENTS.md` yet, you can start with the full example:

```bash
curl -O https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/AGENTS.md
```

This gives you a complete, well-structured starting point (see the [AGENTS.md](./AGENTS.md) in this repo as an example).

### Option C — Advanced: Keep Guidelines Separate

Some teams prefer to keep the Karpathy rules in their own file and reference them:

```markdown
## Behavioral Guidelines

See [karpathy-guidelines.md](./karpathy-guidelines.md) for the core behavioral rules that all agents must follow.
```

Cursor users can also drop the `.cursor/rules/karpathy-guidelines.mdc` file for stronger activation.

---

## Files in This Repository

| File | Purpose | When to use |
|------|---------|-------------|
| `karpathy-guidelines.md` | **Pure guidelines** designed for easy appending | Most teams (recommended) |
| `AGENTS.md` | Full **example** of a combined file | Greenfield projects or as a reference |
| `CLAUDE.md` | Thin reference for Claude Code | When you want Claude to load rules automatically |
| `.github/copilot-instructions.md` | Thin reference for GitHub Copilot | Copilot users |
| `.cursor/rules/karpathy-guidelines.mdc` | Structured Cursor rules with `alwaysApply` | Cursor users who want strong enforcement |

---

## How to Use With Each Agent

### Grok Build

Grok Build automatically discovers `AGENTS.md` (and `Claude.md` / `AGENT.md` variants) from the project root and walks up the directory tree.

**Just make sure your Karpathy guidelines (or a reference to them) exist inside `AGENTS.md`.**

### Claude Code (Anthropic)

Claude Code loads `CLAUDE.md` automatically at the start of every session.

**Recommended options:**

- Keep a thin `CLAUDE.md` that says "Follow the guidelines in `AGENTS.md`"
- Or symlink it to your main `AGENTS.md` (Unix/macOS)
- Or include the demarcated Karpathy section directly in `CLAUDE.md`

### GitHub Copilot

Copilot reads `.github/copilot-instructions.md`.

Best practice is usually a thin file that points to your main `AGENTS.md` (which contains the Karpathy section).

### Cursor

Cursor reads `AGENTS.md` from the project root.

For maximum reliability, also add:

```bash
mkdir -p .cursor/rules
curl -o .cursor/rules/karpathy-guidelines.mdc \
  https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/.cursor/rules/karpathy-guidelines.mdc
```

The `.mdc` file uses `alwaysApply: true` and gives Cursor stronger structured control.

---

## Keeping Guidelines Up to Date

Because the installer scripts **replace** the demarcated section instead of appending, you can safely re-run the installer in the future when the Karpathy guidelines are improved.

We also provide `verify` scripts that are useful in CI pipelines:

```bash
bash <(curl -sL https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/scripts/verify.sh)
```

See [scripts/README.md](./scripts/README.md) for all options.

---

## Quick Start Recipes

### Recommended: Use the Installer Script

See the [one-liner commands above](#easiest-way-use-the-installer-script-recommended-for-most-people). This is the safest and easiest method for almost everyone.

### Manual: For an Existing Project That Already Has `AGENTS.md`

```bash
# 1. Get the clean appendable block
curl -O https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/karpathy-guidelines.md

# 2. Open your AGENTS.md and append the section under a heading
#    (use the BEGIN/END markers to keep it demarcated)
```

### Manual: For a New Project

```bash
curl -O https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/AGENTS.md

# Optionally add the agent-specific shims
mkdir -p .github .cursor/rules
curl -o CLAUDE.md https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/CLAUDE.md
curl -o .github/copilot-instructions.md https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/.github/copilot-instructions.md
curl -o .cursor/rules/karpathy-guidelines.mdc https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/.cursor/rules/karpathy-guidelines.mdc
```

---

## Why We Provide Both `karpathy-guidelines.md` and `AGENTS.md`

- `karpathy-guidelines.md` → Optimized for **composition** (append-friendly)
- `AGENTS.md` → Shows a **complete, realistic example** of what a combined file looks like

This dual approach makes the repository useful whether you're starting fresh or have years of accumulated agent instructions.

---

## Customization

After appending the Karpathy section, feel free to add more project-specific rules **above or below** it in your `AGENTS.md`.

You can also extend the individual shim files (`CLAUDE.md`, etc.) with agent-specific notes when needed.

---

## Attribution & Philosophy

These guidelines are heavily inspired by Andrej Karpathy's public discussions on effective prompting and workflows for coding agents, combined with patterns that have proven effective in large codebases throughout 2025–2026.

The goal of this repository is to make high-quality behavioral guardrails **easy to adopt** without forcing teams to throw away their existing conventions.

Maintained at: https://github.com/pexus/ca-karpathy-guidelines

## License

MIT — use freely.

---

**Contributions welcome.** The highest-leverage improvements are around making composition with existing `AGENTS.md` files even smoother.