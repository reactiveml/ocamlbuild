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

include Rmlbuild_pack.Signatures.PLUGIN
  with module Pathname = Rmlbuild_pack.Pathname
   and module Outcome  = Rmlbuild_pack.My_std.Outcome
   and module Tags     = Rmlbuild_pack.Tags
   and module Command  = Rmlbuild_pack.Command
