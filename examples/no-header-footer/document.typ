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
#let parsedDate = "2026-01-22"
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


#(cfg.toc-depth = 3)
#(cfg.disable-header = true)
#(cfg.disable-footer = true)
#(cfg.abstract-title = [Abstract])

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
    block(above: 1.5em, below: 1.5em)[
      #set par(leading: leading * 0.75)
      #code
    ]
}



#import "@preview/note-me:0.6.0": *






#set page(
  numbering: cfg.page-numbering,
  header: make-header(),
  footer: make-footer(),
  columns: cfg.columns,
)

#counter(page).update(1)

= Blindtext
<blindtext>
#lorem(100)

#lorem(30)

- #lorem(10)
- #lorem(10)
- #lorem(10)
- #lorem(10)
- #lorem(10)

== Some more Blindtext
<some-more-blindtext>
#lorem(80)

#lorem(120)

== Just another Title
<just-another-title>
#lorem(120)

#lorem(120)
