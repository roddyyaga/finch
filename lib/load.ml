open Jingoo
open Core

let split_front_matter s =
  let s = String.strip s ^ "\n" in
  let front_matter_start_opt = String.substr_index ~pattern:"---\n" s in
  match front_matter_start_opt with
  | None -> (None, s)
  | Some fm_start -> (
      let frontmatter_end_opt = String.substr_index ~pattern:"\n---\n" s in
      match frontmatter_end_opt with
      | Some fm_end ->
          let frontmatter = String.slice s (fm_start + 4) (fm_end + 1) in
          let content = String.slice s (fm_end + 5) 0 in
          (Some frontmatter, content)
      | None -> failwith "Frontmatter start with no corresponding end" )

let frontmatter_of_string yaml =
  match Yaml.of_string_exn yaml with
  | `O pairs -> pairs
  | _ -> failwith "Frontmatter must be YAML object"

let get_string frontmatter k =
  List.Assoc.find frontmatter k ~equal:String.equal
  |> Option.map ~f:(function
       | `String v -> v
       | other ->
           Printf.failwithf "'%s' must have string value in frontmatter, got %s"
             k (Yaml.to_string_exn other) ())

type data_file = { yaml: string option; markdown: string; file: string }

let data root file =
  let qualified_file = Filename.concat root file in
  let _, extension = Filename.split_extension file in
  match extension with
  | Some "yml" | Some "yaml" ->
      let yaml = In_channel.read_all qualified_file in
      { yaml = Some yaml; markdown = ""; file }
  | _ ->
      let yaml, markdown =
        split_front_matter (In_channel.read_all qualified_file)
      in
      { yaml; markdown; file }

type layout = {
  frontmatter: (string * Yaml.value) list option;
  template: Jg_template2.Loaded.t;
}

let layout_cache = Hashtbl.create (module String)

let layout ~env file =
  Hashtbl.find_or_add layout_cache file ~default:(fun () ->
      let frontmatter, body = split_front_matter (In_channel.read_all file) in
      let frontmatter = Option.map frontmatter ~f:frontmatter_of_string in
      { frontmatter; template = Jg_template2.Loaded.from_string ~env body })
