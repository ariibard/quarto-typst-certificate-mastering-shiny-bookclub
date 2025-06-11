#set text(font: "Lato", fill: rgb("#444444"))
#set par(leading: 0.7em)
#set block(spacing: 1.4em)

#let nbis-certificate(

  logo: none,
  title: none,
  date: none,
  headnotes-1: none,
  headnotes-2: none,
  gap: 5pt,
  participant: none,
  bg-image: none,
  logo-image: none,
  sign-image: none,
  sign-height: 25mm,
  teacher: none,
  footnotes: none,
  version: "Unknown",
  body

) = {

  // body font
  set text(12.5pt, font: "Lato")

set page(
    width: 29.7cm,
    height: 21cm,
    margin: (left: 2.5cm, right: 2.5cm, top: 5.5cm, bottom: 4cm),
    background: if bg-image != none {
      place(center + top, image(bg-image.path, height: 100%))
    },

    header: grid(
      columns: (1fr, 1fr),
      row-gutter: 0pt,
      grid(
        columns: 1fr,
        rows: (12pt, 14pt),
        row-gutter: 0pt,
        text(weight: "medium", size: 11pt, tracking: 1.05pt, align(left + bottom, headnotes-1)),
        text(weight: "medium", size: 14pt, tracking: 1.1pt, align(left + bottom, headnotes-2)),
      ),
      
      align(right, pad(top: 100mm, image(logo-image.path, height: 35mm)))
    ),
    footer: {
      set text(8pt)
      set par(leading: 0.5em)
      set block(spacing: 1em)
      set par(justify: true)
      footnotes
      set text(6pt)
      pad(top: 1pt, version + h(1pt) + date)
    }
  )

  // configure headings.
  show heading.where(level: 1): set text(1.1em)
  show heading.where(level: 1): set par(leading: 0.4em)
  show heading.where(level: 1): set block(below: 0.8em)
  show heading: it => {
    set text(weight: 600) if it.level > 2
    it
  }

  // underline links.
  show link: underline

  // page body
  grid(
    columns: 1fr,
    row-gutter: 20pt,
    
 // logo secundario centrado arriba del título
    
    if logo != none {
        align(center, pad(image(logo.path, height: 45mm)))
      },
  
    // title.
    pad(
      top: 5pt,
      bottom: gap,
      align(center, text(30pt, weight: 300, tracking: 1.3pt, title))
    ),

    // participant name
    align(center, text(26pt, weight: 600, participant)),

    // body flow
    align(center, {
      body
      if sign-image != none {
        image(sign-image.path, height: sign-height)
      }
       teacher
    })
  )
}
