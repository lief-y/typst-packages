#import "@preview/nth:0.2.0": nth

#let datedisp(
  weekdayname: true,
  date
) = {
  if type(date) != "datetime" { 
    date 
  } else { 
    if weekdayname {
      date.display("[weekday repr:long]")
      [,]
      h(0.25em)
    }
    [#date.display("[month repr:long]") #nth(date.day()), #date.year()]
  }
}

#let semester(date) = {
  let semestername = {
    if (date.month() == 1 and date.day() <= 25) {
      "Winter"
    } else if date.month() < 6 {
      "Spring"
    } else if date.month() < 8  {
      "Summer"
    } else {
      "Fall"
    }
  }
  semestername + " " + str(date.year())
}

// #let lines(count) = {
//     for _ in range(count) {
//         block(spacing: 1.6em, line(length:100%, stroke: rgb("#616A6B")) )
//     }
// }

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
        context {if bonuscounter.final().at(0) == 1 {
          metadata("Bonus")
        }}
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

#let part(body, points: none, bonus: false, level: 2) = [
  #set text(weight: "regular")
  #pointgrid({
      qstcounter.step(level: level)
      h(1.5em)
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

#let pagetotal = context{
  name-it(
  if bonuscounter.final().first() > 0 { 
    query(metadata.where(value: "Bonus")).first().location().page() - 3
  } else {counter(page).final().first()}
  )
}
#let questiontotal = context{ name-it(qstcounter.final().first()) }
#let pointtotal = context{ total_points.final() }


#set par(leading: 0.55em, first-line-indent: 1.8em, justify: true)

// The exam function defines how your document looks.
#let exam(
  kind: "Exam", // indicates the type of exam -> Class Test | Pop Quiz | Short Test
  date: datetime.today(),  // date of the exam
  coursenumber: "",
  coursename: "", // course number and title name
  college: "", // displays the school's name in text or logo in image.
  version: "A", //Letter or Number
  instructor: "", // instructor name
  lhead: "",
  chead: "",
  rhead: "",
  lfoot: "", 
  rfoot: "",
  intro: none,  // used to display a hint about clean writing and if grammar is valued, etc...
  sol: false, // show solutions
  coverpage: true, // show name and grade box
  body
) = {
  // Cover page

  if coverpage {
    set text(size: 11pt)
    let cell(content) = {
      set align(left)
      rect(
        width: 100%,
        height: 100%,
        inset: 0.5em,
        stroke: 1.5pt, //(left: 1pt, right: 1pt),
        [
          #set text(14pt, weight: "medium")
          #content
        ]
      )
    }
    set page(
      margin: (top: 1.2in),
      header:   grid(
        columns: (1fr, 1fr, 1fr),
        align: top,
        rows: (0.6in),
        cell()[#smallcaps("Name (PRINT):")],
        cell()[#smallcaps("ID:")],
        cell()[#smallcaps("Signature:")],
      ),
      footer: {
          grid(
            align: (left, center, right),
            columns: (1fr, 1fr,1fr),
            strong(semester(datetime.today())),
            lfoot,
            if rfoot != "" {strong(rfoot)} else {instructor}
          )
        }
    )


  align(center, text(18pt, weight: "semibold", {
    if coursenumber != "" { coursenumber }
    if coursename != "" {
      linebreak()
      coursename
      linebreak()
    }
    if kind != "" {kind}
  }))

  if intro != none {
    block(
      // fill: rgb("#98e3fd").lighten(70%),
      above: 1em,
      inset: 0.5em, 
      width: 100%, 
      radius: 0.3em, 
      stroke: none
    )[
      #set text(12pt)
      #set par(
        leading: 0.8em,
        justify: true
      )    
      #pad(x: 0.5em)[
        #text(14pt, weight: "bold")[Instructions and Policies]
        
        #intro
      ]
    ]
  } 
    
// create grading table
  context {
    let totalquestions = qstcounter.final().first()
  
    let questions = for n in range(0, totalquestions) {
      n = n + 1
      ([*Q#n*],)
    }
  
    let totalrows = calc.ceil(totalquestions / 5)
    let questionarray = ([*Qst. \#*],) + questions.slice(0, calc.min(totalquestions, 5)) + ([],)*(5 - calc.min(totalquestions, 5)) + ([*Score*],)+ ([],) * 5
  
    let tq = totalquestions
    while totalrows > 1 {
      questions = questions.slice(5)
      tq = tq - 5
      questionarray = questionarray + ([*Qst. \#*],) + questions.slice(0, calc.min(tq, 5)) + ([],)*(5 - calc.min(tq, 5)) + ([*Score*],) + ([],) * 5
      totalrows = totalrows - 1
    }

    // let numcols = 1 + calc.min(totalquestions, 5)

    v(1fr)
    table(
      columns: (1fr, ) * 6,
      align: center+horizon,
      stroke: 1.5pt,
      rows: 2.5em,
      ..questionarray,
      table.cell(colspan: 3, align: right, stroke: (left: none, bottom: none))[],
      table.cell(colspan: 2, inset: 0.5em, text(1.6em)[*Total Score:*]),
      []
    )
  }
  
  pagebreak()
  set page(header: none, footer: none)
  
  counter(page).update(0)
}

  // Set page, headers and footers for the main body

  set page(
    header: {
      set block(spacing: 0.5em)
      set text(12pt, weight: "bold")
      if college != "" {
        align(center)[#college];
      } else {}
      grid(
        columns: (1fr, 2.5fr, 1fr),
        align: (left, center, right),
        if lhead != none {
            if lhead != "" {lhead} else {date}
        },
        text(16pt)[
              #if chead != "" {chead} else if coursename != "" [#coursename #if college!= "" {} else {linebreak()} #kind] else [#kind]
        ],
        if rhead != none {
            if rhead != "" {rhead} else {"Ver. " + version}
        }
      )
      line(length: 100%);
    },
    header-ascent: 10%,
    footer: {
      set text(10pt, weight: "bold")
      grid(
        columns:(1fr, 5em, 1fr),
        align(left)[
          #if lfoot != none {
            if lfoot != "" { lfoot } else { datedisp(date) }
          }
        ],
        align(center)[
          #counter(page).display("1 / 1", both: true)
        ],
        align(right)[
          #if rfoot != none {
            if rfoot != "" {rfoot} else { instructor }
          }
        ]
      )
    }
  )
  
  // Update global state show solution
    
  show_sol.update(sol)

  

  // End before-body
  
  // Main body.

  show heading.where(level: 2): it => {
    set block(above: 1.2em, below: 1em)
    set text(weight: 600)
    question[#it.body]
  }
  
  show heading.where(level: 3): it => {
    set text(weight: "regular")
    part(points: none)[#it.body]
  }


  let inline_list(counter-fmt, it) = {
    if it.tight {
      grid(
        columns: (1fr,) * calc.min(it.children.len(), 4),
        column-gutter: 0.5em,
        row-gutter: 1.2em,
        ..it.children
            .enumerate()
            .map(((n, item)) => grid(
              columns: (auto, 1fr),
              column-gutter: .5em,
              counter-fmt(n + 1),
              item.body,
            ))
      )
    } else {
      it
    }
  }

  // show list: inline-list.with(_ => sym.bullet)
  show enum: inline_list.with(numbering.with("1)"))

  // Content-Body
  body

  metadata("endofexam")
}
