#!/usr/bin/env bash
# FasterAgent Installer for Linux / macOS (Bash)
set -euo pipefail

GLOBAL=true
LOCAL=false
TARGET_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)
      GLOBAL=true
      shift
      ;;
    --local)
      LOCAL=true
      shift
      ;;
    --target-dir)
      TARGET_DIR="$2"
      LOCAL=true
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo -e "\033[1;36m==========================================\033[0m"
echo -e "\033[1;33m   ⚡ FasterAgent Installer for Antigravity\033[0m"
echo -e "\033[1;36m==========================================\033[0m"

# 1. Global Installation to ~/.gemini and ~/.gemini/config
if [ "$GLOBAL" = true ]; then
  GEMINI_HOME_DIR="${HOME}/.gemini"
  GEMINI_CONFIG_DIR="${GEMINI_HOME_DIR}/config"
  GLOBAL_RULES_DIR="${GEMINI_CONFIG_DIR}/rules"
  GLOBAL_SKILLS_DIR="${GEMINI_CONFIG_DIR}/skills/faster-agent"
  GLOBAL_GEMINI_MD="${GEMINI_HOME_DIR}/GEMINI.md"

  echo -e "\033[0;32m[+] Installing FasterAgent globally to: ${GEMINI_HOME_DIR}\033[0m"

  mkdir -p "${GLOBAL_RULES_DIR}"
  mkdir -p "${GLOBAL_SKILLS_DIR}"

  cp -f "${ROOT_DIR}/rules/faster-agent.md" "${GLOBAL_RULES_DIR}/faster-agent.md"
  echo "  -> Installed rule: ${GLOBAL_RULES_DIR}/faster-agent.md"

  cp -f "${ROOT_DIR}/skills/faster-agent/SKILL.md" "${GLOBAL_SKILLS_DIR}/SKILL.md"
  echo "  -> Installed skill: ${GLOBAL_SKILLS_DIR}/SKILL.md"

  # Inject FasterAgent directly into ~/.gemini/GEMINI.md
  FASTER_BLOCK=$(cat << 'EOF'
<!-- faster-agent-global -->
# FasterAgent: Velocity-First, Anti-Loop & Surgical Execution Protocol

CRITICAL OPERATIONAL DIRECTIVE FOR ALL SESSIONS:
Your primary mandate is **high-velocity 100% task execution** without getting trapped in exploratory loops, tool hesitation, background polling, or excessive testing.

## ⚡ 1. VELOCITY & TURN-1 EXECUTION (ZERO STUBS)
1. **Immediate Execution**: Begin modifying code or performing requested operations immediately in turn 1. Do NOT emit long conversational explanations or narrative plans before taking action.
2. **100% Functional Completeness**: Complete 100% of the requested technical features, code deliverables, and edge cases. NEVER leave stubs, `// TODO: implement later`, placeholder functions, or truncated logic.
3. **Batched & Parallel Operations**: Bundle independent tool calls and edits into a single turn whenever possible. Modify multiple target files or chunks in one operation to minimize turn latency.
4. **Tool Fallback Shield (Zero Hesitation)**: If specialized or lean tools (e.g. `ctx_*`) are NOT registered in your active tool list, **IMMEDIATELY and without hesitation use native tools** (`view_file`, `replace_file_content`, `run_command`, `grep_search`, `list_dir`). Never deliberate or apologize for tool availability; proceed instantly with available native tools.

## 🛑 2. ANTI-POLLING & ANTI-LOOP CIRCUIT BREAKERS
1. **Zero Background Polling**: NEVER repeatedly poll or loop on `manage_task(Action='status')` or wait in a loop for commands/containers to finish. Antigravity automatically notifies you reactively when background tasks complete. Launch background commands and STOP calling tools to end your turn.
2. **External Infrastructure Circuit Breaker (Max 1 Check/Fix)**: For Docker containers, dev servers, external databases, or services: perform at most ONE (1) restart or diagnostic check. If the service fails or remains restarting after 1 attempt, HALT immediately and present the diagnostic logs to the user. Do NOT retry in loops.
3. **Anti-Exploration Shield**: Only view files directly relevant to the user request. Never recursively scan irrelevant directories or read entire multi-thousand-line files when inspecting a specific function or bug.

## 🧪 3. HYBRID SMOKE & SURGICAL TESTING POLICY
1. **Smoke Check First**: Validate syntax/typechecking on modified files only (`tsc --noEmit`, `py_compile`, `php -l`, `cargo check`).
2. **Surgical Test Only**: Run ONLY the single test file or specific test case directly mapped to the modified code.
3. **Forbidden Full Suites**: NEVER execute repository-wide test suites (`npm test`, `pytest`, `cargo test`, `composer test`) unless the user explicitly requested a full regression run.
4. **Strict Test Circuit Breaker**: Stop immediately once the surgical test passes. If it fails, attempt at most ONE (1) fix. If still failing, HALT testing immediately and present the diagnosis to the user.

## 🎯 4. LEAN CONTEXT & TOKEN CONSERVATION
1. Keep outputs concise and action-oriented: 1-sentence action summary, code changes/diffs, and verification result.
2. Avoid conversational filler or repeating user input.
<!-- /faster-agent-global -->
EOF
)

  if [ -f "${GLOBAL_GEMINI_MD}" ]; then
    if grep -q "<!-- faster-agent-global -->" "${GLOBAL_GEMINI_MD}"; then
      # Strip existing block and re-insert
      sed -i.bak '/<!-- faster-agent-global -->/,/<!-- \/faster-agent-global -->/d' "${GLOBAL_GEMINI_MD}"
      echo -e "${FASTER_BLOCK}\n\n$(cat "${GLOBAL_GEMINI_MD}")" > "${GLOBAL_GEMINI_MD}"
      echo "  -> Updated FasterAgent directives in: ${GLOBAL_GEMINI_MD}"
    else
      echo -e "${FASTER_BLOCK}\n\n$(cat "${GLOBAL_GEMINI_MD}")" > "${GLOBAL_GEMINI_MD}"
      echo "  -> Injected FasterAgent directives into top of: ${GLOBAL_GEMINI_MD}"
    fi
  else
    echo "${FASTER_BLOCK}" > "${GLOBAL_GEMINI_MD}"
    echo "  -> Created new global GEMINI.md with FasterAgent rules: ${GLOBAL_GEMINI_MD}"
  fi

  echo -e "\n\033[0;32m[✔] Global FasterAgent configuration active across all Antigravity sessions!\033[0m"
