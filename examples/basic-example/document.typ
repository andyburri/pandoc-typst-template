//load defaults cfg dict
#let cfg = (:)
// overwrite defaults from pandoc variables


#(cfg.title = [Pandoc Typst Template])
#(cfg.toc-depth = 3)
#(cfg.abstract-title = "Abstract")

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
#let footer-right() = {
  return cfg.at(
    "footer-right",
    default: counter(
      page,
    ).display(page.numbering, both: page.numbering.contains(regex("[ /]"))),
  )
}

#let make-footer() = context {
  if cfg.at("disable-header-and-footer", default: false) != true [
    #line(length: 100%, stroke: cfg.at("header-and-footer-stroke", default: 1pt + black))
    #v(-par.spacing + 0.5em)
    #grid(
      columns: (1fr, auto, 1fr),
      align: (left, center, right),
      cfg.at("footer-left", default: authors.map(author => author.name).join(", ")),
      cfg.at("footer-center", default: none),
      footer-right(),
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
  numbering: cfg.at("page-numbering", default: "1"),
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
    block(above: 1.5em, below: 1.5em)[
      #set par(leading: leading * 0.75)
      #code
    ]
}



#import "@preview/note-me:0.6.0": *




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

#set page(
  numbering: cfg.at("page-numbering", default: "1"),
  header: make-header(),
  footer: make-footer(),
  columns: cfg.at("columns", default: 1),
)

#counter(page).update(1)

= Demo of the Pandoc Typst Template
<demo-of-the-pandoc-typst-template>
Until now, trying to make a beautiful, consistent document from Markdown
using Pandoc has often meant spending hours fiddling with YAML headers,
LaTeX templates, and obscure configuration options.

By default, Pandoc gives you a ton of power --- you can output to PDF,
HTML, DOCX, and more --- but the default styling can be… let's say,
“utilitarian.” If you want your document to look professionally typeset,
you usually end up writing your own LaTeX template or resorting to
manual tweaking.

People often ask us things like:

#quote(block: true)[
"Why does my PDF look so plain? How do I make Pandoc output something
that looks designed?"
]

We hear you. You probably don't want to dive into a full LaTeX preamble
just to get decent margins or a better heading style. And you definitely
don't want to use the default Times New Roman look. \
What you really want is a document that looks #emph[awesome], not awful.

That's exactly what this Typst template aims to do --- give you what you
#emph[actually] want: a clean, elegant design for Markdown-to-PDF
conversion, without touching a single LaTeX file.

Just tell Pandoc to use this template, and you'll instantly get a
well-balanced, beautiful document:

#figure(```bash
pandoc "$input" -o "$output" --pdf-engine=typst
```
)
For more information about how to use this template and what it
supports, see the documentation.

== What to expect from here on out
<what-to-expect-from-here-on-out>
What follows is a sample document meant to showcase how various Markdown
elements render using this Typst template. \
You'll see examples of #strong[bold text], #emph[italics], lists, code
blocks, block quotes, tables, and more.

The goal is to make sure everything looks good out of the box ---
because when you're writing, \
you should be focusing on #emph[content], not kerning.

Here's a list of reasons we made this demo:

+ To test every typographic element.
+ To make sure spacing and sizing feel natural.
+ Because lists with three items always feel more satisfying.

Now, let's move on to another section.

=== Typography should just work
<typography-should-just-work>
If we've done our job, this heading looks nicely balanced with the text
that follows it.

Someone once said:

#quote(block: true)[
Good typography is invisible --- you only notice it when it's bad.
]

Images should also look good by default (see @my-img-ref):

#figure(image("../images/image.jpg"),
  caption: [
    Contrary to popular belief, Lorem Ipsum is not simply random text.
  ]
)
<my-img-ref>

Now here's an unordered list:

- First item in the list.
- Second item, short and sweet.
- Third one, because three just feels right.

And that's the end of this section.

== What if we stack headings?
<what-if-we-stack-headings>
=== This should look fine too.
<this-should-look-fine-too.>
Sometimes headings appear directly after one another --- this template
adjusts the spacing so they look intentional, not awkward.

=== When a heading comes after a paragraph …
<when-a-heading-comes-after-a-paragraph>
You should see a bit more breathing room above it. \
Let's also test how complex lists look.

- ==== Heading inside a list item
  <heading-inside-a-list-item>
  This is a list item with its own heading and a couple of paragraphs. \
  Getting this spacing right in a typeset document is surprisingly
  tricky, but we've tuned it carefully.

- #strong[Here's another item] \
  A list wouldn't be much of a list with only one entry. \
  Notice how the paragraph spacing and indentation feel natural.

- #strong[And finally, a third] \
  Mostly here for visual balance --- but hey, it's nice to look at.

After this, it's good practice to have a closing paragraph. It helps the
rhythm of the page.

== Code should look great too
<code-should-look-great-too>
Pandoc can render fenced code blocks in many languages, and this Typst
template styles them cleanly by default.

Here's an example configuration file:

#figure(```yaml
from: markdown
to: pdf
template: typst-template.typ
variables:
  color: "blue"
  fontsize: 11pt
```
)
Hopefully that looks as good as it reads.

=== Nested lists
<nested-lists>
Nested lists are hard to make look good, but we've tried our best.

+ #strong[Try not to overdo it.]
  - Deep nesting makes things hard to read.
  - Flat is almost always better.
+ #strong[But we support it anyway.]
  - Two levels deep looks okay.
  - Three? You're on your own.

And now, back to a normal paragraph.

== Description lists
<description-lists>
These are useful for FAQs, glossaries, or term explanations --- and yes,
they're styled too.

/ What is Typst?: #block[
A modern, fast typesetting system designed to make writing beautiful
documents easy.
]

/ What is Pandoc?: #block[
The universal document converter --- it turns your Markdown into just
about anything.
]

/ Why combine them?: #block[
Because together, they let you go from plain text to publication-ready
PDFs with minimal effort.
]

== Other elements worth checking
<other-elements-worth-checking>
We also have link styles --- like this one to the
#link("https://typst.app")[Typst website] --- that blend neatly into the
text.

Tables are supported as well (see @demo-table):

#figure(
  align(center)[#table(
    columns: 3,
    align: (auto,auto,auto,),
    table.header([Wrestler], [Origin], [Finisher],),
    table.hline(),
    [Bret "The Hitman" Hart], [Calgary, AB], [Sharpshooter],
    [Stone Cold Steve Austin], [Austin, TX], [Stone Cold Stunner],
    [Randy Savage], [Sarasota, FL], [Elbow Drop],
    [Vader], [Boulder, CO], [Vader Bomb],
    [Razor Ramon], [Chuluota, FL], [Razor's Edge],
  )]
  , caption: [Demo Table]
  , kind: table
  )
<demo-table>

Inline code looks like this: `#let title = "Demo"`, and we even handle
code inside headings.

=== Sometimes I even put `code` in headings
<sometimes-i-even-put-code-in-headings>
Probably not best practice, but hey --- it's good to know it works.

==== We haven't used an `h4` yet
<we-havent-used-an-h4-yet>
Now we have. You probably don't need to go deeper --- most documents
only need a few heading levels anyway.

Let's finish with a paragraph that's long enough to show line wrapping,
spacing, and rhythm. A good document template shouldn't just look good
--- it should make your writing feel comfortable to read. If you've made
it this far, congratulations --- your Typst template is ready for real
work.
