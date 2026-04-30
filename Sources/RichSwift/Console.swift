import Foundation

public final class Console: @unchecked Sendable {
    public var width: Int
    public var colorMode: ColorMode
    public var markup: Bool
    private let writer: (String) -> Void

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

    public func render(_ value: Any, markup: Bool? = nil, style: Style = .plain) -> String {
        let context = RenderContext(width: width, colorMode: colorMode, markup: markup ?? self.markup)
        if let renderable = value as? RichRenderable {
            let rendered = renderable.render(in: context)
            return style == .plain ? rendered : Segment(rendered, style: style).render(colorEnabled: context.colorEnabled)
        }
        return Text(String(describing: value), style: style, markup: markup ?? self.markup).render(in: context)
    }

    public func print(_ values: Any..., separator: String = " ", terminator: String = "\n", style: Style = .plain, markup: Bool? = nil) {
        let output = values.map { render($0, markup: markup, style: style) }.joined(separator: separator) + terminator
        writer(output)
    }

    public func rule(_ title: String? = nil, style: Style = Style("dim")) {
        let label = title.map { " " + $0 + " " } ?? ""
        let remaining = max(0, width - displayWidth(label))
        let left = remaining / 2
        let right = remaining - left
        print(String(repeating: "─", count: left) + label + String(repeating: "─", count: right), style: style)
    }

    public func log(_ values: Any..., separator: String = " ") {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let time = formatter.string(from: Date())
        print("[dim]\(time)[/] " + values.map { render($0) }.joined(separator: separator), markup: true)
    }

    public func status(_ message: String, spinner: Spinner = .dots) -> Status {
        Status(console: self, message: message, spinner: spinner)
    }

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

public func richPrint(_ values: Any..., separator: String = " ", terminator: String = "\n", style: Style = .plain) {
    let console = Console()
    let output = values.map { console.render($0, style: style) }.joined(separator: separator) + terminator
    Swift.print(output, terminator: "")
}
