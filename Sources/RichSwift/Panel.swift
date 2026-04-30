import Foundation

/// A bordered container for another renderable.
public struct Panel: RichRenderable, Sendable {
    /// The content rendered inside the panel.
    public var renderable: any RichRenderable

    /// Optional label embedded in the top border.
    public var title: String?

    /// Optional label embedded in the bottom border.
    public var subtitle: String?

    /// Style applied to the complete rendered panel.
    public var style: Style

    /// Border characters used by the panel.
    public var box: Box

    /// Number of spaces inserted around content inside the panel.
    public var padding: Int

    /// Creates a panel around an arbitrary renderable.
    public init(_ renderable: any RichRenderable, title: String? = nil, subtitle: String? = nil, style: Style = .plain, box: Box = .rounded, padding: Int = 1) {
        self.renderable = renderable
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.box = box
        self.padding = max(0, padding)
    }

    /// Creates a panel around a text value.
    public init(_ text: String, title: String? = nil, subtitle: String? = nil, style: Style = .plain, box: Box = .rounded, padding: Int = 1) {
        self.init(Text(text), title: title, subtitle: subtitle, style: style, box: box, padding: padding)
    }

    /// Renders the panel and its nested content.
    public func render(in context: RenderContext) -> String {
        let innerWidth = max(1, context.width - 4 - padding * 2)
        let innerContext = RenderContext(width: innerWidth, colorMode: context.colorMode, markup: context.markup)
        let rendered = renderable.render(in: innerContext)
        let rawLines = rendered.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let contentWidth = min(max(rawLines.map { displayWidth(stripANSI($0)) }.max() ?? 0, displayWidth(title ?? ""), displayWidth(subtitle ?? "")), innerWidth)
        let lines = rawLines.flatMap { line -> [String] in
            displayWidth(stripANSI(line)) > contentWidth ? wrapPlain(stripANSI(line), width: contentWidth) : [line]
        }
        let horizontalWidth = contentWidth + padding * 2 + 2

        var output: [String] = []
        output.append(edge(left: box.topLeft, right: box.topRight, width: horizontalWidth, label: title))
        for line in lines {
            let padded = String(repeating: " ", count: padding) + pad(line, to: contentWidth) + String(repeating: " ", count: padding)
            output.append("\(box.vertical) \(padded) \(box.vertical)")
        }
        output.append(edge(left: box.bottomLeft, right: box.bottomRight, width: horizontalWidth, label: subtitle))
        let text = output.joined(separator: "\n")
        return style == .plain ? text : Segment(text, style: style).render(colorEnabled: context.colorEnabled)
    }

    private func edge(left: Character, right: Character, width: Int, label: String?) -> String {
        guard let label, !label.isEmpty, width > displayWidth(label) + 2 else {
            return String(left) + String(repeating: String(box.horizontal), count: width) + String(right)
        }
        let decorated = " \(label) "
        let remaining = width - displayWidth(decorated)
        return String(left) + decorated + String(repeating: String(box.horizontal), count: remaining) + String(right)
    }
}
