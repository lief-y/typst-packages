// author: tinger

#let part = figure.with(
  kind: "part",
  // same as heading
  numbering: none,
  // this cannot use auto to translate this automatically as headings can, auto also means something different for figures
  supplement: "Part",
  // empty caption required to be included in outline
  caption: [],
)

// emulate element function by creating show rule
#let part-style(it) = {
  set page(numbering: none, header: none, footer: none)
  // let partpage = counter(page).at(it.location()).first() - 1
  // counter(page).update(partpage)
  v(1fr)
  // we must use numbering here, because figure does not have numbering by default
  // counter(heading).update(0)
  if it.numbering != none { 
    text(26pt, strong(it.supplement + " " + it.counter.display(it.numbering)))
    }
  block(text(22pt, strong(it.body)))
  v(1.5fr)
  pagebreak(weak: true)
  if calc.rem(counter(page).at(it.location()).first(), 2) != 0 {
    // if the page is even, we add a blank page
    // counter(page).update(partpage)
    page(numbering: none, header: none, footer: none)[]
    pagebreak(weak: true)
  }
}

#let out-line-style(it) =  {
  if it.element.func() == figure {
    // we're configuring part printing here, effectively recreating the default show impl with slight tweaks
    let res = link(it.element.location(), 
      // we must recreate part of the show rule from above once again
      if it.element.numbering != none {
        box(stroke: none, inset: (right: 5pt), it.element.supplement + " " +
          numbering(it.element.numbering, ..it.element.counter.at(it.element.location()))
        )
        // 
      } + [ ] + it.element.body
    )

    if it.fill != none {
      res += [ ] + box(width: 1fr, it.fill) + [ ] 
    } else {
      res += h(1fr)
    }

    res += link(it.element.location(), it.page())
    strong(res)
  } else {
    // we're doing no indenting here
    box(inset: (left: 12pt), it)
  }
  linebreak()
}

// new target selector for default outline
#let parts-and-headings = figure.where(kind: "part", outlined: true).or(heading.where(outlined: true))


#let part = part.with(numbering: "I")
#let linkcolor = rgb("#3f7fe0")

#let layoutrules(body) = {
  show figure.where(kind: "part"): it => part-style(it)
  show outline.entry: it => out-line-style(it)


  show outline.entry: it => {
    text(fill: linkcolor , it)
  }

  show link: set text(fill: linkcolor)

  body
}
