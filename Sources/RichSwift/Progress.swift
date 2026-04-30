import Foundation

/// A determinate progress bar renderable.
public struct ProgressBar: RichRenderable, Sendable {
    /// Amount of work completed.
    public var completed: Double

    /// Total amount of work.
    public var total: Double

    /// Width of the bar portion, excluding the percentage text.
    public var width: Int

    /// Style applied to the completed portion.
    public var completeStyle: Style

    /// Style applied to the remaining portion.
    public var remainingStyle: Style

    /// Creates a progress bar.
    public init(completed: Double, total: Double, width: Int = 32, completeStyle: Style = Style("green"), remainingStyle: Style = Style("dim")) {
        self.completed = completed
        self.total = max(total, 0.0001)
        self.width = max(1, width)
        self.completeStyle = completeStyle
        self.remainingStyle = remainingStyle
    }

    /// Completion fraction clamped to `0...1`.
    public var fraction: Double {
        min(1, max(0, completed / total))
    }

    /// Renders the bar and percentage text.
    public func render(in context: RenderContext) -> String {
        let filled = Int((fraction * Double(width)).rounded(.down))
        let empty = width - filled
        let bar = Segment(String(repeating: "━", count: filled), style: completeStyle).render(colorEnabled: context.colorEnabled)
            + Segment(String(repeating: "━", count: empty), style: remainingStyle).render(colorEnabled: context.colorEnabled)
        let percentage = Int((fraction * 100).rounded())
        return "\(bar) \(percentage)%"
    }
}

/// A sequence of frames used for indeterminate status output.
public struct Spinner: Sendable {
    /// Frames shown by repeated `Status.update` calls.
    public var frames: [String]

    /// Suggested interval between frames.
    public var interval: TimeInterval

    /// Creates a spinner.
    public init(frames: [String], interval: TimeInterval = 0.08) {
        self.frames = frames
        self.interval = interval
    }

    /// Braille dot spinner frames.
    public static let dots = Spinner(frames: ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"])

    /// ASCII line spinner frames.
    public static let line = Spinner(frames: ["-", "\\", "|", "/"])
}

/// Lightweight state object for redrawing an indeterminate console status.
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

    /// Writes the next spinner frame.
    ///
    /// - Parameter message: Optional replacement message for this update.
    public func update(_ message: String? = nil) {
        let frame = spinner.frames[index % spinner.frames.count]
        index += 1
        console.print("\r[cyan]\(frame)[/] \(message ?? self.message)", terminator: "", markup: true)
    }

    /// Stops the status display.
    ///
    /// - Parameter clear: Whether to clear the current terminal line.
    public func stop(clear: Bool = true) {
        if clear {
            console.print("\r" + String(repeating: " ", count: console.width) + "\r", terminator: "", markup: false)
        }
    }
}
