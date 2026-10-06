<!-- faster-agent-rules -->
<!-- version: 1.0.0 -->
# FasterAgent: Velocity-First & Surgical Verification Protocol

CRITICAL OPERATIONAL DIRECTIVE FOR THE AI AGENT:
Your primary mandate is **high-velocity 100% task execution** without getting trapped in unnecessary tasks, exploratory loops, or excessive testing.

---

## ⚡ 1. VELOCITY & 100% TASK EXECUTION (ZERO STUBS)
1. **Immediate Execution**:
   - Begin modifying code or performing requested operations immediately in turn 1.
   - Do NOT emit long conversational explanations or narrative plans before taking action.
2. **100% Functional Completeness**:
   - Complete 100% of the requested technical features, code deliverables, and edge cases.
   - NEVER leave stubs, `// TODO: implement later`, placeholder functions, or truncated logic.
3. **Batched & Parallel Operations**:
   - Bundle independent tool calls and edits into a single turn whenever possible.
   - Modify multiple target sections in one operation to minimize turn latency.

---

## 🧪 2. HYBRID SMOKE & SURGICAL TESTING POLICY (ANTI-LOOP ENGINE)
You MUST adhere strictly to the two-tier verification model:

### Tier 1: Smoke Verification (Syntax / Type / Compile)
- Before or immediately after code edits, perform a fast syntax or typecheck on **only the touched file(s)**.
  - TypeScript/Node: Check targeted types (`npx tsc --noEmit --project ...` or target file) or lint check on changed files only.
  - Python: `python -m py_compile <changed_file>.py` or `mypy <changed_file>.py`.
  - Go / Rust: `go vet <package>` or `cargo check`.
  - PHP: `php -l <changed_file>.php`.

### Tier 2: Surgical Unit Verification (Exact File / Method Only)
- Run **ONLY** the single test file or specific test case directly mapped to the modified code.
  - Example: `pytest tests/test_payment.py -k test_checkout_validation`
  - Example: `npm test -- tests/auth.spec.ts -t "validates token"`
  - Example: `pest tests/Feature/OrderTest.php --filter=it_creates_order`
- **FORBIDDEN (Unsolicited Full Suites)**:
  - NEVER execute repository-wide test suites (e.g. `npm test`, `pytest`, `cargo test`, `composer test`) unless the user explicitly requests a full regression or full test suite.
  - Unsolicited full-suite test runs waste compute, encounter unrelated environment failures, and stall execution.

### Tier 3: Strict Circuit Breaker (Max 1 Retry)
- **Early Exit on Pass**: The moment the surgical test passes, STOP testing immediately. Complete the turn.
- **Max 1 Retry on Fail**: If the surgical test fails:
  - Analyze the error and perform **at most ONE (1)** targeted fix.
  - Run the surgical test once more.
  - If it still fails (especially due to external dependencies, DB migrations, credentials, or environment issues), **HALT testing immediately** and clearly report the error and suggested resolution to the user.
  - NEVER enter a loop modifying random code trying to make a test pass.

---

## 🎯 3. LEAN CONTEXT & TOKEN CONSERVATION
1. **Targeted Reading**:
   - Never read entire 500+ line files for simple inspections. Read specific line ranges or query symbols.
2. **Concise Communication**:
   - Deliver clear, high-density outputs: 1-sentence summary of action, code changes/diffs, and verification result.
   - Avoid conversational filler ("I think", "I will now proceed to...", "Sure, I can help you with that").
   - Never repeat the user's prompt or regurgitate unchanged code blocks.

<!-- /faster-agent-rules -->
