//load defaults cfg dict
// The base configuration for the template
// Don't delete any keys in this dictionary. The template depends on them.

#let cfg = (
  // Metadata
  date: "%today%", // use ISO format like 2022-01-01
  dateformat: "[year]-[month]-[day]",
  authors: (),
  title: "",
  subtitle: "",
  keywords: "",
  lang: "en",
  region: "US",
  // Layout
  margin: (x: 2.5cm, top: 3.5cm, bottom: 3.5cm),
  paper: "a4",
  columns: 1,
  color-fg: black,
  color-bg: white,
  // Numbering
  page-numbering: "1",
  page-numbering-both: false,
  number-sections: false,
  section-numbering: "1.1.1.1.1",
  // Typography
  font: "noto sans",
  heading-font: "noto sans",
  code-font: "noto mono",
  header-footer-font: "noto sans",
  fontsize: 11pt,
  leading: 0.65em,
  spacing: 1.2em,
  justify: true,
  smartquote: true,
  // Titlepage
  titlepage-rule: 3pt + black,
  titlepage-bg: white,
  titlepage-fg: black,
  titlepage-logo: none,
  titlepage-logo-width: none,
  titlepage-supervisor: none,
  // Table of contents
  toc: false,
  toc-depth: 6,
  toc-title: "Table of contents",
  toc-own-page: false,
  lof: false,
  lof-title: "List of figures",
  lof-own-page: false,
  lot: false,
  lot-title: "List of tables",
  lot-own-page: false,
  toc-page-numbering: "I",
  // Header and footer
  header-footer-stroke: 1pt + black,
  disable-header: false,
  disable-footer: false,
  header-left: "%title%",
  header-center: none,
  header-right: "%date%",
  footer-left: "%author%",
  footer-center: none,
  footer-right: "%page%",
  // Abstract
  abstract-title: "Abstract",
  abstract: none,
  abstract-own-page: false,
  thanks-title: "Thanks",
  thanks: none,
  // Figures
  figure-prefix: "Fig.",
  table-prefix: "Table",
  listing-prefix: "Listing",
  // Tables
  table-header-bg: luma(200),
  table-striped-bg: luma(230),
  table-stroke-border-x: 1pt + black,
  table-stroke-border-y: 1pt + black,
  table-stroke-header-b: 1pt + black,
  table-stroke-horizontal: 1pt + black,
  table-stroke-vertical: 1pt + black,
  table-inset: 6pt,
  // Other
  listings: false,
  equation-numbering: none,
  glossary: none,
)
// load and join user cfg
#let user_cfg = none
// these values override base values if provided

#let user_cfg = (
  dateformat: "[day].[month].[year]",
  authors: (),
  keywords: "",
  lang: "de",
  region: "CH",
  table-header-bg: orange.lighten(75%),
  table-striped-bg: orange.lighten(90%),
  table-stroke-border-x: none,
  table-stroke-border-y: 1.5pt + orange.darken(50%),
  table-stroke-header-b: 1.5pt + orange.darken(50%),
  table-stroke-vertical: 0pt,
  table-stroke-horizontal: 1pt + orange.darken(50%),
)
#(cfg = cfg + user_cfg)

// overwrite base config from pandoc variables
#let parsedDate = "2015-01-01"
#if type(parsedDate) == str {
  let dateArray = parsedDate.split("-")
  parsedDate = datetime(
    year: int(dateArray.at(0)),
    month: int(dateArray.at(1)),
    day: int(dateArray.at(2)),
  )
}
#(cfg.date = parsedDate)

// replace date placeholder
#if cfg.date == "%today%" {
  (cfg.date = datetime.today())
}


#(cfg.authors = (
    ( name: "Firstname Lastname",
      affiliation: "Wizard University",
      email: "firstname.lastname\@example.com",
    ),
  ))
#(cfg.title = "This is the title of the thesis")
#(cfg.subtitle = "This is the subtitle of the thesis")
#(cfg.supervisor = "Supervision: Professor Louis Fage")
#(cfg.lang = "en")
#(cfg.toc = true)
#(cfg.toc-depth = 3)
#(cfg.lof = true)
#(cfg.lot = true)
#(cfg.number-sections = true)
#(cfg.abstract-title = [Abstract])
#(cfg.abstract = [Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam et turpis gravida, lacinia ante sit amet, sollicitudin erat. Aliquam efficitur vehicula leo sed condimentum. Phasellus lobortis eros vitae rutrum egestas. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec at urna imperdiet, vulputate orci eu, sollicitudin leo. Donec nec dui sagittis, malesuada erat eget, vulputate tellus. Nam ullamcorper efficitur iaculis. Mauris eu vehicula nibh. In lectus turpis, tempor at felis a, egestas fermentum massa.

])
#(cfg.thanks = [Interdum et malesuada fames ac ante ipsum primis in faucibus. Aliquam congue fermentum ante, semper porta nisl consectetur ut. Duis ornare sit amet dui ac faucibus. Phasellus ullamcorper leo vitae arcu ultricies cursus. Duis tristique lacus eget metus bibendum, at dapibus ante malesuada. In dictum nulla nec porta varius. Fusce et elit eget sapien fringilla maximus in sit amet dui.

