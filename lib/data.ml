open Base

type t = { file: string; yaml: (string * Yaml.value) list; markdown: string }

let of_string file yaml markdown =
  let pairs = Load.frontmatter_of_string yaml in
  let yaml = pairs in
  { yaml; markdown; file }

let of_file { Load.yaml; markdown; file } =
  match yaml with
  | Some yaml -> of_string file yaml markdown
  | None -> { yaml = []; markdown; file }
