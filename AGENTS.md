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