Mauris eget blandit nisi, faucibus imperdiet odio. Suspendisse blandit dolor sed tellus venenatis, venenatis fringilla turpis pretium. Donec pharetra arcu vitae euismod tincidunt. Morbi ut turpis volutpat, ultrices felis non, finibus justo. Proin convallis accumsan sem ac vulputate. Sed rhoncus ipsum eu urna placerat, sed rhoncus erat facilisis. Praesent vitae vestibulum dui. Proin interdum tellus ac velit varius, sed finibus turpis placerat.

])

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
#show raw: set text(ligatures: true, font: cfg.code-font)// YAML-driven tables: load YAML, normalize to a grid, render Typst tables.

// --- cell / column helpers ---

#let yaml-cell(value) = {
  if type(value) == dictionary and value.at("markup", default: false) == true {
    let text = value.at("value", default: value.at("text", default: none))
    eval(str(if text != none { text } else { "" }), mode: "markup")
  } else if type(value) == str and value.ends-with("!markup") {
    eval(value.slice(0, value.len() - 7), mode: "markup")
  } else {
    [#value]
  }
}

#let parse-align(a) = {
  if a == auto {
    auto
  } else if type(a) == str {
    if a == "left" { left } else if a == "center" { center } else if a == "right" { right } else {
      panic("unknown column align: " + a)
    }
  } else {
    a
  }
}

#let parse-width(w) = {
  if w == auto {
    auto
  } else if type(w) == str {
    eval(w)
  } else {
    w
  }
}

#let parse-column-spec(col) = {
  if type(col) == dictionary and "id" in col {
    (
      id: str(col.id),
      label: col.at("label", default: str(col.id)),
      align: parse-align(col.at("align", default: auto)),
      width: parse-width(col.at("width", default: auto)),
    )
  } else if type(col) == dictionary {
    let keys = col.keys()
    if keys.len() != 1 {
      panic("column entry must have id/label or be a single-key dictionary")
    }
    let id = keys.at(0)
    (
      id: str(id),
      label: col.at(id),
      align: auto,
      width: auto,
    )
  } else {
    panic("invalid column spec: " + repr(col))
  }
}

#let row-cells(row, col-ids) = {
  col-ids.map(id => {
    if id not in row {
      panic("row missing column '" + id + "': " + repr(row))
    }
    yaml-cell(row.at(id))
  })
}

#let legacy-single-key-rows(rows, col-ids) = {
  let grouped = ()
  let buf = (:)
  for row in rows {
    if type(row) != dictionary {
      panic("expected dictionary row in legacy map format")
    }
    let keys = row.keys()
    if keys.len() != 1 {
      return none
    }
    let key = keys.at(0)
    let val = row.at(key)
    buf.insert(str(key), val)
    if buf.len() == col-ids.len() {
      grouped.push(row-cells(buf, col-ids))
      buf = (:)
    }
  }
  if buf.len() != 0 {
    panic("legacy row list does not divide evenly into " + str(col-ids.len()) + " columns")
  }
  grouped
}

#let rows-are-legacy-single-key(rows) = {
  if rows.len() == 0 {
    return false
  }
  rows.all(row => type(row) == dictionary and row.len() == 1)
}

// --- schema detection ---

#let detect-schema(raw) = {
  if type(raw) == dictionary {
    if "headers" in raw and "rows" in raw and type(raw.headers) == array {
      if raw.rows.len() > 0 and type(raw.rows.at(0)) == array {
        return "matrix"
      }
    }
    if "columns" in raw and "rows" in raw {
      return "map"
    }
    let reserved = ("columns", "rows", "headers")
    let keys = raw.keys()
    if keys.all(k => k not in reserved) {
      return "kv"
    }
  }
  if type(raw) == array and raw.len() > 0 and type(raw.at(0)) == dictionary {
    return "records"
  }
  panic(
    "could not detect YAML table schema; set schema: explicitly\n" + "data: " + repr(raw),
  )
}

