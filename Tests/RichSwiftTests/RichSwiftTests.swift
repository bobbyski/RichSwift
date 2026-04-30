import Testing
@testable import RichSwift

@Test func markupRendersANSIAndPlainText() {
    let colored = Markup.render("Hello [bold red]World[/]", colorEnabled: true)
    #expect(colored.contains("\u{001B}[1;31mWorld\u{001B}[0m"))

    let plain = Markup.render("Hello [bold red]World[/]", colorEnabled: false)
    #expect(plain == "Hello World")
}

@Test func consoleCanCaptureOutputWithoutColors() {
    let output = Console.capture { console in
        console.print("Hello [green]Swift[/]")
    }

    #expect(output == "Hello Swift\n")
}

@Test func tableRendersRowsAndHeaders() {
    var table = Table(title: "Packages")
    table.addColumn("Name")
    table.addColumn("Status", alignment: .right)
    table.addRow("RichSwift", "[green]ready[/]")

    let output = table.render(in: RenderContext(width: 80, colorMode: .disabled))

    #expect(output.contains("Packages"))
    #expect(output.contains("RichSwift"))
    #expect(output.contains("ready"))
}

@Test func panelWrapsRenderable() {
    let panel = Panel("Hello from a deliberately long line that should wrap cleanly", title: "Greeting")
    let output = panel.render(in: RenderContext(width: 32, colorMode: .disabled))

    #expect(output.contains("Greeting"))
    #expect(output.contains("Hello"))
    #expect(output.contains("╭"))
    #expect(output.split(separator: "\n").allSatisfy { displayWidth(String($0)) <= 32 })
}

@Test func progressBarShowsPercentage() {
    let bar = ProgressBar(completed: 3, total: 4, width: 8)
    let output = bar.render(in: RenderContext(colorMode: .disabled))

    #expect(output.contains("75%"))
    #expect(stripANSI(output).contains("━━━━━━━━"))
}

@Test func syntaxAddsLineNumbers() {
    let syntax = Syntax("let answer = 42", language: "swift", lineNumbers: true)
    let output = syntax.render(in: RenderContext(colorMode: .disabled))

    #expect(output.contains("1 │ let answer = 42"))
}
