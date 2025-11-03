# Changelog

All notable changes to this repository are documented in this file.

## [Unreleased]

## 2025-11-03 - Stabilization

- Introduced `domain_lookup_min.sh` as the canonical non-interactive diagnostics tool.
- Added `domain_lookup_lib.sh` with shared helpers for DNS, HTTP and WHOIS checks.
- Implemented `domain_lookup_interactive.sh` as a gum-enabled interactive bridge (gum optional).
- Added Markdown (`--output-md`) and JSON (`--output-json`) export options and tests.
- Added unit and smoke tests under `test/` and a GitHub Actions workflow to run ShellCheck and tests.
- Kept `domain_lookup.sh` as a compatibility shim that delegates to `domain_lookup_min.sh`.

Small, low-risk improvements were made to quoting and test coverage. Future items: ShellCheck cleanup iteration, Windows open_url hardening, more MX/TXT parsing tests.
