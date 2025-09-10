#import "parts_and_outline.typ": *

#let simplebook(
  title: "",
  subtitle: "",
  author: "",
  affiliation: "",
  year: none,
  version: none,
  date: datetime.today().display(),
  logo: none,
  theme_colors: (
    primary_color: "E94845",
    secondary_color: "FF5045",
  ),
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

  // Save heading and body font families in variables.
  let body-font = main_font
  let title-font = if title_font != "" { title_font } else { main_font }

  // Set colors
  let primary-color = rgb(theme_colors.primary_color)
  let secondary-color = rgb(theme_colors.secondary_color)

  // Set body font family.
  set text(font: body-font, lang: "en", 12pt)
  show heading: set text(font: title-font, fill: primary-color)

  // Set link style
  // show link: it => underline(text(fill: primary-color, it))

  // Set heading number style
  set heading(
    bookmarked: true,
    numbering: " 1.1",
  )

  show heading.where(level: 1): it => {
    if it.body == outline.title or it.numbering == none { 
      return it.body } else {
        if it.supplement != none {
          [#it.supplement#counter(heading).display(it.numbering) #it.body]
        } else {it}
    }
  }
  //insert metadata and center heading
  show heading.where(level: 1): chap => context {
    metadata("endchap")
    pagebreak(weak: true, to: "odd")
    align(center)[
      #chap
      #metadata("startchap")
      #v(0.5em)
    ]
  }

  // Set page header and footer.
  set page(
    header-ascent: 0%,
    header: context {
      set text(font: title-font, fill: primary-color, weight: 700, size: 10pt)
      
      let EndChapQuery = query(
        metadata.where(value: "endchap").before(here()),
      ).find(m => m.location().page() == here().page() - 1)

      let StartChapQuery = query(
        metadata.where(value: "startchap").after(here()),
      ).find(m => m.location().page() == here().page() + 1)
      
      let chapter_before = query(
        selector(heading.where(level: 1)).before(here()),
      )
      
      let chapter_after = query(
        selector(heading.where(level: 1)).after(here()),
      )

      let currentheading = query(
        metadata.where(value: "startchap"),
      ).find(h => h.location().page() == here().page())

      let pagenum_mainmatter = query(
        metadata.where(value: "mainmatter"),
      ).first().location().page()

      let SectionsBefore = query(
        selector(heading.where(level: 2)).before(here())
      )

      let SectionsAfter = query(
        selector(heading.where(level: 2)).after(here())
      )

      let PreviousSection = none
      if SectionsBefore.len() > 0 { PreviousSection = SectionsBefore.last() }
    
      let NextSection = none
      if SectionsAfter.len() > 0 { NextSection = SectionsAfter.first() }

      let CurrentSection = {
        if NextSection != none and here().page() == NextSection.location().page() {
          NextSection
        } else if PreviousSection != none {
          PreviousSection
        } else {
          none
        }
      }

      if EndChapQuery != none and StartChapQuery != none {
        return none
      } else if (
        chapter_before.len() > 0 and chapter_before.last().location().page() >= pagenum_mainmatter and currentheading == none
      ) {
        table(
          stroke: none,
          columns: (auto, 1fr, auto),
          align: (left, center, right),
          rows: (1em, auto),
          inset: (x: 0em, bottom: 0.65em),
          if lhead == "" {
            [
              #chapter_before.last().supplement
              // #h(0.25em)
              #counter(heading).get().first()
              #h(0.25em)
              #smallcaps(chapter_before.last().body)
            ]
          } else {
            lhead
          },
          chead,
          if rhead == "" {
            if CurrentSection.body == [Exercises] {
              [Exercises]
            } else {
              counter(heading).at(CurrentSection.location()).map(n => [#n]).join(".") + h(0.25em) + CurrentSection.body
            }
          } else {
            rhead
          },
          table.hline(stroke: 1pt + primary-color),
        )
      }
    },
    footer: context {
      set text(10pt)
      let EndChapQuery = query(
        metadata.where(value: "endchap").before(here()),
      ).find(m => m.location().page() == here().page() - 1)

      let StartChapQuery = query(
        metadata.where(value: "startchap").after(here()),
      ).find(m => m.location().page() == here().page() + 1)
      
      let pagenum_mainmatter = query(
        metadata.where(value: "mainmatter"),
      ).first().location().page()
      
      if EndChapQuery != none and StartChapQuery != none {
        none
      } else {
        if here().page() < 3 {
          none
        } else if here().page() < pagenum_mainmatter {
          align(center, counter(page).display("i"))
        } else {
          table(
            stroke: none,
            columns: (1fr, 1fr, 1fr),
            align: (left, center, right),
            lfoot,
            if cfoot == "" {
              counter(page).display("1 / 1", both: true)
            } else {
              cfoot
            },
            rfoot,
          )
        }
      }
    },
  )

  set par(justify: true)

  // Title page.
  page(numbering: none)[
    #if logo != none {
      set image(width: 6cm)
      place(top + right, logo)
    }

    #v(2fr)

    #align(
      center,
      text(font: title-font, fill: primary-color, 3em, weight: 700, title),
    )

    #v(2em, weak: true)

    #align(
      center,
      text(font: title-font, fill: secondary-color, 2em, weight: 700, subtitle),
    )

    #if date != none {
      v(2em, weak: true)
      align(center, text(1.1em, date))
    }

    #v(2fr)

    #align(center)[
      #if author != none {
        text(author, fill: primary-color, 14pt, weight: "bold")
      }

      #if affiliation != none {
        text(font: title-font, fill: secondary-color)[#affiliation]
      }

      #if version != none {
        v(0.65em)
        text(size: 0.7em)[Version: #version]
      }

      #if year != none {
        v(0.65em)
        text(size: 0.7em)[Year: #year\ ]
      }
    ]
  ]

  // Format Exercises Heading
  show heading.where(body: [Exercises]): set heading(numbering: none)

  show heading.where(body: [Exercises]): it => {
    set text(14pt, weight: "bold")
    box(width: 20%, inset: (bottom: 0.6em), stroke: (bottom: 5pt + blue), it.body)
  }
  // body includes frontmatter, such as preface and toc, and mainmatter such as main body, bibliography and appendixes.
  body
}

// #let blankpage = page(numbering: none, header: none)[]

#let frontmatter = {
  pagebreak(weak: true, to: "odd")
  metadata("frontmatter")
  counter(page).update(1)
}

#let mainmatter = {
  pagebreak(weak: true, to: "odd")
  metadata("mainmatter")
  counter(page).update(1)
}

#let preface(preface_title: "Preface", body) = {
  counter(page).update(1)
  heading(numbering: none, outlined: false)[#preface_title]
  page(numbering: none)[
    #body
  ]
}
