# Table.swift

`Table.swift` provides Rich-style terminal tables.

## Create A Table

```swift
var table = Table(title: "Build Matrix")
table.addColumn("Platform", style: Style("bold cyan"))
table.addColumn("Status", alignment: .right)
table.addRow("macOS", "[green]passing[/]")
table.addRow("Linux", "[green]passing[/]")

Console().print(table)
```

Cells may contain markup. Headers can have their own styles.

## Columns

Add columns before rows:

```swift
table.addColumn("Name")
table.addColumn("Count", alignment: .right)
table.addColumn("Notes", style: Style("bold yellow"))
```

Alignment applies to cells in that column and to the header.

## Rows

Rows are arrays of strings:

```swift
table.addRow("RichSwift", "ready", "terminal rendering")
```

If a row contains fewer cells than there are columns, missing cells render as
empty strings.

## Titles And Headers

Use a title for a centered heading above the bordered table:

```swift
var table = Table(title: "Packages")
```

Hide headers when the table is acting as a compact grid:

```swift
var table = Table(showHeader: false)
```

## Box Styles

Choose a border style:

```swift
var rounded = Table(box: .rounded)
var square = Table(box: .square)
var ascii = Table(box: .ascii)
```

Use `.ascii` when targeting terminals that may not render Unicode box drawing
characters correctly.

## Width Behavior

Tables inspect the render context width and shrink wide columns proportionally.
Long cell content wraps to fit the computed column width.

```swift
let output = table.render(in: RenderContext(width: 80, colorMode: .disabled))
```

For predictable tests, render with a fixed width and disabled color.

