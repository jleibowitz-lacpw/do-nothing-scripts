
🧘 A small collection of "do-nothing" shell scripts that use Charmbracelet's `gum` to scaffold ideas, guide manual workflows, and act as placeholders for gradual automation.

Started with a `sentry` helper that walks you through creating and configuring a Sentry project. These scripts are intentionally lightweight — they show the steps and collect inputs, but don't perform destructive actions or call external APIs.

There's also `gum_demo.sh`, a short demonstration of `gum` features useful when building interactive automation.

Installing gum

On Windows you can install `gum` with the `scoop` package manager:

```powershell
scoop install gum
```

For other platforms and package managers, follow the official instructions:

https://github.com/charmbracelet/gum#installation

Language choice

These examples are written in Bash, but the approach is language-agnostic: you can implement similar helpers in Python, PowerShell, JavaScript, etc. Use whatever works best for your environment.

