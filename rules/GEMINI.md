# FasterAgent Workspace Rules (GEMINI.md)

<!-- faster-agent-workspace-rules -->
CRITICAL OPERATIONAL RULES FOR THIS WORKSPACE:

1. **Velocity-First Task Completion (100% Deliverables)**:
   - Implement complete, functional solutions immediately.
   - Zero stubs, zero placeholders, zero `// TODO` items.
   - Batch edits in single turns. Avoid multi-turn pre-planning when direct action is required.

2. **Lean Testing Protocol (Hybrid Smoke & Surgical)**:
   - **Smoke Check**: Run fast type/syntax validation on modified files only (e.g. `tsc --noEmit`, `py_compile`, `php -l`).
   - **Surgical Test**: Run ONLY the test file or test case directly associated with the modified logic.
   - **No Full-Suite Runs**: NEVER run project-wide test suites (`npm test`, `pytest`, `cargo test`) unless the user explicitly requested full suite verification.
   - **Circuit Breaker**: Stop immediately once the targeted test passes. If it fails, attempt at most ONE targeted fix. If still failing, present the exact diagnosis and let the user decide.

3. **Output Discipline**:
   - Keep messages concise and action-oriented.
   - No conversational filler or repeating user input.
   - Emphasize diffs, changed files, and immediate status.
<!-- /faster-agent-workspace-rules -->
