import Foundation

public struct RenderContext: Sendable {
    public var width: Int
    public var colorMode: ColorMode
    public var markup: Bool

    public init(width: Int = 80, colorMode: ColorMode = .automatic, markup: Bool = true) {
        self.width = max(1, width)
        self.colorMode = colorMode
        self.markup = markup
    }

    public var colorEnabled: Bool {
        switch colorMode {
        case .disabled:
            return false
        case .standard, .automatic:
            return true
        }
    }
}

public protocol RichRenderable: Sendable {
    func render(in context: RenderContext) -> String
}

public struct Segment: Equatable, Sendable {
    public var text: String
    public var style: Style

    public init(_ text: String, style: Style = .plain) {
        self.text = text
        self.style = style
    }

    func render(colorEnabled: Bool) -> String {
        let prefix = style.ansiPrefix(enabled: colorEnabled)
        return prefix.isEmpty ? text : prefix + text + ansiReset
    }
}

extension String: RichRenderable {
    public func render(in context: RenderContext) -> String {
        if context.markup {
            return Markup.parse(self).render(colorEnabled: context.colorEnabled)
        }
        return self
    }
}

extension Array: RichRenderable where Element == Segment {
    public func render(in context: RenderContext) -> String {
        render(colorEnabled: context.colorEnabled)
    }

    func render(colorEnabled: Bool) -> String {
        map { $0.render(colorEnabled: colorEnabled) }.joined()
    }
}

func displayWidth(_ text: String) -> Int {
    text.reduce(0) { total, character in
        if character.unicodeScalars.allSatisfy({ $0.value < 32 }) {
            return total
        }
        return total + 1
    }
}

func stripANSI(_ text: String) -> String {
    var result = ""
    var iterator = text.makeIterator()
    while let character = iterator.next() {
        if character == "\u{001B}" {
            while let next = iterator.next(), next != "m" {}
        } else {
            result.append(character)
        }
    }
    return result
}

func pad(_ text: String, to width: Int, alignment: Alignment = .left) -> String {
    let missing = max(0, width - displayWidth(stripANSI(text)))
    switch alignment {
    case .left:
        return text + String(repeating: " ", count: missing)
    case .right:
        return String(repeating: " ", count: missing) + text
    case .center:
        let left = missing / 2
        let right = missing - left
        return String(repeating: " ", count: left) + text + String(repeating: " ", count: right)
    }
}

func wrapPlain(_ text: String, width: Int) -> [String] {
    guard width > 0 else { return [text] }
    var lines: [String] = []
    for rawLine in text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init) {
        var current = ""
        for word in rawLine.split(separator: " ").map(String.init) {
            if current.isEmpty {
                current = word
            } else if displayWidth(current) + 1 + displayWidth(word) <= width {
                current += " " + word
            } else {
                lines.append(current)
                current = word
            }
        }
        lines.append(current)
    }
    return lines.isEmpty ? [""] : lines
}

public enum Alignment: Sendable {
    case left
    case center
    case right
}
