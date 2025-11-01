#import "defaults.typ"

#let conf(
  title: none,
  subtitle: none,
  authors: defaults.authors,
  dozent: none,
  dozentin: none,
  date: defaults.date,
  abstract: none,
  abstract-title: none,
  margin: defaults.margin,
  paper: defaults.paper,
  lang: defaults.lang,
  region: defaults.region,
  font: defaults.font,
  fontsize: defaults.fontsize,
  pagenumbering: defaults.pagenumbering,
  titlepage: defaults.titlepage,
  titlepage-rule: defaults.titlepage-rule,
  titlepage-bg: defaults.titlepage-bg,
  titlepage-fg: defaults.titlepage-fg,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
  )

  set par(
    justify: true,
    leading: 0.8em,
    spacing: 2em,
  )
  set text(lang: lang, region: region, font: font, size: fontsize)

  // set heading styles
  show heading.where(level: 1): set block(above: 3em, below: 1.75em)
  show heading.where(level: 1): set text(fontsize * 1.25)

  show heading.where(level: 2): set block(above: 2.5em, below: 1.5em)
  show heading.where(level: 2): set text(fontsize * 1.1)

  show heading.where(level: 3): set block(above: 1.75em, below: 1em)

  // set figure styles
  show figure.where(kind: table): set block(above: 2em, below: 2em)
  show figure.where(kind: image): set block(above: 2em, below: 2em)

  // set table caption to top
  show figure.where(
    kind: table,
  ): set figure.caption(position: top)

  // set image caption to bottom
  show figure.where(
    kind: image,
  ): set figure.caption(position: bottom)

  // set captions to left
  show figure.caption: set align(left)

  if titlepage {
    let fg-color = black
    let bg-color = white

    if titlepage-fg != none {
      if titlepage-fg.starts-with("\\#") {
        fg-color = rgb(titlepage-fg.replace("\\", ""))
      }
    }

    if titlepage-bg != none {
      if titlepage-bg.starts-with("\\#") {
        bg-color = rgb(titlepage-bg.replace("\\", ""))
      }
    }

    set page(
      numbering: none,
      margin: (left: 5cm),
      fill: bg-color,
    )
    set text(fill: fg-color)

    line(length: 100% + margin.x - 3mm, stroke: titlepage-rule)

    if title != none {
      align(left)[
        #v(20%)
        #text(weight: "bold", size: 1.5em)[#title]
      ]
    }

    if subtitle != none {
      align(left)[
        #v(-1em)
        #text(size: 1.1em)[#subtitle]
      ]
    }

    if dozent != none {
      align(left)[
        #v(1em)
        #text(weight: "bold", size: 1.2em)[Dozent:]
        #text(size: 1.2em)[#dozent]
      ]
    }

    if dozentin != none {
      align(left)[
        #v(1em)
        #text[Dozentin: #dozentin]
      ]
    }

    if authors != none {
      v(2em)
      let count = authors.len()
      let ncols = calc.min(count, 3)
      grid(
        columns: (1fr,) * ncols,
        row-gutter: 24pt,
        ..authors.map(author => [
          #author.name \
          #author.affiliation \
          #link("mailto:" + author.email.replace("\\", ""))
        ]),
      )
    }

    if date != none {
      align(left + bottom)[
        #date
        #v(3cm)
      ]
    }

    counter(page).update(0)
  }

  set page(
    footer: context [
      #line(length: 100%)
      #v(-1.5em)
      #if authors != none {
        authors.map(author => author.name).join(", ")
      }
      #h(1fr)
      #counter(page).display(
        "1/1",
        both: true,
      )
    ],
  )

  if abstract != none {
    block(inset: 2em)[
      #text(weight: "semibold")[Abstract] #h(1em) #abstract
    ]
  }

  doc
}
