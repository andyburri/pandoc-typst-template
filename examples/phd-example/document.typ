//load defaults cfg dict
#let cfg = (:)
// overwrite defaults from pandoc variables
#let parsedDate = "2015-01-01"
#if type(parsedDate) == str {
  let dateArray = parsedDate.split(regex("[-/.]"))
  parsedDate = datetime(
    year: int(dateArray.at(0)),
    month: int(dateArray.at(1)),
    day: int(dateArray.at(2)),
  )
}
#(cfg.date = parsedDate)


#(cfg.authors = (
    ( name: "Firstname Lastname",
      affiliation: [Wizard University],
      email: "firstname.lastname\@example.com" ),
    )
)
#(cfg.title = [This is the title of the thesis])
#(cfg.subtitle = [This is the subtitle of the thesis])
#(cfg.supervisor = [Supervision: Professor Louis Fage])
#(cfg.lang = "en")
#(cfg.toc = true)
#(cfg.toc-depth = 3)
#(cfg.lof = true)
#(cfg.lot = true)
#(cfg.number-sections = true)
#(cfg.abstract-title = "Abstract")
#(cfg.abstract = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam et turpis gravida, lacinia ante sit amet, sollicitudin erat. Aliquam efficitur vehicula leo sed condimentum. Phasellus lobortis eros vitae rutrum egestas. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec at urna imperdiet, vulputate orci eu, sollicitudin leo. Donec nec dui sagittis, malesuada erat eget, vulputate tellus. Nam ullamcorper efficitur iaculis. Mauris eu vehicula nibh. In lectus turpis, tempor at felis a, egestas fermentum massa.

")
#(cfg.thanks = "Interdum et malesuada fames ac ante ipsum primis in faucibus. Aliquam congue fermentum ante, semper porta nisl consectetur ut. Duis ornare sit amet dui ac faucibus. Phasellus ullamcorper leo vitae arcu ultricies cursus. Duis tristique lacus eget metus bibendum, at dapibus ante malesuada. In dictum nulla nec porta varius. Fusce et elit eget sapien fringilla maximus in sit amet dui.

Mauris eget blandit nisi, faucibus imperdiet odio. Suspendisse blandit dolor sed tellus venenatis, venenatis fringilla turpis pretium. Donec pharetra arcu vitae euismod tincidunt. Morbi ut turpis volutpat, ultrices felis non, finibus justo. Proin convallis accumsan sem ac vulputate. Sed rhoncus ipsum eu urna placerat, sed rhoncus erat facilisis. Praesent vitae vestibulum dui. Proin interdum tellus ac velit varius, sed finibus turpis placerat.

")

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

#let authors = cfg.at("authors", default: ((name: "", email: "", affiliation: ""),))
#let disable-header-footer = cfg.at("disable-header-and-footer", default: false)

// Define a helper for the header
#let make-header() = context {
  if disable-header-footer != true [
    #grid(
      columns: (1fr, auto, 1fr),
      align: (left, center, right),
      cfg.at("header-left", default: cfg.at("title", default: none)),
      cfg.at("header-center", default: none),
      cfg.at(
        "header-right",
        default: cfg
          .at("date", default: datetime.today())
          .display(cfg.at("dateformat", default: "[year]-[month]-[day]")),
      ),
    )
    #v(-par.spacing + 0.5em)
    #line(length: 100%, stroke: cfg.at("header-and-footer-stroke", default: 1pt + black))
  ] else []
}

// Define a helper for the footer
#let page-numbering = cfg.at("page-numbering", default: "1")
#let footer-right(
  pn: page-numbering,
) = {
  return cfg.at(
    "footer-right",
    default: counter(
      page,
    ).display(pn, both: pn.contains(regex("[ /]"))),
  )
}

#let make-footer(
  pn: page-numbering,
) = context {
  if cfg.at("disable-header-and-footer", default: false) != true [
    #line(length: 100%, stroke: cfg.at("header-and-footer-stroke", default: 1pt + black))
    #v(-par.spacing + 0.5em)
    #grid(
      columns: (1fr, auto, 1fr),
      align: (left, center, right),
      cfg.at("footer-left", default: authors.map(author => author.name).join(", ")),
      cfg.at("footer-center", default: none),
      footer-right(pn: pn),
    )
  ] else []
}

// setting pdf meta data
#set document(
  title: cfg.at("title", default: none),
  keywords: cfg.at("keywords", default: ""),
  date: cfg.at("date", default: datetime.today()),
  author: authors.map(author => author.name).join(", "),
)

#let margin = cfg.at("margin", default: (x: 2.5cm, y: 3.5cm))
#if disable-header-footer == true {
  margin = margin.y - 3em
}

#set page(
  paper: cfg.at("paper", default: "a4"),
  margin: margin,
  numbering: page-numbering,
)

#let leading = cfg.at("leading", default: 0.65em)
#set par(
  justify: cfg.at("justify", default: true),
  leading: leading,
  spacing: cfg.at("spacing", default: 1.2em),
)

#let font = cfg.at("font", default: ("noto sans", "arial"))
#let fontsize = cfg.at("fontsize", default: 11pt)

#set text(
  lang: cfg.at("lang", default: "en"),
  region: cfg.at("region", default: "US"),
  font: font,
  size: fontsize,
)

// set heading styles
#let numbering = none
#if cfg.at("number-sections", default: false) {
  numbering = cfg.at("section-numbering", default: "1.1.1.1.1")
}

