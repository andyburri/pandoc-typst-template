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
