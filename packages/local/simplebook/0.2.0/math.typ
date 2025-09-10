#import "@preview/cetz:0.4.0"
#import "@preview/cetz-plot:0.1.2": plot
#import "@preview/theorion:0.4.0": *
#import cosmos.simple: *



#let smallerlabel(v) = { text(9pt, $#v$) }
#let coordinateoptions = (
  x-tick-step: 1,
  y-tick-step: 1,
  axis-style: "school-book",
  x-grid: true,
  y-grid: true,
)

#let smallticks = (
  x-format: v => text(10pt, $#v$),
  y-format: v => text(10pt, $#v$),
)
#let tinyticks = (
  x-format: v => text(8pt, $#v$),
  y-format: v => text(8pt, $#v$),
)

#let (example-counter, example-box, example, show-example) = make-frame(
  "example",
  "Example",
  inherited-levels: 1,
  render: (prefix: none, title: "", full-title: auto, body) => block(inset: (x: 6pt), width: 100%)[#place(start+top, dx: -6pt, dy: -6pt, box(width:8em, height:2em, stroke: (left: 2pt + gradient.linear(rgb("#96b6e9"), rgb("#ecf6f5")), top: 2pt + gradient.linear(rgb("#96b6e9"), rgb("#ecf6f5")))))#strong[#full-title.]#sym.space#body],
)

#let (exercise-counter, exercise-box, exercise, show-exercise) = make-frame(
  "exercise",
  "Exercise",
  inherited-levels: 1,
  render: (prefix: none, title: "", full-title: auto, body) => block(width: 100%)[#text(font: "Comic Neue")[#emoji.pen.ball #strong(full-title)].#sym.space#body],
)

#let solution(title: "Solution", body, ..args) = block(
  width: 100%,
  inset: (x: 6pt),
  ..args
)[#emph(title).#sym.space#body#h(1fr)#place(end+bottom, dx: 6pt, dy:-3pt, box(width: 8em, height:2em, stroke: (bottom: 2pt + gradient.linear(rgb("#ecf6f5"),rgb("#96b6e9")), right: 2pt + gradient.linear(rgb("#ecf6f5"),rgb("#96b6e9")))))]

#let luminance(color) = {
  let c = color.components()
  0.2126 * float(c.at(0)) +  0.7152 * float(c.at(1)) +  0.0722 * float(c.at(2))
}

#let fancybox(
  title: "title",
  body,
  icon: none,
  strokecolor: rgb("#888888"),
  titlefill: rgb("#f2f2f2"),
  radius: 6pt,
  ..args
) = {
  let textcolor = if luminance(titlefill) > 0.5 { black } else { white }
  block(
    stroke: (
      top: 3pt + strokecolor,
      right: 0.5pt + strokecolor,
      bottom: 0.5pt + strokecolor,
      left: 0.5pt + strokecolor,
    ),
    radius: radius,
    ..args
  )[
    #block(
      fill: titlefill,
      inset: (x: 5pt, y: 7.5pt),
      outset: (x: -0.5pt, y: -1.5pt),
      above: -6pt,
      below: 0pt,
      radius: 2pt,
    )[
      #text(fill: textcolor, weight: "bold", title)
    ]
    #block(
      width: 100%,
      inset: (top: 0.5em, x: 5pt, bottom: 0.5em),
    )[
      #if icon != none {
        grid(
          columns: (2.5em, 1fr),
          gutter: 6pt,
          align: (center + horizon, start + top),
          inset: 3pt,
          text(size: 2.5em, icon),
          body,
        )
      } else {
        body
      }
    ]
  ]
}

#let learning-goals-box(
  title: "Learning Goals",
  body,
) = fancybox(
  title: title,
  icon: emoji.darts,
  strokecolor: rgb("#2980b9"),
  titlefill: rgb("#d6eaf8"),
)[
  #set list(marker: emoji.square.white)
  #body
]

#let property-box(
  title: "",
  body,
) = fancybox(
  title: title,
  body,
  strokecolor: rgb("#1f77b4"),
  titlefill: rgb("#d6eaf8"),
)

#let think-box(
  title: "",
  body,
) = fancybox(
  title: title,
  body,
  icon: emoji.face.think,
  strokecolor: rgb("#4b6cb7"),
  titlefill: rgb("#8fbcff"),
)

#let tip-box(
  title: "",
  body,
) = fancybox(
  title: title,
  body,
  icon: emoji.lightbulb + " ",
  strokecolor: rgb("#2ecc71"),
  titlefill: rgb("#d4f4dd"),
)

#let note-box(
  title: "",
  body,
) = fancybox(
  title: title,
  body,
  icon: emoji.page.pencil + " ",
  strokecolor: rgb("#f4a259"),
  titlefill: rgb("#ffe6c7"),
)

#let warning-box(
  title: "",
  body,
) = fancybox(
  title: title,
  body,
  icon: emoji.warning + " ",
  strokecolor: rgb("#e74c3c"),        // strong red
  titlefill: rgb("#fdecea"),          // light red background
)


#let table_options = {
  (stroke: 1pt + rgb("#3883f2"), align: center, inset: 0.5em)
}

#let mathrules(body) = {
// author: eric1102
  show math.equation: it => {
    if it.body.fields().at("size", default: none) != "display" {
      return math.display(it)
    }
    it
  }
  // author: gijsleb
  show math.equation: it => {
    if it.has("label") {
      // Don't forget to change your numbering style in `numbering`
      // to the one you actually want to use.
      math.equation(block: true, numbering: "(1)", it)
    } else {
      it
    }
  }

  show ref: it => {
    let el = it.element
    if el != none and el.func() == math.equation {
      link(el.location(), numbering(
        // don't forget to change the numbering according to the one
        // you are actually using (e.g. section numbering)
        "(1)",
        counter(math.equation).at(el.location()).at(0) + 1
      ))
    } else {
      it
    }
}
  show: show-example
  show: show-exercise
  show: show-theorion
  
  body
}

