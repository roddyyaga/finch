open Core
open Jingoo

let rec model_of_yaml = function
  | `Null -> Jg_types.Tnull
  | `Bool b -> Jg_types.Tbool b
  | `Float f -> Jg_types.Tfloat f
  | `String s -> Jg_types.Tstr s
  | `A xs -> Jg_types.Tlist (List.map ~f:model_of_yaml xs)
  | `O pairs ->
      Jg_types.Tobj (List.map ~f:(fun (k, v) -> (k, model_of_yaml v)) pairs)

let of_data { Data.yaml; markdown; _ } =
  let yaml_pairs = List.map ~f:(fun (k, v) -> (k, model_of_yaml v)) yaml in
  let markdown_content =
    if
      List.Assoc.find yaml_pairs "content" ~equal:String.equal |> Option.is_none
    then
      let content = Omd.(markdown |> of_string |> to_html) in
      [ ("content", Jg_types.Tsafe content) ]
    else []
  in
  markdown_content @ yaml_pairs

let output_link ~pretty_urls ~content_file ~layout_file =
  let name, _ = Filename.split_extension content_file in
  let _, extension = Filename.split_extension layout_file in
  let extension = Option.value extension ~default:"" in
  match (pretty_urls, String.(Filename.basename name = "index"), extension) with
  | true, false, "html" ->
      if Filename.(check_suffix name dir_sep) then name
      else name ^ Filename.dir_sep
  | _ -> name ^ "." ^ extension

let of_content ~pretty_urls { Content.layout; data = { yaml; markdown; file } }
    =
  let data_model = of_data { yaml; markdown; file } in
  let link =
    match List.Assoc.find data_model "link" ~equal:String.equal with
    | None ->
        [
          ( "link",
            Jg_types.Tstr
              (output_link ~pretty_urls ~content_file:file ~layout_file:layout)
          );
        ]
    | Some link -> [ ("link", link) ]
  in
  link @ data_model

let file_models_cache = Hashtbl.create (module String)

let strip_extension fn = fst (Filename.split_extension fn)

let rec of_directory of_file root directory =
  let qualified = Filename.concat directory in
  let directories, files =
    List.fold ~init:([], [])
      (Sys.ls_dir (Filename.concat root directory))
      ~f:(fun (directories, files) basename ->
        match Sys.is_file_exn (Filename.concat root (qualified basename)) with
        | true -> (directories, of_file root (qualified basename) :: files)
        | false ->
            ( (basename, of_directory of_file root (qualified basename))
              :: directories,
              files ))
  in
  Jg_types.(Tobj (("files", Tlist files) :: directories))

let content_of_file ~pretty_urls content_root file =
  Jg_types.Tobj
    ( file |> Load.data content_root |> Content.of_content_file
    |> of_content ~pretty_urls )

let content_of_directory ~pretty_urls =
  of_directory (content_of_file ~pretty_urls)

let data_of_file data_root file =
  Jg_types.Tobj (file |> Load.data data_root |> Data.of_file |> of_data)

let data_of_directory = of_directory data_of_file

let data_or_content_lookup ~of_file ~of_directory root key =
  match Sys.file_exists_exn root with
  | false -> None
  | true -> (
      match Sys.is_directory_exn root with
      | false ->
          let file_data = of_file root "" |> Jg_types.unbox_obj in
          let value = List.Assoc.find ~equal:String.equal file_data key in
          value
      | true -> (
          let first_level_content = Sys.ls_dir root in
          let qualified = Filename.concat root in
          let matching =
            List.filter first_level_content ~f:(fun basename ->
                String.(strip_extension basename = key))
          in
          let is_directory basename =
            Sys.is_directory_exn (qualified basename)
          in
          let sorted_matching =
            List.sort matching ~compare:(fun x y ->
                Bool.compare (is_directory x) (is_directory y))
          in
          match sorted_matching with
          | [] -> None
          | x :: _ -> (
              match Sys.is_file_exn (qualified x) with
              | true -> Some (of_file root x)
              | false -> Some (of_directory root x) ) ) )

let uncached_lookup ~pretty_urls ~content_root ~data_root key =
  let found_in_data =
    data_or_content_lookup ~of_file:data_of_file ~of_directory:data_of_directory
      data_root key
  in
  match found_in_data with
  | Some data -> data
  | None -> (
      let found_in_content =
        data_or_content_lookup
          ~of_file:(content_of_file ~pretty_urls)
          ~of_directory:(content_of_directory ~pretty_urls)
          content_root key
      in
      match found_in_content with
      | Some content -> content
      | None -> raise Caml.Not_found )

let lookup ~pretty_urls ~content_root ~data_root key =
  Hashtbl.find_or_add file_models_cache key ~default:(fun () ->
      uncached_lookup ~pretty_urls ~content_root ~data_root key)
