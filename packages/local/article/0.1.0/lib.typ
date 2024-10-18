// This template is derived from https://github.com/daskol/typst-templates/blob/main/tmlr/tmlr.typ
#let std-bibliography = bibliography

// We prefer to use CMU Bright variant instead of Computer Modern Bright when
// ever it is possible.

#let font-family = ("Libre Baskerville", "CMU Serif", "Latin Modern Roman", "New Computer Modern",
                    "Serif")
#let font-family-sans = ("Open Sans", "CMU Sans Serif", "Latin Modern Sans",
                         "New Computer Modern Sans", "Sans")

#let math-font = ("STIX Two Math", "TeX Gyre Pagella Math",  "Latin Modern Math", "New Computer Modern Math")

#let font = (
  Large: 17pt,
  footnote: 10pt,
  large: 12pt,
  normal: 10.5pt,
  script: 8pt,
  small: 9pt,
)

#import "@preview/ctheorems:1.1.2": *

#let mythmrules(..args, doc) = thmrules(qed-symbol: $square$, doc) 

#let theorem = thmbox(
  "theorem", 
  text(font: font-family-sans)[Theorem],
  // stroke: rgb("#0500ec") + 1pt,
  // fill: rgb("#00ffa3"),
  inset: 0em
)

#let lemma = thmbox(
  "theorem",
  text(font: font-family-sans)[Lemma],
  // stroke: rgb("#0500ec") + 1pt,
  // fill: rgb("#00ffa3"),
  inset: 0em
)
#let proposition = thmbox(
  "theorem",
  text(font: font-family-sans)[Proposition],
  // stroke: rgb("#0500ec") + 1pt,
  // fill: rgb("#00ffa3")
  inset: 0em
)

#let corollary = thmbox(
  "theorem",
  text(font: font-family-sans)[Corollary],
  // stroke:  rgb("#0500ec") + 1pt,
  inset: 0em
)

#let definition = thmbox(
  "definition", 
  text(font: font-family-sans)[Definition],
  // stroke: rgb("#0500ec") + 1pt,
  inset: 0em,
)

#let example = thmplain(
  "example", 
  text(font: font-family-sans)[Example],
  inset: 0em
).with(numbering: none)

#let proof = thmproof(
  "proof", 
  text(font: font-family-sans)[Proof],
  // stroke: rgb("#8cfc47") + 1pt,
  inset: 0em
)




#let affl-keys = ("department", "institution", "address")

#let make-author(author, affls) = {
  let author-affls = (author.affl, ).flatten()

  let addresses = author-affls.map(key => {
    let affl = affls.at(key)
    return affl-keys
      .map(key => affl.at(key, default: none))
      .filter(it => it != none)
      .join("\n")
  }).map(it => emph(it))

  return block(spacing: 0em, above: 1.2em, {
    set par(justify: true, leading: 0.50em)  // Visually perfect.
    show par: set block(spacing: 0.5em,)
    text(size: font.normal)[*#author.name* #v(0.5em)]
    text(size: font.small)[#addresses.join([\ #v(0.5em)])]
    v(0.5em)
    text(size: font.small)[Email: #link("mailto:" + author.email, underline(author.email))]
  })
}

#let make-contacts(authors, affls) = {
  let contacts = authors.map(it => (make-author(it, affls)))

  return contacts.join([#v(0.5em)])
  // return grid(
  //   columns: (1fr, 1fr),
  //   row-gutter: 2em,
  //   ..cells
  // )
}

  // Render title.
#let make-title(title, authors, date) = {
  set align(center)
    v(-0.03in)  // Visually perfect.
    block(spacing: 0em, {
      set block(spacing: 0em)
      set par(leading: 10pt)  // Empirically found.
      text(font: font-family-sans, size: font.Large, weight: "bold", title)
    })
    v(31pt, weak: true)  // Visually perfect.
    authors.first().map(it => it.name).join(", ", last: ", and")
    v(14.9pt, weak: true)  // Visually perfect.
    if date == none {return} else {date.display("[month repr:short] [day], [year]")}
    v(14.9pt, weak: true)  // Visually perfect.
}

  // Render abstract.
#let make-abstract(abstract) = {
  block(spacing: 0em, width: 100%, {
    set text(size: font.normal)
    set par(leading: 0.51em)  // Original 0.55em (or 0.45em?).

    // While all content is serif, headers and titles are sans serif.
      align(center,
        text(
          font: font-family-sans,
          size: font.large,
          weight: "bold",
          [*Abstract*]))
      v(22.2pt, weak: true)
      pad(left: 0.5in, right: 0.5in, abstract)
    })

  v(29.5pt, weak: true)  // Visually perfect.
}


#let affls = (
  qcc: (
    department: "Department of Mathematics and Computer Science",
    institution: "Queensborough Community College of CUNY",
    address: [222-05 56th Ave., Bayside, NY, 11364]
  ),
  gc: (department: "Department of Mathematics",
    institution: "The CUNY Graduate Center",
    address: [365 Fifth Avenue, New York, NY 10016]
  ),
)

