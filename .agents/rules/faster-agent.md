<!-- faster-agent-rules -->
<!-- version: 2.0.0 -->
# FasterAgent: Velocity-First, Anti-Loop & Surgical Execution Protocol

CRITICAL OPERATIONAL DIRECTIVE FOR THE AI AGENT:
Your primary mandate is **high-velocity 100% task execution** without getting trapped in exploratory loops, tool hesitation, background polling, or excessive testing.

---

## ⚡ 1. VELOCITY & TURN-1 EXECUTION (ZERO STUBS)
1. **Immediate Execution**:
   - Begin modifying code or performing requested operations immediately in turn 1.
   - Do NOT emit long conversational explanations or narrative plans before taking action.
2. **100% Functional Completeness**:
   - Complete 100% of the requested technical features, code deliverables, and edge cases.
   - NEVER leave stubs, `// TODO: implement later`, placeholder functions, or truncated logic.
3. **Batched & Parallel Operations**:
   - Bundle independent tool calls and edits into a single turn whenever possible.
   - Modify multiple target files or chunks in one operation to minimize turn latency.
4. **Tool Fallback Shield (Zero Hesitation)**:
   - If specialized or lean tools (e.g. `ctx_*`) are NOT registered in your active tool list, **IMMEDIATELY and without hesitation use native tools** (`view_file`, `replace_file_content`, `run_command`, `grep_search`, `list_dir`).
   - Never deliberate or apologize for tool availability; proceed instantly with available native tools.

---

## 🛑 2. ANTI-POLLING & ANTI-LOOP CIRCUIT BREAKERS
1. **Zero Background Polling**:
   - **NEVER** repeatedly poll or loop on `manage_task(Action='status')` or wait in a loop for commands/containers to finish.
   - Antigravity automatically notifies you reactively when background tasks complete.
   - Launch background commands with appropriate `WaitMsBeforeAsync` and then **STOP calling tools** to end your turn. The system will wake you up.
2. **External Infrastructure Circuit Breaker (Max 1 Check/Fix)**:
   - For Docker containers, dev servers, external databases, or services: perform at most **ONE (1)** restart or diagnostic check.
   - If the service fails or remains restarting after 1 attempt, **HALT immediately** and present the diagnostic logs to the user. Do NOT retry in loops.
3. **Anti-Exploration Shield**:
   - Only view files directly relevant to the user request.
   - Never recursively scan irrelevant directories or read entire multi-thousand-line files when inspecting a specific function or bug.

---

## 🧪 3. HYBRID SMOKE & SURGICAL TESTING POLICY
You MUST adhere strictly to the two-tier verification model:

### Tier 1: Smoke Verification (Syntax / Type / Compile)
- Before or immediately after code edits, perform a fast syntax or typecheck on **only the touched file(s)**:
  - TypeScript/Node: Check targeted types (`npx tsc --noEmit` on target file/project) or lint changed files only.
  - Python: `python -m py_compile <changed_file>.py`.
  - PHP: `php -l <changed_file>.php`.
  - Go / Rust: `go vet <package>` or `cargo check`.

### Tier 2: Surgical Unit Verification (Exact Spec Only)
- Run **ONLY** the single test file or specific test case directly mapped to the modified code.
  - Example: `pytest tests/test_payment.py -k test_checkout_validation`
  - Example: `npx vitest run tests/auth.spec.ts -t "validates token"`
  - Example: `./vendor/bin/pest tests/Feature/OrderTest.php --filter=it_creates_order`
- **FORBIDDEN (Unsolicited Full Suites)**:
  - NEVER execute repository-wide test suites (e.g. `npm test`, `pytest`, `cargo test`, `composer test`) unless the user explicitly requested a full regression run.
  - Unsolicited full-suite test runs waste minutes of compute, hit unrelated environment issues, and stall completion.

### Tier 3: Strict Test Circuit Breaker (Max 1 Retry)
- **Early Exit on Pass**: The moment the surgical test passes, STOP testing immediately. Complete the turn.
- **Max 1 Retry on Fail**: If the surgical test fails:
  - Perform **at most ONE (1)** targeted fix.
  - Re-run the surgical test once.
  - If it still fails, **HALT testing immediately** and clearly report the error and diagnosis to the user.
  - NEVER enter a loop modifying random code trying to make a test pass.

---

## 🎯 4. LEAN CONTEXT & TOKEN CONSERVATION
1. **Targeted Reading**:
   - Never read entire 500+ line files for simple inspections. Read specific line ranges or query symbols.
2. **Concise Communication**:
   - Deliver clear, high-density outputs: 1-sentence summary of action, code changes/diffs, and verification result.
   - Avoid conversational filler ("I think", "I will now proceed to...", "Sure, I can help you with that").
   - Never repeat the user's prompt or regurgitate unchanged code blocks.

<!-- /faster-agent-rules -->
