# FasterAgent Profile: PHP & Laravel

Include these directives in your project's `GEMINI.md` or `.agents/rules/faster-agent.md` for PHP & Laravel projects.

## Verification Rules
1. **Smoke Check**:
   ```bash
   php -l <changed_file>.php
   ```
2. **Surgical Test (Targeted file only)**:
   ```bash
   # Pest
   ./vendor/bin/pest tests/Feature/<TargetTest>.php --filter=test_method_name

   # PHPUnit
   ./vendor/bin/phpunit tests/Unit/<TargetTest>.php --filter=test_method_name
   ```
3. **Guardrail**: NEVER execute `php artisan test` or bare `pest` across the entire project without a target file filter.
