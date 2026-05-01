# RichSwift

RichSwift is a SwiftPM terminal formatting library inspired by Python's
[Rich](https://github.com/Textualize/rich). It provides a practical core for
styled console output, markup, tables, panels, progress bars, Markdown-ish
rendering, syntax highlighting, inspection, and traceback display.

The package is Foundation-only and is intended to build on macOS, Linux, and
Windows with Swift 6 or newer.

## Install

Add RichSwift to `Package.swift`:

```swift
.package(url: "https://github.com/bobbyski/RichSwift.git", from: "0.1.0")
```

Then depend on the library target:

```swift
.target(
    name: "YourTool",
    dependencies: ["RichSwift"]
)
```

## Console And Markup

```swift
import RichSwift

let console = Console()
console.print("Hello, [bold magenta]World[/]!")
console.print("Warnings are easier to spot", style: Style("yellow"))
console.log("A timestamped diagnostic")
```

Markup tags use a compact Rich-like syntax:

```swift
console.print("[bold red]Error[/] [dim]Something went wrong[/]")
console.print("[#4ec9b0]True color[/] and [color(208)]256-color[/] styles")
```

Supported style tokens include `bold`, `dim`, `italic`, `underline`,
`strikethrough`, `inverse`, named ANSI colors, `#rrggbb`, and `color(n)`.

## Tables

```swift
var table = Table(title: "Build Matrix")
table.addColumn("Platform", style: Style("bold cyan"))
table.addColumn("Status", alignment: .right)
table.addRow("macOS", "[green]passing[/]")
table.addRow("Linux", "[green]passing[/]")
table.addRow("Windows", "[yellow]expected[/]")

console.print(table)
```

## Panels

```swift
console.print(
    Panel("Deploy [green]complete[/]", title: "Release", subtitle: "v0.1.0")
)
```

## Progress

```swift
console.print(ProgressBar(completed: 42, total: 100))
```

For indeterminate work, `Console.status` exposes a lightweight spinner object:

```swift
let status = console.status("[bold]Compiling[/]")
status.update()
status.stop()
```

## Markdown And Syntax

```swift
let markdown = Markdown("""
# Notes
- Inline `code`
> Quoted text
""")

console.print(markdown)

let syntax = Syntax("let answer = 42", language: "swift", lineNumbers: true)
console.print(syntax)
```

Syntax highlighting is intentionally small and dependency-free. It highlights
keywords, strings, numbers, comments, and line numbers for Swift, Python, and
JSON-style input. Projects that need full grammar highlighting can wrap a
specialized highlighter and render it through `RichRenderable`.

## Demo

```bash
swift run richswift-demo
```

## Documentation

Detailed feature guides are available in [documentation/usage.md](documentation/usage.md).

## Current Scope

RichSwift aims to be a functional Swift analogue of the most common Rich
workflows, not a byte-for-byte port of Python internals. The core extension
points are `RichRenderable`, `RenderContext`, `Style`, and `Segment`, so new
renderables can plug into `Console.print` without changing the console.