#let authors = (
  (
    name: "Fei Ye", 
    email: "feye@qcc.cuny.edu", 
    affl: ("qcc", "gc")
  ),
)

#let authorInfo = (authors, affls)

#let article(
  title: [],
  authors: authorInfo,
  keywords: (),
  MRC: (),
  date: datetime.today(),
  abstract: none,
  bibliography: none,
  body,
) = {
  // Prepare authors for PDF metadata.
  let author = authors.first().map(it => it.name)

  set document(
    title: title,
    author: author,
    keywords: keywords,
    date: date)

  set page(
    paper: "us-letter",
    margin: (x: 1in, top: 1.18in, bottom: 11in - (1.18in + 9in)),
    header-ascent: 46pt,  // 1.5em in case of 10pt
    footer-descent: 20pt, // Visually perfect.
    footer: align(center, text(size: font.normal, counter(page).display("1 / 1", both:true)))
  )

  set text(font: font-family, size: font.normal)
  show math.equation: set text(font: math-font)
  
  set par(justify: true, leading: 0.52em)  // TODO: Why? Visually perfect.
  show par: set block(spacing: 1.1em)

  // Configure heading appearence and numbering.
  set heading(numbering: "1.1"+".")
  show heading: set text(font: font-family-sans)

  // Configure code blocks (listings).
  show raw: set block(spacing: 1.95em)

  // Configure footnote (almost default).
  show footnote.entry: set text(size: 8pt)
  set footnote.entry(
    separator: line(length: 2in, stroke: 0.35pt),
    clearance: 6.65pt,
    gap: 0.40em,
    indent: 12pt)  // Original 12pt.

  // All captions either centered or aligned to the left.
  // show figure.caption: set align(left)

  // Configure figures.
  show figure.where(kind: image): set figure.caption(position: bottom)
  set figure(gap: 16pt)

  // Configure tables.
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(gap: 6pt)
  set table(inset: 4pt)

  // Configure numbered lists.
  set enum(indent: 2.4em, spacing: 1.3em)
  show enum: set block(above: 2em)

  // Configure bullet lists.
  set list(indent: 2.4em, spacing: 1.3em, marker: ([•], [‣], [⁃]))
  show list: set block(above: 2em)

  // Configure math numbering and referencing.
  set math.equation(numbering: "(1)", supplement: [])
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      let numb = numbering(
        "1",
        ..counter(eq).at(el.location())
      )
      let color = rgb(0%, 8%, 45%)  // Originally `mydarkblue`. :D
      let content = link(el.location(), text(fill: color, numb))
      [(#content)]
    } else {
      it
    }
  }

  // Render title + authors + abstract.
  make-title(title, authors, date)
  
  
  
  if abstract != none {
    make-abstract(abstract)
  }

  show: mythmrules
  let url(uri) = {
    link(uri, raw(uri))
  }

  set cite(style: "alphanumeric")

  // Render body as is.
  body

  if bibliography != none {
    set std-bibliography(title: [References])
    bibliography
  }
  make-contacts(..authors)
}
