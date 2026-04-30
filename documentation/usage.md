# RichSwift Usage Guide

This directory contains feature-focused documentation for the Swift source files
in `Sources/RichSwift`. Start with `Console.md` for day-to-day output, then use
the renderable-specific guides as needed.

## Table Of Contents

| Swift file | Documentation | What it covers |
| --- | --- | --- |
| `ANSI.swift` | [ANSI.md](ANSI.md) | Colors, style parsing, ANSI attributes, and color modes |
| `Console.swift` | [Console.md](Console.md) | Printing, rendering, rules, logging, status output, and capture |
| `Markdown.swift` | [Markdown.md](Markdown.md) | Terminal rendering for headings, lists, quotes, code, and inline Markdown |
| `Markup.swift` | [Markup.md](Markup.md) | Rich-style `[bold red]...[/]` markup and `Text` renderables |
| `Panel.swift` | [Panel.md](Panel.md) | Framed content, titles, subtitles, padding, and wrapping |
| `Pretty.swift` | [Pretty.md](Pretty.md) | Value inspection and traceback-style error displays |
| `Progress.swift` | [Progress.md](Progress.md) | Determinate progress bars and indeterminate status spinners |
| `Renderable.swift` | [Renderable.md](Renderable.md) | `RichRenderable`, render contexts, segments, alignment, and layout helpers |
| `RichSwift.swift` | [RichSwift.md](RichSwift.md) | Module overview and recommended import patterns |
| `Syntax.swift` | [Syntax.md](Syntax.md) | Lightweight code highlighting, themes, and line numbers |
| `Table.swift` | [Table.md](Table.md) | Tables, columns, rows, alignment, and border styles |

## Suggested Reading Order

1. [RichSwift.md](RichSwift.md) for the big picture.
2. [Console.md](Console.md) for how output flows through the library.
3. [Markup.md](Markup.md) and [ANSI.md](ANSI.md) for styling text.
4. [Table.md](Table.md), [Panel.md](Panel.md), and [Progress.md](Progress.md)
   for common terminal UI components.
5. [Markdown.md](Markdown.md), [Syntax.md](Syntax.md), and [Pretty.md](Pretty.md)
   for richer content rendering.
6. [Renderable.md](Renderable.md) when adding your own custom renderables.

