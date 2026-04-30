import Foundation
import RichSwift

let width = 112
let labelWidth = 16
let console = Console(width: width, colorMode: .standard)
let context = RenderContext(width: width, colorMode: .standard)

func plainWidth(_ value: String) -> Int {
    var width = 0
    var isEscape = false
    for character in value {
        if character == "\u{001B}" {
            isEscape = true
        } else if isEscape, character == "m" {
            isEscape = false
        } else if !isEscape {
            width += 1
        }
    }
    return width
}

func padded(_ value: String, to target: Int, alignment: Alignment = .left) -> String {
    let missing = max(0, target - plainWidth(value))
    switch alignment {
    case .left:
        return value + String(repeating: " ", count: missing)
    case .right:
        return String(repeating: " ", count: missing) + value
    case .center:
        let left = missing / 2
        return String(repeating: " ", count: left) + value + String(repeating: " ", count: missing - left)
    }
}

func styled(_ markup: String) -> String {
    Markup.render(markup, colorEnabled: true)
}

func emit(_ rendered: String = "") {
    console.print(rendered, markup: false)
}

func section(_ label: String, _ lines: [String]) {
    let labelLines = label.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    let rowCount = max(labelLines.count, lines.count)
    for (index, line) in lines.enumerated() {
        let heading = index < labelLines.count ? styled("[bold red]\(labelLines[index])[/]") : ""
        emit(padded(heading, to: labelWidth, alignment: .right) + "  " + line)
    }
    if lines.count < rowCount {
        for index in lines.count..<rowCount {
            let heading = index < labelLines.count ? styled("[bold red]\(labelLines[index])[/]") : ""
            emit(padded(heading, to: labelWidth, alignment: .right) + "  ")
        }
    }
}

func section(_ label: String, _ line: String) {
    section(label, [line])
}

func gradientBlock(columns: Int = 64, rows: Int = 6) -> [String] {
    (0..<rows).map { y in
        (0..<columns).map { x in
            let hue = Double(x) / Double(max(1, columns - 1))
            let value = 0.42 + (Double(y) / Double(max(1, rows - 1))) * 0.58
            let rgb = hsvToRGB(hue: hue, saturation: 0.96, value: value)
            return styled("[on_\(hex(rgb))] [/]") 
        }.joined()
    }
}

func hsvToRGB(hue: Double, saturation: Double, value: Double) -> (Int, Int, Int) {
    let i = Int((hue * 6).rounded(.down))
    let f = hue * 6 - Double(i)
    let p = value * (1 - saturation)
    let q = value * (1 - f * saturation)
    let t = value * (1 - (1 - f) * saturation)
    let triple: (Double, Double, Double)
    switch i % 6 {
    case 0: triple = (value, t, p)
    case 1: triple = (q, value, p)
    case 2: triple = (p, value, t)
    case 3: triple = (p, q, value)
    case 4: triple = (t, p, value)
    default: triple = (value, p, q)
    }
    return (Int(triple.0 * 255), Int(triple.1 * 255), Int(triple.2 * 255))
}

func hex(_ rgb: (Int, Int, Int)) -> String {
    String(format: "#%02x%02x%02x", rgb.0, rgb.1, rgb.2)
}

func textColumns() -> [String] {
    let left = [
        "[green]Lorem ipsum dolor sit",
        "amet, consectetur",
        "adipiscing elit.",
        "Quisque in metus sed",
        "sapien ultricies",
        "pretium a at justo.",
        "Maecenas luctus velit",
        "et auctor maximus.[/]"
    ].map(styled)
    let center = [
        "[yellow]Lorem ipsum dolor sit",
        "   amet, consectetur",
        "      adipiscing elit.",
        " Quisque in metus sed",
        "   sapien ultricies",
        "pretium a at justo.",
        "Maecenas luctus velit",
        "   et auctor maximus.[/]"
    ].map(styled)
    let right = [
        "[blue]Lorem ipsum dolor sit",
        "     amet, consectetur",
        "       adipiscing elit.",
        " Quisque in metus sed",
        "   sapien ultricies",
        " pretium a at justo.",
        "Maecenas luctus velit",
        "   et auctor maximus.[/]"
    ].map(styled)
    let full = [
        "[red]Lorem  ipsum  dolor  sit",
        "amet,      consectetur",
        "adipiscing       elit.",
        "Quisque  in  metus  sed",
        "sapien       ultricies",
        "pretium  a  at  justo.",
        "Maecenas  luctus  velit",
        "et auctor maximus.[/]"
    ].map(styled)

    return (0..<left.count).map { index in
        padded(left[index], to: 24)
            + padded(center[index], to: 25)
            + padded(right[index], to: 25)
            + full[index]
    }
}

