# FasterAgent ⚡
> High-Velocity, 100% Task Execution & Surgical Testing Engine for Google Antigravity and AI Coding Agents.

---

## 🚀 Overview

AI coding agents often fall into common productivity traps:
- **Test Loops & Procrastination**: Running full regression test suites repeatedly, analyzing unrelated failures, and looping indefinitely on edge cases.
- **Over-Exploration & Inertia**: Spending countless turns reading unrelated files, explaining what they "plan to do" instead of writing code.
- **Incomplete Implementations**: Leaving placeholders, stubs, and `// TODO` comments instead of finishing 100% of the requested task.

**FasterAgent** eliminates agent friction by enforcing a strict **Velocity-First Protocol** paired with a **Hybrid Smoke & Surgical Testing Policy**. It forces models to execute complete, production-grade code immediately, verify changes with minimal overhead, and conclude without unnecessary delays.

---

## ⚡ Core Principles

### 1. 100% Task Delivery (Zero Stubs & Turn-1 Action)
- **Direct Action**: Moves straight from intent extraction to code modification without preliminary narration.
- **Exhaustive Implementation**: Output 100% complete, functional code. No stubs, no omitted logic, and no placeholder comments.
- **Batched Operations**: Perform multi-file and multi-chunk modifications in single turns.
- **Tool Fallback Shield**: If specialized/lean tools (`ctx_*`) are absent from the agent profile, immediately use native Antigravity tools (`view_file`, `replace_file_content`, `run_command`, `grep_search`, `list_dir`) with zero hesitation.

### 2. Anti-Polling & Infrastructure Circuit Breakers
- **Zero Background Polling**: Prohibits looping on `manage_task(Action='status')` or checking background commands/containers repeatedly. Leverages Antigravity's reactive wake-up notifications.
- **External Service Circuit Breaker**: Allows at most ONE (1) diagnostic or restart attempt on Docker, databases, or dev servers. If failing, halts and reports diagnosis immediately.
- **Anti-Exploration Shield**: Limits exploration strictly to target files directly mapped to the user's intent.

### 3. Hybrid Smoke & Surgical Testing (Lean Verification)
- **Smoke Check First**: Validate syntax, types, and compilation for the modified files only (`tsc --noEmit`, `py_compile`, `php -l`, `cargo check`).
- **Surgical Test Only**: Run exclusively the single test file or targeted test case mapped to the modified code.
- **No Full-Suite Runs**: Prohibits executing repository-wide test suites (`npm test`, `pytest`, `cargo test`) unless the user explicitly commands it.
- **Single-Pass & Circuit Breaker**: If the surgical test passes, stop immediately. If it fails, allow at most **one (1)** targeted fix attempt; if still failing due to environment or external dependencies, report directly to the user instead of looping.

### 4. Lean Context & Token Economy
- **Targeted Slicing**: Inspect exact symbol signatures and line ranges rather than ingesting entire files.
- **Concise Reporting**: Omit conversational filler, status monologues, and repetition. Present concise actions, diffs, and results.

---

## 📂 Project Structure

```text
faster-agent/
├── rules/
│   ├── faster-agent.md        # Global drop-in rule for ~/.gemini/config/rules/
│   ├── GEMINI.md              # Project-level rule for Antigravity workspaces
│   └── AGENTS.md              # Universal cross-agent standard rule
├── skills/
│   └── faster-agent/
│       └── SKILL.md           # Antigravity skill definition & workflows
├── scripts/
│   ├── install.ps1            # Windows PowerShell one-click installer
│   ├── install.sh             # Linux/macOS Bash one-click installer
│   └── smart_test_runner.py   # CLI tool to detect & run only affected tests
└── templates/
    ├── node-typescript.md     # Stack profile: Node.js / TypeScript / Vite
    ├── python.md              # Stack profile: Python / Pytest / FastAPI
    ├── php-laravel.md         # Stack profile: PHP / Laravel / Pest
    └── rust-go.md             # Stack profile: Rust / Go
```

---

## 🛠️ Quick Installation

### Option A: Install Globally (Applies to all Antigravity projects)

**Windows (PowerShell):**
```powershell
.\scripts\install.ps1 -Global
```

**Linux / macOS (Bash):**
```bash
./scripts/install.sh --global
```

This installs the rule directly into `~/.gemini/config/rules/faster-agent.md`, registers the `faster-agent` skill in `~/.gemini/config/skills/faster-agent/`, **injects the global FasterAgent directive directly into `~/.gemini/GEMINI.md`** (ensuring 100% active coverage across every project in Antigravity), and neutralizes any blocking tool denial hooks in `settings.json`.

---

### Option B: Install Locally in Current Project

**Windows (PowerShell):**
```powershell
.\scripts\install.ps1 -Local -TargetDir "D:\MyProject"
```

**Linux / macOS (Bash):**
```bash
./scripts/install.sh --local --target-dir "/path/to/project"
```

This installs `GEMINI.md` and `AGENTS.md` into the target workspace root.

---

## ⚙️ Configuration Matrix

| Policy | FasterAgent Default | Standard Agent Behavior |
| :--- | :--- | :--- |
| **Initial Action** | Direct tool call & code edits | Long explanation of plan before editing |
| **Code Completeness** | 100% full implementation | Often leaves `// TODO` or partial code |
| **Testing Scope** | Surgical (single test file) + Smoke Check | Runs whole test suite (`npm test`, `pytest`) |
| **Test Retry Limit** | Max 1 retry attempt (Circuit Breaker) | Loops indefinitely until token limit |
| **Full Suite Execution** | Blocked unless explicitly requested | Run by default after every minor edit |
| **Output Style** | Concise status, diffs, and verification | Multi-paragraph reasoning and conversational filler |

---

## 🧪 Smart Test Runner Utility

FasterAgent includes a standalone Python utility (`scripts/smart_test_runner.py`) that uses `git diff` to automatically identify only the test files affected by staged or unstaged changes, and runs them with strict execution timeouts:

```bash
# Automatically finds affected tests from git diff and runs them
python scripts/smart_test_runner.py --auto

# Run smoke check only (typecheck / syntax / compile)
python scripts/smart_test_runner.py --smoke

# Run surgical test for a specific file with 10s timeout
python scripts/smart_test_runner.py --target tests/feature_test.py --timeout 10
```

---

## 📄 License

MIT © mohammed abdullah.
