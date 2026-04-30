import Foundation

/// A terminal color that can be rendered as ANSI foreground or background codes.
///
/// `Color` supports named ANSI colors, 256-color palette indexes, and true-color
/// RGB values. Named colors use the standard ANSI names such as `.red`,
/// `.brightBlue`, and `.white`.
public enum Color: Equatable, Sendable {
    /// A named ANSI color, such as `"red"` or `"brightBlue"`.
    case named(String)

    /// A color from the 256-color ANSI palette.
    case indexed(UInt8)

    /// A 24-bit true-color RGB value.
    case rgb(UInt8, UInt8, UInt8)

    /// Standard black.
    public static let black = Color.named("black")
    /// Standard red.
    public static let red = Color.named("red")
    /// Standard green.
    public static let green = Color.named("green")
    /// Standard yellow.
    public static let yellow = Color.named("yellow")
    /// Standard blue.
    public static let blue = Color.named("blue")
    /// Standard magenta.
    public static let magenta = Color.named("magenta")
    /// Standard cyan.
    public static let cyan = Color.named("cyan")
    /// Standard white.
    public static let white = Color.named("white")
    /// Bright black, commonly displayed as gray.
    public static let brightBlack = Color.named("brightBlack")
    /// Bright red.
    public static let brightRed = Color.named("brightRed")
    /// Bright green.
    public static let brightGreen = Color.named("brightGreen")
    /// Bright yellow.
    public static let brightYellow = Color.named("brightYellow")
    /// Bright blue.
    public static let brightBlue = Color.named("brightBlue")
    /// Bright magenta.
    public static let brightMagenta = Color.named("brightMagenta")
    /// Bright cyan.
    public static let brightCyan = Color.named("brightCyan")
    /// Bright white.
    public static let brightWhite = Color.named("brightWhite")

    init?(styleToken: String) {
        let token = styleToken.trimmingCharacters(in: .whitespacesAndNewlines)
        if token.hasPrefix("#"), token.count == 7 {
            let hex = String(token.dropFirst())
            guard let value = UInt32(hex, radix: 16) else { return nil }
            self = .rgb(UInt8((value >> 16) & 0xff), UInt8((value >> 8) & 0xff), UInt8(value & 0xff))
            return
        }
        if token.hasPrefix("color("), token.hasSuffix(")") {
            let inner = token.dropFirst(6).dropLast()
            guard let value = UInt8(inner) else { return nil }
            self = .indexed(value)
            return
        }
        let normalized = token.replacingOccurrences(of: "_", with: "").replacingOccurrences(of: "-", with: "").lowercased()
        guard Color.foregroundCodes[normalized] != nil else { return nil }
        self = .named(normalized)
    }

    func ansiCode(background: Bool = false) -> String? {
        switch self {
        case .named(let name):
            guard let foreground = Color.foregroundCodes[name] else { return nil }
            return String(background ? foreground + 10 : foreground)
        case .indexed(let index):
            return "\(background ? 48 : 38);5;\(index)"
        case .rgb(let red, let green, let blue):
            return "\(background ? 48 : 38);2;\(red);\(green);\(blue)"
        }
    }

    private static let foregroundCodes: [String: Int] = [
        "black": 30,
        "red": 31,
        "green": 32,
        "yellow": 33,
        "blue": 34,
        "magenta": 35,
        "cyan": 36,
        "white": 37,
        "brightblack": 90,
        "brightred": 91,
        "brightgreen": 92,
        "brightyellow": 93,
        "brightblue": 94,
        "brightmagenta": 95,
        "brightcyan": 96,
        "brightwhite": 97
    ]
}

/// Controls whether renderers emit ANSI color and style escape sequences.
public enum ColorMode: Sendable {
    /// Let the console decide whether color should be emitted.
    ///
    /// The current implementation treats this as enabled; callers can use
    /// `.disabled` for deterministic plain-text output.
    case automatic

    /// Always emit ANSI color and style escape sequences.
    case standard

    /// Never emit ANSI escape sequences.
    case disabled
}

/// A collection of text attributes that can be converted to ANSI styles.
///
/// Styles can be created directly or parsed from Rich-like descriptions:
///
/// ```swift
/// Style("bold red")
/// Style(foreground: .cyan, underline: true)
/// ```
public struct Style: Equatable, Sendable {
    /// The foreground text color.
    public var foreground: Color?

    /// The background text color.
    public var background: Color?

    /// Whether the text should be rendered bold.
    public var bold: Bool

    /// Whether the text should be rendered dim.
    public var dim: Bool

