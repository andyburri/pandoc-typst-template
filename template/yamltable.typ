// YAML-driven tables: load YAML, normalize to a grid, render Typst tables.

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
