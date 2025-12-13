#set page(
  numbering: none,
  margin: (left: 5cm),
  fill: cfg.at("titlepage-bg", default: white),
)
#set text(fill: cfg.at("titlepage-fg", default: black))

#line(length: 100% + margin.x, stroke: cfg.at("titlepage-rule", default: 2.5pt + black))

#if cfg.at("title", default: none) != none [
  #v(20%)
  #show title: set text(size: 0.9em)
  #title[#cfg.title]
]

#if cfg.at("subtitle", default: none) != none [
  #v(0.65em)
  #text(size: 1.1em)[#cfg.subtitle]
]

#if cfg.at("supervisor", default: none) != none [
  #v(2em)
  #cfg.supervisor
  #v(2em)
]

#if authors != none {
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

#let logo = none

#if cfg.at("titlepage-logo", default: none) != none {
  logo = box(image(cfg.titlepage-logo, width: cfg.at("titlepage-logo-width", default: 12em)))
}

#v(1fr)

#cfg.at("date", default: datetime.today()).display(cfg.at("dateformat", default: "[year]-[month]-[day]"))
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
