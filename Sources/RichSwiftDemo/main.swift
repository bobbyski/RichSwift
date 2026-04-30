import RichSwift

let console = Console()

console.rule("RichSwift")
console.print("Hello, [bold magenta]World[/]! This is Rich-style terminal output in Swift.")

var table = Table(title: "Feature Map")
table.addColumn("Renderable", style: Style("bold cyan"))
table.addColumn("Purpose")
table.addColumn("Status", alignment: .right)
table.addRow("Text / Markup", "BBCode-style nested terminal styles", "[green]ready[/]")
table.addRow("Table", "Unicode or ASCII terminal tables", "[green]ready[/]")
table.addRow("Panel", "Framed content with titles", "[green]ready[/]")
table.addRow("Markdown", "Headings, bullets, quotes, and code blocks", "[yellow]basic[/]")
table.addRow("Syntax", "Keyword, string, number, and comment highlighting", "[yellow]basic[/]")
console.print(table)

console.print(Panel("Use [cyan]Console[/], [cyan]Table[/], [cyan]Panel[/], [cyan]Markdown[/], [cyan]Syntax[/], and [cyan]ProgressBar[/] from any SwiftPM executable.", title: "API"))
console.print(ProgressBar(completed: 72, total: 100, width: 36))

let markdown = Markdown("""
# Markdown
- Styled headings
- Bullets and inline `code`
> Block quotes

```swift
let console = Console()
console.print("[bold green]Ship it[/]")
```
""")

console.print(markdown)
