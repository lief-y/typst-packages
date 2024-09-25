#import "@local/date:0.1.0": *

#let note(body, fontcolor: black, fontsize: 1.2em, ..) = {
  set text(size: fontsize, fill: fontcolor)
  strong(body)
}

#let warning(body) = note(fontcolor: red, body)
#let reminder(body) = note(fontcolor: blue, body)

#let coursecal(
  college: "",
  title: "",
  semester: semester(datetime.today()),
  instructor: "",
  start_date: datetime.today(),
  num_weeks: 16,
  rowheight: "",
  week_days: (1, 3),
  lessons: (),
  body
) = {
  set page(
    paper: "us-letter",
    margin: (x: 0.6in, y: 0.8in),
    header: {
      grid(
        columns: (1em, 1fr, 1em),
        align: (left, center, right),
        [], text(1.5em, strong(title)), []
      )
    },
    footer: {
      grid(
        columns: (1fr,)*3,
        align: (left, center, right),
        strong(semester),
        counter(page).display("1 / 1", both: true),
        strong(instructor)
      )
    }
  )

  context {
    let pageheight = page.height
    
    let meeting_days = week_days
    let ncolumns = meeting_days.len()
    let semester_start = start_date
    let number_weeks = num_weeks
    
    let nameweekday(num) = {
    ("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday").at(num)
    }
    
    let tableheader = for n in meeting_days {(nameweekday(n - 1),)}
  
  let rowwidth = if rowheight != "" {
     rowheight
  } else {
    1.25*(pageheight - 2em) / number_weeks
  }
  
    show table.cell: it => {
      if it.y > 0 {
        for n in range(ncolumns) {
          if it.x == n {
            grid(
              rows:(1em, rowwidth),
              grid.cell(
                inset: (left: 5pt, top: 0.5em, bottom: 0em),
                text(0.9em, weight: "bold",
                  underline(
                    ndaysfromdate((meeting_days.at(n) - semester_start.weekday() + 7 * (it.y - 1)), date: semester_start).display("[month repr:short] [day], [year]")
                  )
                )
              ),
              grid.cell(
                align: horizon,
                inset: (left: 1em, top: 0.6em), 
                it.body
              )
            )
          }
        }
      } else {
        it
      }
    }
  
    show table.cell.where(y: 0): set text(16pt, weight: "bold")
  
    
    table(
      columns: (1fr,)*ncolumns,
      align: (_, y) =>
        if y == 0 { center+horizon } else { left },
      table.header(
        repeat: true,
        ..tableheader.flatten(),
      ),
        ..lessons.flatten(),
    )
    
    body
  }
}