// --- normalizers → grid model ---

// grid: (headers, rows, col-keys, col-aligns, col-widths, header-default)
#let normalize-kv(raw) = {
  let pairs = raw.pairs()
  let rows = pairs.map(p => (yaml-cell(p.at(0)), yaml-cell(p.at(1))))
  (
    headers: none,
    rows: rows,
    col-keys: ("key", "value"),
    col-aligns: (auto, auto),
    col-widths: (auto, auto),
    header-default: false,
  )
}

#let normalize-matrix(raw) = {
  let headers = raw.headers.map(h => yaml-cell(h))
  let n = headers.len()
  let rows = raw.rows.map(r => {
    if r.len() != n {
      panic("matrix row length " + str(r.len()) + " != header count " + str(n))
    }
    r.map(c => yaml-cell(c))
  })
  (
    headers: headers,
    rows: rows,
    col-keys: headers.map(h => repr(h)),
    col-aligns: headers.map(_ => auto),
    col-widths: headers.map(_ => auto),
    header-default: true,
  )
}

#let normalize-map(raw) = {
  let col-specs = raw.columns.map(parse-column-spec)
  let col-ids = col-specs.map(c => c.id)
  let headers = col-specs.map(c => yaml-cell(c.label))
  let col-aligns = col-specs.map(c => c.align)
  let col-widths = col-specs.map(c => c.width)

  let data-rows = if rows-are-legacy-single-key(raw.rows) {
    legacy-single-key-rows(raw.rows, col-ids)
  } else {
    raw.rows.map(row => {
      if type(row) != dictionary {
        panic("map row must be a dictionary")
      }
      row-cells(row, col-ids)
    })
  }

  if data-rows == none {
    panic("failed to normalize map rows")
  }

  (
    headers: headers,
    rows: data-rows,
    col-keys: col-ids,
    col-aligns: col-aligns,
    col-widths: col-widths,
    header-default: raw.at("header", default: true),
  )
}

#let normalize-records(raw) = {
  let col-ids = if raw.len() > 0 {
    raw.at(0).keys().map(k => str(k))
  } else {
    ()
  }
  let headers = col-ids.map(id => yaml-cell(id))
  let rows = raw.map(row => row-cells(row, col-ids))
  (
    headers: headers,
    rows: rows,
    col-keys: col-ids,
    col-aligns: col-ids.map(_ => auto),
    col-widths: col-ids.map(_ => auto),
    header-default: true,
  )
}

#let normalize(raw, schema) = {
  let kind = if schema == auto {
    detect-schema(raw)
  } else if type(schema) == str {
    schema
  } else {
    panic("schema must be auto or a string")
  }

  if kind == "kv" {
    normalize-kv(raw)
  } else if kind == "map" or kind == "grid" {
    normalize-map(raw)
  } else if kind == "matrix" {
    normalize-matrix(raw)
  } else if kind == "records" {
    normalize-records(raw)
  } else {
    panic("unknown schema: " + repr(kind))
  }
}

// --- rendering ---

#let resolve-fill(fill, has-header: true) = {
  if has-header {
    if fill == none or fill == auto {
      none
    } else if fill == "striped" {
      (x, y) => {
        if y == 0 {
          cfg.table-header-bg
        } else if calc.even(y) {
          cfg.table-striped-bg
        } else {
          none
        }
      }
    } else {
      fill
    }
  } else if fill == none or fill == auto {
    // Without table.header(), row 0 is data — override global header-row fill.
    (x, y) => if y == 0 { white } else { none }
  } else if fill == "striped" {
    (x, y) => {
      if calc.even(y) {
        cfg.table-striped-bg
      } else {
        none
      }
    }
  } else {
    let base = fill
    (x, y) => if y == 0 { white } else { base(x, y) }
  }
}

#let resolve-stroke(stroke, has-header: true) = {
  if has-header {
    stroke
  } else if stroke == auto {
    // Without table.header(), row 1 is data — use horizontal stroke, not header-b.
    table-stroke
  } else if type(stroke) == function {
    (x, y) => {
      let s = table-stroke(x, y)
      if y == 1 and type(s) == dictionary {
        s + (top: cfg.table-stroke-horizontal)
      } else {
        s
      }
    }
  } else {
    stroke
  }
}

#let resolve-header(header, grid) = {
  if header == auto {
    if grid.header-default {
      grid.headers
    } else {
      none
    }
  } else if header == false {
    none
  } else if header == true {
    grid.headers
  } else if type(header) == array {
    header.map(h => yaml-cell(h))
  } else {
    panic("header must be auto, true, false, or an array")
  }
}

