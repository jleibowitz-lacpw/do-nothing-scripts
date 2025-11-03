# Domain Diagnostics Agent

## domain_lookup.sh

Automated Bash script for domain diagnostics and network troubleshooting. Features:

- Smart apex/www domain detection and testing
- DNS layer analysis (A, AAAA, CNAME, NS, SOA, MX, TXT records)
- Network connectivity testing (ping, traceroute)
- HTTP/HTTPS analysis with SSL certificate inspection
- Tool availability detection with graceful fallbacks
- Interactive TUI using gum for user input
- Non-interactive summary table output

### Usage

Run the script and follow the interactive prompts:

```bash
./domain_lookup.sh
```

Note: `domain_lookup.sh` is currently a compatibility shim that delegates non-interactive runs to `domain_lookup_min.sh`. `domain_lookup_min.sh` is the canonical, scripted entrypoint for automation and CI; see `CHANGELOG.md` for recent changes.

Select domain variants and diagnostic level. Results are shown in a summary table at the end.

See [AGENTS.md](./AGENTS.md) for more details about agents and philosophy.
# Minimal, non-interactive helper

If you prefer a small non-interactive tool (no gum), use `domain_lookup_min.sh`:

```bash
./domain_lookup_min.sh --host example.com
./domain_lookup_min.sh --host example.com --both
```

### `domain_lookup_min.sh` usage

This lightweight script collects DNS and connectivity evidence for a hostname and can emit a Markdown checklist for easy sharing.

Basic usage:

```bash
./domain_lookup_min.sh --host example.com --output-md out.md
```

Fields produced in the markdown checklist:
- A (A record)
- AAAA (IPv6 address)
- CNAME
- NS (nameservers)
- SOA (authority)
- WHOIS (registrar or organization when available via `whois`)
- Ping result
- HTTP / HTTPS reachability

Notes:
- The script prefers `dig` and falls back to `nslookup` when `dig` is not available.
- `whois` is best-effort and may not be installed; if absent the WHOIS field is `-`.
- MX/TXT checks are intentionally deferred to a future iteration.

## Why write a "do-nothing" script?

There are a lot of opinions online about writing tools and automations; here's the distilled, practical version we actually use when building these tiny utilities.

- Start cheap, learn fast. A do-nothing script is a low-friction way to capture the exact sequence of steps, commands, and checks you reach for when troubleshooting. It doesn't have to be perfect — it just has to be useful and repeatable.
- Reduce cognitive load for humans. The value isn't only in full automation; it's in making the knowledge explicit. When someone runs the script they see the same checklist and evidence you would collect, which makes shared reasoning way faster than a docx or a hand-off email.
- Make mistakes safe and observable. Small, well-scoped scripts are easy to review and revert. They encourage experimentation (try a new check, add an output format) without dragging huge, fragile systems into the change.
- Build a scaffold for real automation. The script may start as a checklist generator, but because it lives in code you can incrementally add idempotent steps, tests, and CI. That turns tribal knowledge into reproducible automation over time.
- Ship early, iterate often. If you wait to perfect a tool you never show it to teammates. A minimal script that documents intent is far more valuable than a polished, hidden plan.
- Prioritize clarity over cleverness. The best utilities are readable and forgiving. Future you (and your teammates) will thank you for explicit outputs, clear fallbacks, and a tiny smoke test.

In short: do-nothing scripts reduce friction, make expertise shareable, and create a thin, testable path from human workflow to automation. They're the smallest useful increment toward continuous improvement.

### Why Gum / TUI tooling?

We picked Gum (and similar small TUI helpers) for a few practical reasons that line up with our do-nothing philosophy:

- Human-first UX: a tiny TUI reduces typing and helps beginners follow a flow without hiding what's happening under the hood. It surfaces choices and makes the process repeatable.
- Low cost, high signal: Gum is just shell tooling; it doesn't add heavy dependencies or obscure logic. If it breaks, the fallback is plain CLI input — no black box.
- Incremental ergonomics: a TUI improves the experience immediately while keeping the codebase simple enough to refactor into real automation later.
- Fallback-first design: everything interactive should have a non-interactive CLI mode. That lets you run checks in CI or from scripts and keeps demos reliable in noisy environments.

Bottom line: Gum is a pragmatic ergonomics layer, not a requirement. We use it to make demos and manual workflows smoother while preserving scriptability and auditability.
# do-nothing-scripts
🧘‍♂️ A collection of “do-nothing” shell scripts using Gum. These stub scripts scaffold thought, guide workflows, and serve as placeholders for eventual automation. Start with nothing, grow into something.

## Try it (one-command demo)

Run the small test runner which executes syntax checks and smoke tests locally:

```bash
./test/run_all.sh
```

What I'll demo (1 minute each):

- Run the test runner: `./test/run_all.sh` (syntax checks + smoke tests)
- Generate a shareable checklist: `./domain_lookup_min.sh --host example.com --output-md demo_example.md`
- Show the interactive export shortcut (if `gum` is installed): `./domain_lookup_interactive.sh --export-md example.com demo_interactive.md`

These steps produce a tiny Markdown checklist and optional JSON you can paste into an issue or slides.

### Export & share (interactive)

The interactive `domain_lookup_interactive.sh` provides an "Export & share" action (Gum UI) that can write:

- Markdown checklist (same format as `--output-md`)
- JSON summary (`--output-json`) — a small array of objects with keys: domain, soa, ns, a, aaaa, cname, whois, ping, http, https
- Both Markdown and JSON

Non-interactive equivalents:

```bash
# write markdown
./domain_lookup_interactive.sh --export-md example.com out.md

# write json
./domain_lookup_interactive.sh --export-json example.com out.json

# write both
./domain_lookup_interactive.sh --export-both example.com out.md out.json
```

The JSON format is intentionally simple and intended for quick ingestion in scripts or dashboards. If you need a stricter schema or additional fields (MX/TXT parsing, certificate details), we can extend it.


This is a quick way to validate the repository tools on a machine with `bash`, `curl`, and basic networking.
