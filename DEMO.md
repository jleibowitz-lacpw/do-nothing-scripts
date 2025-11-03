Quick demo for showing the domain lookup tool in ~5 minutes.

Prereqs:
- Bash (Git Bash or WSL on Windows)
- curl (for HTTP checks)
- Optional: gum (for interactive UI), pwsh/powershell (clipboard/open helpers)

Quick steps:

1) Run the smoke test runner (syntax checks + quick non-interactive demos):

```bash
./test/run_all.sh
```

2) Minimal, scripted demo (non-interactive):

```bash
./domain_lookup_min.sh --host example.com --output-md demo_example.md
ls -l demo_example.md
sed -n '1,120p' demo_example.md
```

3) Interactive export demo (uses `gum` if available; falls back to printing URLs):

```bash
./domain_lookup_interactive.sh --export-md example.com demo_example_interactive.md
cat demo_example_interactive.md
```

4) If you need JSON output for ingestion:

```bash
./domain_lookup_interactive.sh --export-json example.com demo_example.json
jq . demo_example.json || cat demo_example.json
```

Notes for Windows demo (Git Bash):
- If you installed ShellCheck via Scoop, you can run `shellcheck` locally to lint scripts.
- PowerShell (`pwsh.exe` or `powershell.exe`) is used as a fallback to open URLs and copy to clipboard when available.

That's it — these steps produce a small Markdown checklist and optional JSON you can paste into a ticket or demo slides.
