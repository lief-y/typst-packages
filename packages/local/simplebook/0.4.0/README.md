# Simplebook

A beautiful, academic-style book template for [Typst](https://typst.app) with full **PDF** and **HTML** export support.

## Features

- **Dual-target output** — Compile to PDF (`typst compile`) or HTML (`typst compile --format html`) from the same source
- **4 built-in color themes** — `default`, `ocean`, `forest`, `midnight`, plus custom colors
- **Academic typography** — Justified text, first-line indent, chapter/section numbering, equation numbering per chapter
- **Rich front/back matter** — Title page, preface, parts, table of contents, exercises
- **Running headers & footers** (PDF) — Chapter/section headers with page numbers on outside margins
- **Semantic HTML output** — Uses proper HTML elements (`<h1>`–`<h6>`, `<blockquote>`, `<section>`, etc.) with inline CSS styling
- **Part divisions** — Render book parts with "Part I", "Part II", etc.
- **Exercises section** — Specially styled headings for exercise sections

## Installation

This is a local Typst package. Place it in your Typst packages directory:

```
{data-dir}/typst/packages/local/simplebook/0.4.0/
```

## Usage

```typst
#import "@local/simplebook:0.4.0": *

#show: simplebook.with(
  title: "My Book Title",
  subtitle: "A Fascinating Journey",
  author: "Jane Doe",
  affiliation: "University of Knowledge",
  theme: "ocean",
)

#frontmatter
#outline()
#preface[Your preface content here...]

#mainmatter
= Introduction
Welcome to this book...

#part("Foundations")
= First Chapter
Content of the first chapter...

== A Section
Section content...

== Exercises

#backmatter
= Appendix
Extra material...
```

### Compilation

```bash
# Compile to PDF
typst compile book.typ

# Compile to HTML
typst compile --format html book.typ book.html

# Watch mode (hot reload)
typst watch book.typ
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `title` | `str` | `""` | Book title (shown on title page) |
| `subtitle` | `str` | `""` | Book subtitle |
| `author` | `str` | `""` | Author name |
| `affiliation` | `str` | `""` | Affiliation / institution |
| `year` | `none` / `str` | `none` | Publication year |
| `version` | `str` | `"default"` | Version string (`"default"` shows auto-generated date) |
| `date` | `str` | today's date | Display date on title page and footer |
| `logo` | `none` / `content` | `none` | Logo image on title page |
| `theme` | `str` | `"default"` | Color theme: `"default"`, `"ocean"`, `"forest"`, `"midnight"` |
| `custom_colors` | `none` / `dict` | `none` | Custom colors as `(primary: "HEX", secondary: "HEX")` |
| `title_font` | `str` | `""` | Font for headings (falls back to `main_font`) |
| `main_font` | `str` | `""` | Font for body text (defaults to Arial) |
| `lhead` / `chead` / `rhead` | `str` | `""` | Custom left/center/right header text (PDF only) |
| `lfoot` / `cfoot` / `rfoot` | `str` | `""` | Custom left/center/right footer text (PDF only) |

### Helper Functions

| Function | Description |
|----------|-------------|
| `frontmatter` | Begins front matter (roman page numbers in PDF) |
| `mainmatter` | Begins main content (arabic page numbers in PDF) |
| `backmatter` | Begins back matter |
| `preface(title, body)` | Renders a preface chapter |
| `part(title, numbering)` | Renders a book part divider |

## How HTML Export Works

This template uses Typst's built-in `target()` function to detect the output format and applies different styling rules:

- **PDF (paged)**: Full academic layout with page headers, footers, page breaks, and print-optimized typography
- **HTML**: Semantic HTML elements with inline CSS, a hero-style title section, gradient part banners, and responsive layout

All content (chapters, sections, equations, figures, etc.) is written once and renders correctly in both formats.

### PDF vs HTML differences

| Feature | PDF | HTML |
|---------|-----|------|
| Page headers/footers | ✓ | — |
| Page breaks | ✓ | — |
| Title page | Full dedicated page | Hero section with CSS |
| Part dividers | Full blank-page spreads | Gradient banners |
| Blockquotes | Left-accent border | `<blockquote>` with CSS border |
| Chapter headings | Centered, offset from top | Centered with `<hr>` divider |
| Exercises | Underlined box | CSS-bordered inline heading |

## Themes

| Theme | Primary | Secondary | Preview |
|-------|---------|-----------|---------|
| `default` | `#C9302C` | `#E94845` | Classic red |
| `ocean` | `#005C8A` | `#0096C7` | Blue tones |
| `forest` | `#2E7D32` | `#4CAF50` | Green palette |
| `midnight` | `#1A237E` | `#3949AB` | Deep indigo |

Use `custom_colors` to define your own:

```typst
#show: simplebook.with(
  custom_colors: (primary: "6A1B9A", secondary: "AB47BC"),
)
```

## Requirements

- Typst **0.12.0** or later (for `html.elem()` and related HTML export features)

## License

MIT
