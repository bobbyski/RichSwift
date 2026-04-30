import Foundation

public struct Syntax: RichRenderable, Sendable {
    public var code: String
    public var language: String
    public var theme: Theme
    public var lineNumbers: Bool

    public init(_ code: String, language: String, theme: Theme = .default, lineNumbers: Bool = false) {
        self.code = code
        self.language = language.lowercased()
        self.theme = theme
        self.lineNumbers = lineNumbers
    }

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

public struct Theme: Sendable {
    public var keyword: Style
    public var string: Style
    public var number: Style
    public var comment: Style
    public var lineNumber: Style

    public static let `default` = Theme(
        keyword: Style("bold magenta"),
        string: Style("green"),
        number: Style("cyan"),
        comment: Style("dim"),
        lineNumber: Style("dim")
    )
}

