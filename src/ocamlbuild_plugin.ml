(***********************************************************************)
(*                                                                     *)
(*                             ocamlbuild                              *)
(*                                                                     *)
(*  Nicolas Pouillard, Berke Durak, projet Gallium, INRIA Rocquencourt *)
(*                                                                     *)
(*  Copyright 2007 Institut National de Recherche en Informatique et   *)
(*  en Automatique.  All rights reserved.  This file is distributed    *)
(*  under the terms of the GNU Library General Public License, with    *)
(*  the special exception on linking described in file ../LICENSE.     *)
(*                                                                     *)
(***********************************************************************)


(* Original author: Nicolas Pouillard *)

open Rmlbuild_pack
include Rmlbuild_pack.My_std
module Arch = Rmlbuild_pack.Ocaml_arch
module Command = Rmlbuild_pack.Command
module Pathname = Rmlbuild_pack.Pathname
module Tags = Rmlbuild_pack.Tags
include Pathname.Operators
include Tags.Operators
module Rule = Rmlbuild_pack.Rule
module Options = Rmlbuild_pack.Options
module Findlib = Rmlbuild_pack.Findlib
type command = Command.t = Seq of command list | Cmd of spec | Echo of string list * string | Nop
and spec = Command.spec =
  | N | S of spec list | A of string | P of string | Px of string
  | Sh of string | T of Tags.t | V of string | Quote of spec
include Rule.Common_commands
type env = Pathname.t -> Pathname.t
type builder = Pathname.t list list -> (Pathname.t, exn) Rmlbuild_pack.My_std.Outcome.t list
type action = env -> builder -> Command.t
let rule = Rule.rule
let clear_rules = Rule.clear_rules
let dep = Command.dep
let pdep = Command.pdep
let copy_rule = Rule.copy_rule
let ocaml_lib = Rmlbuild_pack.Ocaml_utils.ocaml_lib
let rml_lib = Rmlbuild_pack.Rml_specific.rml_lib
let flag = Rmlbuild_pack.Flags.flag ?deprecated:None
let pflag = Rmlbuild_pack.Flags.pflag ?doc_param:None
let mark_tag_used = Rmlbuild_pack.Flags.mark_tag_used
let flag_and_dep = Rmlbuild_pack.Flags.flag_and_dep
let pflag_and_dep = Rmlbuild_pack.Flags.pflag_and_dep ?doc_param:None
let non_dependency = Rmlbuild_pack.Ocaml_utils.non_dependency
let use_lib = Rmlbuild_pack.Ocaml_utils.use_lib
let module_name_of_pathname = Rmlbuild_pack.Ocaml_utils.module_name_of_pathname
let string_list_of_file = Rmlbuild_pack.Ocaml_utils.string_list_of_file
let expand_module = Rmlbuild_pack.Ocaml_utils.expand_module
let tags_of_pathname = Rmlbuild_pack.Tools.tags_of_pathname
let hide_package_contents = Rmlbuild_pack.Ocaml_compiler.hide_package_contents
let tag_file = Rmlbuild_pack.Configuration.tag_file
let tag_any = Rmlbuild_pack.Configuration.tag_any
let run_and_read = Rmlbuild_pack.My_unix.run_and_read
type hook = Rmlbuild_pack.Hooks.message =
  | Before_hygiene
  | After_hygiene
  | Before_options
  | After_options
  | Before_rules
  | After_rules
let dispatch = Rmlbuild_pack.Hooks.setup_hooks
