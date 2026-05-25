# AGENTS.md

This file contains instructions and behavioral guidelines for all coding agents working in this project (Grok Build, Claude Code, Cursor, GitHub Copilot, etc.).

---

## Project-Specific Rules

> **Replace or extend this section** with your own project's conventions, tech stack rules, testing requirements, architecture decisions, etc.

Examples of what belongs here:
- Preferred libraries and forbidden patterns
- Testing strategy and coverage expectations
- Code style and formatting rules
- Architecture decisions (e.g., "prefer server components", "all data mutations go through server actions")
- Review checklist items

Add your rules below this line:

---

<!-- This is an EXAMPLE of how to include the Karpathy guidelines in a larger AGENTS.md file -->

## Karpathy Behavioral Guidelines

<!-- BEGIN karpathy-guidelines -->
<!-- Source: https://github.com/pexus/ca-karpathy-guidelines -->

These rules dramatically improve the quality of code produced by LLMs (Claude Code, Cursor, GitHub Copilot, Grok Build, and similar agents). They are inspired by principles popularized by Andrej Karpathy.

**Core philosophy:** Bias toward minimal, correct, surgical changes rather than clever or speculative solutions.

### 1. Think Before Coding

**Don't assume. Surface confusion and tradeoffs early.**

Before writing or editing code:
- Explicitly state your assumptions when the request is ambiguous.
- If a request has multiple valid interpretations, present the options — do not silently choose one.
- If you see a significantly simpler approach, say so and explain the tradeoffs.
- When something is unclear or risky, stop and ask rather than guessing.

### 2. Simplicity First

**Minimum code that solves the actual problem. No speculative work.**

- Implement *exactly* what was requested — nothing more.
- Do not introduce new abstractions, configuration systems, or "future-proofing" unless explicitly asked.
- Do not add defensive error handling or logging for scenarios that cannot realistically occur.
- If the solution can be expressed in far fewer lines while remaining correct, do that.
- Rule of thumb: If a senior engineer would call the diff over-engineered for the goal, simplify it.

### 3. Surgical Changes

**Touch only what is necessary. Clean up only the mess you created.**

When modifying existing code:
- Change **only** the lines required to fulfill the request.
- Do not reformat, refactor, rename, or "clean up" unrelated code in the same change.
- Do not delete pre-existing dead code, unused imports, or outdated comments as a side effect.
- Only remove code that *your change* made dead.
- Match the surrounding style and conventions exactly.

### 4. Goal-Driven Execution

**Define verifiable success criteria before starting. Loop until they pass.**

For any non-trivial task:
- Convert the request into concrete, testable success criteria.
- Examples:
  - "Add input validation" → "Write tests covering invalid and edge cases, then make them pass."
  - "Fix the bug" → "Add a failing test that reproduces it, then make the test pass."
  - Refactors → "All existing tests continue to pass; new behavior is verified."
- For multi-step work, outline a short plan with verification checkpoints.
- Never claim a task is complete until you have actually verified it (run tests, execute the script, inspect output).

**These guidelines are working well when:**
- Diffs stay small and focused
- Clarifying questions appear *before* code is written
- Over-engineering and scope creep become rare
- Completed work rarely needs follow-up fixes for unrelated changes

<!-- END karpathy-guidelines -->

---

## Agent-Specific Notes

### Grok Build
Grok Build natively discovers `AGENTS.md` (and `Claude.md` / `AGENT.md` variants) from the project root.

### Claude Code
Claude Code automatically loads `CLAUDE.md` at the start of every session. You can keep a thin `CLAUDE.md` that points here, or use a symlink.

### Cursor
Cursor reads this `AGENTS.md` file. For even stronger enforcement you can also maintain `.cursor/rules/` files.

### GitHub Copilot
Copilot reads `.github/copilot-instructions.md`. Many teams keep a thin reference file there that points to this `AGENTS.md`.

---

*This example file shows one recommended way to compose the Karpathy behavioral guidelines with your own project rules. See the README for more composition strategies.*