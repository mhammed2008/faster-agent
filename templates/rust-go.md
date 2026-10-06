# FasterAgent Profile: Rust & Go

Include these directives in your project's `GEMINI.md` or `.agents/rules/faster-agent.md` for Rust and Go projects.

## Verification Rules: Rust
1. **Smoke Check**:
   ```bash
   cargo check
   ```
2. **Surgical Test**:
   ```bash
   cargo test <test_function_name>
   ```

## Verification Rules: Go
1. **Smoke Check**:
   ```bash
   go vet ./path/to/pkg
   ```
2. **Surgical Test**:
   ```bash
   go test -v -run TestTargetFunction ./path/to/pkg
   ```
