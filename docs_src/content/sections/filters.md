---
title: Filters
---
Finch provides several additional filters for use in templates. See [here](http://tategakibunko.github.io/jingoo/templates/templates.en.html) for inbuilt Jingoo filters.

## strftime
`strftime(fmt, date)` parses the string `date` as an ISO 8601 timestamp and then formats it according to `fmt` (see
[here](https://www.man7.org/linux/man-pages/man3/strftime.3.html) for specification of the format string).

## date
`date` is an alias for `strftime`.

## strptime
`strptime(fmt, date)` parses the string `date` according to the format string `fmt` and then formats it as an ISO 8601
timestamp string.


## react
`react(source)` looks for a JavaScript file at the path `source` (relative to where finch has been called from) which should export a function `make` that is a React component. It returns the result of `ReactDOMServer.renderToString(React.createElement(make, { }))`.

## react_static
`react_static(source)` is the same as `react`, except that it calls `ReactDOMServer.renderToStaticMarkup` instead of
`ReactDOMServer.renderToString` (see
[here](https://reactjs.org/docs/react-dom-server.html#rendertostaticmarkup)
for the difference).