fi

# 2. Local Installation to specific workspace
if [ "$LOCAL" = true ] || [ -n "$TARGET_DIR" ]; then
  if [ -z "$TARGET_DIR" ]; then
    TARGET_DIR="$(pwd)"
  fi

  echo -e "\n\033[0;32m[+] Installing FasterAgent locally to workspace: ${TARGET_DIR}\033[0m"

  LOCAL_RULES_DIR="${TARGET_DIR}/.agents/rules"
  mkdir -p "${LOCAL_RULES_DIR}"

  cp -f "${ROOT_DIR}/rules/GEMINI.md" "${TARGET_DIR}/GEMINI.md"
  echo "  -> Copied GEMINI.md to workspace root: ${TARGET_DIR}/GEMINI.md"

  cp -f "${ROOT_DIR}/rules/AGENTS.md" "${TARGET_DIR}/AGENTS.md"
  echo "  -> Copied AGENTS.md to workspace root: ${TARGET_DIR}/AGENTS.md"

  cp -f "${ROOT_DIR}/rules/faster-agent.md" "${LOCAL_RULES_DIR}/faster-agent.md"
  echo "  -> Copied rule to ${LOCAL_RULES_DIR}/faster-agent.md"

  echo -e "\n\033[0;32m[✔] Workspace FasterAgent rules applied to: ${TARGET_DIR}\033[0m"
fi

echo -e "\n\033[1;36mFasterAgent is ready! High-velocity execution and surgical testing are now enabled.\033[0m"
