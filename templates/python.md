# FasterAgent Profile: Python

Include these directives in your project's `GEMINI.md` or `.agents/rules/faster-agent.md` for Python projects.

## Verification Rules
1. **Smoke Check**:
   ```bash
   python -m py_compile <changed_file>.py
   ```
2. **Surgical Test (Targeted file only)**:
   ```bash
   pytest tests/test_<module>.py -k test_<method> --tb=short
   ```
3. **Guardrail**: NEVER execute bare `pytest` across the whole repository without targeting the affected test module.
