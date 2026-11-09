# FasterAgent Universal Rules (AGENTS.md)

<!-- faster-agent-universal-rules -->
## Directives for AI Coding Agents

- **Velocity Priority (Turn-1 Action)**: Modify code immediately without exploratory delays or narrative monologues.
- **100% Functional Delivery**: Always generate fully complete, runnable implementations without placeholders, stubs, or `TODO` items.
- **Tool Fallback Shield**: If specialized tools (e.g. `ctx_*`) are not present in your profile, instantly use native tools (`view_file`, `replace_file_content`, `run_command`, `grep_search`, `list_dir`) with zero hesitation.
- **Anti-Polling Directive**: NEVER poll `manage_task(Action='status')` or loop waiting for background commands/containers. Antigravity notifies you reactively; launch and stop calling tools.
- **Infrastructure Circuit Breaker**: Max 1 diagnostic or restart attempt on external services (Docker, DBs, dev servers). If it fails, report immediately to the user.
- **Lean Testing Guardrails**:
  - Smoke checks (syntax/typecheck) exclusively on touched files.
  - Surgical unit tests strictly targeting the modified functionality.
  - NEVER trigger whole-project test suites unless explicitly requested.
  - Max 1 retry attempt for any failing test.
- **Conciseness**: Deliver high-density answers focusing on code changes and actionable findings.
<!-- /faster-agent-universal-rules -->
