#let article(
  title: [Paper title],
  authors: (
        name: ([Author 1], [Author 2],),
        department: [Department of Mathematics],
        organization: [The University of],
        location: [New York],
        email: "abc@univ.edu",
        url: "https://abc.edu",
      ),
  bibstyle: "din-1505-2-alphanumeric.csl",
  bib: none,
  body,
) = {
  let names = authors.map(author => author.name)
  let author-string = if authors.len() == 2 {
    names.join(" and ")
  } else {
    names.join(", ", last: ", and ")
  }

  set document(title: title, author: names)

  set page(
    paper:"us-letter",
    header-ascent: 14pt,
    header: locate(loc => {
      let i = counter(page).at(loc).first()
      if i == 1 { return }
      set text(size: 0.8em)
      grid(
        columns: (6em, 1fr, 6em),
        if calc.even(i) [#i],
        align(center, upper(
          if calc.odd(i) { title } else { author-string }
        )),
        if calc.odd(i) { align(right)[#i] }
      )
    }),
    footer-descent: 12pt,
    footer: locate(loc => {
      let i = counter(page).at(loc).first()
      if i == 1 {
        align(center, text(size: 0.8em, [#i]))
      }
    })
  )

// Configure headings.
  set heading(numbering: "1.")
  show heading: it => {
    set text(weight: 500)
    // Create the heading numbering.
    let number = if it.numbering != none {
      counter(heading).display(it.numbering)
      h(0.7em, weak: true)
    }

    // Level 1 headings are centered and smallcaps.
    // The other ones are run-in.
    if it.level == 1 {
      v(1.15em,weak: true)
      set align(center)
      // smallcaps
      [
        #number
        #it.body
      ]
      v(1.15em,weak: true)
    } else {
      number
      let styled = if it.level == 2 { strong } else { emph }
      styled(it.body + [. ])
      h(0.7em, weak: true)
    }
  }
// // Configure lists and links.
//   set list(indent: 1.5em, body-indent: 1.2em)
//   set enum(indent: 1.5em, body-indent: 1.2em)

  // Configure citation and bibliography styles.
   set bibliography(
    style: bibstyle, 
    title: text(weight: 500, [References])
  )

  // Configure equations.
  // show math.equation: set block(below: 0.75em, above: 0.8em)
  // show math.equation: set text(weight: 400)

  // Display the title and authors.
  align(
    center, 
    upper({
      text(size: 18pt, weight: 700, title)
      v(1.5em, weak: true)
      text(size: 1em, author-string)
    })
  )

  set par(
    first-line-indent: 1.2em, 
    justify: true, 
    leading: 0.58em
  )

  show par: set block(spacing: (1.75*0.58em))

  body

  set par(first-line-indent: 0pt)

 // Display the bibliography, if any is given.

if bib != none {
  set text(size: 10pt)
  bib
}

  // The thing ends with details about the authors.
  // show: pad.with(x: 1.2em)
  
  set text(0.8em)
  
  for author in authors {
    let keys = ("department", "organization", "location")

    let dept-str = keys
      .filter(key => key in author)
      .map(key => author.at(key))
      .join(", ")

    smallcaps(dept-str)
    
    if "email" in author [
      _Email address:_ #link("mailto:" + author.email) \
    ]

    if "url" in author [
      _URL:_ #link(author.url)
    ]
  }
}

