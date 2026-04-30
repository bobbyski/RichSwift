# Renderable.swift

`Renderable.swift` defines the core rendering protocol and the small layout
helpers used by other features.

## RenderContext

`RenderContext` carries rendering options:

```swift
let context = RenderContext(width: 100, colorMode: .standard, markup: true)
```

Fields:

- `width`: target output width in terminal character cells.
- `colorMode`: controls ANSI escape output.
- `markup`: controls whether plain strings are parsed as markup.
- `colorEnabled`: convenience property derived from `colorMode`.

Renderers should respect the context rather than hard-coding widths or color
behavior.

## RichRenderable

Conform to `RichRenderable` to make a custom type printable by `Console`:

```swift
struct Banner: RichRenderable {
    var title: String

    func render(in context: RenderContext) -> String {
        Markup.render("[bold cyan]\(title)[/]", colorEnabled: context.colorEnabled)
    }
}

Console().print(Banner(title: "Build Complete"))
```

The protocol is intentionally small:

```swift
func render(in context: RenderContext) -> String
```

## Segment

`Segment` represents a styled run of text:

```swift
let segment = Segment("OK", style: Style("bold green"))
```

Segments are useful when implementing renderers that build output from many
styled pieces. Arrays of `Segment` already conform to `RichRenderable`.

## Alignment

`Alignment` is used by tables and layout helpers:

```swift
table.addColumn("Total", alignment: .right)
```

Available values:

- `.left`
- `.center`
- `.right`

## Layout Helpers

This file also contains internal helpers for measuring, padding, stripping ANSI
codes, and wrapping plain text. They are shared by built-in renderables so
tables and panels can align styled output reliably.

