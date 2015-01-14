Require Import Coq.Lists.List.
Require Import Coq.NArith.NArith.
Require Import Coq.Strings.String.
Require Import FunctionNinjas.All.
Require Import ListString.All.
Require Import Computation.
Require Http.
Require Import Model.

Import ListNotations.
Import C.Notations.
Local Open Scope string.
Local Open Scope list.

Module Controller.
  Definition error : C.t Http.Answer.t :=
    C.Ret Http.Answer.Error.

  Definition mime_type (file_name : LString.t) : LString.t :=
    let extension := List.last (LString.split file_name ".") (LString.s "") in
    LString.s @@ match LString.to_string extension with
    | "html" => "text/html; charset=utf-8"
    | "css" => "text/css"
    | "js" => "text/javascript"
    | "png" => "image/png"
    | "svg" => "image/svg+xml"
    | _ => "text/plain"
    end.

  Definition static (path : list LString.t) : C.t Http.Answer.t :=
    let mime_type := mime_type @@ List.last path (LString.s "") in
    let file_name := LString.join (LString.s "/") path in
    let! content := Command.FileRead file_name in
    match content with
    | None => error
    | Some content => C.Ret @@ Http.Answer.Static mime_type content
    end.

  Definition index : C.t Http.Answer.t :=
    let directory := LString.s "posts/" in
    let! posts := Command.ListPosts directory in
    match posts with
    | None =>
      do! Command.Log (LString.s "Cannot open the " ++ directory ++
        LString.s " directory") in
      C.Ret @@ Http.Answer.Index []
    | Some posts => C.Ret @@ Http.Answer.Index posts
    end.

  Definition args (args : list (LString.t * list LString.t))
    : C.t Http.Answer.t :=
    C.Ret @@ Http.Answer.Args args.
End Controller.

Definition server (request : Http.Request.t) : C.t Http.Answer.t :=
  match request with
  | Http.Request.Get path args =>
    do! Command.Log (LString.s "GET /" ++ LString.join (LString.s "/") path) in
    let path := List.map LString.to_string path in
    match path with
    | "static" :: _ => Controller.static (List.map LString.s path)
    | [] => Controller.index
    | ["args"] => Controller.args args
    | _ => Controller.error
    end
  end.

Require Extraction.
Definition main := Extraction.main server.
Extraction "extraction/microBlog" main.
