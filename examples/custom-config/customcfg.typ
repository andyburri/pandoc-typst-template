// Custom configuration for the Typst template
#let user_cfg = (
  lang: "de",
  region: "DE",
  paper: "a5",
  authors: (
    (
      name: "Max Mustermann",
      affiliation: "Musterfirma",
      email: "max@example.com",
    ),
    (
      name: "Erika Musterfrau",
      affiliation: "Universität",
      email: "erika@example.com",
    ),
  ),
  // You can also override typography settings
  fontsize: 10pt,
  leading: 0.8em,
)
