# Markdown.swift

`Markdown.swift` contains a small terminal Markdown renderer.

## Basic Usage

```swift
let markdown = Markdown("""
# Release Notes
- Added tables
- Added panels
> Terminal output should be readable
""")

Console().print(markdown)
```

## Supported Elements

The renderer supports a practical subset:

- Headings beginning with `#`.
- Block quotes beginning with `>`.
- Unordered list items beginning with `- ` or `* `.
- Fenced code blocks using triple backticks.
- Inline bold markers using `**`.
- Inline code markers using backticks.

## Headings

```markdown
# Main Heading
## Smaller Heading
```

Level 1 headings render bold cyan. Other heading levels render bold.

## Lists

```markdown
- First
- Second with `inline code`
```

List markers render as terminal bullets.

## Block Quotes

```markdown
> A useful note
```

Block quotes render with a left bar and dim italic styling.

## Fenced Code Blocks

````markdown
```swift
let console = Console()
console.print("[green]OK[/]")
```
````

Code blocks are passed through `Syntax`, using the language identifier after the
opening fence.

## Scope

This renderer is intentionally small. It is intended for CLI help text, release
notes, and status output. It is not a complete CommonMark implementation.