#let build-table-args(
  grid,
  header-cells,
  columns,
  align,
  fill,
  stroke,
  inset,
  strong-header,
  table-args,
) = {
  let n = grid.col-keys.len()

  let col-spec = if columns != auto {
    columns
  } else {
    let ws = grid.col-widths
    if ws.all(w => w == auto) {
      // Typst defaults to a single column unless columns is set explicitly.
      n
    } else {
      ws
    }
  }

  let col-aligns = if align != auto {
    align
  } else {
    let grid-aligns = grid.col-aligns
    if grid-aligns.all(a => a == auto) {
      auto
    } else {
      grid-aligns
    }
  }

  let has-header = header-cells != none
  let resolved-fill = resolve-fill(fill, has-header: has-header)
  let resolved-stroke = resolve-stroke(stroke, has-header: has-header)

  let args = (columns: col-spec)
  if col-aligns != auto {
    args.insert("align", col-aligns)
  }
  if resolved-fill != none {
    args.insert("fill", resolved-fill)
  }
  if resolved-stroke != auto {
    args.insert("stroke", resolved-stroke)
  }
  if inset != auto {
    args.insert("inset", inset)
  }
  for (k, v) in table-args.named() {
    args.insert(str(k), v)
  }

  let header-row = if header-cells != none {
    let cells = if strong-header {
      header-cells.map(c => strong(c))
    } else {
      header-cells
    }
    (table.header(..cells), table.hline())
  } else {
    ()
  }

  let flat-rows = ()
  for row in grid.rows {
    for cell in row {
      flat-rows.push(cell)
    }
  }

  (args: args, header-row: header-row, flat-rows: flat-rows)
}

#let yaml-table(
  path,
  schema: auto,
  header: auto,
  columns: auto,
  align: auto,
  fill: none,
  stroke: auto,
  inset: auto,
  strong-header: true,
  as-figure: false,
  caption: none,
  kind: table,
  ..table-args,
) = {
  let raw = yaml(path)
  let grid = normalize(raw, schema)
  let header-cells = resolve-header(header, grid)
  let built = build-table-args(
    grid,
    header-cells,
    columns,
    align,
    fill,
    stroke,
    inset,
    strong-header,
    table-args,
  )

  let tbl = table(..built.args, ..built.header-row, ..built.flat-rows)

  if as-figure {
    figure(tbl, caption: caption, kind: kind)
  } else {
    tbl
  }
}

#let yaml-table-figure(path, caption: none, ..args) = {
  yaml-table(path, as-figure: true, caption: caption, ..args)
}
// listings
#show raw.where(block: true): code => {
    block(
      fill: gray.lighten(92%),
      inset: 1em,
      stroke: 0.5pt + gray,
      width: 100%,
    )[
      #grid(
        columns: (auto, auto),
        column-gutter: 1em,
        row-gutter: leading * 0.75,
        align: (right, raw.align),
        ..for line in code.lines {
          (
            text(fill: gray)[#line.number],
            line.body,
          )
        },
      )
    ]
}

#set math.equation(numbering: "\(1)".replace("\(", "("))

#import "@preview/glossarium:0.5.10": make-glossary, register-glossary, print-glossary, gls, glspl
#show: make-glossary
#let glossary-data = yaml("glossary.yaml")

#let new-glossary-data = ()
#for arr in glossary-data {
  if arr.at("description", default: none) != none {
    arr.description = eval(arr.description, mode: "markup")
    new-glossary-data.push(arr)
  } else {
    new-glossary-data.push(arr)
  }
}

#(glossary-data = new-glossary-data)

#register-glossary(glossary-data)

#import "@preview/note-me:0.6.0": *



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

#if cfg.abstract != none {
  heading(cfg.abstract-title, numbering: none, outlined: false)
  cfg.abstract

  if cfg.abstract-own-page {
    pagebreak()
  }
}


#if cfg.thanks != none {
  heading(cfg.thanks-title, numbering: none, outlined: false)
  cfg.thanks
}

#if cfg.thanks != none or cfg.abstract != none {
  pagebreak()
}
#set page(
  numbering: cfg.toc-page-numbering,
)

#show outline.entry.where(
  level: 1,
): set block(above: 0.75em)

#outline(
  title: cfg.toc-title,
  depth: cfg.toc-depth,
)

#if cfg.toc-own-page {
  pagebreak()
}

