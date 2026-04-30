import Foundation

/// Metadata describing a single table column.
public struct TableColumn: Sendable {
    /// The header text shown for the column.
    public var title: String

    /// The style applied to the header.
    public var style: Style

    /// The horizontal alignment used for cells in this column.
    public var alignment: Alignment

    /// Creates a table column.
    public init(_ title: String, style: Style = Style("bold"), alignment: Alignment = .left) {
        self.title = title
        self.style = style
        self.alignment = alignment
    }
}

/// A Rich-style terminal table with optional title, header, rows, and box art.
public struct Table: RichRenderable, Sendable {
    /// The optional title centered above the table.
    public var title: String?

    /// The columns that define table shape and alignment.
    public var columns: [TableColumn]

    /// Row data. Missing cells are rendered as empty strings.
    public var rows: [[String]]

    /// Whether to render the header row.
    public var showHeader: Bool

    /// The box drawing style used for borders.
    public var box: Box

    /// Creates a table.
    ///
    /// - Parameters:
    ///   - title: Optional title centered above the table.
    ///   - columns: Initial column definitions.
    ///   - rows: Initial rows.
    ///   - showHeader: Whether column headers should be rendered.
    ///   - box: Border characters to use.
    public init(title: String? = nil, columns: [TableColumn] = [], rows: [[String]] = [], showHeader: Bool = true, box: Box = .rounded) {
        self.title = title
        self.columns = columns
        self.rows = rows
        self.showHeader = showHeader
        self.box = box
    }

    /// Appends a column to the table.
    public mutating func addColumn(_ title: String, style: Style = Style("bold"), alignment: Alignment = .left) {
        columns.append(TableColumn(title, style: style, alignment: alignment))
    }

    /// Appends a row to the table.
    ///
    /// Cells may contain Rich-style markup.
    public mutating func addRow(_ cells: String...) {
        rows.append(cells)
    }

    /// Renders the table into bordered terminal text.
    public func render(in context: RenderContext) -> String {
        guard !columns.isEmpty else { return "" }
        let colorEnabled = context.colorEnabled
        let columnCount = columns.count
        let normalizedRows = rows.map { row in
            row + Array(repeating: "", count: max(0, columnCount - row.count))
        }
        var widths = columns.map { displayWidth(stripANSI(Markup.render($0.title, style: $0.style, colorEnabled: false))) }
        for row in normalizedRows {
            for index in 0..<columnCount {
                widths[index] = max(widths[index], displayWidth(stripANSI(row[index])))
            }
        }
        let maxTableWidth = max(columnCount * 3 + columnCount + 1, context.width)
        let fixedOverhead = 1 + columnCount * 2 + (columnCount - 1) + 1
        let available = max(columnCount, maxTableWidth - fixedOverhead)
        let total = widths.reduce(0, +)
        if total > available {
            widths = widths.map { max(4, Int(Double($0) / Double(total) * Double(available))) }
        }

        var lines: [String] = []
        if let title {
            let contentWidth = widths.reduce(0, +) + (columnCount - 1) * 3
            lines.append(pad(Markup.render(title, style: Style("bold"), colorEnabled: colorEnabled), to: contentWidth, alignment: .center))
        }

        lines.append(border(left: box.topLeft, joint: box.topJoint, right: box.topRight, widths: widths))
        if showHeader {
            let header = zip(columns, widths).map { column, width in
                pad(Markup.render(column.title, style: column.style, colorEnabled: colorEnabled), to: width, alignment: column.alignment)
            }.joined(separator: " \(box.vertical) ")
            lines.append("\(box.vertical) \(header) \(box.vertical)")
            lines.append(border(left: box.leftJoint, joint: box.cross, right: box.rightJoint, widths: widths))
        }

        for row in normalizedRows {
            let wrappedCells = row.enumerated().map { index, cell in
                wrapPlain(stripANSI(cell), width: widths[index])
            }
            let height = wrappedCells.map(\.count).max() ?? 1
            for lineIndex in 0..<height {
                let cells = (0..<columnCount).map { index in
                    let value = lineIndex < wrappedCells[index].count ? wrappedCells[index][lineIndex] : ""
                    return pad(Markup.render(value, colorEnabled: colorEnabled), to: widths[index], alignment: columns[index].alignment)
                }.joined(separator: " \(box.vertical) ")
                lines.append("\(box.vertical) \(cells) \(box.vertical)")
            }
        }

        lines.append(border(left: box.bottomLeft, joint: box.bottomJoint, right: box.bottomRight, widths: widths))
        return lines.joined(separator: "\n")
    }

    private func border(left: Character, joint: Character, right: Character, widths: [Int]) -> String {
        String(left) + widths.map { String(repeating: String(box.horizontal), count: $0 + 2) }.joined(separator: String(joint)) + String(right)
    }
}

/// Box drawing characters used by table and panel renderers.
public struct Box: Sendable {
    /// Top-left corner character.
    public var topLeft: Character

    /// Top-right corner character.
    public var topRight: Character

    /// Bottom-left corner character.
    public var bottomLeft: Character

    /// Bottom-right corner character.
    public var bottomRight: Character

    /// Horizontal border character.
    public var horizontal: Character

    /// Vertical border character.
    public var vertical: Character

    /// Joint used along the top border between columns.
    public var topJoint: Character

    /// Joint used along the bottom border between columns.
    public var bottomJoint: Character

    /// Joint used on the left edge for header separators.
    public var leftJoint: Character

    /// Joint used on the right edge for header separators.
    public var rightJoint: Character

    /// Joint used where horizontal and vertical rules cross.
    public var cross: Character

    /// Rounded Unicode borders.
    public static let rounded = Box(
        topLeft: "╭", topRight: "╮", bottomLeft: "╰", bottomRight: "╯",
        horizontal: "─", vertical: "│", topJoint: "┬", bottomJoint: "┴",
        leftJoint: "├", rightJoint: "┤", cross: "┼"
    )

    /// Square Unicode borders.
    public static let square = Box(
        topLeft: "┌", topRight: "┐", bottomLeft: "└", bottomRight: "┘",
        horizontal: "─", vertical: "│", topJoint: "┬", bottomJoint: "┴",
        leftJoint: "├", rightJoint: "┤", cross: "┼"
    )

    /// ASCII-only borders for terminals without Unicode box drawing support.
    public static let ascii = Box(
        topLeft: "+", topRight: "+", bottomLeft: "+", bottomRight: "+",
        horizontal: "-", vertical: "|", topJoint: "+", bottomJoint: "+",
        leftJoint: "+", rightJoint: "+", cross: "+"
    )
}
