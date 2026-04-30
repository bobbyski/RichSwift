# Markup.swift

`Markup.swift` implements Rich-style inline styling with square-bracket tags.
It also defines the `Text` renderable.

## Basic Markup

```swift
console.print("Hello, [bold magenta]World[/]!")
```

Opening tags push a style onto a stack. Closing tags pop the most recent style:

```swift
console.print("[bold]outer [red]inner[/] outer again[/]")
```

## Supported Style Tokens

Markup tags use the same tokens as `Style.parse`:

```swift
[bold]
[italic cyan]
[underline #ff8800]
[black on_yellow]
[color(208)]
```

## Rendering Markup Directly

Use `Markup.render` when you want a styled string without going through a
`Console`:

```swift
let rendered = Markup.render("[green]OK[/]", colorEnabled: true)
```

Disable color for plain text:

```swift
let plain = Markup.render("[green]OK[/]", colorEnabled: false)
```

## Parsing Into Segments

Use `Markup.parse` when building a custom renderable:

```swift
let segments = Markup.parse("A [bold]styled[/] value")
```

Each `Segment` contains text plus the style active for that text.

## Escaping A Literal Bracket

Use `[[` to render a literal `[`:

```swift
console.print("[[not a tag]")
```

## Text Renderable

`Text` wraps a string, base style, and markup setting:

```swift
let text = Text("Warning", style: Style("bold yellow"), markup: false)
console.print(text)
```

Use `Text` when passing styled text as a renderable to `Panel`, `Console`, or a
custom component.