#if cfg.lof {
  outline(
    title: cfg.lof-title,
    target: figure.where(kind: image),
  )

  if cfg.lof-own-page {
    pagebreak()
  }
}

#if cfg.lot {
  outline(
    title: cfg.lot-title,
    target: figure.where(kind: table),
  )

  if cfg.lot-own-page {
    pagebreak()
  }
}

#set page(
  numbering: cfg.page-numbering,
)
#set page(
  numbering: cfg.page-numbering,
  header: make-header(),
  footer: make-footer(),
  columns: cfg.columns,
)

#counter(page).update(1)

= Literature review, with maths
<sec:lit-review>
== Introduction
<introduction>
This is the introduction. Duis in neque felis. In hac habitasse platea
dictumst. Cras eget rutrum elit. Pellentesque tristique venenatis
pellentesque. Cras eu dignissim quam, vel sodales felis. Vestibulum
efficitur justo a nibh cursus eleifend. Integer ultrices lorem at nunc
efficitur lobortis.

== The middle
<the-middle>
This is the literature review. Nullam quam odio, volutpat ac ornare
quis, vestibulum nec nulla. Aenean nec dapibus in $m L\/m i n^(- 1)$.
Mathematical formula can be inserted using Latex and can be
automatically numbered:

$ f\(x\)= a x^3 + b x^2 + c x + d $ <eq:my_equation>

Nunc eleifend, ex a luctus porttitor, felis ex suscipit tellus, ut
sollicitudin sapien purus in libero. Nulla blandit eget urna vel tempus.
Praesent fringilla dui sapien, sit amet egestas leo sollicitudin at.

Later on in the text, you can reference @eq:my_equation and its
mind-blowing ramifications. Pellentesque habitant morbi tristique
senectus et netus et malesuada fames ac turpis egestas. Sed faucibus
pulvinar volutpat. Ut semper fringilla erat non dapibus. Nunc vitae
felis eget purus placerat finibus laoreet ut nibh.

== A complicated math equation
<a-complicated-math-equation>
The following raw text in markdown behind @eq:my_complicated_equation
shows that you can fall back on if it is more convenient for you. Note
that this will only be rendered in `thesis.pdf`

$ x_(1\,2) = frac(- b plus.minus sqrt(b^2 - 4 a c), 2 a) med $
<eq:my_complicated_equation>

== Conclusion
<conclusion>
This is the conclusion. Donec pulvinar molestie urna eu faucibus. In
tristique ut neque vel eleifend. Morbi ut massa vitae diam gravida
iaculis. Pellentesque habitant morbi tristique senectus et netus et
malesuada fames ac turpis egestas.

- first item in the list
- second item in the list
- third item in the list

= First research study, with code
<sec:research-code>
== Introduction
<introduction-1>
This is the introduction. Nam mollis congue tortor, sit amet convallis
tortor mollis eget. Fusce viverra ut magna eu sagittis. Vestibulum at
ultrices sapien, at elementum urna. Nam a blandit leo, non lobortis
quam. Aliquam feugiat turpis vitae tincidunt ultricies. Mauris
ullamcorper pellentesque nisl, vel molestie lorem viverra at.

== Method
<method>
Suspendisse iaculis in lacus ut dignissim. Cras dignissim dictum
eleifend. Suspendisse potenti. Suspendisse et nisi suscipit, vestibulum
est at, maximus sapien. Sed ut diam tortor.

=== Subsection 1 with example code block
<sec:subsec-code>
This is the first part of the methodology. Cras porta dui a dolor
tincidunt placerat. Cras scelerisque sem et malesuada vestibulum.
Vivamus faucibus ligula ac sodales consectetur. Aliquam vel tristique
nisl. Aliquam erat volutpat. Pellentesque iaculis enim sit amet posuere
facilisis. Integer egestas quam sit amet nunc maximus, id bibendum ex
blandit.

For syntax highlighting in code blocks, add three "\`" characters before
and after a code block:

#figure(```python
mood = 'happy'
if mood == 'happy':
    print("I am a happy robot")
