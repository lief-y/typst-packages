// const icons
#let icon_size = 1em

#let colored_icon(path: "", color: "", size: icon_size) = {
  box(
    baseline: 15%,
    height: size,
    if color == "" {
      image(path)
    } else {
      image.decode(
        read(path).replace(
          "#CC5500",
          color.to-hex(),
        )
      )
    }
  )
}

#let orchid_icon_path = "icons/orcid.svg"
#let phone_icon_path = "icons/phone-solid.svg"
#let email_icon_path = "icons/envelope-solid.svg"
#let web_icon_path = "icons/globe-solid.svg"
#let github_icon_path = "icons/github-mark.svg"
#let bookmark_icon_path = "icons/bookmark-solid.svg"

#let github_link = "https://github.com/"
#let orcid_link = "https://orcid.org/"

#let icon_link(icon, web, account_name) = {
  align(horizon)[
    #icon
    #link(web + account_name, account_name)
  ]
}

//Resume layout

#let left_column_width = 18%
#let column_gutter = 1em

#let resume(
  title: "",
  author: (:), 
  date: datetime.today().display("[month repr:long] [day], [year]"), 
  theme: (:),
  body
) = {
  set text(
    font: theme.font,
    lang: "en",
    size: 11pt,
    fallback: true
  )

  let primary_color = rgb("#CC5500")
  let accent_color = rgb("#2B80FF")

  // Set up theme color
  if theme.primarycolor != "" {
      primary_color = theme.primarycolor
  } 
  if theme.accentcolor != "" {
      accent_color = theme.accentcolor
  } 

  set document(
    author: author.firstname + " " + author.lastname, 
    title: title,
  )


  // Set page style 
  set page(
    paper: "us-letter",
    margin: (left: 0.6in, right: 0.6in, top: 0.6in, bottom: 0.6in),
    footer: [
      #set text(fill: accent_color, size: 8pt)
      #grid(
        columns: (1fr,)*3,
        align: (left, center, right),
        smallcaps[#date],
        counter(page).display("1 / 1", both: true),
        smallcaps[
              #author.firstname
              #author.lastname
              #sym.dot.c
              #title
            ],
        )
    ],
  )
  
  // Set paragraph spacing
  
  show par: set block(above: 1em, below: 1em)
  set par(justify: true)

  // Set heading styles
  
  set heading(
    numbering: none,
    outlined: false,
  )

  show heading: set block(above: 1em)

  show heading.where(level:1): it => {
    set text(
      size: 1.2em,
      weight: "bold",
      fill: primary_color
    )
    grid(
      columns: (left_column_width, 1fr),
      column-gutter: column_gutter,
      align(horizon, line(stroke: 5pt + gradient.linear(primary_color, primary_color.lighten(20%), angle: 0deg), length: 100%)),
      pad(left: -0.5em, it.body)
    )
  }

  // show heading.where(level: 2): it => {
  //   set text(
  //     size: 1.1em, 
  //     style: "normal", 
  //     fill: primary_color, 
  //     weight: "semibold"
  //   )
  //   grid(
  //     columns: (left_column_width, 1fr),
  //     align: (right, left),
  //     column-gutter: column_gutter,
  //     row-gutter: 0.5em,
  //     [],
  //     pad(left: -0.25em, it.body)
  //   )
  // }

  // show heading.where(level: 3): it => {
  //   set text(size: 10pt, weight: "regular")
  //   grid(
  //     columns: (left_column_width, 1fr),
  //     align: (right, left),
  //     column-gutter: column_gutter,
  //     row-gutter: 0.5em,
  //     [],
  //     pad(left: -0.25em, smallcaps[#it.body])
  //   )
  // }

  // show heading.where(level:1): it => {
  //   set text(
  //     size: 1.2em,
  //     weight: "semibold", 
  //     fill: primary_color
  //   )
  //     box(
  //       width: 100%,
  //       stroke: (bottom: 3pt + gradient.linear(primary_color, white, angle: 0deg)),
  //       inset: (bottom: 0.5em),
  //       it.body
  //     )
  // }

  show heading.where(level: 2): it => {
    set text(primary_color, size: 1.1em, style: "normal", weight: "bold")
    it.body
  }
  show heading.where(level: 3): it => {
    set text(size: 10pt, weight: "regular")
    grid(
      columns: (left_column_width, 1fr),
      align: (right, left),
      column-gutter: 1.2em,
      row-gutter: 0.5em,
      [],
      pad(left: -0.25em, smallcaps[#it.body])
    )
  }


  set enum(
      numbering: n => {
          box(
            baseline: -40%, 
            width: 0.8em
          )[
            #place(
              dy: -0.25em, 
              circle(
                radius: 0.65em, 
                // height: 1.5em, 
                fill: gradient.linear(primary_color, primary_color.lighten(20%), angle: 0deg), 
                align(
                  center+horizon,
                  text(fill: white, weight: "bold", size: 0.8em)[#n]
                )
              )
            )
          ]
        },
      body-indent: 1.2em+3pt,
      spacing: 1.2em,
      tight: false
  )

  set list(
    marker: pad(right: 0.5em, colored_icon(path: bookmark_icon_path, color: accent_color, size: 1em)),
    // text(fill: primary_color, weight: "bold", size: 1em)[$bullet$],
    body-indent: column_gutter
  )

  // Set name style
  
  let name = {
    set text(
      size: 2.5em, 
      weight: "bold", 
      fill: primary_color
    )
    pad(bottom: 0.5em)[
      #author.firstname
      #h(0.2em)
      #author.lastname
    ]
  }

  // Set position style
  
  let positions = {
    set text(
      accent_color,
      size: 0.8em,
      weight: "regular"
    )
    smallcaps(
      author.positions.join(
        text[#"  "#sym.dot.c#"  "]
      )
    )
  }

  // Set address style
  let address = {
    set text(
      size: 0.8em,
      weight: "bold",
      style: "italic",
    )
    align(right, author.address)
  }

  // Set contact information styles
  
  let contactinfo = {
    align(right)[
      #set text(size: 0.8em, weight: "regular", style: "normal")
      #align(horizon)[
        #if (author.phone != "") {
          colored_icon(path: phone_icon_path, color: accent_color)
          box(inset: (left: 6pt),  
            author.phone
          )
        }
        
        #if (author.email != "") {
          colored_icon(path: email_icon_path, color: accent_color)
          box(inset: (left: 6pt), link("mailto:" + author.email)[#author.email])
        }
      ]
    ]
  }
  
  let socialinfo = {
    set text(size: 0.9em, weight: "regular", style: "normal")
    grid(
      columns: (1fr,) + (auto,)*3,
      column-gutter: 1.5em,
      align: (left, right, right, right),
      [],
      if (author.web != "") {
        icon_link(colored_icon(path: web_icon_path, color: accent_color), "", author.web)
      },
      if (author.orcid != "") {
        icon_link(colored_icon(path: orchid_icon_path, color: ""), orcid_link, author.orcid)
      },
      if (author.github != "") {
        icon_link(colored_icon(path: github_icon_path, color: accent_color), github_link, author.github)
      }
    )
  }
  
  grid(
    columns: (1fr, 2fr),
    align: (left, right), 
    {name; positions;},
    {address; contactinfo},
  )
  socialinfo
  body
}

// Resume-list: marker will be placed on the left

#let resume_list(body) = {
  set text(size: 1em, weight: 400)
  set par(leading: 0.65em)

  set enum(
    numbering: n => {
        box(
          baseline: -40%, 
          width: left_column_width
        )[
          #place(
            dy: -0.25em, 
            circle(
              radius: 0.65em, 
              // height: 1.5em, 
              fill: blue, 
              align(
                center+horizon,
                text(fill: white, weight: "bold", size: 0.8em)[#n]
              )
            )
          )
        ]
      },
    body-indent: 1.2em,
    spacing: 1.2em,
    tight: false
  )


  show list.item: it => {
    grid(
      columns: (left_column_width, 1fr),
      align: (right, left),
      column-gutter: column_gutter,
      row-gutter: 0.5em,
      box(
          baseline: -40%,
          inset: (right: 0.5em), 
          width: left_column_width,
          colored_icon(path: bookmark_icon_path, color: blue, size: 1em)
      ),
      it.body
    )
  }

  show terms.item: it => {
    grid(
      columns: (left_column_width, 1fr),
      align: (right, left),
      column-gutter: column_gutter,
      row-gutter: 0.5em,
      par(justify: true, it.term),
      it.description
    )
  }

  body
}

#let resume_entry(
  date: "",
  title: "",
  department: "",
  university: "",
  location: "", 
  description: ""
) = {
  set block(above: 0.8em, below: 1em)
  grid(
      columns: (left_column_width, auto, 1fr),
      align: (right, left, right),
      column-gutter: column_gutter,
      row-gutter: 0.5em,
      grid.cell(
        rowspan: 2,
        date,
      ),
      strong(title),
      department,
      emph(university),
      location,
      [],
      description
    )
}

// Reverse the numbering of enum items. It was shared by frozolotl. A reimplement of enum can be found in https://gist.github.com/frozolotl/1eeafa5ff4a38b2aab412743bd9c1ded. It may be used to realize the same feature.

#let reverse(it) = {
  let len = it.children.filter(child => child.func() == enum.item).len()
  set enum(numbering: n => box(width: left_column_width, align(right)[#(1 + len - n).])
  ) 
  it
}

// ---- End of Resume Template ----
