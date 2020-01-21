(* lab4/mach.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

(* |metrics| -- target representation of data object *)
type metrics = 
  { r_size: int;                (* Size of object *)
    r_align: int }              (* Address must be multiple of this *)

let int_rep = { r_size = 4; r_align = 4 }
let char_rep = { r_size = 1; r_align = 1 }
let bool_rep = { r_size = 1; r_align = 1 }
let void_rep = { r_size = 0; r_align = 1 }
let addr_rep = { r_size = 4; r_align = 4 }
let proc_rep = { r_size = 8; r_align = 4 }
let param_rep = { r_size = 4; r_align = 4 }
let max_align = 4

(* 
Frame layout:

        arg n  \
        ...     > Stored by caller
        arg 4  /
        arg 3  \
                > Saved by prolog
 +40    arg 0  /
        ----------------
 +36    return address
 +32    saved sp
 +28    dynamic link
 +24    static link
 +20    saved r9
        ...
  +4    saved r5
fp:     saved r4
        ----------------
  -4    local 1
        ...
        local m
        ----------------
        outgoing arg a
        ...
  +4    outgoing arg 5
sp:     outgoing arg 4
*)

let param_base = 40
let local_base = 0
let stat_link = 24
let nregvars = 3
let share_globals = true

let comment = "@ "
