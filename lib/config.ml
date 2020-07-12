open Core

let load file =
  if Sys.file_exists_exn file then
    file |> In_channel.read_all |> Yaml.of_string_exn
    |> (function
         | `O alist -> alist | _ -> failwith "Config file must be YAML object")
    |> Option.some
  else None

let lookup config_opt key =
  match config_opt with
  | None -> None
  | Some config -> List.Assoc.find config key ~equal:String.equal

let get_opt config_opt arg key =
  match (arg, lookup config_opt key) with
  | Some value, _ -> Some value
  | None, Some (`String value) -> Some value
  | None, Some other ->
      Printf.failwithf "Config value '%s' for key '%s' should be string"
        (Yaml.to_string_exn other) key ()
  | None, None -> None

let get_string ?default config_opt arg key =
  Option.value
    (get_opt config_opt arg key)
    ~default:(Option.value default ~default:key)

let get_bool config_opt arg key =
  match (arg, lookup config_opt key) with
  | true, _ -> true
  | false, Some (`Bool value) -> value
  | false, Some other ->
      Printf.failwithf "Config value '%s' for key '%s' should be bool"
        (Yaml.to_string_exn other) key ()
  | false, None -> false
