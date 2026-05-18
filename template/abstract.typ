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
