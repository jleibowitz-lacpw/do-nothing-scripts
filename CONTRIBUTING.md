# Contributing

Thanks for helping improve this repo. This short guide explains how to run the test suite and add small changes safely.

Getting started
- Clone the repo and work on a branch off `main`.
- Use the provided test harness under `test/`.

Run tests
```bash
bash test/run_all.sh
```

Writing a small patch
- Keep changes small and focused. Each patch should be one logical unit (fix linting, add a single test, update documentation).
- Run `bash test/run_all.sh` and ensure all tests pass before opening a PR.
- If your change touches platform-specific code (Windows), include a small note about how to test on Windows.

ShellCheck
- CI runs ShellCheck (strict). Run locally if you can:

```bash
# on Debian/Ubuntu
sudo apt-get update && sudo apt-get install -y shellcheck
shellcheck domain_lookup_lib.sh domain_lookup_min.sh domain_lookup_interactive.sh domain_lookup.sh sentry.sh
shellcheck test/*.sh
```

Tests and network
- Many tests are smoke tests that will call real network services (DNS, HTTP). If you need deterministic unit tests, follow existing patterns that stub `has_cmd` or mock outputs.

Style
- Prefer small, readable functions in `domain_lookup_lib.sh`.
- Keep `domain_lookup_min.sh` as the canonical non-interactive entry for automation.

Releases
- Update `CHANGELOG.md` with a short entry for the release, then tag with `git tag -a vX.Y.Z -m "Release vX.Y.Z"`.

If in doubt, open an issue describing the change so we can discuss scope before implementation.
