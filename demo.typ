// for markdown hr
#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

#set table(
  inset: 6pt,
)

#import "defaults.typ"

#let conf(
  title: none,
  subtitle: none,
  authors: defaults.authors,
  dozent: none,
  dozentin: none,
  date: defaults.date,
  abstract: none,
  abstract-title: none,
  margin: defaults.margin,
  paper: defaults.paper,
  lang: defaults.lang,
  region: defaults.region,
  font: defaults.font,
  fontsize: defaults.fontsize,
  pagenumbering: defaults.pagenumbering,
  titlepage: defaults.titlepage,
  titlepage-rule: defaults.titlepage-rule,
  titlepage-bg: defaults.titlepage-bg,
  titlepage-fg: defaults.titlepage-fg,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
  )

  set par(
    justify: true,
    leading: 0.8em,
    spacing: 2em,
  )
  set text(lang: lang, region: region, font: font, size: fontsize)

  // set heading styles
  show heading.where(level: 1): set block(above: 3em, below: 1.75em)
  show heading.where(level: 1): set text(fontsize * 1.25)

  show heading.where(level: 2): set block(above: 2.5em, below: 1.5em)
  show heading.where(level: 2): set text(fontsize * 1.1)

  show heading.where(level: 3): set block(above: 1.75em, below: 1em)

  // set figure styles
  show figure.where(kind: table): set block(above: 2em, below: 2em)
  show figure.where(kind: image): set block(above: 2em, below: 2em)

  // set table caption to top
  show figure.where(
    kind: table,
  ): set figure.caption(position: top)

  // set image caption to bottom
  show figure.where(
    kind: image,
  ): set figure.caption(position: bottom)

  // set captions to left
  show figure.caption: set align(left)

  if titlepage {
    let fg-color = black
    let bg-color = white

    if titlepage-fg != none {
      if titlepage-fg.starts-with("\\#") {
        fg-color = rgb(titlepage-fg.replace("\\", ""))
      }
    }

    if titlepage-bg != none {
      if titlepage-bg.starts-with("\\#") {
        bg-color = rgb(titlepage-bg.replace("\\", ""))
      }
    }

    set page(
      numbering: none,
      margin: (left: 5cm),
      fill: bg-color,
    )
    set text(fill: fg-color)

    line(length: 100% + margin.x - 3mm, stroke: titlepage-rule)

    if title != none {
      align(left)[
        #v(20%)
        #text(weight: "bold", size: 1.5em)[#title]
      ]
    }

    if subtitle != none {
      align(left)[
        #v(-1em)
        #text(size: 1.1em)[#subtitle]
      ]
    }

    if dozent != none {
      align(left)[
        #v(1em)
        #text(weight: "bold", size: 1.2em)[Dozent:]
        #text(size: 1.2em)[#dozent]
      ]
    }

    if dozentin != none {
      align(left)[
        #v(1em)
        #text[Dozentin: #dozentin]
      ]
    }

    if authors != none {
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

    if date != none {
      align(left + bottom)[
        #date
        #v(3cm)
      ]
    }

    counter(page).update(0)
  }

  set page(
    footer: context [
      #line(length: 100%)
      #v(-1.5em)
      #if authors != none {
        authors.map(author => author.name).join(", ")
      }
      #h(1fr)
      #counter(page).display(
        "1/1",
        both: true,
      )
    ],
  )

  if abstract != none {
    block(inset: 2em)[
      #text(weight: "semibold")[Abstract] #h(1em) #abstract
    ]
  }

  doc
}


#show: doc => conf(
  title: [Demo of the Pandoc Typst Template],
  subtitle: [Just another Pandoc template],
  authors: (
    ( name: [Hans Muster],
      affiliation: "Muster Firma",
      email: "hans.muster\@example.com" ),
    ( name: [Peter Lustig],
      affiliation: "Muster Firma",
      email: "peter.lustig\@example.com" ),
    ),
  region: "CH",
  abstract-title: [Abstract],
  pagenumbering: "1",
  titlepage: true,
  titlepage-rule: 2.5pt + white,
  titlepage-bg: "\#005e24ff",
  titlepage-fg: "\#fff",
  cols: 2,
  doc,
)

#set page(
  header: [
    Demo of the Pandoc Typst Template
    #h(1fr)
    #datetime.today().display()
    #v(-1.5em)
    #line(length: 100%)
  ]
)

#set heading(numbering: "1.1.1.")

#show raw.where(block: true): code => {
  block(fill: luma(240), inset: 1em, stroke: 0.5pt + gray, width: 100%)[
    #grid(
      columns: (auto, auto),
      column-gutter: 1em,
      row-gutter: 0.75em,
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
#show raw.where(block: true): set text(1em / 0.9)


#outline(
  title: auto,
  depth: 2
);



#pagebreak()


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
Why does my PDF look so plain? How do I make Pandoc output something
that looks designed?
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

```bash
pandoc input.md -o output.pdf --template=typst.template
```

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

Images should also look good by default:

#figure(image("https://images.unsplash.com/photo-1556740758-90de374c12ad?auto=format&fit=crop&w=1000&q=80"),
  caption: [
    Contrary to popular belief, Lorem Ipsum is not simply random text.
  ]
)

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

- #strong[Heading inside a list item] \
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

```yaml
from: markdown
to: pdf
template: typst-template.typ
variables:
  color: "blue"
  fontsize: 11pt
```

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

What is Typst?
A modern, fast typesetting system designed to make writing beautiful
documents easy.
What is Pandoc?
The universal document converter --- it turns your Markdown into just
about anything.
Why combine them?
Because together, they let you go from plain text to publication-ready
PDFs with minimal effort.
== Other elements worth checking
<other-elements-worth-checking>
We also have link styles --- like this one to the Typst website --- that
blend neatly into the text.

Tables are supported as well:

#figure(
  align(center)[#table(
    columns: 3,
    align: (auto,auto,auto,),
    table.header([Language], [Purpose], [Example Command],),
    table.hline(),
    [Markdown], [Input format], [`pandoc input.md`],
    [Typst], [Output format], [`--template=typst-template.typ`],
    [PDF], [Final document], [`-o output.pdf`],
  )]
  , caption: [Demo Table]
  , kind: table
  )

Inline code looks like this: `#let title = "Demo"`, and we even handle
code inside headings.

Sometimes I even put code in headings

Probably not best practice, but hey --- it's good to know it works.

We haven't used an `h4` yet

Now we have. You probably don't need to go deeper --- most documents
only need a few heading levels anyway.

Let's finish with a paragraph that's long enough to show line wrapping,
spacing, and rhythm. A good document template shouldn't just look good
--- it should make your writing feel comfortable to read. If you've made
it this far, congratulations --- your Typst template is ready for real
work.
