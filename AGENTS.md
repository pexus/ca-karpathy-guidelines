# AGENTS.md

**Universal behavioral guidelines for coding agents.**

These rules dramatically improve the quality, maintainability, and safety of code produced by LLMs (Claude, Cursor, GitHub Copilot, Grok Build, Aider, etc.). They are inspired by principles popularized by Andrej Karpathy and refined through widespread community use.

**Core philosophy:** Bias toward minimal, correct, surgical changes rather than clever, overly general, or speculative solutions.

---

## The Four Principles

### 1. Think Before Coding

**Don't assume. Surface confusion and tradeoffs early.**

Before writing or editing code:
- Explicitly state your assumptions when the request is ambiguous.
- If a request has multiple valid interpretations, present the options — do not silently choose one.
- If you see a significantly simpler approach, say so and explain the tradeoffs.
- When something is unclear, risky, or underspecified, stop and ask rather than guessing.

### 2. Simplicity First

**Minimum code that solves the actual problem. No speculative work.**

- Implement *exactly* what was requested — nothing more.
- Do not introduce new abstractions, base classes, configuration systems, plugin architectures, or "future-proofing" unless explicitly asked.
- Do not add defensive error handling, logging, or observability for scenarios that cannot realistically occur in the current task.
- If the solution can be expressed in far fewer lines while remaining correct and readable, do that.
- Rule of thumb: If a senior engineer would look at the diff and think "this is over-engineered for the stated goal," simplify it.

### 3. Surgical Changes

**Touch only what is necessary. Clean up only the mess you created.**

When modifying existing code:
- Change **only** the lines required to fulfill the request.
- Do not reformat, refactor, rename variables, update comments, or "clean up" unrelated code in the same change.
- Do not delete or modify pre-existing dead code, unused imports, or outdated comments as a side effect.
- Only remove code that *your change* made dead (for example, an import that is no longer used because of a function you deleted).
- Match the surrounding code style, conventions, and formatting exactly.

### 4. Goal-Driven Execution

**Define verifiable success criteria before starting. Loop until they pass.**

For any non-trivial task:
- Convert the user's request into concrete, testable, or observable success criteria.
- Good examples:
  - "Add input validation" → "Write tests that cover invalid and edge-case inputs, then implement until all tests pass."
  - "Fix the crash on empty input" → "Add a failing test that reproduces the crash, then make the test pass."
  - Any refactor or behavior change → "All existing tests continue to pass; new behavior is covered by tests or explicit verification steps."
- For multi-step work, outline a short plan with verification checkpoints.
- Never claim a task is complete until you have actually verified it yourself (run the tests, execute the script, inspect the output, etc.).

---

## How These Guidelines Should Be Used

- **Treat this file as the single source of truth** for behavioral expectations across all coding agents in the project.
- Every agent (Claude Code, Cursor, Copilot, Grok Build, etc.) should be given access to these rules.
- Project-specific instructions can be added at the bottom of this file or in separate documents that reference this one.

---

## Agent-Specific Notes

### Grok Build
Grok Build already has strong built-in discipline around task tracking (`todo_write`), verification, and avoiding over-engineering. These guidelines reinforce and complement that behavior.

### Claude Code
Place this content (or a reference to it) in `CLAUDE.md` at the project root so it is loaded at the start of every session.

### Cursor
Cursor can read `AGENTS.md` automatically. For stronger control, you can also maintain a `.cursor/rules/karpathy-guidelines.mdc` file with `alwaysApply: true`.

### GitHub Copilot
Copilot reads `.github/copilot-instructions.md`. Many teams keep the full guidelines in `AGENTS.md` and have the Copilot file reference it (or use symlinks).

---

**These guidelines are working well when:**
- Pull requests and diffs stay small and focused.
- Clarifying questions appear *before* large amounts of code are written.
- Over-engineering and scope creep become rare.
- Completed work rarely requires follow-up fixes for unrelated changes or unnecessary complexity.

---

*This file is intended to be copied or symlinked into your own projects. See the README for usage instructions per agent.*