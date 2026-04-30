# Panel.swift

`Panel.swift` renders framed content with optional title and subtitle labels.

## Basic Panel

```swift
let panel = Panel("Deploy [green]complete[/]", title: "Release")
Console().print(panel)
```

Panel content can be any `RichRenderable`, not just text:

```swift
var table = Table(title: "Summary")
table.addColumn("Metric")
table.addColumn("Value")
table.addRow("Tests", "[green]passing[/]")

console.print(Panel(table, title: "CI"))
```

## Titles And Subtitles

```swift
Panel("Content", title: "Top", subtitle: "Bottom")
```

The title is embedded in the top border. The subtitle is embedded in the bottom
border.

## Padding

Padding controls spaces around content:

```swift
Panel("Compact", padding: 0)
Panel("Roomy", padding: 2)
```

Padding is clamped to zero or higher.

## Box Styles

Panels use the same `Box` values as tables:

```swift
Panel("Unicode", box: .rounded)
Panel("ASCII", box: .ascii)
```

## Width And Wrapping

Panels render within the supplied context width:

```swift
let context = RenderContext(width: 60, colorMode: .standard)
let output = Panel("A long line...").render(in: context)
```

Long plain-text content wraps so the frame stays within the available width.
If the content already includes complex ANSI styling, keep lines short for the
most predictable wrapping.

