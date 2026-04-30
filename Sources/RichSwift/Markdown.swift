import Foundation

public struct Markdown: RichRenderable, Sendable {
    public var source: String

    public init(_ source: String) {
        self.source = source
    }

    public func render(in context: RenderContext) -> String {
        var output: [String] = []
        var inCodeBlock = false
        var codeLanguage = ""
        var codeLines: [String] = []

        func flushCode() {
            guard !codeLines.isEmpty || inCodeBlock else { return }
            output.append(Syntax(codeLines.joined(separator: "\n"), language: codeLanguage, lineNumbers: false).render(in: context))
            codeLines.removeAll()
            codeLanguage = ""
        }

        for line in source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init) {
            if line.hasPrefix("```") {
                if inCodeBlock {
                    flushCode()
                    inCodeBlock = false
                } else {
                    inCodeBlock = true
                    codeLanguage = String(line.dropFirst(3))
                }
                continue
            }
            if inCodeBlock {
                codeLines.append(line)
                continue
            }
            if line.hasPrefix("#") {
                let level = line.prefix { $0 == "#" }.count
                let title = line.dropFirst(level).trimmingCharacters(in: .whitespaces)
                let style = level == 1 ? Style("bold cyan") : Style("bold")
                output.append(Text(String(title), style: style, markup: true).render(in: context))
            } else if line.hasPrefix(">") {
                output.append(Text("┃ " + line.dropFirst().trimmingCharacters(in: .whitespaces), style: Style("italic dim"), markup: true).render(in: context))
            } else if line.hasPrefix("- ") || line.hasPrefix("* ") {
                output.append("• " + renderInlineMarkdown(String(line.dropFirst(2)), context: context))
            } else {
                output.append(renderInlineMarkdown(line, context: context))
            }
        }
        if inCodeBlock {
            flushCode()
        }
        return output.joined(separator: "\n")
    }

    private func renderInlineMarkdown(_ line: String, context: RenderContext) -> String {
        var text = line
        text = text.replacingOccurrences(of: "**", with: "[bold]", options: [], range: nil)
        text = text.replacingOccurrences(of: "`", with: "[cyan]", options: [], range: nil)
        return Text(balanceMarkup(text), markup: true).render(in: context)
    }

    private func balanceMarkup(_ text: String) -> String {
        var result = ""
        var boldOpen = false
        var codeOpen = false
        var index = text.startIndex
        while index < text.endIndex {
            if text[index...].hasPrefix("[bold]") {
                result += boldOpen ? "[/]" : "[bold]"
                boldOpen.toggle()
                index = text.index(index, offsetBy: 6)
            } else if text[index...].hasPrefix("[cyan]") {
                result += codeOpen ? "[/]" : "[cyan]"
                codeOpen.toggle()
                index = text.index(index, offsetBy: 6)
            } else {
                result.append(text[index])
                index = text.index(after: index)
            }
        }
        if codeOpen { result += "[/]" }
        if boldOpen { result += "[/]" }
        return result
    }
}
