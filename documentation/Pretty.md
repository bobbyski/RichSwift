# Pretty.swift

`Pretty.swift` contains diagnostic helpers inspired by Rich's inspection and
traceback features.

## Inspect Values

Use `inspect` to render a reflected view of a Swift value:

```swift
struct Build {
    var target: String
    var passed: Bool
}

let build = Build(target: "RichSwift", passed: true)
Console().print(inspect(build))
```

The output is a `Panel` containing a table of reflected child properties.

## Custom Titles

```swift
Console().print(inspect(build, title: "Current Build"))
```

The title appears on the inner table. The outer panel is titled `Inspect`.

## Scalar Values

Values without reflected children render as a single `value` row:

```swift
Console().print(inspect(42))
```

## Traceback

Use `Traceback` to format an error with call-site context:

```swift
do {
    try riskyOperation()
} catch {
    Console().print(Traceback(error))
}
```

By default, `Traceback` captures:

- The error description.
- The source file.
- The source line.
- The function name.

You can override those values when adapting errors from another system:

```swift
let traceback = Traceback(error, file: "main.swift", line: 42, function: "run()")
```

## Scope

These helpers are intentionally compact. They are designed for CLI diagnostics,
debug output, and examples rather than complete debugger-level inspection.

