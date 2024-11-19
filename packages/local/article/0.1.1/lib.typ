// This template is derived from https://github.com/daskol/typst-templates/blob/main/tmlr/tmlr.typ

#let std-bibliography = bibliography

// Font settings
#let font_families = state("usrfonts", ("default", "default", "default"))

#let title_font = state("titlefonts", ("Noto Sans", "New Computer Modern"))
#let body_font = state("bodyfonts",("Noto Sans", "New Computer Modern Sans"))
#let math_font = state("mathfont", ("STIX Two Math", "New Computer Modern Math"))

#let fontsize = (
  Large: 18pt,
  footnote: 10pt,
  large: 12pt,
  normal: 10.5pt,
  script: 8pt,
  small: 9pt,
)

// Import theorem styles
#import "@preview/ctheorems:1.1.3": *

#let mythmrules(..args, doc) = thmrules(qed-symbol: $square$, doc) 

#let thmstyle = (
  namefmt: x => context {text(font: title_font.get(), [(#x)])},   
  titlefmt: x => context {text(font: title_font.get(), strong(x))},
  inset: 0em,
  breakable: true,
)

// Define theorem environments
#let theorem = thmbox("theorem", [Theorem],   bodyfmt: x => emph(x), ..thmstyle)
#let lemma = thmbox("theorem", [Lemma],   bodyfmt: x => emph(x), ..thmstyle)
#let proposition = thmbox("theorem", [Proposition],   bodyfmt: x => emph(x), ..thmstyle)
#let corollary = thmbox("theorem", [Corollary],  bodyfmt: x => emph(x), ..thmstyle)

#let definition = thmbox("definition", [Definition], ..thmstyle)
#let remark = thmbox("remark", [Remark], ..thmstyle)
#let example = thmbox("example", [Example], ..thmstyle)
#let proof = thmproof("proof", [Proof], ..thmstyle)

// Author and affiliation settings
#let affl-keys = ("department", "institution", "address")

#let make-author(author, affls) = {
    let author-affls =   if "affl" in author { (author.affl, ).flatten() } else { none }
    let addresses = if author-affls != none {author-affls.map(key => {
      let affl = affls.at(key)
      return affl-keys
        .map(key => affl.at(key, default: none))
        .filter(it => it != none)
        .join("\n")
    }).map(it => emph(it))
    } else { none }

  return block(spacing: 0em, above: 2em, {
    set par(justify: true, leading: 0.65em, spacing: 0.65em)
    text(size: fontsize.normal)[*#author.name*]
    {
      set text(size: fontsize.small)
      if addresses != none {
        v(0.5em)
        addresses.join([#v(0.5em)])
      }
      if "email" in author {
        v(0.5em)
        [_Email address:_ ] + link("mailto:" + author.email)
      }
      if "url" in author {
        v(0.5em)
        [_Homepage:_ ] + link(author.url)
      }
    }
  })
}

#let make-contacts(authors, affls) = {
  let contacts = authors.map(it => (make-author(it, affls)))
  return contacts.join([#v(0.5em)])
}

// Render title
#let make-title(title, authors, date) = context {
  set text(font: title_font.get(), weight: "regular")
  set align(center)
  v(-0.03in)
  block(spacing: 0em, {
    set block(spacing: 0em)
    set par(leading: 10pt)
    text(size: fontsize.Large, weight: 600, upper(title))
  })
  v(31pt, weak: true)
  authors.first().map(it => upper(it.name)).join(", ", last: ", and")
  v(14.9pt, weak: true)
  if date == none {return} else {date.display("[month repr:short] [day], [year]")}
  v(14.9pt, weak: true)
}

// Render abstract
#let make-abstract(abstract) = context {
  block(spacing: 0em, width: 100%, {
    v(29.5pt, weak: true)
    align(center, text(font: title_font.get(), size: fontsize.large, weight: "bold", [*Abstract*]))
    set text(size: fontsize.normal)
    set par(leading: 0.51em)
    pad(left: 0.5in, right: 0.5in, abstract)
  })
  v(29.5pt, weak: true)
}

// Affiliation details
#let qccgc = (
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
#let fye = (
  (
    name: "Fei Ye", 
    email: "feye@qcc.cuny.edu",
    url: "https://yfei.page",
    affl: ("qcc", "gc")
  ),
)

#let authorInfo = (fye, qccgc)

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
  if font_families.get() != none and font_families.get() != ("default", "default", "default") {
    let fontfamilies = font_families.get()
    if fontfamilies.at(0) != "default" {
        title_font.update(t => (fontfamilies.at(0), ) + t)
    }
    if fontfamilies.at(1) != "default" {
      body_font.update(t => (fontfamilies.at(1), ) + t)
    }
    if fontfamilies.at(2) != "default" {
      math_font.update(t => (fontfamilies.at(2), ) + t)
    }
  }
  // Prepare authors for PDF metadata
  let author_names(capitalized: false) = authors.first().map(author => if capitalized {upper(author.name)} else {author.name})
  let author_list(uppercase: false) = {
    if author_names(capitalized: uppercase).len() == 2 {
      author_names(capitalized: uppercase).join(" and ")
    } else {
      author_names(capitalized: uppercase).join(", ", last: ", and ")
    }
  }

  set document(
    title: title,
    author: author_list(),
    keywords: keywords,
    date: date
  )

  set page(
    paper: "us-letter",
    margin: (x: 1in, top: 1.18in, bottom: 11in - (1.18in + 9in)),
    header-ascent: 16pt,
    header: context {
      let i = counter(page).get().first()
      if i == 1 { return }
      set text(size: fontsize.small, weight: 500)
      if calc.even(i) {[#i]+h(1fr)+author_list(uppercase: true)} else {upper(title)+h(1fr)+[#i]}
    },
    footer-descent: 12pt,
    footer: context {
      let i = counter(page).get().first()
      if i == 1 {
        align(center, text(size: fontsize.small)[#i])
      }
    }
  )

  set text(font: body_font.get(), size: fontsize.normal)
  show math.equation: set text(font: math_font.get(), weight: 400)
  
  // set block(above: 0.65em, below: 0.65em)

  show link: set text(blue)
  

  set par(
      // first-line-indent: 1.15em, 
      justify: true, 
      leading: 0.58em, 
      spacing: (1.2em),
      // hanging-indent: -1em
  )

  

  set heading(numbering: "1.1"+".")
  show heading: it => {
    set text(font: title_font.get(), weight: 600)
    set block(spacing: 0em)
    v(1.15em, weak: true)
    it + h(0em, weak: true)
  }
  
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

  set enum(indent: 1.2em, spacing: 1.3em)
  show enum: set block(above: 2em)

  set list(indent: 1.2em, spacing: 1.3em, marker: ([•], [‣], [⁃]))
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
  show cite: set text(blue)

  // Render body
  body

  set par(first-line-indent: 0em) 
  // Render bibliography if provided
  if bibliography != none {
    set std-bibliography(title: [References])
    set text(font: body_font.get(), size: fontsize.normal)
    bibliography
  }

  // Render author contacts
  make-contacts(..authors)
}
