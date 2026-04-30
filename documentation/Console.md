# Console.swift

`Console` is the primary way to render and write RichSwift output.

## Create A Console

```swift
let console = Console()
```

By default, the console:

- Uses the `COLUMNS` environment variable for width when available.
- Falls back to width `80`.
- Parses markup in strings.
- Emits ANSI color in automatic mode.
- Writes to standard output.

Customize it when needed:

```swift
let console = Console(width: 120, colorMode: .standard, markup: true)
```

## Print Values

```swift
console.print("Hello, [bold magenta]World[/]!")
console.print("Build", "[green]passed[/]", separator: ": ")
```

`Console.print` accepts any values. Values that conform to `RichRenderable` are
rendered by their own implementation. Other values are converted with
`String(describing:)`.

## Render Without Writing

Use `render` when you need the output string:

```swift
let output = console.render(Panel("Done", title: "Status"))
```

This is helpful for tests, snapshots, logging integrations, or composing larger
renderables.

## Disable Markup For One Call

```swift
console.print("[not markup]", markup: false)
```

Use this when displaying user input that may contain square brackets.

## Rules

Draw a horizontal rule:

```swift
console.rule("Results")
```

Rules use the console width and can be styled:

```swift
console.rule("Debug", style: Style("dim cyan"))
```

## Timestamped Logging

```swift
console.log("Downloaded", "42 files")
```

`log` prefixes the message with a dim timestamp. It is intentionally lightweight
and does not replace a full logging framework.

## Status Output

Use `status` for simple indeterminate progress:

```swift
let status = console.status("Working")
status.update()
status.update("Still working")
status.stop()
```

`Status` writes carriage-return based updates. It is best for interactive
terminal programs.

## Capture Output

Tests can capture output without ANSI styling:

```swift
let output = Console.capture { console in
    console.print("Hello [green]Swift[/]")
}

// output == "Hello Swift\n"
```

You can also capture colored output:

```swift
let output = Console.capture(colorMode: .standard) { console in
    console.print("[bold]Styled[/]")
}
```

## Convenience Printing

For quick scripts:

```swift
richPrint("[green]Ready[/]")
```

For larger programs, prefer keeping a `Console` instance so width, color mode,
and capture behavior are explicit.

