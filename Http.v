Require Import Coq.Lists.List.
Require Import Coq.Strings.Ascii.
Require Import ListString.All.

Import ListNotations.
Local Open Scope char.

Module Request.
  Module Kind.
    Inductive t :=
    | Get
    | Post.
  End Kind.

  Record t := New {
    kind : Kind.t;
    path : list LString.t }.

  Definition path_of_string (path : LString.t) : list LString.t :=
    match path with
    | "/" :: path => LString.split path "/"
    | _ => LString.split path "/"
    end.
End Request.

Module Answer.
  Inductive t :=
  | Index
  | Users
  | Error.

  Definition to_string (page : t) : LString.t :=
    match page with
    | Index => LString.s "Welcome to the index page!"
    | Users => LString.s "This will be the list of users."
    | Error => LString.s "Error"
    end.
End Answer.
