open Base
open Jingoo
module Config = Config
module Content = Content
module Files = Files
module Load = Load
module Model = Model

let model_function ~pretty_urls ~content_root ~data_root content_model key =
  match key with
  | "page" -> content_model
  | other_key -> Model.lookup ~pretty_urls ~content_root ~data_root other_key

let custom_filters =
  [
    ("react_static", Jg_types.func_arg1_no_kw React.static);
    ("react", Jg_types.func_arg1_no_kw React.non_static);
    ("nullmap", Jg_types.func_arg2_no_kw Filters.nullmap);
    ("strptime", Jg_types.func_arg2_no_kw Filters.strptime);
    ("strftime", Jg_types.func_arg2_no_kw Filters.strftime);
    (* date is alias for strftime *)
    ("date", Jg_types.func_arg2_no_kw Filters.strftime);
  ]

let env layouts_root =
  {
    Jg_types.std_env with
    filters = Jg_types.std_env.filters @ custom_filters;
    template_dirs = [ layouts_root ];
  }

let make ~pretty_urls ~content_root ~data_root content layout =
  let content_model = Jg_types.Tobj (Model.of_content ~pretty_urls content) in
  let models =
    model_function ~pretty_urls ~content_root ~data_root content_model
  in
  Jg_template2.Loaded.eval ~models layout
