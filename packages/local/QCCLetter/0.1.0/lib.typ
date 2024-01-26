// This function gets your whole document as its `body`
// and formats it as a simple letter.
#let letter(
  // The letter's sender, which is display at the top of the page.
  sender: none,

  // The letter's recipient, which is displayed close to the top.
  recipient: none,

  // The date, displayed to the right.
  date: none,

  // The subject line.
  subject: none,

  // The name with which the letter closes.
  name: none,

  margins: (top: 1.25in, bottom: 1in),

  // The letter's content.
  body
) = {
  // Configure page and text properties.
  set page(
    margin: margins,
    header: {
      set block(spacing: 0.8em)
      align(center)[
        #image("logo.svg", height: 3em)
        #text(//font: "Trajan Pro 3", 
        fill: rgb("#0033A1"), size: 12pt)[#upper[*Department of Mathematics and Computer Science*]]
      ]
      line(
        length: 100%,
        stroke: 0.5pt + rgb("#FFB71B"),
      )
    },
    header-ascent: 10%,
    footer: {
      set block(spacing: 0.65em)
      line(
        length: 100%,
        stroke: 0.5pt + rgb("#FFB71B"),
      ) 
      align(center, text(fill: rgb("#0033A1"), size: 0.8em)[
        718-631-6361 #h(1pt)\u{25AA}#h(1pt)
        FAX 718-631-6290 #h(1pt)\u{25AA}#h(1pt) 
        Science, Room 245 #h(1pt)\u{25AA}#h(1pt)
        222-05 56th Avenue #h(1pt)\u{25AA}#h(1pt)
        Bayside, NY 11364-1497]
    )
    },
    // footer-descent: 10%,
  )
  // set text(font: "PT Sans")

  // // Display sender at top of page. If there's no sender
  // // add some hidden text to keep the same spacing.
  if sender == none {
    hide("a")
  } else {
    align(right, sender)
  }
  // v(-1em)
  // Display date. If there's no date add some hidden
  // text to keep the same spacing.
  align(left, if date != none {
    date
  })

  // Display recipient.
  block(spacing: 1.2em, recipient)
  
  // Add the subject line, if any.
  if subject != none {
     strong(subject)
  }

  
  // Add body and name.
  body

  v(1.5em, weak: true)
  name
}
