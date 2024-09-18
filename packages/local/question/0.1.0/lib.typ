#let lines(count) = {
    for _ in range(count) {
        block(spacing: 1.6em, line(length:100%, stroke: rgb("#616A6B")) )
    }
}

// Global state 
#let show_sol = state("s", false)
#let total_points = state("t", 0)

#let qstcounter = counter("question-counter");
#let bonuscounter = counter("bonus-counter");

/*
  function for the numbering of the questions and questions
*/
#let questionnumbering = (..args) => {
    let nums = args.pos()
    if nums.len() == 1 {
      numbering("1. ", nums.last())
    } else if nums.len() == 2 {
      numbering("(1) ", nums.last())
    }
  }

/*
  draws a small gray box which indicates the amount of points for that question/question
  points: given points -> needs to be an integer
  plural: if true it displays an s if more than one point
*/

#let pointbox(points, plural: false, total_include: true) = {
  assert.eq(type(points),"integer")
  if total_include == true {
    total_points.update(t => t + points)
  }
  box(
      // stroke: blue,
      inset: 2pt,
      radius: 0.2em,
      fill: rgb("#98e3fd").lighten(50%)
    )[
        #set align(center + horizon)
        #set text(weight: "regular")
        #points #smallcaps[pt#if points > 1 [s]]
    ]
}

/*
  template for a grid to display the pointbox on the right side.
*/
#let pointgrid(body, points, bonusqst: false) = {
  grid(
    columns: (100%, 10%),
    gutter: 1em,
    body,
    if points != none {
        pointbox(points, total_include: not(bonusqst))
    }
  )
}

#let question(points: none, title: "", bonus: false, content) = {
  if title == "" [
    #pointgrid({
      set text(weight: 600)
      if bonus == true {
        bonuscounter.step()
        [Bonus Question ] + bonuscounter.display(questionnumbering)
      } else {
        qstcounter.step()
        qstcounter.display(questionnumbering)
      }
      set text(weight: "regular")
      content
    },
    points, 
    bonusqst: bonus
  )
  ] else [
  #pointgrid({
      set text(weight: 600)
      qstcounter.step()
      qstcounter.display(questionnumbering)
      title
    },
    points, bonusqst: bonus
  )
  #pad(left:1em, top:-0.5em)[#content]
]
}

#let part(body, points: none, bonus: false, level: 2, indent: false) = [
  #set text(weight: "regular")
  #pointgrid({
      qstcounter.step(level: level)
      if indent {h(1.5em)}
      qstcounter.display(questionnumbering)
      body
    },
    points,
    bonusqst: bonus
  )
]

/*
  solution for a question
  will only be printed if the global state show_sol is true.
  You can achieve this by calling show_sol.update(true) from your document.
  Optional you can give a placeholder which will be printed if show_sol is false.
*/
#let solution(solution, placeholder: []) = {
    locate(loc => {
      if show_sol.at(loc) == false { placeholder }
    })
    set text(fill: rgb( 55, 43, 251 ))
    locate(loc => {
      if show_sol.at(loc) == true {
        block(
          width: 100%, 
          inset: 1em,
          stroke: blue+1.5pt,
          radius: 5pt,
          {
            strong[Solution: ]
            solution
          }
        )
      }
    })
}

/*
  body will only be printed if show_sol is false
*/
#let notifso(body) = {
  locate(loc => {
    if show_sol.at(loc) == false { body }
  })
}

#let mct(choices: (), answer: none) = [
  #assert(type(answer) == "integer", message: "Answer needs to be an integer of the correct answer")
  #assert(type(choices) == "array", message: "Choises must be given as an array")
  #assert(choices.len() >= answer, message: "anwers outside of bound")
  
  #for (i,a) in choices.enumerate() [
      #box(inset: (x: 0.5em))[
        #locate(loc => {
         square(
          width: 0.8em, 
          height: 0.8em, 
          stroke: black, 
          fill: if show_sol.at(loc) and (i+1)==answer {red})
          
        })
      ] #a \
  ]
]

#import "@preview/name-it:0.1.1": *

#let pagetotal = locate(loc => name-it(counter(page).final(loc).at(0)))
#let questiontotal = locate(loc => name-it(qstcounter.final(loc).at(0)))
#let pointtotal = locate(loc => total_points.final(loc))
