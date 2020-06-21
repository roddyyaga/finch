open Core

let to_last xs = List.drop xs (List.length xs - 1)

let contained_files root_dir =
  let ( / ) = Filename.concat in
  let rec f path =
    if Sys.is_file_exn (root_dir / path) then [ path ]
    else
      List.concat_map
        (Sys.ls_dir (root_dir / path))
        ~f:(fun inner -> f (path / inner))
  in
  List.concat_map (Sys.ls_dir root_dir) ~f

let output_path ~content_file ~layout_file =
  let name, _ = Filename.split_extension content_file in
  let _, extension = Filename.split_extension layout_file in
  let extension = Option.value extension ~default:"" in
  name ^ "." ^ extension
