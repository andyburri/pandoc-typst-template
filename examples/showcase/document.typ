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
#let page-numbering = cfg.at("page-numbering", default: "1")
#let footer-right(
  pn: page-numbering,
) = {
  return cfg.at(
    "footer-right",
    default: counter(
      page,
    ).display(pn, both: pn.contains(regex("[ /]"))),
  )
}

#let make-footer(
  pn: page-numbering,
) = context {
  if cfg.at("disable-header-and-footer", default: false) != true [
    #line(length: 100%, stroke: cfg.at("header-and-footer-stroke", default: 1pt + black))
    #v(-par.spacing + 0.5em)
    #grid(
      columns: (1fr, auto, 1fr),
      align: (left, center, right),
      cfg.at("footer-left", default: authors.map(author => author.name).join(", ")),
      cfg.at("footer-center", default: none),
      footer-right(pn: pn),
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
  numbering: page-numbering,
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

#set math.equation(numbering: "\(1)".replace("\(", "("))


#import "@preview/note-me:0.6.0": *




#set page(
  header: make-header(),
  footer: make-footer(pn: "I"),
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
  header: make-header(),
  footer: make-footer(pn: page-numbering),
  columns: cfg.at("columns", default: 1),
)

#counter(page).update(1)

= Feature Showcase
<feature-showcase>
This document demonstrates all the features available in the
typst-pandoc converter.

== Text Formatting
<text-formatting>
Basic formatting includes #strong[bold], #emph[italic], and
#strong[#emph[bold italic]] text. You can also use
#strike[strikethrough] and `inline code`.

== Headings
<headings>
=== Level 3 Heading
<level-3-heading>
==== Level 4 Heading
<level-4-heading>
===== Level 5 Heading
<level-5-heading>
====== Level 6 Heading
<level-6-heading>
== Lists
<lists>
=== Unordered Lists
<unordered-lists>
- Item 1
- Item 2
  - Nested item 2.1
  - Nested item 2.2
- Item 3

=== Ordered Lists
<ordered-lists>
+ First item
+ Second item
  + Nested item 2.1
  + Nested item 2.2
+ Third item

=== Definition Lists
<definition-lists>
/ Term 1: #block[
Definition 1
]

/ Term 2: #block[
Definition 2.1

Definition 2.2
]

== Tables
<tables>
#figure(
  align(center)[#table(
    columns: 3,
    align: (right,left,center,),
    fill: striped,
    table.header([Feature], [Description], [Support],),
    table.hline(),
    [Tables], [Basic tables with alignment], [✓],
    [Lists], [Ordered and unordered lists], [✓],
    [Code], [Syntax highlighting], [✓],
  )]
  , kind: table
  )
== Code Blocks
<code-blocks>
#figure(```python
def hello_world():
    print("Hello, World!")
```
)
#figure(```typescript
function greet(name: string): void {
  console.log(`Hello, ${name}!`);
}
```
)
== Blockquotes
<blockquotes>
#quote(block: true)[
This is a blockquote. It can span multiple lines.

#quote(block: true)[
And it can be nested.
]
]

== Images
<images>
Here's an example image:

#figure(image("https://images.unsplash.com/photo-1516383274235-5f42d6c6426d?auto=format&fit=crop&w=1000&q=80", width: 75.0%),
  caption: [
    Example graph showing data visualization
  ]
)

== Mathematical Equations
<mathematical-equations>
Inline math: $E = m c^2$

Display math:

$ integral_a^b x^2 d x = [x^3 / 3]_a^b $

<formula-one>

This is a reference to @formula-one

== Cross-references
<cross-references>
See #link(<tables>)[Section Tables] for more information.

== Abbreviations
<abbreviations>
The HTML{.abbr title="HyperText Markup Language"} specification is
maintained by the W3C{.abbr title="World Wide Web Consortium"}.

== Footnotes
<footnotes>
Here's a sentence with a footnote#footnote[This is the footnote
content.].

== Horizontal Rule
<horizontal-rule>

#horizontalrule

== Custom Divs
<custom-divs>
#block[
This is a warning message styled with custom CSS.

]
#block[
This is a note message styled differently.

]
== Mermaid Code
<mermaid-code>
#box(image("8e349b70ff1c7b0cc952a26f8c910dcb3657af95.svg"))
== Grid Table
<grid-table>
#[
#show figure: set align(left)
#figure(
  align(center)[#table(
    columns: (27.78%, 8.33%),
    align: (center,right,),
    table.header(table.cell(colspan: 2)[#strong[Percentages]],),
    table.hline(),
    [Fortyfive], [45%],
    [Twenty], [20%],
    [Thirtyfive], [35%],
  )]
  , kind: table
  )
]

