import Foundation

/// A lightweight syntax highlighter for terminal output.
///
/// `Syntax` is intentionally small and dependency-free. It highlights keywords,
/// strings, numbers, comments, and optional line numbers for a few common
/// languages.
public struct Syntax: RichRenderable, Sendable {
    /// Source code to highlight.
    public var code: String

    /// Language identifier, such as `"swift"`, `"python"`, or `"json"`.
    public var language: String

    /// Theme used for token styles.
    public var theme: Theme

    /// Whether to include a line-number gutter.
    public var lineNumbers: Bool

    /// Creates a syntax-highlighted code block.
    ///
    /// - Parameters:
    ///   - code: Source code to highlight.
    ///   - language: Language identifier used to choose keywords.
    ///   - theme: Styles used for highlighted token groups.
    ///   - lineNumbers: Whether to include a line-number gutter.
    public init(_ code: String, language: String, theme: Theme = .default, lineNumbers: Bool = false) {
        self.code = code
        self.language = language.lowercased()
        self.theme = theme
        self.lineNumbers = lineNumbers
    }

    /// Renders the highlighted code block.
    public func render(in context: RenderContext) -> String {
        let lines = code.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let gutterWidth = String(lines.count).count
        return lines.enumerated().map { offset, line in
            let highlighted = highlightLine(line, colorEnabled: context.colorEnabled)
            if lineNumbers {
                let number = pad(String(offset + 1), to: gutterWidth, alignment: .right)
                return Segment(number, style: theme.lineNumber).render(colorEnabled: context.colorEnabled) + " │ " + highlighted
            }
            return highlighted
        }.joined(separator: "\n")
    }

    private func highlightLine(_ line: String, colorEnabled: Bool) -> String {
        let keywords = Syntax.keywords[language] ?? Syntax.keywords["swift"]!
        var result = ""
        var token = ""

        func flushToken() {
            guard !token.isEmpty else { return }
            if keywords.contains(token) {
                result += Segment(token, style: theme.keyword).render(colorEnabled: colorEnabled)
            } else if token.allSatisfy(\.isNumber) {
                result += Segment(token, style: theme.number).render(colorEnabled: colorEnabled)
            } else {
                result += token
            }
            token.removeAll(keepingCapacity: true)
        }

        var inString = false
        var stringBuffer = ""
        for character in line {
            if character == "\"" {
                flushToken()
                stringBuffer.append(character)
                if inString {
                    result += Segment(stringBuffer, style: theme.string).render(colorEnabled: colorEnabled)
                    stringBuffer.removeAll()
                }
                inString.toggle()
                continue
            }
            if inString {
                stringBuffer.append(character)
                continue
            }
            if character.isLetter || character.isNumber || character == "_" {
                token.append(character)
            } else {
                flushToken()
                result.append(character)
            }
        }
        flushToken()
        if !stringBuffer.isEmpty {
            result += Segment(stringBuffer, style: theme.string).render(colorEnabled: colorEnabled)
        }

        if let commentRange = result.range(of: "//") {
            let before = String(result[..<commentRange.lowerBound])
            let comment = String(result[commentRange.lowerBound...])
            return before + Segment(comment, style: theme.comment).render(colorEnabled: colorEnabled)
        }
        return result
    }

    private static let keywords: [String: Set<String>] = [
        "swift": ["actor", "any", "as", "associatedtype", "await", "break", "case", "catch", "class", "continue", "defer", "do", "else", "enum", "extension", "false", "for", "func", "guard", "if", "import", "in", "init", "let", "nil", "private", "protocol", "public", "return", "self", "static", "struct", "switch", "throw", "throws", "true", "try", "var", "while"],
        "python": ["and", "as", "assert", "async", "await", "break", "class", "continue", "def", "elif", "else", "except", "false", "for", "from", "if", "import", "in", "is", "lambda", "none", "not", "or", "pass", "raise", "return", "true", "try", "while", "with", "yield"],
        "json": ["true", "false", "null"]
    ]
}

/// Style palette used by `Syntax`.
public struct Theme: Sendable {
    /// Style applied to language keywords.
    public var keyword: Style

    /// Style applied to string literals.
    public var string: Style

    /// Style applied to numeric literals.
    public var number: Style

    /// Style applied to comments.
    public var comment: Style

    /// Style applied to line numbers.
    public var lineNumber: Style

    /// Default terminal-friendly syntax theme.
    public static let `default` = Theme(
        keyword: Style("bold magenta"),
        string: Style("green"),
        number: Style("cyan"),
        comment: Style("dim"),
        lineNumber: Style("dim")
    )
}
