import Foundation

public struct TableColumn: Sendable {
    public var title: String
    public var style: Style
    public var alignment: Alignment

    public init(_ title: String, style: Style = Style("bold"), alignment: Alignment = .left) {
        self.title = title
        self.style = style
        self.alignment = alignment
    }
}

public struct Table: RichRenderable, Sendable {
    public var title: String?
    public var columns: [TableColumn]
    public var rows: [[String]]
    public var showHeader: Bool
    public var box: Box

    public init(title: String? = nil, columns: [TableColumn] = [], rows: [[String]] = [], showHeader: Bool = true, box: Box = .rounded) {
        self.title = title
        self.columns = columns
        self.rows = rows
        self.showHeader = showHeader
        self.box = box
    }

    public mutating func addColumn(_ title: String, style: Style = Style("bold"), alignment: Alignment = .left) {
        columns.append(TableColumn(title, style: style, alignment: alignment))
    }

    public mutating func addRow(_ cells: String...) {
        rows.append(cells)
    }

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

public struct Box: Sendable {
    public var topLeft: Character
    public var topRight: Character
    public var bottomLeft: Character
    public var bottomRight: Character
    public var horizontal: Character
    public var vertical: Character
    public var topJoint: Character
    public var bottomJoint: Character
    public var leftJoint: Character
    public var rightJoint: Character
    public var cross: Character

    public static let rounded = Box(
        topLeft: "╭", topRight: "╮", bottomLeft: "╰", bottomRight: "╯",
        horizontal: "─", vertical: "│", topJoint: "┬", bottomJoint: "┴",
        leftJoint: "├", rightJoint: "┤", cross: "┼"
    )

    public static let square = Box(
        topLeft: "┌", topRight: "┐", bottomLeft: "└", bottomRight: "┘",
        horizontal: "─", vertical: "│", topJoint: "┬", bottomJoint: "┴",
        leftJoint: "├", rightJoint: "┤", cross: "┼"
    )

    public static let ascii = Box(
        topLeft: "+", topRight: "+", bottomLeft: "+", bottomRight: "+",
        horizontal: "-", vertical: "|", topJoint: "+", bottomJoint: "+",
        leftJoint: "+", rightJoint: "+", cross: "+"
    )
}

