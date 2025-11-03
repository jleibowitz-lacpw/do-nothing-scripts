# AGENTS.md

## Purpose
This file documents the automated agents, scripts, and their roles in the `do-nothing-scripts` repository.

## Agents & Scripts

### domain_lookup.sh
- **Role:** Automated domain diagnostic tool for network troubleshooting and DNS analysis.
- **Features:**
  - Smart apex/www domain detection and testing
  - DNS layer analysis (A, AAAA, CNAME, NS, SOA, MX, TXT records)
  - Network connectivity testing (ping, traceroute)
  - HTTP/HTTPS analysis with SSL certificate inspection
  - Tool availability detection with graceful fallbacks
  - Interactive TUI using gum for user input
  - Non-interactive summary table output
- **Usage:**
  - Run `./domain_lookup.sh` and follow interactive prompts
  - Select domain variants and diagnostic level
  - View results in a summary table

### domain_lookup_min.sh
- **Role:** Lightweight non-interactive domain diagnostic helper. Produces a compact summary and can emit a Markdown checklist for sharing.
- **When to use:** Quick checks, CI jobs, or when the interactive TUI is not available.
- **Usage:** `./domain_lookup_min.sh --host example.com [--both] [--output-md out.md]`

### domain_lookup_lib.sh
- **Role:** Shared helper library used by `domain_lookup_min.sh` and the interactive script during refactor.
- **Contents:** helper functions for tool detection, DNS lookups (A/AAAA/CNAME/NS/SOA), ping/http checks, and best-effort WHOIS extraction.
- **Note:** Keep helpers simple and side-effect free where possible to allow reuse in both non-interactive and interactive flows.

- **open_url(url)**: convenience helper to open a browser to a given URL (explorer.exe, xdg-open or `open`), falls back to printing the URL when no opener available.

## Agent Philosophy
Agents in this repo are designed to:
- Automate repetitive diagnostics and troubleshooting tasks
- Provide robust, user-friendly output
- Adapt to available system tools and environments
- Educate users about network and DNS concepts

## Contribution
To add a new agent:
- Place your script in the repo root or a relevant subfolder
- Document its purpose, features, and usage in this file
- Update the README.md with a summary and usage instructions

---
For more details, see individual script headers and the README.md.

## WHOIS / RDAP guidance

When inspecting domain registration data we intentionally prefer nudging people to open a WHOIS or RDAP lookup in their browser instead of trying to fully parse every registry's output locally. Registry formats vary a lot and local `whois` clients often query different servers, producing inconsistent results.

Suggested quick workflow:
- Open the RDAP view for the domain (https://rdap.org/domain/<domain>) or the ICANN lookup (https://rdap.icann.org/lookup?domain=<domain>). These are canonical and easy to share.
- Look for these four items first (they're the most actionable):
  1. Registrar name (who manages the registration)
  2. Expiration / registry expiry date (when the domain will drop)
 3. Expected authoritative nameservers (NS records) — mismatch here often explains missing DNS resolution
  4. Domain status flags (e.g. clientHold, serverTransferProhibited) — `clientHold` will stop resolution and is the common "domain is parked/blocked" state you asked about

Common gotchas and reminders:
- Multiple whois servers / formats: different TLDs (and legacy gTLDs) show data with varying labels. RDAP normalizes this better than text whois.
- Registrar vs DNS hosting: the registrar is who you pay for registration; nameservers may be hosted elsewhere (CDN or DNS provider). Both matter when debugging.
- Expiry vs auto-renew: expiry in RDAP is the registry expiry. The registrar may still auto-renew on billing; if expiry is imminent and registrar shows unpaid, escalate to the registrar UI.
- Status flags: `clientHold` or `redemptionPeriod` indicate the domain may not resolve; `serverHold`/`serverTransferProhibited` are registry-side controls. If you see these, check the registrar account for lock/unlock or contact support.
- Privacy / redaction: many registrars redact contact fields (GDPR/post-GDPR), so absence of contact data doesn't mean the domain is unowned.

If you want a small, local helper we include `whois_rdap.sh` which prints quick RDAP links and uses `whois` if available, but for accuracy and sharing we recommend opening RDAP in a browser.