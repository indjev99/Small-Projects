(* lab4/util.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

(* |take n [x1; x2; ...] = [x1; x2; ...; xn]| *)
let rec take n =
  function
      [] -> []
    | x::xs -> if n = 0 then [] else x :: take (n-1) xs

(* |drop n [x1; x2; ...] = [x_{n+1}; x_{n+2}; ...]| *)
let rec drop n =
  function
      [] -> []
    | x::xs -> if n = 0 then x::xs else drop (n-1) xs

(* |can f x| is true if |f x| doesn't raise |Not_found| *)
let can f x = try f x; true with Not_found -> false

(* |make_hash n [(x1, y1); ...]| creates a hash table of size |n|
   that initially contains the pairs |(x1, y1)|, ... *)
let make_hash n ps = 
  let table = Hashtbl.create n in
  List.iter (function (x, y) -> Hashtbl.add table x y) ps;
  table

(* |accum f [x1; x2; ...; xn] a| computes f xn (... (f x2 (f x1 a)) ...) *)
let rec accum f ys a =
  match ys with
      [] -> a
    | x::xs -> accum f xs (f x a)