#set heading(numbering: numbering)

#show heading: set text(font: cfg.at("heading-font", default: font))

#show heading.where(level: 1): set text(fontsize * 1.3)
#show heading.where(level: 1): set block(above: 2.65em, below: 1.75em)

#show heading.where(level: 2): set text(fontsize * 1.1)
#show heading.where(level: 2): set block(above: 2em, below: 1.375em)

// #show heading.where(level: 3): set text(fontsize * 1.1)
#show heading.where(level: 3): set block(above: 3.25em, below: 1em)

// set figure styles
#show figure: set block(above: 2em, below: 2em)

#show figure.where(kind: table): set figure.caption(position: top)
#show figure.where(kind: table): set figure(supplement: cfg.at("table-prefix", default: "Table"))

#show figure.where(kind: image): set figure.caption(position: bottom)
#show figure.where(kind: image): set figure(supplement: cfg.at("figure-prefix", default: "Fig."))

// listings
#show figure.where(kind: raw): set figure.caption(position: bottom)
#show figure.where(kind: raw): set figure(supplement: cfg.at("listing-prefix", default: "Listing"))
#show figure.where(kind: raw): set align(left)

// set captions to left
#show figure.caption: set align(left)

// indent lists
#show list: set list(indent: 6pt)
#show enum: set enum(indent: 6pt)

// table styling
#let table-stroke = (_, y) => (
  left: { 0pt },
  right: { 0pt },
  top: if y < 1 { stroke(1pt + luma(120)) } else if y == 1 { none } else { 0pt },
  bottom: if y < 1 { stroke(.5pt + luma(120)) } else { stroke(1pt + luma(120)) },
)

// fill for striped tables
#let striped = (x, y) => {
  if calc.even(y) and y > 1 {
    luma(230)
  } else {
    none
  }
}

#set table(
  stroke: table-stroke,
  inset: 6pt,
)

#show table: set par(justify: false, linebreaks: "optimized")
#show table: set text(hyphenate: true, costs: (hyphenation: 100000%))

// set smart quotes
#set smartquote(enabled: cfg.at("smart", default: true))

// reduce code line spacing
#show raw.where(block: true): set text(1em / 0.9)
#show raw: set text(ligatures: true, font: cfg.at("code-font", default: ("noto mono", "courier new")))
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

#import "@preview/glossy:0.9.0": *
#let glossy-data = yaml("glossy.yaml")

#let glossy-theme = (
  // Main glossary section
  section: (title, body) => {
    body
  },

  // Group of related terms
  group: (name, index, total, body) => {
    // index = group index, total = total groups
    if name != "" and total > 1 {
      show heading.where(level: 2): set block(above: 2em, below: 1.375em)
      heading(level: 2, name)
    }
    body
  },

  // Individual glossary entry
  entry: (entry, index, total) => {
    // index = entry index, total = total entries in group
    let output = [#entry.short#entry.label] // **NOTE:** Label here!
    if entry.long != none {
      output = [#output -- #entry.long]
    }
    if entry.description != none {
      output = [#output: #entry.description]
    }
    block(
      grid(
        columns: (auto, 1fr, auto),
        output,
        h(1fr),
        entry.pages.join(", "),
      )
    )
  }
)

#show: init-glossary.with(glossy-data)

#import "@preview/note-me:0.6.0": *



#set page(
  numbering: none,
  margin: (left: 5cm),
  fill: cfg.at("titlepage-bg", default: white),
)
#set text(fill: cfg.at("titlepage-fg", default: black))

#line(length: 100% + margin.x, stroke: cfg.at("titlepage-rule", default: 2.5pt + black))

#if cfg.at("title", default: none) != none [
  #v(20%)
  #show title: set text(size: 0.9em)
  #title[#cfg.title]
]

#if cfg.at("subtitle", default: none) != none [
  #v(0.65em)
  #text(size: 1.1em)[#cfg.subtitle]
]

#if cfg.at("supervisor", default: none) != none [
  #v(2em)
  #cfg.supervisor
]

#if authors != none {
  v(2em)
  let count = authors.len()
  let ncols = calc.min(count, 3)
  grid(
    columns: (1fr,) * ncols,
    row-gutter: 24pt,
    ..authors.map(author => [
      #author.name \
      #author.affiliation \
      #link("mailto:" + author.email.replace("\\", ""))
    ]),
  )
}

#let logo = none

#if cfg.at("titlepage-logo", default: none) != none {
  logo = box(image(cfg.titlepage-logo, width: cfg.at("titlepage-logo-width", default: 12em)))
}

#v(1fr)

#cfg.at("date", default: datetime.today()).display(cfg.at("dateformat", default: "[year]-[month]-[day]"))
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
#set page(
  header: make-header(),
  footer: make-footer(pn: page-numbering),
  columns: cfg.at("columns", default: 1),
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
quis, vestibulum nec nulla. Aenean nec dapibus in $m L \/ m i n^(- 1)$.
Mathematical formula can be inserted using Latex and can be
automatically numbered:

$ f \( x \) = a x^3 + b x^2 + c x + d $ <eq:my_equation>

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

$ x_(1 \, 2) = frac(- b plus.minus sqrt(b^2 - 4 a c), 2 a) med $
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

#figure(image("figures/example_figure.pdf", width: 100.0%),
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

#figure(image("figures/full_caption_example.jpg", width: 75.0%),
  caption: [
    This is not a boat
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
#glossary(theme: glossy-theme, show-all: true)

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
