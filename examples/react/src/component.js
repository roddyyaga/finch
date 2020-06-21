'use strict';
var React = require("react");

function Component(props) {
    return React.createElement('h1', {}, 'Hello world!');
}

var make = Component;

exports.make = make;
