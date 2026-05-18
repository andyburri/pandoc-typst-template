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
