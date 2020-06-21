'use strict';
var Component = require("./component.js");

ReactDOM.hydrate(Component.make({}), document.getElementById("component"));
