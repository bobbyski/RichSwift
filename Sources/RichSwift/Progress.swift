import Foundation

public struct ProgressBar: RichRenderable, Sendable {
    public var completed: Double
    public var total: Double
    public var width: Int
    public var completeStyle: Style
    public var remainingStyle: Style

    public init(completed: Double, total: Double, width: Int = 32, completeStyle: Style = Style("green"), remainingStyle: Style = Style("dim")) {
        self.completed = completed
        self.total = max(total, 0.0001)
        self.width = max(1, width)
        self.completeStyle = completeStyle
        self.remainingStyle = remainingStyle
    }

    public var fraction: Double {
        min(1, max(0, completed / total))
    }

    public func render(in context: RenderContext) -> String {
        let filled = Int((fraction * Double(width)).rounded(.down))
        let empty = width - filled
        let bar = Segment(String(repeating: "━", count: filled), style: completeStyle).render(colorEnabled: context.colorEnabled)
            + Segment(String(repeating: "━", count: empty), style: remainingStyle).render(colorEnabled: context.colorEnabled)
        let percentage = Int((fraction * 100).rounded())
        return "\(bar) \(percentage)%"
    }
}

public struct Spinner: Sendable {
    public var frames: [String]
    public var interval: TimeInterval

    public init(frames: [String], interval: TimeInterval = 0.08) {
        self.frames = frames
        self.interval = interval
    }

    public static let dots = Spinner(frames: ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"])
    public static let line = Spinner(frames: ["-", "\\", "|", "/"])
}

public final class Status: @unchecked Sendable {
    private let console: Console
    private let message: String
    private let spinner: Spinner
    private var index = 0

    init(console: Console, message: String, spinner: Spinner) {
        self.console = console
        self.message = message
        self.spinner = spinner
    }

    public func update(_ message: String? = nil) {
        let frame = spinner.frames[index % spinner.frames.count]
        index += 1
        console.print("\r[cyan]\(frame)[/] \(message ?? self.message)", terminator: "", markup: true)
    }

    public func stop(clear: Bool = true) {
        if clear {
            console.print("\r" + String(repeating: " ", count: console.width) + "\r", terminator: "", markup: false)
        }
    }
}

