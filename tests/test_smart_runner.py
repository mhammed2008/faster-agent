"""
Tests for FasterAgent smart test runner
"""
import unittest
import sys
import os

# Add scripts directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "scripts")))

from smart_test_runner import find_candidate_tests, run_smoke_checks

class TestSmartTestRunner(unittest.TestCase):
    def test_find_candidate_tests_pattern(self):
        """Verify candidate test pattern matching."""
        # Test file itself should be matched or recognized
        res = find_candidate_tests("scripts/smart_test_runner.py")
        self.assertIsInstance(res, list)

    def test_smoke_checks_valid_python(self):
        """Smoke checks should succeed on valid Python files."""
        script_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "scripts", "smart_test_runner.py"))
        success = run_smoke_checks([script_path])
        self.assertTrue(success)

if __name__ == "__main__":
    unittest.main()
