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

// author parsing
#let authors_oneline = cfg.authors.map(a => a.name).join(", ")
#if authors_oneline == none {
  authors_oneline = ""
}
#let authors_name_array = cfg.authors.map(a => a.name)

#let disable-header = cfg.disable-header
#let disable-footer = cfg.disable-footer
#let font = cfg.font
#let header-footer-font = cfg.header-footer-font

#let replace_header_content(content) = {
  if content != none {
    if content == "%page%" {
      let both = context {
        page
          .numbering
          .clusters()
          .filter(c => (
            c
              in (
                "1",
                "a",
                "A",
                "i",
                "I",
                "α",
                "Α",
                "*",
                "א",
                "一",
                "壹",
                "あ",
                "い",
                "ア",
                "イ",
                "ㄱ",
                "가",
                "\u{0661}",
                "\u{06F1}",
                "\u{0967}",
                "\u{09E7}",
                "\u{0995}",
                "①",
                "⓵",
              )
          ))
          .len()
        if both >= 2 {
          return context counter(page).display(page.numbering, both: true)
        }
      }

      return context counter(page).display(page.numbering)
    }

    return content
      .replace("%title%", cfg.title)
      .replace("%date%", cfg.date.display(cfg.dateformat))
      .replace("%author%", authors_oneline)
  }
}

#(cfg.header-left = replace_header_content(cfg.header-left))
#(cfg.header-center = replace_header_content(cfg.header-center))
#(cfg.header-right = replace_header_content(cfg.header-right))
#(cfg.footer-left = replace_header_content(cfg.footer-left))
#(cfg.footer-center = replace_header_content(cfg.footer-center))
#(cfg.footer-right = replace_header_content(cfg.footer-right))


// Define a helper for the header
#let make-header() = context {
  if disable-header != true [
    #set text(font: header-footer-font)
    #grid(
      columns: (auto, 1fr, auto),
      align: (left, center, right),
      cfg.header-left, cfg.header-center, cfg.header-right,
    )
    #v(-par.spacing + 0.5em)
    #line(length: 100%, stroke: cfg.header-footer-stroke)
  ] else []
}

// Define a helper for the footer
#let footer-left() = {
  let fl = cfg.footer-left

  if lower(fl) == "none" {
    return none
  } else {
    return fl
  }
}

#let footer-right() = {
  let fr = cfg.footer-right

  if lower(fr) == "none" {
    return none
  } else {
    return fr
  }
}

#let make-footer() = context {
  if disable-footer != true [
    #set text(font: header-footer-font)
    #line(length: 100%, stroke: cfg.header-footer-stroke)
    #v(-par.spacing + 0.5em)
    #grid(
      columns: (auto, 1fr, auto),
      align: (left, center, right),
      footer-left(), cfg.footer-center, footer-right(),
    )
  ] else []
}

// setting pdf meta data
#set document(
  title: cfg.title,
  keywords: cfg.keywords,
  date: cfg.date,
  author: authors_name_array,
)

#let margin = cfg.margin
#if disable-header == true {
  margin = (x: margin.x, top: margin.top - 3em, bottom: margin.bottom)
}

#if disable-footer == true {
  margin = (x: margin.x, top: margin.top, bottom: margin.bottom - 3em)
}

#set page(
  paper: cfg.paper,
  margin: margin,
  numbering: cfg.page-numbering,
)

#let leading = cfg.leading
#set par(
  justify: cfg.justify,
  leading: leading,
  spacing: cfg.spacing,
)

#let fontsize = cfg.fontsize

#set text(
  lang: cfg.lang,
  region: cfg.region,
  font: font,
  size: fontsize,
)

// set heading styles
#let numbering = none
#if cfg.number-sections {
  numbering = cfg.section-numbering
}

#set heading(numbering: numbering)

#show heading: set text(font: cfg.heading-font)

#show heading.where(level: 1): set text(fontsize * 1.3)
#show heading.where(level: 1): set block(above: 2.65em, below: 1.75em)

#show heading.where(level: 2): set text(fontsize * 1.1)
#show heading.where(level: 2): set block(above: 2em, below: 1.375em)

#show heading.where(level: 3): set block(above: 2em, below: 1em)

// set figure styles
#show figure: set block(above: 2em, below: 2em)

#show figure.where(kind: table): set figure.caption(position: top)
#show figure.where(kind: table): set figure(supplement: cfg.table-prefix)

#show figure.where(kind: image): set figure.caption(position: bottom)
#show figure.where(kind: image): set figure(supplement: cfg.figure-prefix)

// listings
#show figure.where(kind: raw): set figure.caption(position: bottom)
#show figure.where(kind: raw): set figure(supplement: cfg.listing-prefix)
#show figure.where(kind: raw): set align(left)

// set captions to left
#show figure.caption: set align(left)

// indent lists
#show list: set list(indent: 6pt)
#show enum: set enum(indent: 6pt)

// table styling
#let table-stroke = (x, y) => (
  left: if x == 0 { cfg.table-stroke-border-x } else { cfg.table-stroke-vertical },
  right: cfg.table-stroke-border-x,
  top: if y == 0 { cfg.table-stroke-border-y } else if y == 1 { cfg.table-stroke-header-b } else {
    cfg.table-stroke-horizontal
  },
  bottom: cfg.table-stroke-border-y,
  x: cfg.table-stroke-vertical,
  y: cfg.table-stroke-horizontal,
)

// fill for striped tables
#let striped = (x, y) => {
  if y == 0 {
    cfg.table-header-bg
  } else if calc.even(y) and y > 1 {
    cfg.table-striped-bg
  } else {
    none
  }
}

#let table-fill = (x, y) => {
  if y == 0 {
    cfg.table-header-bg
  } else {
    none
  }
}

#set table(
  stroke: table-stroke,
  inset: cfg.table-inset,
  fill: table-fill,
)

#show table: set par(justify: false, linebreaks: "optimized")
#show table: set text(hyphenate: true, costs: (hyphenation: 100000%))

// set smart quotes
#set smartquote(enabled: cfg.smartquote)

// reduce code line spacing
#show raw.where(block: true): set text(1em / 0.9)
#show raw: set text(ligatures: true, font: cfg.code-font)
