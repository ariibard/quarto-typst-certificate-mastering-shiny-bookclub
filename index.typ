// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): block.with(
    fill: luma(230), 
    width: 100%, 
    inset: 8pt, 
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    new_title_block +
    old_callout.body.children.at(1))
}

#show ref: it => locate(loc => {
  let target = query(it.target, loc).first()
  if it.at("supplement", default: none) == none {
    it
    return
  }

  let sup = it.supplement.text.matches(regex("^45127368-afa1-446a-820f-fc64c546b2c5%(.*)")).at(0, default: none)
  if sup != none {
    let parent_id = sup.captures.first()
    let parent_figure = query(label(parent_id), loc).first()
    let parent_location = parent_figure.location()

    let counters = numbering(
      parent_figure.at("numbering"), 
      ..parent_figure.at("counter").at(parent_location))
      
    let subcounter = numbering(
      target.at("numbering"),
      ..target.at("counter").at(target.location()))
    
    // NOTE there's a nonbreaking space in the block below
    link(target.location(), [#parent_figure.at("supplement") #counters#subcounter])
  } else {
    it
  }
})

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      block(
        inset: 1pt, 
        width: 100%, 
        block(fill: white, width: 100%, inset: 8pt, body)))
}

#set text(font: "Lato", fill: rgb("#444444"))
#set par(leading: 0.7em)
#set block(spacing: 1.4em)

#let nbis-certificate(

  title: none,
  date: none,
  headnotes-1: none,
  headnotes-2: none,
  gap: 72pt,
  participant: none,
  bg-image: none,
  logo-image: none,
  sign-image: none,
  sign-height: 15mm,
  teacher: none,
  footnotes: none,
  version: "Unknown",
  body

) = {

  // body
  set text(12.5pt)

  set page(
    margin: (left: 2.5cm, right: 2.5cm, top: 4.5cm, bottom: 5cm),
    background: if bg-image != none {
      place(center + top, image(bg-image.path, height: 100%))
    },

    header: grid(
      columns: (1fr, 1fr),
      row-gutter: 0pt,
      grid(
        columns: 1fr,
        rows: (12pt, 14pt),
        row-gutter: 2.5pt,
        text(weight: "medium", size: 11pt, tracking: 1.05pt, align(left + bottom, headnotes-1)),
        text(weight: "medium", size: 14pt, tracking: 1.1pt, align(left + bottom, headnotes-2))
      ),
      align(right, image(logo-image.path, height: 13mm))
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

    // title.
    pad(
      top: 10pt,
      bottom: gap,
      text(36pt, weight: 700, tracking: 1.3pt, title)
    ),

    // participant name
    text(22pt, weight: 600, participant),

    // body flow
    {
      set par(justify: true)
      body
      if sign-image != none {
        image(sign-image.path, height: sign-height)
      }
      teacher
    }
  )
}
#show: nbis-certificate.with(
      title: "Certificate",
  
      headnotes-1: [www.nbis.se],
  
      headnotes-2: [NBIS • TRAINING],
  
      participant: [John Doe],
  
      bg-image: (
      path: "assets/background.png"
    ), 
  
      logo-image: (
      path: "assets/logo.png"
    ), 
  
      sign-image: (
      path: "assets/signature.png"
    ), 
  
  

      teacher: [Course Leader | #strong[John Doe, PhD] \
Associate Professor in Bioinformatics \
NBIS | Uppsala University

],
  
     footnotes: [This is a certificate of participation. Participants are not evaluated. \
#strong[National Bioinformatics Infrastructure Sweden \(NBIS)] is a distributed national research infrastructure supported by the Swedish Research Council, Science for Life Laboratory, Knut and Alice Wallenberg Foundation and all major Swedish universities in providing state-of-the-art bioinformatics to the Swedish life science research community.

],
  
      version: [v2.0.],
  
      date: [Printed 03-Apr-2024 at 14:17.],
  )


has participated in the NBIS workshop #strong[Advanced analysis of data] \
held in #strong[Uppsala] from #strong[18 Mar - 23 Mar, 2024];. \
\
The workshop consisted of 40 hours of lectures and computer exercises. This included the following topics: \
\
- Introduction to data & data analysis \
- Datatypes and data structures \
- Literate programming using data \
- Loops, conditional statements, functions and variable scope \
- Importing and exporting data \
- Visualization of data \
- Introduction to tidy data \
- Overview of package anatomy
