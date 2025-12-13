#show outline.entry.where(
  level: 1,
): set block(above: 0.75em)

#outline(
  title: cfg.at("toc-title", default: auto),
  depth: cfg.at("toc-depth", default: 3),
)

#if cfg.at("lof", default: false) {
  outline(
    title: cfg.at("lof-title", default: "List of Figures"),
    target: figure.where(kind: image),
  )
}

#if cfg.at("lot", default: false) {
  outline(
    title: cfg.at("lot-title", default: "List of Tables"),
    target: figure.where(kind: table),
  )
}

#if cfg.at("toc-own-page", default: false) {
  pagebreak()
}
