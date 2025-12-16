//load defaults cfg dict
#let cfg = (:)
// overwrite defaults from pandoc variables


#(cfg.toc-depth = 3)
#(cfg.abstract-title = "Abstract")

// for markdown hr
#let horizontalrule = line(start: (25%, 0%), end: (75%, 0%))

// definition list styling
#show terms: it => {
  it
    .children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em))[#child.description]
    ])
    .join()
}

#let authors = cfg.at("authors", default: ((name: "", email: "", affiliation: ""),))
#let disable-header-footer = cfg.at("disable-header-and-footer", default: false)

// Define a helper for the header
#let make-header() = context {
  if disable-header-footer != true [
    #grid(
      columns: (1fr, auto, 1fr),
      align: (left, center, right),
      cfg.at("header-left", default: cfg.at("title", default: none)),
      cfg.at("header-center", default: none),
      cfg.at(
        "header-right",
        default: cfg
          .at("date", default: datetime.today())
          .display(cfg.at("dateformat", default: "[year]-[month]-[day]")),
      ),
    )
    #v(-par.spacing + 0.5em)
    #line(length: 100%, stroke: cfg.at("header-and-footer-stroke", default: 1pt + black))
  ] else []
}

// Define a helper for the footer
#let footer-right() = {
  return cfg.at(
    "footer-right",
    default: counter(
      page,
    ).display(page.numbering, both: page.numbering.contains(regex("[ /]"))),
  )
}

#let make-footer() = context {
  if cfg.at("disable-header-and-footer", default: false) != true [
    #line(length: 100%, stroke: cfg.at("header-and-footer-stroke", default: 1pt + black))
    #v(-par.spacing + 0.5em)
    #grid(
      columns: (1fr, auto, 1fr),
      align: (left, center, right),
      cfg.at("footer-left", default: authors.map(author => author.name).join(", ")),
      cfg.at("footer-center", default: none),
      footer-right(),
    )
  ] else []
}

// setting pdf meta data
#set document(
  title: cfg.at("title", default: none),
  keywords: cfg.at("keywords", default: ""),
  date: cfg.at("date", default: datetime.today()),
  author: authors.map(author => author.name).join(", "),
)

#let margin = cfg.at("margin", default: (x: 2.5cm, y: 3.5cm))
#if disable-header-footer == true {
  margin = margin.y - 3em
}

#set page(
  paper: cfg.at("paper", default: "a4"),
  margin: margin,
  numbering: cfg.at("page-numbering", default: "1"),
)

#let leading = cfg.at("leading", default: 0.65em)
#set par(
  justify: cfg.at("justify", default: true),
  leading: leading,
  spacing: cfg.at("spacing", default: 1.2em),
)

#let font = cfg.at("font", default: ("noto sans", "arial"))
#let fontsize = cfg.at("fontsize", default: 11pt)

#set text(
  lang: cfg.at("lang", default: "en"),
  region: cfg.at("region", default: "US"),
  font: font,
  size: fontsize,
)

// set heading styles
#let numbering = none
#if cfg.at("number-sections", default: false) {
  numbering = cfg.at("section-numbering", default: "1.1.1.1.1")
}

#set heading(numbering: numbering)

#show heading: set text(font: cfg.at("heading-font", default: font))

#show heading.where(level: 1): set text(fontsize * 1.3)
#show heading.where(level: 1): set block(above: 2.65em, below: 1.75em)

#show heading.where(level: 2): set text(fontsize * 1.1)
#show heading.where(level: 2): set block(above: 2em, below: 1.375em)

// #show heading.where(level: 3): set text(fontsize * 1.1)
#show heading.where(level: 3): set block(above: 3.25em, below: 1em)

// set figure styles
#show figure: set block(above: 2em, below: 2em)

#show figure.where(kind: table): set figure.caption(position: top)
#show figure.where(kind: table): set figure(supplement: cfg.at("table-prefix", default: "Table"))

#show figure.where(kind: image): set figure.caption(position: bottom)
#show figure.where(kind: image): set figure(supplement: cfg.at("figure-prefix", default: "Fig."))

// listings
#show figure.where(kind: raw): set figure.caption(position: bottom)
#show figure.where(kind: raw): set figure(supplement: cfg.at("listing-prefix", default: "Listing"))
#show figure.where(kind: raw): set align(left)

// set captions to left
#show figure.caption: set align(left)

// indent lists
#show list: set list(indent: 6pt)
#show enum: set enum(indent: 6pt)

// table styling
#let table-stroke = (_, y) => (
  left: { 0pt },
  right: { 0pt },
  top: if y < 1 { stroke(1pt + luma(120)) } else if y == 1 { none } else { 0pt },
  bottom: if y < 1 { stroke(.5pt + luma(120)) } else { stroke(1pt + luma(120)) },
)

// fill for striped tables
#let striped = (x, y) => {
  if calc.even(y) and y > 1 {
    luma(230)
  } else {
    none
  }
}

