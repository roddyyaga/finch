---
title: Home
---
The documentation for [finch](https://github.com/roddyyaga/finch). Other relevant sources of information are the [Jingoo
documentation](https://tategakibunko.github.io/jingoo/), the [Jinja2
documentation](https://jinja.palletsprojects.com/en/2.11.x/), the [YAML specification](
https://yaml.org/spec/1.2/spec.html) and the [Markdown
documentation](https://daringfireball.net/projects/markdown/syntax). Also, there are examples of using finch in the
`examples` directory on GitHub.

Finch is a site generator in the style of Jekyll and Hugo. It compiles documents written in Markdown with optional
frontmatter into (usually) HTML using templates written in Jingoo (an OCaml templating language that is very similar to
Jinja2).

To build a site with finch simply run `finch` in the appropriate directory. Do `finch -help` to see options.

## Content
A content document either consists of Markdown and some YAML frontmatter (delimited by `---` lines), or just some YAML if it is a `.yml` or `.yaml`
file. For example:

```
---
layout: post.html
title: "When I was nearly thirteen..."
author: "Scout"
date: "1960-7-11"
---
... my brother my brother Jem got his arm badly broken at the elbow.
```

Each content document will be compiled using the layout specified in the frontmatter. If no layout is specified, the
template `default.html` in the root of the layouts directory will be used. The output site directory has the same
structure as the content directory, with the compiled version of the file `content.content-extension` with layout
`layout.layout-extension` being called `content.layout-extension`.

The top-level YAML in a content document must be an object. Its values may also be objects or lists as well as simple
values.

Currently four keys in the frontmatter (or content of a YAML file) are treated specially:
- `layout` specifies the layout file that should be used to compile the file
- `content` will override the output of the Markdown content
- `date` will be parsed either as `%Y-%m-%d` or as an ISO timestamp, and output as an ISO timestamp string in the template
- `link` will override the default link for the output, which is the path to it from the root of the output directory

Note that the content of a content file is just treated as Markdown, you can't use Jingoo templating in it.

## Data
Finch can also use a directory of data files when compiling. The files in this have the same format as the content, the
only difference being that they will not be compiled into output (and therefore their objects in templates won't have a
`link` attribute).

## Layouts
A layout file is a Jingoo template. A layout can have variables substituted into it with the syntax `{{ variable }}`.
Layouts can have logic using commands such as `{% if ... %}` and `{% for ... in ... %}`, and one layout can reference
another using `{% extends "parent.template" %}` and blocks, or `{% include "other.template" %}`. For more details, see
the documentation of Jingoo and Jinja2.

The variables provided in the frontmatter of the file being compiled are available in the layout as `page.variable`,
with the compiled Markdown being `page.content`. Other variables will be looked up in the following places (in this
order):
- In the data directory
- In the content directory
- As filters

In the data and content directories, the variable `foo` corresponds to either a file `foo.extension` or a directory
`foo` in the root of the relevant directory. In the case where it is a file, the result will be a object with the same
structure as `page` (i.e. with attributes such as `content` and `layout`). When it is a directory, the result will be an
object with the attribute `files` corresponding to the objects for the files in the directory, and other attributes
corresponding to the child directories.

For example, with this data directory:
```
data/
    foo/
        bar/
            baz.md
        qux.md
        quux.md
```
the variable `foo` would correspond to the following object in a template:
```
{
    bar: {
        files: [
            # baz.md
            {
                content: ...
                ...
            }
         },
    files: [
        # qux.md
        {
            content: ...
            ...
        },
        # quux.md
        {
            content: ...
            ...
        },
    ]
}
```

## Static
Any static files you want to include directly in the output can be put in the static directory. They will be copied over before
content is compiled, so may be overwritten by compiled content with the same name.
