open Core
open Jingoo

let nullmap f opt =
  let f = Jg_types.unbox_fun f in
  match opt with Jg_types.Tnull -> Jg_types.Tnull | non_null -> f non_null

let iso_fmt = "%FT%TZ"

let strptime fmt s =
  let fmt, s = Jg_types.(unbox_string fmt, unbox_string s) in
  let parsed = Unix.strptime ~fmt s in
  Jg_types.Tstr (Unix.strftime parsed iso_fmt)

let strftime fmt s =
  (* Assume ISO formatting *)
  let fmt, s = Jg_types.(unbox_string fmt, unbox_string s) in
  let parsed = Unix.strptime ~fmt:iso_fmt s in
  Jg_types.Tstr (Unix.strftime parsed fmt)
