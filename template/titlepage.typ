#set page(
  numbering: none,
  margin: (left: 5cm),
  fill: cfg.titlepage-bg,
)
#set text(fill: cfg.titlepage-fg)

#line(length: 100% + margin.x, stroke: cfg.titlepage-rule)

#if cfg.title != none [
  #v(20%)
  #show title: set text(size: 0.9em)
  #title[#cfg.title]
]

#if cfg.subtitle != none [
  #v(0.65em)
  #text(size: 1.1em)[#cfg.subtitle]
]

#if cfg.titlepage-supervisor != none [
  #v(2em)
  #cfg.titlepage-supervisor
  #v(2em)
]

#v(2em)
#let count = cfg.authors.len()
#let ncols = calc.min(count, 3)
#grid(
  columns: (1fr,) * ncols,
  row-gutter: 24pt,
  ..cfg.authors.map(author => [
    #author.name \
    #author.affiliation \
    #link("mailto:" + author.email.replace("\\", ""))
  ]),
)


#let logo = none

#if cfg.titlepage-logo != none {
  logo = box(image(cfg.titlepage-logo, width: cfg.titlepage-logo-width))
}

#v(1fr)

#cfg.date.display(cfg.dateformat)
#h(1fr)
#logo

// start page numbers after title page
#counter(page).update(0)

// reset margin and fill
#set page(
  margin: margin,
  fill: none,
)

#set text(fill: black)
