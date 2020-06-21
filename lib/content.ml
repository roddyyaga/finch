open Core

type t = { data: Data.t; layout: string }

let layout_of_yaml_value = function
  | `String s -> s
  | other ->
      Printf.failwithf "Template must be string, got: %s"
        (Yaml.to_string_exn other) ()

let default_loadout _file = "default.html"

let of_content_file data_file =
  let base_data = Data.of_file data_file in
  let given_layout = Load.get_string base_data.yaml "layout" in
  let layout = Option.value ~default:(default_loadout data_file) given_layout in
  let yaml =
    List.filter base_data.yaml ~f:(fun (k, _v) -> String.(k <> "layout"))
    |> List.map ~f:(fun (k, v) ->
           if String.(k = "date") then
             let v' =
               match v with
               | `String s ->
                   let parsed =
                     try Unix.strptime ~fmt:"%F" s
                     with Failure _ -> Unix.strptime ~fmt:Filters.iso_fmt s
                   in
                   `String (Unix.strftime parsed Filters.iso_fmt)
               | other -> other
             in
             (k, v')
           else (k, v))
  in

  { data = { base_data with yaml }; layout }
