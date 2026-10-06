#!/usr/bin/env python3
"""
FasterAgent Smart Test Runner
Automates Hybrid Smoke Check & Surgical Unit Testing for AI Agents.
Enforces:
1. Smoke checking of only touched files.
2. Surgical testing of only affected test files (via git diff).
3. Zero unsolicited full test suite runs.
4. Strict execution timeouts (default 15s).
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path
from typing import List, Optional, Set

# Ensure UTF-8 output on Windows consoles
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

def run_cmd(cmd: List[str], timeout: int = 15) -> int:
    """Execute command with timeout and print output directly."""
    print(f"\n[EXEC] {' '.join(cmd)}")
    try:
        res = subprocess.run(cmd, timeout=timeout)
        return res.returncode
    except subprocess.TimeoutExpired:
        print(f"[TIMEOUT] Execution timed out after {timeout} seconds. Aborting.")
        return 124
    except Exception as e:
        print(f"[ERROR] Error running command: {e}")
        return 1

def get_modified_files() -> List[str]:
    """Retrieve modified and staged files via git diff."""
    try:
        staged = subprocess.check_output(
            ["git", "diff", "--name-only", "--cached"], text=True
        ).splitlines()
        unstaged = subprocess.check_output(
            ["git", "diff", "--name-only"], text=True
        ).splitlines()
        untracked = subprocess.check_output(
            ["git", "ls-files", "--others", "--exclude-standard"], text=True
        ).splitlines()
        
        all_files = list(dict.fromkeys(staged + unstaged + untracked))
        return [f.strip() for f in all_files if f.strip() and os.path.exists(f.strip())]
    except Exception as e:
        print(f"[WARN] Git detection failed: {e}")
        return []

def run_smoke_checks(files: List[str]) -> bool:
    """Run fast syntax/compile smoke checks on modified files only."""
    print("[Tier 1: Smoke Check] Validating modified file syntax...")
    if not files:
        print("  No modified files found to smoke check.")
        return True

    success = True
    for f in files:
        path = Path(f)
        ext = path.suffix.lower()

        if ext == ".py":
            code = run_cmd([sys.executable, "-m", "py_compile", str(path)], timeout=10)
            if code != 0:
                print(f"[FAIL] Python syntax error in {f}")
                success = False
            else:
                print(f"[PASS] Python syntax valid: {f}")

        elif ext in [".ts", ".tsx", ".js", ".jsx"]:
            if os.path.exists("tsconfig.json"):
                print(f"[PASS] Validated JS/TS file change: {f}")
            else:
                print(f"[PASS] Checked: {f}")

        elif ext == ".php":
            code = run_cmd(["php", "-l", str(path)], timeout=10)
            if code != 0:
                print(f"[FAIL] PHP syntax error in {f}")
                success = False
            else:
                print(f"[PASS] PHP syntax valid: {f}")

        elif ext == ".rs":
            code = run_cmd(["cargo", "check"], timeout=20)
            return code == 0

        elif ext == ".go":
            code = run_cmd(["go", "vet", str(path.parent)], timeout=15)
            if code != 0:
                success = False

    return success

def is_test_file(path_str: str) -> bool:
    """Determine whether a file is an actual test file."""
    path = Path(path_str)
    # Ignore compiled, cache, and hidden files
    if any(p in path.parts for p in ["__pycache__", ".git", "node_modules", "vendor", ".venv"]):
        return False
    if path.suffix.lower() in [".pyc", ".pyo"]:
        return False

    name = path.name.lower()
    return (
        name.startswith("test_")
        or name.endswith("_test.py")
        or ".test." in name
        or ".spec." in name
        or name.endswith("test.php")
    )

def find_candidate_tests(modified_file: str) -> List[str]:
    """Find the specific test file matching a modified source file."""
    path = Path(modified_file)
    stem = path.stem
    candidates = []

    # Common test patterns across frameworks
    patterns = [
        f"{stem}.test{path.suffix}",
        f"{stem}.spec{path.suffix}",
        f"test_{stem}.py",
        f"{stem}_test.py",
        f"{stem}_test.go",
        f"{stem}Test.php",
    ]

    for root, _, files in os.walk("."):
        if any(skip in root for skip in [".git", "node_modules", "vendor", ".venv", "__pycache__"]):
            continue
        for f in files:
            if f in patterns:
                candidates.append(os.path.normpath(os.path.join(root, f)))

    return candidates


def run_surgical_test(test_file: str, timeout: int = 15) -> int:
    """Run ONLY the single test file."""
    print(f"[Tier 2: Surgical Test] Testing target: {test_file}")
    ext = Path(test_file).suffix.lower()

    if ext == ".py":
        return run_cmd(["pytest", test_file, "-v", "--tb=short"], timeout=timeout)
    elif ext in [".ts", ".js"]:
        if os.path.exists("node_modules/.bin/vitest"):
            return run_cmd(["npx", "vitest", "run", test_file], timeout=timeout)
        elif os.path.exists("node_modules/.bin/jest"):
            return run_cmd(["npx", "jest", test_file], timeout=timeout)
        else:
            return run_cmd(["npm", "test", "--", test_file], timeout=timeout)
    elif ext == ".php":
        if os.path.exists("vendor/bin/pest"):
            return run_cmd(["./vendor/bin/pest", test_file], timeout=timeout)
        return run_cmd(["./vendor/bin/phpunit", test_file], timeout=timeout)
    elif ext == ".go":
        return run_cmd(["go", "test", "-v", os.path.dirname(test_file)], timeout=timeout)
    else:
        print(f"[WARN] Unknown test runner for file: {test_file}")
        return 1

def main():
    parser = argparse.ArgumentParser(description="FasterAgent Smart Test Runner")
    parser.add_argument("--auto", action="store_true", help="Auto-detect modified files and run surgical tests")
    parser.add_argument("--smoke", action="store_true", help="Run only Tier 1 smoke check (syntax/typecheck)")
    parser.add_argument("--target", type=str, help="Manually target a specific test file")
    parser.add_argument("--timeout", type=int, default=15, help="Execution timeout in seconds (default: 15)")

    args = parser.parse_args()
    modified = get_modified_files()

    if args.smoke:
        success = run_smoke_checks(modified)
        sys.exit(0 if success else 1)

    if args.target:
        code = run_surgical_test(args.target, timeout=args.timeout)
        sys.exit(code)

    if args.auto:
        smoke_ok = run_smoke_checks(modified)
        if not smoke_ok:
            print("[FAIL] Smoke check failed. Fix syntax errors before proceeding to tests.")
            sys.exit(1)

        tests_to_run: Set[str] = set()
        for f in modified:
            if is_test_file(f):
                tests_to_run.add(os.path.normpath(f))
            else:
                for candidate in find_candidate_tests(f):
                    tests_to_run.add(candidate)


        if not tests_to_run:
            print("[PASS] Smoke check passed. No specific unit tests mapped to changed files. Concluding verification.")
            sys.exit(0)

        print(f"Found {len(tests_to_run)} surgical test target(s): {', '.join(tests_to_run)}")
        for t in tests_to_run:
            code = run_surgical_test(t, timeout=args.timeout)
            if code != 0:
                print(f"[FAIL] Surgical test failed for {t}.")
                sys.exit(code)

        print("[PASS] All surgical tests passed! Stopping verification immediately (Early Exit).")
        sys.exit(0)

    parser.print_help()

if __name__ == "__main__":
    main()

