# Task breakdown and quick wins

This file clarifies the remaining work in the repository and turns vague todos into small, actionable tasks you can pick from.

How to use this file
- Each item is intentionally small and low-risk. Prefer working on a single item per commit and run `bash test/run_all.sh` after changes.
- If a task requires network access (DNS/HTTP checks) we keep it as a smoke test and mark it network-dependent.

Quick wins (small, safe tasks you can do now)

1) ShellCheck cleanup (low-risk)
   - Files to check: `domain_lookup_lib.sh`, `domain_lookup_min.sh`, `domain_lookup_interactive.sh`, `domain_lookup.sh`, `sentry.sh`, `test/*.sh`
   - Acceptance: run `shellcheck` and fix warnings about quoting and expansions. Keep changes minimal and run tests.
   - Difficulty: easy. Estimated 30-90 minutes depending on warning count.

2) Windows `open_url()` & clipboard hardening
   - Update `open_url()` in `domain_lookup_lib.sh` to prefer `Start-Process` on PowerShell when available, and keep `explorer.exe` fallback.
   - Improve clipboard copy in interactive export to better support PowerShell quoting.
   - Acceptance: no regressions in tests; manual verification on Windows recommended.
   - Difficulty: small.

3) Add a developer guide (CONTRIBUTING.md)
   - Describe how to run tests, add a smoke test, and the canonical scripts to use for automation.
   - Acceptance: new file with run instructions.
   - Difficulty: trivial.

4) Add focused unit tests for MX/TXT parsing
   - Create small test scripts that stub `has_cmd` or underlying commands and validate output shapes.
   - Acceptance: tests pass in CI without network.
   - Difficulty: small.

5) Changelog & release prep (done)
   - We added `CHANGELOG.md` with the stabilization entry for 2025-11-03.

What I marked complete for now
- Kept `domain_lookup.sh` as a shim (compatibility wrapper) to `domain_lookup_min.sh`.
- Added unit/smoke tests and basic ShellCheck-friendly fixes.
- Added `CHANGELOG.md` and small README updates.

Next recommended step
- Run CI (open a PR) so the strict ShellCheck job runs and provides the exact list of warnings; then iterate to fix the top low-risk ones.

If you want, I can pick one quick win and implement it now — say, (1) ShellCheck cleanup or (2) Windows open_url() hardening. Which should I do next?
