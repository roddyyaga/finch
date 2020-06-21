open Core
open Jingoo

let run_node script error_format_string source =
  let source = Jg_types.unbox_string source in
  let script = Printf.sprintf (format_of_string script) source in
  let node_channels = Unix.open_process_full "node" ~env:[||] in
  Out_channel.output_string node_channels.stdin script;
  Out_channel.close node_channels.stdin;
  let output = In_channel.input_all node_channels.stdout in
  let stderr_content = In_channel.input_all node_channels.stderr in
  let code = Unix.close_process_full node_channels in
  match code with
  | Ok () -> output
  | Error _ ->
      let message =
        Printf.sprintf
          (format_of_string error_format_string)
          source stderr_content
      in
      failwith message

let non_static source =
  let output =
    run_node
      {js|'use strict';
var React = require("react");
var Server = require("react-dom/server");
var Component = require("%s");
console.log(Server.renderToString(React.createElement(Component.make, { })));
|js}
      {|Error in {{ "%s" | react }}:\n%s|} source
  in
  Jg_types.Tsafe output

let static source =
  let output =
    run_node
      {js|'use strict';
var React = require("react");
var Server = require("react-dom/server");
var Component = require("%s");
console.log(Server.renderToStaticMarkup(React.createElement(Component.make, { })));
|js}
      {|Error in {{ "%s" | react_static }}:\n%s|} source
  in
  Jg_types.Tsafe output
