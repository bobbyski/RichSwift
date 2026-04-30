import Foundation

/// Builds a basic inspection panel for any Swift value.
///
/// The function reflects stored children with `Mirror` and presents them as a
/// two-column table wrapped in a panel.
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

/// A compact, Swift-oriented error display inspired by Rich tracebacks.
public struct Traceback: RichRenderable, Sendable {
    /// String representation of the captured error.
    public var error: String

    /// Source file associated with the traceback.
    public var file: String

    /// Source line associated with the traceback.
    public var line: Int

    /// Function associated with the traceback.
    public var function: String

    /// Creates a traceback renderable for an error.
    ///
    /// Defaults capture the call site so the rendered traceback points at where
    /// the `Traceback` was created.
    public init(_ error: any Error, file: String = #fileID, line: Int = #line, function: String = #function) {
        self.error = String(describing: error)
        self.file = file
        self.line = line
        self.function = function
    }

    /// Renders the traceback as a table.
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
