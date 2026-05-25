# ca-karpathy-guidelines

**Universal behavioral guidelines for coding agents** — inspired by principles popularized by Andrej Karpathy and battle-tested across the community.

These rules help Claude Code, GitHub Copilot, Cursor, Grok Build, Aider, and other agents produce dramatically better results: smaller diffs, far less over-engineering, fewer surprise refactors, and more reliable outcomes.

## Why This Exists

Most coding agents are powerful but lack consistent "taste" and discipline. Without explicit guidance they tend to:

- Over-engineer simple requests
- Make unrelated "improvements" while fixing something else
- Hide assumptions instead of surfacing them
- Declare victory without verifiable success criteria

This repository provides a single, high-signal set of rules that works across all major agents.

## The Four Core Principles

1. **Think Before Coding** — Surface assumptions and tradeoffs early. Ask when unclear.
2. **Simplicity First** — Implement exactly what was asked. No speculative abstractions or future-proofing.
3. **Surgical Changes** — Touch only what is necessary. Never refactor unrelated code as a side effect.
4. **Goal-Driven Execution** — Define verifiable success criteria before you start. Loop until they pass.

Full details live in [AGENTS.md](./AGENTS.md).

## Recommended Project Structure

The cleanest approach is to treat `AGENTS.md` as the single source of truth and add thin references (or symlinks) for each agent's native file:

```
your-project/
├── AGENTS.md                          # ← Canonical guidelines (copy from this repo)
├── CLAUDE.md                          # Thin reference or symlink → AGENTS.md
├── .github/
│   └── copilot-instructions.md        # Thin reference or symlink → AGENTS.md
└── .cursor/
    └── rules/
        └── karpathy-guidelines.mdc    # Structured version for Cursor (recommended)
```

## How to Use With Each Agent

### Grok Build

Grok Build natively discovers `AGENTS.md` (and `Claude.md` / `AGENT.md` variants) from the project root and merges instructions from the directory tree.

**Just drop `AGENTS.md` into your project root.** No extra configuration needed.

### Claude Code (Anthropic)

Claude Code automatically loads `CLAUDE.md` at the start of a session when present in the project root.

**Options (best to worst):**

1. **Symlink** (Unix/macOS):
   ```bash
   ln -sfn AGENTS.md CLAUDE.md
   ```

2. **Thin reference file** (cross-platform, recommended):
   Create `CLAUDE.md` containing:
   ```markdown
   # CLAUDE.md
   Please follow the guidelines in [AGENTS.md](./AGENTS.md).
   ```

3. Copy the full content of `AGENTS.md` into `CLAUDE.md` (works but creates drift risk).

### GitHub Copilot

Copilot looks for `.github/copilot-instructions.md`.

**Recommended approaches:**

- Symlink (Unix):
  ```bash
  mkdir -p .github
  ln -sfn ../AGENTS.md .github/copilot-instructions.md
  ```

- Thin reference file at `.github/copilot-instructions.md` pointing to `AGENTS.md`.

VS Code's official guidance also recommends using `AGENTS.md` when you work with multiple AI coding agents.

### Cursor

Cursor automatically reads `AGENTS.md` from the project root.

For stronger, always-on enforcement, also add the structured rule file:

1. Copy `.cursor/rules/karpathy-guidelines.mdc` from this repo into your project.
2. The file uses `alwaysApply: true` so it activates reliably.
3. You can further customize activation with globs if desired.

Cursor users get the best of both worlds: root `AGENTS.md` + the richer `.mdc` format.

## Quick Start (Add to Your Project)

```bash
# From your project root
curl -O https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/AGENTS.md

# Optional but recommended
mkdir -p .github .cursor/rules

# Thin shims (or use symlinks on Unix)
curl -o CLAUDE.md https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/CLAUDE.md
curl -o .github/copilot-instructions.md https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/.github/copilot-instructions.md
curl -o .cursor/rules/karpathy-guidelines.mdc https://raw.githubusercontent.com/pexus/ca-karpathy-guidelines/main/.cursor/rules/karpathy-guidelines.mdc
```

Or simply clone this repo and copy the files you need.

## Symlinks vs Thin Files vs Full Copies

| Approach       | Pros                              | Cons                              | Best For          |
|----------------|-----------------------------------|-----------------------------------|-------------------|
| **Symlinks**   | Single source of truth            | Broken on Windows by default      | Linux / macOS teams |
| **Thin files** | Cross-platform, explicit          | Slight indirection                | Most teams (recommended) |
| **Full copy**  | Works everywhere, no indirection  | Content drifts over time          | Small projects or when you want local edits |

Most mature teams use either symlinks (Unix) or thin reference files.

## Customization

You can (and should) extend `AGENTS.md` with project-specific rules at the bottom of the file:

```markdown
## Project-Specific Rules

- This codebase uses biome for formatting — never run prettier.
- All new features must include Playwright tests.
- Prefer server actions over route handlers for data mutations.
```

Agent-specific notes can also be added to the individual shim files (`CLAUDE.md`, etc.) when one agent needs extra context the others don't.

## Attribution

These guidelines are heavily inspired by the public discussion and materials shared by **Andrej Karpathy** around effective ways to work with coding agents, combined with patterns that have proven effective across many large codebases and agent users in 2025–2026.

Maintained as a reusable, multi-agent-friendly package at:  
https://github.com/pexus/ca-karpathy-guidelines

## License

MIT — use freely in personal and commercial projects.

---

**Contributions and improvements welcome.** The goal is to keep this small, high-signal, and effective across the major coding agents.