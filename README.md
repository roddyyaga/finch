![Build](https://github.com/roddyyaga/finch/workflows/Build%20and%20test/badge.svg)

# Finch
A simple and fast<sup id="a1">[1](#f1)</sup> site generator.

Can be used as:
- A generic static site generator using markdown files with frontmatter and [Jingoo](https://github.com/tategakibunko/jingoo) (very similar to Jinja) templates
- A tiny version of Gatsby -- generate static pages from React components
- A server side renderer to produce static pages with React components that are hydrated by scripts
(see the examples directory)

## Installation
With opam: `opam install finch`

It is also available as a Docker container:
`docker run -v $(pwd):/finch roddylm/finch:latest -help`

## Use
Make a directory called `layouts`. Add template files to it with `{{ page.content }}` where the content of a page being
rendered should go. Then make a directory called `content`. Add files to it that look like this:
```
---
layout: "path/to/a/template/relative/to/layouts"
other: "variables"
if: "you want"
---
The *content* of the page in [markdown](https://en.wikipedia.org/wiki/Markdown).
```

Then run `finch`. The output site will be in the directory `site`.

See [here](https://roddyyaga.github.io/finch) for detailed documentation.

<b id="f1">1</b> From ad hoc comparisons, about twice as fast as Hugo to build simple sites with 10,000-100,000 pages, and
successfully built a site with 500,000 pages where Hugo froze my machine. [↩](#a1)
