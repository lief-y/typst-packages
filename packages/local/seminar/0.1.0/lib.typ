#import "@preview/ctheorems:1.1.2": *
#let mythmrules(..args, doc) = thmrules(qed-symbol: $square$, doc)

#import "@preview/fletcher:0.5.1" as fletcher: diagram, node, edge

#let theorem = thmplain(
  "theorem", 
  "Theorem",
  inset: (x: 0em, y: 0.5em),
  titlefmt: strong,
  // fill: rgb("#eeffee")
)

#let lemma = thmplain(
  "lemma", 
  "Lemma",
  inset: (x: 0em, y: 0.5em),
  titlefmt: strong,
  // fill: rgb("#eeffee")
)

#let proposition = thmplain(
  "proposition", 
  "Proposition",
  inset: (x: 0em, y: 0.5em),
  titlefmt: strong
  // fill: rgb("#eeffee")
)

#let corollary = thmplain(
  "corollary",
  "Corollary",
  inset: (x: 0em, y: 0.5em),
  titlefmt: strong
)

#let definition = thmplain(
  "definition", 
  "Definition", 
  inset: (x: 0em, y: 0.5em),
  titlefmt: strong
)

#let example = thmplain(
  "example", 
  "Example", 
  // base_level: 0, 
  inset: (x: 0em, y: 0.5em),
  titlefmt: strong
)
// .with(numbering: "1")

#let remark = thmplain(
  "remark", 
  "Remark", 
  // base_level: 0, 
  inset: (x: 0em, y: 0.5em),
  titlefmt: strong
)

#let question = thmplain(
  "question", 
  "Question", 
  // base_level: 0, 
  inset: (x: 0em, y: 0.5em),
  titlefmt: strong
)
// .with(numbering: "1")

#let proof = thmproof("proof", "Proof")

#let seminar_note(
  // The article's title.
  title: [Paper title],
  date: datetime.today(),
  speaker: [],
  paper-size: "us-letter",
  bibliography: none,
  body,
) = {
  // set document(title: title, author: speaker)
  set document(title: "Seminar Notes", author: "Taken by Fei Ye")
  
  set text(font: "Noto Sans")
  // Configure the page.
  set page(
    paper: paper-size,
    // The margins depend on the paper size.
    margin: (x: 1in, y: 0.8in),

    footer-descent: 12pt,
    footer: align(center, counter(page).display("1 / 1", both: true))
  )

  // Configure headings.
  set heading(numbering: "1.")

  show math.equation: set block(below: 8pt, above: 9pt)
  show math.equation: set text(font: ("STIX Two Math", "Latin Modern Math", "New Computer Modern Math"))
  show: mythmrules

  align(center, ({
    text(size: 16pt, weight: 700, title)
    v(24pt, weak: true)
    text(size: 12pt, weight: 500, speaker)
    v(12pt, weak: true)
    text(size: 10pt, date.display("[month repr:short] [day], [year]"))
  }))

  // Display the article's contents.
  v(24pt, weak: true)
  body
}

