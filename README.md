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

Select domain variants and diagnostic level. Results are shown in a summary table at the end.

See [AGENTS.md](./AGENTS.md) for more details about agents and philosophy.
# do-nothing-scripts
🧘‍♂️ A collection of “do-nothing” shell scripts using Gum. These stub scripts scaffold thought, guide workflows, and serve as placeholders for eventual automation. Start with nothing, grow into something.