#set table(
  stroke: table-stroke,
  inset: 6pt,
)

#show table: set par(justify: false, linebreaks: "optimized")
#show table: set text(hyphenate: true, costs: (hyphenation: 100000%))

// set smart quotes
#set smartquote(enabled: cfg.at("smart", default: true))

// reduce code line spacing
#show raw.where(block: true): set text(1em / 0.9)
#show raw: set text(ligatures: true, font: cfg.at("code-font", default: ("noto mono", "courier new")))
// listings
#show raw.where(block: true): code => {
    block(above: 1.5em, below: 1.5em)[
      #set par(leading: leading * 0.75)
      #code
    ]
}



#import "@preview/note-me:0.6.0": *




#set page(
  numbering: "I",
  header: make-header(),
  footer: make-footer(),
)

// set links to underline
#show link: it => {
  if type(it.dest) == str {
    underline(it)
  } else {
    it
  }
}

#if cfg.at("abstract", default: none) != none {
  heading(cfg.at("abstract-title", default: "Abstract"), numbering: none, outlined: false)
  cfg.abstract
}

#if cfg.at("thanks", default: none) != none {
  heading(cfg.at("thanks-title", default: "Acknowledgements"), numbering: none, outlined: false)
  cfg.thanks
}

#if cfg.at("thanks", default: none) != none or cfg.at("abstract", default: none) != none {
  pagebreak()
}

#set page(
  numbering: cfg.at("page-numbering", default: "1"),
  header: make-header(),
  footer: make-footer(),
  columns: cfg.at("columns", default: 1),
)

#counter(page).update(1)

= Outline
<outline>
#outline(target: figure.where(kind: table))

#figure(```markdown
`#outline(target: figure.where(kind: table))`{=typst}
```
)
= Tables Example
<tables-example>
#figure(
  align(center)[#table(
    columns: (12.39%, 14.16%, 73.45%),
    align: (left,center,right,),
    table.header([Column One], [Column Two], [Column Three],),
    table.hline(),
    [Row One Left], [Row One Center], [Row One Right, which should
    automatically break if it reaches the width of the page],
    [Row Two Left], [Row Two Center], [Row Two Right],
    [Row Three Left], [Row Three Center], [Row Three Right],
  )]
  , caption: [Tables Caption]
  , kind: table
  )
= Striped Table `{typst:fill=striped}`
<striped-table-typstfillstriped>
#figure(
  align(center)[#table(
    columns: 3,
    align: (left,center,right,),
    fill: striped,
    table.header([Column One], [Column Two], [Column Three],),
    table.hline(),
    [Row One Left], [Row One Center], [Row One Right],
    [Row Two Left], [Row Two Center], [Row Two Right],
    [Row Three Left], [Row Three Center], [Row Three Right],
    [Row Four Left], [Row Four Center], [Row Four Right],
  )]
  , caption: [Striped Table]
  , kind: table
  )
= Table aligned left `{align=left}`
<table-aligned-left-alignleft>
#[
#show figure: set align(left)
#figure(
  align(center)[#table(
    columns: 3,
    align: (left,center,right,),
    table.header([Column One], [Column Two], [Column Three],),
    table.hline(),
    [Row One Left], [Row One Center], [Row One Right],
    [Row Two Left], [Row Two Center], [Row Two Right],
  )]
  , caption: [Left Table]
  , kind: table
  )
]

= Table right aligned `{align=right .unlisted}`
<table-right-aligned-alignright-.unlisted>
#[
#show figure: set align(right)
#figure(
  align(center)[#table(
    columns: 3,
    align: (left,center,right,),
    table.header([Column One], [Column Two], [Column Three],),
    table.hline(),
    [Row One Left], [Row One Center], [Row One Right],
    [Row Two Left], [Row Two Center], [Row Two Right],
  )]
  , caption: [Unlisted Table]
, numbering: none,
  outlined: false,
  kind: table
  )
]

= Plain Table
<plain-table>
#figure(
  align(center)[#table(
    columns: 3,
    align: (left,auto,auto,),
    stroke: none,
    [Row One], [Row One], [Row One],
    [Row Two], [Row Two], [Row Two],
    [Row Three], [Row Three], [Row Three],
  )]
  , caption: [Plain Table]
  , kind: table
  )
= Table with custom column widths `{columns="(25%, 30%, 1fr)"}`
<table-with-custom-column-widths-columns25-30-1fr>
#figure(
  align(center)[#table(
    columns: (25%, 30%, 1fr),
    align: (left,left,left,),
    table.header([Column One], [Column Two], [Column Three],),
    table.hline(),
    [Row One Left with some Fachverantwortlicher], [Row One
    Center], [Row One Right],
    [Row Two Left], [Row Two Center], [Row Two Right],
    [Row Three Left], [Row Three Center \
    Row Three after break], [Row Three Right],
  )]
  , caption: [Tables Caption]
  , kind: table
  )
