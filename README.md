
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

## The Banana Leaf Philosophy

The "do-nothing" approach is in part influenced by a design philosophy from Charles Eames, often called the "banana leaf parable." In a 1978 lecture, Eames described a hierarchy of dinnerware in India, from the simple banana leaf for the lowest castes to ornate gold and silver plates for the wealthy. He observed that the most enlightened people—those with both means and understanding—ultimately return to eating off a simple banana leaf.

> "...it is that process that has happened within the man that changes the banana leaf."
>
> — Charles Eames, [1978 lecture](https://youtu.be/b0vDWqp6J7Y?si=D8XmPYyQEjryIRjB&t=766)

This idea applies perfectly to choosing a simple, interactive shell script over a more complex GUI or a static Word document. While more elaborate tools exist, a well-crafted script is a return to fundamentals. It's a direct, efficient, and universally accessible tool. In the hands of someone with understanding, this "banana leaf" becomes more powerful than its simple appearance suggests, turning a manual process into a refined, repeatable workflow.

