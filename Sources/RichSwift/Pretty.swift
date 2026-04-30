import Foundation

public func inspect(_ value: Any, title: String? = nil) -> Panel {
    let mirror = Mirror(reflecting: value)
    var table = Table(title: title ?? String(describing: type(of: value)))
    table.addColumn("Property", style: Style("bold cyan"))
    table.addColumn("Value")

    if mirror.children.isEmpty {
        table.addRow("value", String(describing: value))
    } else {
        for child in mirror.children {
            table.addRow(child.label ?? "-", String(describing: child.value))
        }
    }

    return Panel(table, title: "Inspect")
}

public struct Traceback: RichRenderable, Sendable {
    public var error: String
    public var file: String
    public var line: Int
    public var function: String

    public init(_ error: any Error, file: String = #fileID, line: Int = #line, function: String = #function) {
        self.error = String(describing: error)
        self.file = file
        self.line = line
        self.function = function
    }

    public func render(in context: RenderContext) -> String {
        var table = Table(title: "Traceback")
        table.addColumn("Field", style: Style("bold red"))
        table.addColumn("Value")
        table.addRow("Error", error)
        table.addRow("File", file)
        table.addRow("Line", String(line))
        table.addRow("Function", function)
        return table.render(in: context)
    }
}