    /// Whether the text should be rendered italic.
    public var italic: Bool

    /// Whether the text should be rendered underlined.
    public var underline: Bool

    /// Whether the text should be rendered with a strikethrough.
    public var strikethrough: Bool

    /// Whether foreground and background colors should be reversed.
    public var inverse: Bool

    /// Whether the text should blink on terminals that support it.
    public var blink: Bool

    /// Creates a style from individual attributes.
    ///
    /// - Parameters:
    ///   - foreground: The foreground text color.
    ///   - background: The background text color.
    ///   - bold: Whether to render bold text.
    ///   - dim: Whether to render dim text.
    ///   - italic: Whether to render italic text.
    ///   - underline: Whether to render underlined text.
    ///   - strikethrough: Whether to render strikethrough text.
    ///   - inverse: Whether to reverse foreground and background.
    ///   - blink: Whether to emit the ANSI blink attribute.
    public init(
        foreground: Color? = nil,
        background: Color? = nil,
        bold: Bool = false,
        dim: Bool = false,
        italic: Bool = false,
        underline: Bool = false,
        strikethrough: Bool = false,
        inverse: Bool = false,
        blink: Bool = false
    ) {
        self.foreground = foreground
        self.background = background
        self.bold = bold
        self.dim = dim
        self.italic = italic
        self.underline = underline
        self.strikethrough = strikethrough
        self.inverse = inverse
        self.blink = blink
    }

    /// A style with no attributes.
    public static let plain = Style()

    /// A bold style.
    public static let bold = Style(bold: true)

    /// A dim style.
    public static let dim = Style(dim: true)

    /// An italic style.
    public static let italic = Style(italic: true)

    /// An underlined style.
    public static let underline = Style(underline: true)

    /// Creates a style by parsing a Rich-like style description.
    ///
    /// Supported tokens include attributes such as `bold`, `italic`, and
    /// `underline`; named colors such as `red`; true-color values such as
    /// `#ff8800`; and 256-color values such as `color(208)`.
    public init(_ description: String) {
        self = Style.parse(description)
    }

    /// Parses a Rich-like style description into a `Style`.
    ///
    /// Unknown tokens are ignored so callers can accept user-provided style
    /// strings without failing the whole render.
    public static func parse(_ description: String) -> Style {
        var style = Style()
        let tokens = description
            .split(whereSeparator: { $0 == " " || $0 == "," || $0 == ";" })
            .map(String.init)

        for token in tokens {
            let lower = token.lowercased()
            switch lower {
            case "bold", "b":
                style.bold = true
            case "dim":
                style.dim = true
            case "italic", "i":
                style.italic = true
            case "underline", "u":
                style.underline = true
            case "strike", "strikethrough", "s":
                style.strikethrough = true
            case "reverse", "inverse":
                style.inverse = true
            case "blink":
                style.blink = true
            default:
                if lower.hasPrefix("on ") {
                    style.background = Color(styleToken: String(token.dropFirst(3)))
                } else if lower.hasPrefix("on_") || lower.hasPrefix("on-") {
                    style.background = Color(styleToken: String(token.dropFirst(3)))
                } else if let color = Color(styleToken: token) {
                    style.foreground = color
                }
            }
        }
        return style
    }

    /// Returns a style produced by applying another style on top of this one.
    ///
    /// Foreground and background colors from `overlay` replace existing colors.
    /// Boolean attributes are combined with logical OR.
    public func merged(with overlay: Style) -> Style {
        Style(
            foreground: overlay.foreground ?? foreground,
            background: overlay.background ?? background,
            bold: bold || overlay.bold,
            dim: dim || overlay.dim,
            italic: italic || overlay.italic,
            underline: underline || overlay.underline,
            strikethrough: strikethrough || overlay.strikethrough,
            inverse: inverse || overlay.inverse,
            blink: blink || overlay.blink
        )
    }

    func ansiPrefix(enabled: Bool) -> String {
        guard enabled else { return "" }
        var codes: [String] = []
        if bold { codes.append("1") }
        if dim { codes.append("2") }
        if italic { codes.append("3") }
        if underline { codes.append("4") }
        if blink { codes.append("5") }
        if inverse { codes.append("7") }
        if strikethrough { codes.append("9") }
        if let foregroundCode = foreground?.ansiCode() { codes.append(foregroundCode) }
        if let backgroundCode = background?.ansiCode(background: true) { codes.append(backgroundCode) }
        return codes.isEmpty ? "" : "\u{001B}[\(codes.joined(separator: ";"))m"
    }
}

let ansiReset = "\u{001B}[0m"
