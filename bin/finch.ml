open Core

let chunk_list chunk_lengths xs =
  List.fold chunk_lengths ~init:([], xs) ~f:(fun (accum, remaining) chunk ->
      (List.take remaining chunk :: accum, List.drop remaining chunk))
  |> fst

let command =
  Command.basic ~summary:"Build a site from content and templates"
    ~readme:(fun () ->
      "See https://roddyyaga.github.io/finch for full documentation")
    Command.Let_syntax.(
      let%map_open content_root =
        flag "-content"
          (optional Filename.arg_type)
          ~doc:"filename path to content (default ./content)"
      and layouts_root =
        flag "-layouts"
          (optional Filename.arg_type)
          ~doc:"filename layouts directory (default ./layouts)"
      and data_root =
        flag "-data"
          (optional Filename.arg_type)
          ~doc:"filename data directory (default ./data)"
      and output_root =
        flag "-output"
          (optional Filename.arg_type)
          ~doc:"filename output directory (default ./site)"
      and static_dir =
        flag "-static"
          (optional Filename.arg_type)
          ~doc:"filename static files directory (default ./static)"
      and source_root =
        flag "-root"
          (optional Filename.arg_type)
          ~doc:
            "filename root dirctory for content, layouts, data and static \
             (default .)"
      and jobs =
        flag "-j" (optional int)
          ~doc:"int maximum number of processes to use (default 4)"
      and no_delete =
        flag "-no-delete" no_arg
          ~doc:"don't delete the output directory before building"
      and list_content =
        flag "-list-content" no_arg
          ~doc:"print the content files that were processed"
      in
      fun () ->
        let content_root = Option.value content_root ~default:"content" in
        let layouts_root = Option.value layouts_root ~default:"layouts" in
        let data_root = Option.value data_root ~default:"data" in
        let static_dir = Option.value static_dir ~default:"static" in
        let output_root = Option.value output_root ~default:"site" in
        let content_root, layouts_root, data_root, static_dir =
          match source_root with
          | Some dir ->
              let qualify = Filename.concat dir in
              ( qualify content_root,
                qualify layouts_root,
                qualify data_root,
                qualify static_dir )
          | None -> (content_root, layouts_root, data_root, static_dir)
        in

        ( if (not no_delete) && Sys.file_exists_exn output_root then
          let delete_exit_code =
            Unix.system (Printf.sprintf "rm -r %s" output_root)
          in
          ignore delete_exit_code );

        if Sys.file_exists_exn static_dir then (
          Unix.mkdir_p output_root;
          let copy_exit_code =
            Unix.system (Printf.sprintf "cp -rT %s %s" static_dir output_root)
          in
          ignore copy_exit_code );

        let jobs = Option.value jobs ~default:4 in
        if not (Sys.file_exists_exn content_root) then
          Printf.failwithf "Path to contents '%s' doesn't exist!" content_root
            ();
        if not (Sys.file_exists_exn content_root) then
          Printf.failwithf "Layouts directory '%s' doesn't exist!" layouts_root
            ();

        let content_root, content_file_paths =
          if Sys.is_directory_exn content_root then
            (content_root, Lib.Files.contained_files content_root)
          else (Filename.current_dir_name, [ content_root ])
        in
        let paths_count = List.length content_file_paths in
        let base_path_number, remainder =
          Int.(paths_count / jobs, paths_count % jobs)
        in
        let chunk_lengths =
          List.init remainder ~f:(fun _ -> base_path_number + 1)
          @ List.init (jobs - remainder) ~f:(fun _ -> base_path_number)
        in
        let process_paths = chunk_list chunk_lengths content_file_paths in
        assert (List.length process_paths = jobs);
        assert (List.(length (concat process_paths)) = paths_count);

        let job_id =
          let rec iter job_id fork_result =
            match fork_result with
            | `In_the_child -> job_id - 1
            | `In_the_parent _ ->
                if job_id < List.length process_paths then
                  iter (job_id + 1) (Unix.fork ())
                else 0
          in
          iter 1 (`In_the_parent (Unix.getpid ()))
        in

        let content_file_paths = List.nth_exn process_paths job_id in

        List.iter content_file_paths ~f:(fun file ->
            if list_content then Stdio.print_endline file;
            let ( / ) = Filename.concat in
            let content =
              file |> Lib.Load.data content_root |> Lib.Content.of_content_file
            in
            let layout_file = layouts_root / content.layout in
            let layout =
              Lib.Load.layout ~env:(Lib.env layouts_root) layout_file
            in
            let output_path_after_root =
              Lib.Files.output_path ~content_file:file ~layout_file
            in
            let output =
              Lib.make ~content_root ~data_root content layout.template
            in
            let output_path = output_root / output_path_after_root in
            let output_dir = Filename.dirname output_path in
            Unix.mkdir_p output_dir;
            Out_channel.write_all ~data:output output_path))

let () = Command.run ~version:"0.1.1" ~build_info:"Development" command
