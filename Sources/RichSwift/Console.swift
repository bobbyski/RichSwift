import Foundation

/// A terminal output coordinator similar to Rich's `Console`.
///
/// `Console` renders `RichRenderable` values, strings with optional markup, and
/// arbitrary Swift values. By default it writes to standard output, but tests
/// and tools can inject a custom writer.
public final class Console: @unchecked Sendable {
    /// The target output width in character cells.
    public var width: Int

    /// The color policy used for rendered output.
    public var colorMode: ColorMode

    /// Whether string values are parsed as markup by default.
    public var markup: Bool

    private let writer: (String) -> Void

    /// Creates a console.
    ///
    /// - Parameters:
    ///   - width: The target output width. If omitted, `COLUMNS` is used when
    ///     available, otherwise `80`.
    ///   - colorMode: Whether to emit ANSI color and style sequences.
    ///   - markup: Whether strings should be parsed for markup by default.
    ///   - writer: A custom output sink. The default writes to standard output.
    public init(
        width: Int? = nil,
        colorMode: ColorMode = .automatic,
        markup: Bool = true,
        writer: ((String) -> Void)? = nil
    ) {
        self.width = width ?? Console.detectWidth()
        self.colorMode = colorMode
        self.markup = markup
        self.writer = writer ?? { Swift.print($0, terminator: "") }
    }

    /// Renders a value without writing it.
    ///
    /// `RichRenderable` values are rendered directly. Other values are converted
    /// using `String(describing:)` and optionally parsed as markup.
    public func render(_ value: Any, markup: Bool? = nil, style: Style = .plain) -> String {
        let context = RenderContext(width: width, colorMode: colorMode, markup: markup ?? self.markup)
        if let renderable = value as? RichRenderable {
            let rendered = renderable.render(in: context)
            return style == .plain ? rendered : Segment(rendered, style: style).render(colorEnabled: context.colorEnabled)
        }
        return Text(String(describing: value), style: style, markup: markup ?? self.markup).render(in: context)
    }

    /// Renders and writes one or more values.
    ///
    /// - Parameters:
    ///   - values: Values to render. `RichRenderable` values are rendered using
    ///     their own implementation.
    ///   - separator: Text inserted between rendered values.
    ///   - terminator: Text appended after the rendered values.
    ///   - style: A style applied to non-renderable values.
    ///   - markup: Overrides the console's markup setting for this call.
    public func print(_ values: Any..., separator: String = " ", terminator: String = "\n", style: Style = .plain, markup: Bool? = nil) {
        let output = values.map { render($0, markup: markup, style: style) }.joined(separator: separator) + terminator
        writer(output)
    }

    /// Writes a horizontal rule across the console width.
    ///
    /// - Parameters:
    ///   - title: Optional text centered inside the rule.
    ///   - style: Style applied to the whole rule.
    public func rule(_ title: String? = nil, style: Style = Style("dim")) {
        let label = title.map { " " + $0 + " " } ?? ""
        let remaining = max(0, width - displayWidth(label))
        let left = remaining / 2
        let right = remaining - left
        print(String(repeating: "─", count: left) + label + String(repeating: "─", count: right), style: style)
    }

    /// Writes a timestamped log line.
    public func log(_ values: Any..., separator: String = " ") {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let time = formatter.string(from: Date())
        print("[dim]\(time)[/] " + values.map { render($0) }.joined(separator: separator), markup: true)
    }

    /// Creates an indeterminate status renderer backed by this console.
    ///
    /// Call `update(_:)` to redraw the current spinner frame and `stop(clear:)`
    /// when the task completes.
    public func status(_ message: String, spinner: Spinner = .dots) -> Status {
        Status(console: self, message: message, spinner: spinner)
    }

    /// Captures console output produced inside `body`.
    ///
    /// This is useful for tests and for rendering rich content into strings.
    public static func capture(width: Int = 80, colorMode: ColorMode = .disabled, _ body: (Console) -> Void) -> String {
        var buffer = ""
        let console = Console(width: width, colorMode: colorMode) { buffer += $0 }
        body(console)
        return buffer
    }

    private static func detectWidth() -> Int {
        if let columns = ProcessInfo.processInfo.environment["COLUMNS"], let width = Int(columns), width > 0 {
            return width
        }
        return 80
    }
}

/// Convenience wrapper that prints with a default `Console`.
public func richPrint(_ values: Any..., separator: String = " ", terminator: String = "\n", style: Style = .plain) {
    let console = Console()
    let output = values.map { console.render($0, style: style) }.joined(separator: separator) + terminator
    Swift.print(output, terminator: "")
}