```
, caption: [Mood detection],
)<lst:code>
You can then reference the code block like this (@lst:code).

=== Subsection 2
<subsection-2>
By running the code in @sec:subsec-code, we solved AI completely. This
is the second part of the methodology. Proin tincidunt odio non sem
mollis tristique. Fusce pharetra accumsan volutpat. In nec mauris vel
orci rutrum dapibus nec ac nibh. Praesent malesuada sagittis nulla, eget
commodo mauris ultricies eget. Suspendisse iaculis finibus ligula.

== Results
<results>
These are the results. Ut accumsan tempus aliquam. Sed massa ex, egestas
non libero id, imperdiet scelerisque augue. Duis rutrum ultrices arcu et
ultricies. Proin vel elit eu magna mattis vehicula. Sed ex erat,
fringilla vel feugiat ut, fringilla non diam.

== Discussion
<discussion>
This is the discussion. Duis ultrices tempor sem vitae convallis.
Pellentesque lobortis risus ac nisi varius bibendum. Phasellus volutpat
aliquam varius. Mauris vitae neque quis libero volutpat finibus. Nunc
diam metus, imperdiet vitae leo sed, varius posuere orci.

== Conclusion
<conclusion-1>
This is the conclusion to the chapter. Praesent bibendum urna orci, a
venenatis tellus venenatis at. Etiam ornare, est sed lacinia elementum,
lectus diam tempor leo, sit amet elementum ex elit id ex. Ut ac viverra
turpis. Quisque in nisl auctor, ornare dui ac, consequat tellus.

= Research containing a figure
<sec:research-figure>
== Introduction
<introduction-2>
This is the introduction. Sed vulputate tortor at nisl blandit interdum.
Cras sagittis massa ex, quis eleifend purus condimentum congue. Maecenas
tristique, justo vitae efficitur mollis, mi nulla varius elit, in
consequat ligula nulla ut augue. Phasellus diam sapien, placerat sit
amet tempor non, lobortis tempus ante.

== Method
<method-1>
Donec imperdiet, lectus vestibulum sagittis tempus, turpis dolor euismod
justo, vel tempus neque libero sit amet tortor. Nam cursus commodo
tincidunt.

=== Subsection 1
<subsection-1>
This is the first part of the methodology. Duis tempor sapien sed tellus
ultrices blandit. Sed porta mauris tortor, eu vulputate arcu dapibus ac.
Curabitur sodales at felis efficitur sollicitudin. Quisque at neque
sollicitudin, mollis arcu vitae, faucibus tellus.

=== Subsection 2
<subsection-2-1>
This is the second part of the methodology. Sed ut ipsum ultrices,
interdum ipsum vel, lobortis diam. Curabitur sit amet massa quis tortor
molestie dapibus a at libero. Mauris mollis magna quis ante vulputate
consequat. Integer leo turpis, suscipit ac venenatis pellentesque,
efficitur non sem. Pellentesque eget vulputate turpis. Etiam id nibh at
elit fermentum interdum.

== Results
<results-1>
These are the results. In vitae odio at libero elementum fermentum vel
iaculis enim. Nullam finibus sapien in congue condimentum. Curabitur et
ligula et ipsum mollis fringilla.

== Discussion
<discussion-1>
@fig:my_fig shows how to add a figure. Donec ut lacinia nibh. Nam
tincidunt augue et tristique cursus. Vestibulum sagittis odio nisl, a
malesuada turpis blandit quis. Cras ultrices metus tempor laoreet
sodales. Nam molestie ipsum ac imperdiet laoreet. Pellentesque habitant
morbi tristique senectus et netus et malesuada fames ac turpis egestas.

#figure(image("figures/salin-de-lile-saint-martin.jpg", width: 100.0%, alt: "RV Calypso is a former British Royal Navy minesweeper converted into a research vessel for the oceanographic researcher Jacques-Yves Cousteau. It was equipped with a mobile laboratory for underwater field research."),
  caption: [
    RV Calypso is a former British Royal Navy minesweeper converted into
    a research vessel for the oceanographic researcher Jacques-Yves
    Cousteau. It was equipped with a mobile laboratory for underwater
    field research.
  ]
)
<fig:my_fig>

== Conclusion
<conclusion-2>
This is the conclusion to the chapter. Quisque nec purus a quam
consectetur volutpat. Cum sociis natoque penatibus et magnis dis
parturient montes, nascetur ridiculus mus. In lorem justo, convallis
quis lacinia eget, laoreet eu metus. Fusce blandit tellus tellus.
Curabitur nec cursus odio. Quisque tristique eros nulla, vitae finibus
lorem aliquam quis. Interdum et malesuada fames ac ante ipsum primis in
faucibus.

#figure(image("figures/full_caption_example.jpg", width: 75.0%, alt: "This is the Luftschiffhafen"),
  caption: [
    This is the Luftschiffhafen
  ]
)
<fig:other_fig>

= Research containing a table
<sec:research-table>
== Introduction
<introduction-3>
This is the introduction. Phasellus non purus id mauris aliquam rutrum
vitae quis tellus. Maecenas rhoncus ligula nulla, fringilla placerat mi
consectetur eu. Aenean nec metus ac est ornare posuere. Nunc ipsum
lacus, gravida commodo turpis quis, rutrum eleifend erat. Pellentesque
id lorem eget ante porta tincidunt nec nec tellus.

== Method
<method-2>
Vivamus consectetur, velit in congue lobortis, massa massa lacinia urna,
sollicitudin semper ipsum augue quis tortor. Donec quis nisl at arcu
volutpat ultrices. Maecenas ex nibh, consequat ac blandit sit amet,
molestie in odio. Morbi finibus libero et nisl dignissim, at ultricies
ligula pulvinar.

=== Subsection 1
<subsection-1-1>
This is the first part of the methodology. Integer leo erat, commodo in
lacus vel, egestas varius elit. Nulla eget magna quam. Nullam
sollicitudin dolor ut ipsum varius tincidunt. Duis dignissim massa in
ipsum accumsan imperdiet. Maecenas suscipit sapien sed dui pharetra
blandit. Morbi fermentum est vel quam pretium maximus.

=== Subsection 2
<subsection-2-2>
This is the second part of the methodology. Nullam accumsan condimentum
eros eu volutpat. Maecenas quis ligula tempor, interdum ante sit amet,
aliquet sem. Fusce tellus massa, blandit id tempus at, cursus in tortor.
Nunc nec volutpat ante. Phasellus dignissim ut lectus quis porta. Lorem
ipsum dolor sit amet, consectetur adipiscing elit @Cousteau1963.

== Results
<results-2>
@tbl:random shows us how to add a table. Integer tincidunt sed nisl eget
pellentesque. Mauris eleifend, nisl non lobortis fringilla, sapien eros
aliquet orci, vitae pretium massa neque eu turpis. Pellentesque
tincidunt aliquet volutpat. Ut ornare dui id ex sodales laoreet.

#pagebreak()

#[
#show figure: set align(left)
#figure(
  align(center)[#table(
    columns: (17.48%, 9.71%, 12.62%, 15.53%, 13.59%, 13.59%, 12.62%),
    align: (left,right,right,right,right,right,right,),
    fill: striped,
    table.header([Landmass], [% stuff], [Number of Owls], [Dolphins per
      Capita], [How Many Foos], [How Many Bars], [Forbidden Float],),
    table.hline(),
    [North
    America], [94%], [20.028], [17.465], [12.084], [20.659], [1.71],
    [Central America], [91%], [6564], [6350], [8.189], [12.012], [1.52],
    [South America], [86%], [3902], [4127], [5.205], [6.565], [1.28],
    [Africa], [84%], [2892], [3175], [3.862], [4.248], [1.1],
    [Europe], [92%], [20.964], [17.465], [5.303], [24.203], [1.58],
    [Asia], [87%], [6852], [6350], [8.255], [11.688], [1.47],
    [Oceania], [87%], [4044], [4127], [5.540], [6.972], [1.28],
    [Antarctica], [83%], [2964], [3175], [4.402], [4.941], [1.13],
  )]
  , caption: [Important data for various land masses.]
  , kind: table
  )
<tbl:random>
]

== Discussion
<discussion-2>
This is the discussion. As we saw in @tbl:random, many things are true,
and other things are not. Etiam sit amet mi eros. Donec vel nisi sed
purus gravida fermentum at quis odio. Vestibulum quis nisl sit amet
justo maximus molestie. Maecenas vitae arcu erat. Nulla facilisi. Nam
pretium mauris eu enim porttitor, a mattis velit dictum. Nulla sit amet
ligula non mauris volutpat fermentum quis vitae sapien.

== Conclusion
<conclusion-3>
This is the conclusion to the chapter. Nullam porta tortor id vehicula
interdum. Quisque pharetra, neque ut accumsan suscipit, orci orci
commodo tortor, ac finibus est turpis eget justo. Cras sodales nibh nec
mauris laoreet iaculis. Morbi volutpat orci felis, id condimentum nulla
suscipit eu. Fusce in turpis quis ligula tempus scelerisque eget quis
odio. Vestibulum et dolor id erat lobortis ullamcorper quis at sem.

= Final research study
<sec:research-final>
== Introduction
<introduction-4>
This is the introduction. Nunc lorem odio, laoreet eu turpis at,
condimentum sagittis diam. Phasellus metus ligula, auctor ac nunc vel,
molestie mattis libero. Praesent id posuere ex, vel efficitur nibh.
Quisque vestibulum accumsan lacus vitae mattis.

== Method
<method-3>
In tincidunt viverra dolor, ac pharetra tellus faucibus eget.
Pellentesque tempor a enim nec venenatis. Morbi blandit magna imperdiet
posuere auctor. Maecenas in maximus est.

=== Subsection 1
<subsection-1-2>
This is the first part of the methodology. Praesent mollis sem diam, sit
amet tristique lacus vulputate quis. Vivamus rhoncus est rhoncus tellus
lacinia, a interdum sem egestas. Curabitur quis urna vel quam blandit
semper vitae a leo. Nam vel lectus lectus.

=== Subsection 2
<subsection-2-3>
This is the second part of the methodology. Aenean vel pretium tortor.
Aliquam erat volutpat. Quisque quis lobortis mi. Nulla turpis leo,
ultrices nec nulla non, ullamcorper laoreet risus.

== Results
<results-3>
These are the results. Curabitur vulputate nisl non ante tincidunt
tempor. Aenean porta nisi quam, sed ornare urna congue sed. Curabitur in
sapien justo. Quisque pulvinar ullamcorper metus, eu varius mauris
pellentesque et. In hac habitasse platea dictumst. Pellentesque nec
porttitor libero. Duis et magna a massa lacinia cursus.

== Discussion
<discussion-3>
This is the discussion. Curabitur gravida nisl id gravida congue. Duis
est nisi, sagittis eget accumsan ullamcorper, semper quis turpis. Mauris
ultricies diam metus, sollicitudin ultricies turpis lobortis vitae. Ut
egestas vehicula enim, porta molestie neque consectetur placerat.
Integer iaculis sapien dolor, non porta nibh condimentum ut.

== Conclusion
<conclusion-4>
This is the conclusion to the chapter. Nulla sed condimentum lectus.
Duis sed tempor erat, at cursus lacus. Nam vitae tempus arcu, id
vestibulum sapien. Cum sociis natoque penatibus et magnis dis parturient
montes, nascetur ridiculus mus.

= Conclusion
<sec:conclusion>
== Thesis summary
<thesis-summary>
In summary, pellentesque habitant morbi tristique senectus et netus et
malesuada fames ac turpis egestas. Nunc eleifend, ex a luctus porttitor,
felis ex suscipit tellus, ut sollicitudin sapien purus in libero. Nulla
blandit eget urna vel tempus. Praesent fringilla dui sapien, sit amet
egestas leo sollicitudin at.

== Future work
<future-work>
There are several potential directions for extending this thesis. Lorem
ipsum dolor sit amet, consectetur adipiscing elit. Aliquam gravida ipsum
at tempor tincidunt. Aliquam ligula nisl, blandit et dui eu, eleifend
tempus nibh. Nullam eleifend sapien eget ante hendrerit commodo.
Pellentesque pharetra erat sit amet dapibus scelerisque.

Vestibulum suscipit tellus risus, faucibus vulputate orci lobortis eget.
Nunc varius sem nisi. Nunc tempor magna sapien, euismod blandit elit
pharetra sed. In dapibus magna convallis lectus sodales, a consequat sem
euismod. Curabitur in interdum purus. Integer ultrices laoreet aliquet.
Nulla vel dapibus urna. Nunc efficitur erat ac nisi auctor sodales.

#bibliography("references.bib", title: [References])
#heading(level: 1, numbering: none)[Glossary]
<glossary>
#set heading(numbering: none)
#print-glossary(glossary-data)

#pagebreak()
#set heading(numbering: none, supplement: [Anhang])
#counter(heading).update(0)
= Appendix 1: Some extra stuff
<app-1>
Add appendix 1 here. Vivamus hendrerit rhoncus interdum. Sed ullamcorper
et augue at porta. Suspendisse facilisis imperdiet urna, eu pellentesque
purus suscipit in. Integer dignissim mattis ex aliquam blandit.
Curabitur lobortis quam varius turpis ultrices egestas.

= Appendix 2: Some more extra stuff
<app-2>
Add appendix 2 here. Aliquam rhoncus mauris ac neque imperdiet, in
mattis eros aliquam. Etiam sed massa et risus posuere rutrum vel et
mauris. Integer id mauris sed arcu venenatis finibus. Etiam nec
hendrerit purus, sed cursus nunc. Pellentesque ac luctus magna. Aenean
non posuere enim, nec hendrerit lacus. Etiam lacinia facilisis tempor.
Aenean dictum nunc id felis rhoncus aliquam.
