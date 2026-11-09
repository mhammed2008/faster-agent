# FasterAgent Workspace Rules (GEMINI.md)

<!-- faster-agent-workspace-rules -->
CRITICAL OPERATIONAL RULES FOR THIS WORKSPACE:

1. **Velocity-First Task Completion (100% Functional Deliverables)**:
   - Implement complete, functional solutions immediately in turn 1.
   - Zero stubs, zero placeholders, zero `// TODO` items.
   - Batch edits across files in single turns. Avoid multi-turn pre-planning when direct action is required.
   - If specialized/lean tools (`ctx_*`) are missing from your profile, use native Antigravity tools (`view_file`, `replace_file_content`, `run_command`, `grep_search`, `list_dir`) immediately with zero hesitation.

2. **Anti-Polling & Infrastructure Circuit Breakers**:
   - **Zero Background Polling**: Never poll `manage_task(Action='status')` or loop waiting for commands/containers. Antigravity notifies you reactively; launch and stop calling tools.
   - **Service Circuit Breaker**: Max 1 diagnostic/restart attempt for Docker, databases, or dev servers. If failing after 1 check, stop and report diagnosis to the user.

3. **Lean Testing Protocol (Hybrid Smoke & Surgical)**:
   - **Smoke Check**: Run fast type/syntax validation on modified files only (`tsc --noEmit`, `py_compile`, `php -l`).
   - **Surgical Test**: Run ONLY the test file or test case directly associated with the modified logic.
   - **No Full-Suite Runs**: NEVER run project-wide test suites (`npm test`, `pytest`, `cargo test`) unless the user explicitly requested full suite verification.
   - **Circuit Breaker**: Stop immediately once the targeted test passes. If it fails, attempt at most ONE targeted fix. If still failing, present the exact diagnosis and let the user decide.

4. **Output Discipline**:
   - Keep messages concise and action-oriented.
   - No conversational filler or repeating user input.
   - Emphasize diffs, changed files, and immediate status.
<!-- /faster-agent-workspace-rules -->
