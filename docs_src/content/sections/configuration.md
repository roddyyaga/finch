---
title: Configuration
---
The following options can be set either in a configuration file (by default `finch.yml`) or as command line flags, with the latter taking precedence. The configuration file should be YAML, for example:

```
root: docs_src
output: docs
pretty_urls: true
```

Command line flags containing "-" instead have "\_" as configuration keys.

## Options

- `content: path` specifies the path to the content directory (default `./content`)
- `data: path` specifies the path to the data directory (default `./data`)
- `layouts: path` specifies the path to the data directory (default `./layouts`)
- `list_content: bool` if set, names of processed content files will be printed
- `no_delete: bool` if set, the output directory won't be deleted before building
- `output: path` specifies the path of the output directory (default `./site`)
- `pretty_urls: bool` if set, `some/path/index.html` will be generated instead of `some/path.html`
- `root: path` specifies the root for content, layouts, data and static (default `.`)
- `static: path` specifies the path to the static directory (default `./static`)

Additionally `config` and `j` (jobs) may be set as command line flags only.
