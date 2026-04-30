# ANSI.swift

`ANSI.swift` defines the styling model used throughout RichSwift. It contains
`Color`, `ColorMode`, and `Style`, which together describe how text becomes ANSI
terminal output.

## Colors

Use `Color` when constructing styles directly:

```swift
let style = Style(foreground: .cyan, bold: true)
```

Supported color forms:

- Named ANSI colors, such as `.red`, `.green`, `.blue`, `.white`.
- Bright named colors, such as `.brightRed`, `.brightBlue`, `.brightWhite`.
- 256-color palette indexes with `.indexed(208)`.
- True-color RGB values with `.rgb(255, 128, 0)`.

## Style Descriptions

Most application code can use `Style("...")` instead of constructing the style
manually:

```swift
let warning = Style("bold yellow")
let command = Style("cyan underline")
let custom = Style("#ff8800")
let indexed = Style("color(208)")
```

Common tokens:

| Token | Effect |
| --- | --- |
| `bold` or `b` | Bold text |
| `dim` | Dim text |
| `italic` or `i` | Italic text |
| `underline` or `u` | Underlined text |
| `strike`, `strikethrough`, or `s` | Strikethrough text |
| `reverse` or `inverse` | Reverse video |
| `blink` | ANSI blink attribute |
| `red`, `green`, `cyan`, etc. | Foreground color |
| `#rrggbb` | True-color foreground |
| `color(n)` | 256-color foreground |

## Background Colors

Markup and style parsing support background tokens prefixed by `on_` or `on-`:

```swift
console.print("[black on_yellow] highlighted [/] text")
```

When constructing a `Style` directly, use the `background` parameter:

```swift
let label = Style(foreground: .black, background: .yellow, bold: true)
```

## Color Modes

`ColorMode` controls whether ANSI escape codes are emitted:

```swift
let colored = Console(colorMode: .standard)
let plain = Console(colorMode: .disabled)
```

Use `.disabled` for tests, logs, files, or anywhere escape codes would be
undesirable. Use `.standard` for terminals known to support ANSI styling.
`.automatic` currently behaves as color-enabled output.

## Merging Styles

Styles can be layered:

```swift
let base = Style("bold")
let overlay = Style("red underline")
let combined = base.merged(with: overlay)
```

Color values in the overlay replace color values from the base. Boolean
attributes are combined, so `bold` remains active after merging.

