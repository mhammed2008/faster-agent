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

# 1. Global Installation to ~/.gemini/config
if [ "$GLOBAL" = true ]; then
  GEMINI_CONFIG_DIR="${HOME}/.gemini/config"
  GLOBAL_RULES_DIR="${GEMINI_CONFIG_DIR}/rules"
  GLOBAL_SKILLS_DIR="${GEMINI_CONFIG_DIR}/skills/faster-agent"

  echo -e "\033[0;32m[+] Installing FasterAgent globally to: ${GEMINI_CONFIG_DIR}\033[0m"

  mkdir -p "${GLOBAL_RULES_DIR}"
  mkdir -p "${GLOBAL_SKILLS_DIR}"

  cp -f "${ROOT_DIR}/rules/faster-agent.md" "${GLOBAL_RULES_DIR}/faster-agent.md"
  echo "  -> Installed rule: ${GLOBAL_RULES_DIR}/faster-agent.md"

  cp -f "${ROOT_DIR}/skills/faster-agent/SKILL.md" "${GLOBAL_SKILLS_DIR}/SKILL.md"
  echo "  -> Installed skill: ${GLOBAL_SKILLS_DIR}/SKILL.md"

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
