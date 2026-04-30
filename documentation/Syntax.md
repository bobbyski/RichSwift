# Syntax.swift

`Syntax.swift` provides lightweight, dependency-free syntax highlighting.

## Basic Usage

```swift
let code = """
let console = Console()
console.print("[green]OK[/]")
"""

Console().print(Syntax(code, language: "swift", lineNumbers: true))
```

## Supported Languages

The highlighter includes keyword sets for:

- `swift`
- `python`
- `json`

Unknown languages fall back to Swift keywords.

## What Gets Highlighted

`Syntax` highlights:

- Language keywords.
- String literals using double quotes.
- Numeric literals made only of digits.
- Swift-style `//` comments.
- Optional line numbers.

It is intentionally simple, so it does not parse every language grammar edge
case. For full grammar highlighting, wrap another highlighter in a custom
`RichRenderable`.

## Line Numbers

```swift
let syntax = Syntax(code, language: "swift", lineNumbers: true)
```

Line numbers are rendered in a dim gutter.

## Themes

Customize token styles with `Theme`:

```swift
let theme = Theme(
    keyword: Style("bold magenta"),
    string: Style("green"),
    number: Style("cyan"),
    comment: Style("dim"),
    lineNumber: Style("dim")
)

let syntax = Syntax(code, language: "swift", theme: theme)
```

Use `.default` for the built-in theme.