func movieTable() -> [String] {
    let headers = [
        padded(styled("[bold green]Date[/]"), to: 16),
        padded(styled("[bold blue]Title[/]"), to: 42),
        padded(styled("[bold cyan]Production Budget[/]"), to: 24, alignment: .right),
        padded(styled("[bold magenta]Box Office[/]"), to: 22, alignment: .right)
    ].joined()

    let rows = [
        ("Dec 20, 2019", "Star Wars: The Rise of Skywalker", "$275,000,000", "$375,126,118"),
        ("May 25, 2018", "Solo: A Star Wars Story", "$275,000,000", "$393,151,347"),
        ("Dec 15, 2017", "Star Wars Ep. VIII: The Last Jedi", "$262,000,000", "$1,332,539,889"),
        ("May 19, 1999", "Star Wars Ep. I: The Phantom Menace", "$115,000,000", "$1,027,044,677")
    ]

    let renderedRows = rows.map { date, title, budget, boxOffice in
        padded(styled("[green]\(date)[/]"), to: 16)
            + padded(styled("[blue]\(title)[/]"), to: 42)
            + padded(styled("[cyan]\(budget)[/]"), to: 24, alignment: .right)
            + padded(styled("[magenta]\(boxOffice)[/]"), to: 22, alignment: .right)
    }

    return [headers, styled("[dim]" + String(repeating: "─", count: 104) + "[/]")] + renderedRows
}

func syntaxAndPretty() -> [String] {
    let code = """
def iter_last(values: Iterable[T]) -> Iterator[tuple[bool, T]]:
    "Iterate and generate a tuple with a last flag."
    iter_values = iter(values)
    try:
        previous_value = next(iter_values)
    except StopIteration:
        return
    for value in iter_values:
        yield False, previous_value
        previous_value = value
    yield True, previous_value
"""
    let syntax = Syntax(code, language: "python", lineNumbers: true).render(in: context).split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
    let pretty = [
        styled("[dim]{[/]"),
        styled("  [green]'foo'[/]: [dim][[/]"),
        styled("    [cyan]3.1427[/],"),
        styled("    [dim]([/]"),
        styled("      [green]'Paul Atreides'[/],"),
        styled("      [green]'Vladimir Harkonnen'[/],"),
        styled("      [green]'Thufir Hawat'[/]"),
        styled("    [dim])[/]"),
        styled("  [dim]],[/]"),
        styled("  [green]'atomic'[/]: ([red]False[/], [green]True[/], [magenta]None[/])"),
        styled("[dim]}[/]")
    ]

    return (0..<max(syntax.count, pretty.count)).map { index in
        padded(index < syntax.count ? syntax[index] : "", to: 58) + "  " + (index < pretty.count ? pretty[index] : "")
    }
}

func markdownComparison() -> [String] {
    let source = [
        styled("[cyan]# Markdown[/]"),
        "",
        styled("[cyan]Supports much of the *markdown*, __syntax__![/]"),
        "",
        styled("[cyan]- Headers[/]"),
        styled("[cyan]- Basic formatting: **bold**, *italic*, `code`[/]"),
        styled("[cyan]- Block quotes[/]"),
        styled("[cyan]- Lists, and more...[/]")
    ]

    let rendered = [
        "┌" + String(repeating: "─", count: 43) + "┐",
        "│" + padded(styled("[bold]Markdown[/]"), to: 43, alignment: .center) + "│",
        "└" + String(repeating: "─", count: 43) + "┘",
        "",
        styled("Supports much of the [italic]markdown[/], [italic]syntax[/]!"),
        "",
        styled("[yellow]•[/] Headers"),
        styled("[yellow]•[/] Basic formatting: [bold]bold[/], [italic]italic[/], [inverse]code[/]"),
        styled("[yellow]•[/] Block quotes"),
        styled("[yellow]•[/] Lists, and more...")
    ]

    return (0..<max(source.count, rendered.count)).map { index in
        padded(index < source.count ? source[index] : "", to: 50) + "  " + (index < rendered.count ? rendered[index] : "")
    }
}

emit(padded(styled("[bold italic]Rich features[/]"), to: width, alignment: .center))
emit()

let colorLines = [
    styled("✓ [green]4-bit color[/]"),
    styled("✓ [blue]8-bit color[/]"),
    styled("✓ [magenta]Truecolor (16.7 million)[/]"),
    styled("✓ [yellow]Dumb terminals[/]"),
    styled("✓ [cyan]Automatic color conversion[/]")
]
let gradient = gradientBlock()
section("Colors", (0..<gradient.count).map { index in
    padded(index < colorLines.count ? colorLines[index] : "", to: 34) + gradient[index]
})
emit()

section("Styles", styled("All ansi styles: [bold]bold[/], [dim]dim[/], [italic]italic[/], [underline]underline[/], [strikethrough]strikethrough[/], [inverse]reverse[/], and even [blink]blink[/]."))
emit()

section("Text", styled("Word wrap text. Justify [green]left[/], [yellow]center[/], [blue]right[/] or [red]full[/]."))
section("", textColumns())
emit()

section("Asian\nlanguage\nsupport", [
    "🇨🇳 该库支持中文，日文和韩文文本!",
    "🇯🇵 ライブラリは中国語、日本語、韓国語のテキストをサポートしています",
    "🇰🇷 이 라이브러리는 중국어, 일본어 및 한국어 텍스트를 지원합니다"
])
emit()

section("Markup", styled("[magenta]Rich[/] supports a simple [italic]bbcode[/] like [bold]markup[/] for [yellow]color[/], [underline]style[/], and emoji! 👍 🍎 🐜 🐻 🥖 🚌"))
emit()

section("Tables", movieTable())
emit()

section("Syntax\nhighlighting\n&\npretty\nprinting", syntaxAndPretty())
emit()

section("Markdown", markdownComparison())
emit()

section("+more!", "Progress bars, columns, styled logging handler, tracebacks, etc...")
