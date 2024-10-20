// This template is derived from https://github.com/daskol/typst-templates/blob/main/tmlr/tmlr.typ

#let std-bibliography = bibliography

// Font settings

#let title-font = state("fonts", ("Noto Serif", "New Computer Modern"))
#let body-font = state("fonts",("Noto Sans", "New Computer Modern Sans"))
#let math-font = state("font", ("STIX Two Math", "New Computer Modern Math"))

#let font = (
  Large: 17pt,
  footnote: 10pt,
  large: 12pt,
  normal: 10.5pt,
  script: 8pt,
  small: 9pt,
)

// Import theorem styles
#import "theorems.typ": *

#let mythmrules(..args, doc) = thmrules(qed-symbol: $square$, doc) 

#let thmstyle = (
  namefmt: x => context {text(font: title-font.get(), [(#x)])},   
  titlefmt: x => context {text(font: title-font.get(), strong(x))},
  inset: 0em,
)

// Define theorem environments
#let theorem = thmbox("theorem", "Theorem", ..thmstyle)
#let lemma = thmbox("theorem", [Lemma], ..thmstyle)
#let proposition = thmbox("theorem", [Proposition], ..thmstyle)
#let corollary = thmbox("theorem", [Corollary], ..thmstyle)
#let remark = thmbox("remark", [Remark], ..thmstyle)
#let definition = thmbox("definition", [Definition], ..thmstyle)
#let example = thmplain("example", [Example], ..thmstyle)
#let proof = thmproof("proof", [Proof], ..thmstyle)

// Author and affiliation settings
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
    set par(justify: true, leading: 0.50em, spacing: 0.5em)
    text(size: font.normal)[*#author.name* #v(0.5em)]
    text(size: font.small)[#addresses.join([\ #v(0.5em)])]
    v(0.5em)
    text(size: font.small)[Email: #link("mailto:" + author.email, underline(author.email))]
  })
}

#let make-contacts(authors, affls) = {
  let contacts = authors.map(it => (make-author(it, affls)))
  return contacts.join([#v(0.5em)])
}

// Render title
#let make-title(title, authors, date) = context {
  set text(font: title-font.get(), weight: "regular")
  set align(center)
  v(-0.03in)
  block(spacing: 0em, {
    set block(spacing: 0em)
    set par(leading: 10pt)
    text(size: font.Large, weight: "bold", title)
  })
  v(31pt, weak: true)
  authors.first().map(it => it.name).join(", ", last: ", and")
  v(14.9pt, weak: true)
  if date == none {return} else {date.display("[month repr:short] [day], [year]")}
  v(14.9pt, weak: true)
}

// Render abstract
#let make-abstract(abstract) = context {
  block(spacing: 0em, width: 100%, {
    set text(size: font.normal)
    set par(leading: 0.51em)
    align(center, text(font: title-font.get(), size: font.large, weight: "bold", [*Abstract*]))
    v(22.2pt, weak: true)
    pad(left: 0.5in, right: 0.5in, abstract)
  })
  v(29.5pt, weak: true)
}

// Affiliation details
#let affls = (
  qcc: (
    department: "Department of Mathematics and Computer Science",
    institution: "Queensborough Community College of CUNY",
    address: [222-05 56th Ave., Bayside, NY, 11364]
  ),
  gc: (
    department: "Department of Mathematics",
    institution: "The CUNY Graduate Center",
    address: [365 Fifth Avenue, New York, NY 10016]
  ),
)

// Author details
#let authors = (
  (
    name: "Fei Ye", 
    email: "feye@qcc.cuny.edu", 
    affl: ("qcc", "gc")
  ),
)

#let authorInfo = (authors, affls)

// Main article structure
#let article(
  title: [],
  authors: authorInfo,
  keywords: (),
  MRC: (),
  date: datetime.today(),
  abstract: none,
  bibliography: none,
  body,
) = context {
  // Prepare authors for PDF metadata
  let author = authors.first().map(it => it.name)

  set document(
    title: title,
    author: author,
    keywords: keywords,
    date: date
  )

  set page(
    paper: "us-letter",
    margin: (x: 1in, top: 1.18in, bottom: 11in - (1.18in + 9in)),
    header-ascent: 46pt,
    footer-descent: 20pt,
    footer: align(center, text(size: font.normal, context{counter(page).display("1 / 1", both:true)}))
  )

  set text(font: body-font.get(), size: font.normal)
  show math.equation: set text(font: math-font.get())
  
  set par(justify: true, leading: 0.52em, spacing: 1.1em)
  set heading(numbering: "1.1"+".")
  show heading: set text(font: title-font.get())

  show raw: set block(spacing: 1.95em)
  show footnote.entry: set text(size: 8pt)
  set footnote.entry(
    separator: line(length: 2in, stroke: 0.35pt),
    clearance: 6.65pt,
    gap: 0.40em,
    indent: 12pt
  )

  show figure.where(kind: image): set figure.caption(position: bottom)
  set figure(gap: 16pt)

  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(gap: 6pt)
  set table(inset: 4pt)

  set enum(indent: 2.4em, spacing: 1.3em)
  show enum: set block(above: 2em)

  set list(indent: 2.4em, spacing: 1.3em, marker: ([•], [‣], [⁃]))
  show list: set block(above: 2em)

  set math.equation(numbering: "(1)", supplement: [])
  show ref: it => {
    let eq = math.equation
    let el = it.element
    if el != none and el.func() == eq {
      let numb = numbering(
        "1",
        ..counter(eq).at(el.location())
      )
      let color = rgb(0%, 8%, 45%)
      let content = link(el.location(), text(fill: color, numb))
      [(#content)]
    } else {
      it
    }
  }

  // Render title, authors, and abstract
  make-title(title, authors, date)
  if abstract != none {
    make-abstract(abstract)
  }

  show: mythmrules
  let url(uri) = {
    link(uri, raw(uri))
  }

  set cite(style: "alphanumeric")

  // Render body
  body

  // Render bibliography if provided
  if bibliography != none {
    set std-bibliography(title: [References])
    set text(font: body-font.get(), size: font.normal)
    bibliography
  }

  // Render author contacts
  make-contacts(..authors)
}
