# FasterAgent Profile: Node.js & TypeScript

Include these directives in your project's `GEMINI.md` or `.agents/rules/faster-agent.md` for Node/TypeScript projects.

## Verification Rules
1. **Smoke Check**:
   ```bash
   npx tsc --noEmit
   ```
2. **Surgical Test (Targeted file only)**:
   ```bash
   # Vitest
   npx vitest run path/to/changed.test.ts

   # Jest
   npx jest path/to/changed.spec.ts
   ```
3. **Guardrail**: NEVER execute `npm test` or `pnpm test` without path arguments.
