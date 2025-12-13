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
