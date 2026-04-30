# RichSwift.swift

`RichSwift.swift` is the module-level entry point. It does not contain runtime
logic; it exists to provide a central place for module documentation and to make
the package intent clear.

## Purpose

Importing `RichSwift` gives you access to the full public API:

```swift
import RichSwift
```

From there, you can use:

- `Console` for rendering and writing output.
- `Style`, `Color`, and `Markup` for styled terminal text.
- `Table`, `Panel`, `ProgressBar`, `Markdown`, and `Syntax` for Rich-style
  renderables.
- `inspect` and `Traceback` for diagnostic output.

## Recommended First Program

```swift
import RichSwift

let console = Console()
console.print("Hello, [bold magenta]RichSwift[/]!")
```

This uses the default console, parses markup, and writes ANSI-styled text to
standard output.

## Package Usage

Add the library product as a dependency in your SwiftPM target:

```swift
.target(
    name: "YourTool",
    dependencies: ["RichSwift"]
)
```

Then import `RichSwift` from any source file that needs terminal rendering.

## Design Notes

RichSwift is designed around small renderable values. A `Console` does not need
to know about every possible component. It only needs values to conform to
`RichRenderable`, which allows the library to grow through new renderables
without changing the console API.

