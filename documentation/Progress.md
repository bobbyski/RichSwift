# Progress.swift

`Progress.swift` contains progress-oriented renderables: `ProgressBar`,
`Spinner`, and `Status`.

## Determinate Progress Bars

Use `ProgressBar` when you know completed and total work:

```swift
let bar = ProgressBar(completed: 42, total: 100)
Console().print(bar)
```

Customize the visual width and styles:

```swift
let bar = ProgressBar(
    completed: 7,
    total: 10,
    width: 24,
    completeStyle: Style("green"),
    remainingStyle: Style("dim")
)
```

The bar clamps its fraction to `0...1`, so values below zero render as 0% and
values above total render as 100%.

## Fraction

Read `fraction` when you need the normalized completion value:

```swift
let fraction = bar.fraction
```

## Spinners

`Spinner` describes the frames for indeterminate progress:

```swift
let dots = Spinner.dots
let line = Spinner.line
let custom = Spinner(frames: [".", "..", "..."], interval: 0.2)
```

`interval` is advisory. The caller decides when to update.

## Status

Create a `Status` from `Console`:

```swift
let status = console.status("Loading", spinner: .dots)
status.update()
status.update("Almost done")
status.stop()
```

`Status` writes the next frame with a carriage return. This works best in an
interactive terminal. Avoid using it when writing to files or non-interactive
logs.

