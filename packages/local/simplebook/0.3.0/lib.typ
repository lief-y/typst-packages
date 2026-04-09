// 1. Define document state
#let doc-part = state("doc-part", "frontmatter")

// 2. Built-in Themes Dictionary
#let THEMES = (
  default:  (primary: "C9302C", secondary: "E94845"),
  ocean:    (primary: "005C8A", secondary: "0096C7"),
  forest:   (primary: "2E7D32", secondary: "4CAF50"),
  midnight: (primary: "1A237E", secondary: "3949AB"),
)

#let today = datetime.today()

#let simplebook(
  title: "",
  subtitle: "",
  author: "",
  affiliation: "",
  year: none,
  version: "default",
  date: datetime.today().display(),
  logo: none,
  theme: "default",          
  custom_colors: none,       
  title_font: "",
  main_font: "",
  lhead: "",
  chead: "",
  rhead: "",
  lfoot: "",
  cfoot: "",
  rfoot: "",
  body,
) = {
  set document(author: author, title: title)

  // Resolve Colors
  let active_theme = if custom_colors != none { custom_colors } else { THEMES.at(theme, default: THEMES.default) }

  let primary-color = rgb(active_theme.primary)
  let secondary-color = rgb(active_theme.secondary)

  // Robust Font Fallbacks
  let body-font = if main_font != "" { (main_font,) } else { ("Arial",) }
  let title-font = if title_font != "" { (title_font, "Helvetica") } else { body-font }

  set text(font: body-font, lang: "en", size: 12pt)
  show heading: set text(font: title-font, fill: primary-color)
  show link: set text(fill: primary-color)

  // --- ACADEMIC TYPOGRAPHY SETUP ---
  // Clean up lists and quotes
  set list(indent: 1em, body-indent: 0.5em)
  set enum(indent: 1em, body-indent: 0.5em)
  
  // Math Equation Numbering (Standard for Graduate Texts)
  set math.equation(numbering: "(1.1)")
  
  // Style blockquotes to use the secondary color and an accent line
  show quote.where(block: true): it => {
    v(0.5em)
    pad(left: 1.5em, right: 1.5em)[
      #block(
        stroke: (left: 2pt + secondary-color),
        inset: (left: 1em),
        text(fill: luma(80), style: "italic", it.body)
      )
    ]
    v(0.5em)
  } 

  set heading(bookmarked: true, numbering: "1.1")
  show heading.where(level: 1): set heading(supplement: [Chapter])
  show heading.where(level: 2): set heading(supplement: [Section])

  // --- CHAPTER HEADING FORMATTING ---
  show heading.where(level: 1): it => {
    if it.body == outline.title or it.numbering == none { 
      return it.body 
    } else {
      if it.supplement != none {
        // Formats as: "Chapter 1: Title"
        [#it.supplement #counter(heading).display(it.numbering): #it.body]
      } else { it }
    }
  }

  // Insert metadata, center heading, and add academic breathing room
  show heading.where(level: 1): chap => context {
    metadata("endchap")
    pagebreak(weak: true, to: "odd")
    counter(math.equation).update(0) // Reset equations per chapter
    
    v(10%) // Push chapter titles down slightly for a premium feel
    align(center)[
      #text(size: 1.2em, weight: "black", chap)
      #metadata("startchap")
      // #v(1.5em, weak: true) // Add breathing room after chapter title
    ]
  }

  // --- PART FORMATTING ---
  show figure.where(kind: "part"): it => {
    set page(header: none, footer: none)
    pagebreak(to: "odd", weak: true)
    
    align(center + horizon)[
      #if it.numbering != none {
        text(size: 26pt, fill: primary-color, weight: "bold")[
          #it.supplement #it.counter.display(it.numbering)
        ]
        v(1.5em, weak: true)
      }
      #text(size: 22pt, weight: "bold", fill: primary-color, it.caption.body)
    ]
    pagebreak(to: "odd", weak: true)
  }

  // --- TOC ---
  set outline(
    target: figure.where(kind: "part", outlined: true).or(heading.where(outlined: true)),
    indent: auto, 
  )

  show outline.entry: set outline.entry(fill: repeat[.])

  show outline.entry: it => {
    // 1. Part Custom Intercept
    if it.element.func() == figure and it.element.kind == "part" {
      let part_num = if it.element.numbering != none {
        numbering(it.element.numbering, ..it.element.counter.at(it.element.location()))
      } else {
        none
      }

      v(1.5em, weak: true)
      align(center)[
        #link(it.element.location())[
          #text(size: 14pt, weight: "bold", fill: primary-color)[
            #if part_num != none {
              part_num + [. ]
            }
            #it.element.caption.body
          ]
        ]
      ]
    }
    // 2. Heading Custom Intercept
    else {
      set text(fill: primary-color)
      if it.level == 1 {
        v(1.2em, weak: true)
        strong(it)
      } else {
        it
      }
    }
  }

  // Helper function to detect blank pages before new chapters efficiently
  let is_filler_page() = {
    let prev_ends = query(metadata.where(value: "endchap").before(here()))
    let next_starts = query(metadata.where(value: "startchap").after(here()))
    
    prev_ends.len() > 0 and next_starts.len() > 0 and prev_ends.last().location().page() == here().page() - 1 and next_starts.first().location().page() == here().page() + 1
  }

  // --- ACADEMIC HEADERS & FOOTERS ---
  set page(
    header-ascent: 0%,
    header: context {
      if is_filler_page() { return none }
      if doc-part.get() != "mainmatter" { return none }

      let currentheading = query(metadata.where(value: "startchap")).find(h => h.location().page() == here().page())
      if currentheading != none { return none } 

      set text(font: title-font, fill: primary-color, weight: 700, size: 10pt)
      
      let chaps_before = query(heading.where(level: 1).before(here()))
      let is_even = calc.even(here().page())
      
      if chaps_before.len() > 0 {
        let last_chap = chaps_before.last()
        let secs_before = query(heading.where(level: 2).before(here()))
        let secs_after = query(heading.where(level: 2).after(here()))
        
        let current_sec = if secs_after.len() > 0 and secs_after.first().location().page() == here().page() {
          secs_after.first()
        } else if secs_before.len() > 0 {
          secs_before.last()
        } else { none }

        // Determine Header Content based on Even (Left) vs Odd (Right) page
        let header_content = if is_even {
          // EVEN PAGE: Chapter on the left
          (if lhead == "" [
            #last_chap.supplement #counter(heading).at(last_chap.location()).first() #h(0.5em) #smallcaps(last_chap.body)
          ] else { lhead },
          if rhead == "" {counter(page).display()} else { rhead })
        } else {
          // ODD PAGE: Section on the right
          (if lhead == "" {counter(page).display()} else { lhead },
          if rhead == "" {
            if current_sec != none {
              if current_sec.body == [Exercises] {
                smallcaps[Exercises]
              } else {
                smallcaps[#counter(heading).at(current_sec.location()).map(n => [#n]).join(".") #h(0.5em) #current_sec.body]
              }
            }
          } else { rhead })
        }

        table(
          stroke: none,
          columns: if is_even {(1fr, auto)} else {(auto, 1fr)},
          align: if is_even { left } else { right },
          rows: (1em, auto),
          inset: (x: 0em, bottom: 0.65em),
          ..header_content,
          table.hline(stroke: 1pt + primary-color),
        )
      }
    },
    footer: context {
      if is_filler_page() { return none }
      
      set text(10pt)
      let is_even = calc.even(here().page())
      
      if here().page() < 3 {
        none
      } else if doc-part.get() == "frontmatter" {
        align(center, counter(page).display("i"))
      } else {
        // Page numbers on outside margins
        table(
          stroke: none,
          columns: (1fr, 1fr, 1fr),
          align: (left, center, right),
          if lfoot == "" {
            if is_even { date } else { author }
          } else {
            lfoot
          },
          cfoot,
          if rfoot == "" {
            if not(is_even) { date } else { author }
          } else {
            rfoot
          },
        )
      }
    },
  )

  // Book-standard paragraph styling
  set par(
    justify: true,
    leading: 0.65em, 
    first-line-indent: 1.5em, 
  )
  
  // Prevent indent on the very first paragraph after a heading
  show heading: it => {
    it
    par(text(size: 0pt, "")) 
  }

  // Title page.
  page(numbering: none)[
    #if logo != none {
      set image(width: 6cm)
      place(top + right, logo)
    }
    #v(1fr)
    #align(center, text(font: title-font, fill: primary-color, 3em, weight: 700, title))
    #v(2em, weak: true)
    #align(center, text(font: title-font, fill: secondary-color, 2em, weight: 700, subtitle))

    #v(2em, weak: true)

    #if date != none {
      v(2em, weak: true)
      align(center, text(1.1em, date))
    }

    #v(2fr)

    #align(center)[
      #if author != none { text(author, fill: primary-color, 14pt, weight: "bold") }

      #if affiliation != none { text(font: title-font, fill: secondary-color)[#affiliation] }

      #if version != none and version == "default" {
        v(0.65em)
        text(size: 0.7em)[Version: #datetime.today().display("[year].[month].[day]")]
      } else if version != none {
        v(0.65em)
        text(size: 0.7em)[Version: #version]
      }

      #if year != none {
        v(0.65em)
        text(size: 0.7em)[Year: #year\ ]
      }
    ]
  ]

  show heading.where(body: [Exercises]): set heading(numbering: none)
  show heading.where(body: [Exercises]): it => {
    v(1em, weak: true) // Breathing room before exercises
    set text(14pt, weight: "bold")
    box(width: 20%, inset: (bottom: 0.6em), stroke: (bottom: 5pt + secondary-color), it.body)
    v(0.5em, weak: true) // Breathing room after exercise title
  }
  
  body
}

// --------------------------------------------------------
// GLOBAL HELPER FUNCTIONS
// --------------------------------------------------------

#let frontmatter = [
  #pagebreak(weak: true, to: "odd")
  #doc-part.update("frontmatter")
  #counter(page).update(1)
]

#let mainmatter = [
  #pagebreak(weak: true, to: "odd")
  #doc-part.update("mainmatter")
  #counter(page).update(1)
]

#let backmatter = [
  #pagebreak(weak: true, to: "odd")
  #doc-part.update("backmatter")
]

#let preface(preface_title: "Preface", body) = [
  #counter(page).update(1)
  #heading(numbering: none, outlined: false)[#preface_title]
  #body
]

// --- INTEGRATED: Part Definition ---
#let part(title, numbering: "I") = [
  #figure(
    kind: "part",
    numbering: numbering,
    supplement: "Part",
    caption: title, 
  )[]
]