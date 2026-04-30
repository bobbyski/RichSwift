import Foundation

public enum Markup {
    public static func parse(_ text: String, baseStyle: Style = .plain) -> [Segment] {
        var segments: [Segment] = []
        var stack: [Style] = [baseStyle]
        var buffer = ""
        var index = text.startIndex

        func flush() {
            guard !buffer.isEmpty else { return }
            segments.append(Segment(buffer, style: stack.last ?? baseStyle))
            buffer.removeAll(keepingCapacity: true)
        }

        while index < text.endIndex {
            let character = text[index]
            if character == "[", let close = text[index...].firstIndex(of: "]") {
                let tag = String(text[text.index(after: index)..<close])
                if tag == "[" {
                    buffer.append("[")
                    index = text.index(after: close)
                    continue
                }
                if tag.hasPrefix("/") {
                    flush()
                    if stack.count > 1 {
                        _ = stack.popLast()
                    }
                    index = text.index(after: close)
                    continue
                }
                let parsed = Style.parse(tag)
                if parsed != .plain || !tag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    flush()
                    stack.append((stack.last ?? baseStyle).merged(with: parsed))
                    index = text.index(after: close)
                    continue
                }
            }
            buffer.append(character)
            index = text.index(after: index)
        }

        flush()
        return segments
    }

    public static func render(_ text: String, style: Style = .plain, colorEnabled: Bool = true) -> String {
        parse(text, baseStyle: style).render(colorEnabled: colorEnabled)
    }
}

public struct Text: RichRenderable, Sendable {
    public var content: String
    public var style: Style
    public var markup: Bool

    public init(_ content: String, style: Style = .plain, markup: Bool = true) {
        self.content = content
        self.style = style
        self.markup = markup
    }

    public func render(in context: RenderContext) -> String {
        if markup {
            return Markup.render(content, style: style, colorEnabled: context.colorEnabled)
        }
        return Segment(content, style: style).render(colorEnabled: context.colorEnabled)
    }
}

