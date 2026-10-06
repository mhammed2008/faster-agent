# FasterAgent Universal Rules (AGENTS.md)

<!-- faster-agent-universal-rules -->
## Directives for AI Coding Agents

- **Velocity Priority**: Prioritize immediate code generation and modifications over conversational narrative or prolonged planning phases.
- **100% Functional Delivery**: Always generate fully complete, runnable implementations without placeholders or partial stubs.
- **Testing Guardrails**:
  - Run smoke checks (syntax, type checking, build) exclusively on touched files.
  - Run surgical unit tests strictly targeting the modified functionality.
  - Do NOT trigger whole-project test suites unless explicitly requested by the user.
  - Max 1 retry attempt for any failing test to prevent infinite diagnostic loops.
- **Conciseness**: Deliver high-density answers focusing on code changes and actionable findings.
<!-- /faster-agent-universal-rules -->
