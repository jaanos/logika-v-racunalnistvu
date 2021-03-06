(** The main program. *)

(** The end of file character. *)
let eof =
  match Sys.os_type with
      "Unix" | "Cygwin" -> "Ctrl-D"
    | "Win32" -> "Ctrl-Z"
    | _ -> "\"end of file\""
;;

(** The startup message. *)
let startup = "Propositional logic manipulator. Press " ^ eof ^ " to quit."
;;

let rec print_ps = function
  | []    -> ""
  | p::ps -> p ^ " = " ^ (print_ps ps)

(** Top level reads input, parses, evaluates and prints the result. *)
let main =
  print_endline startup ;
  let env = ref [] in
    try
      while true do
        print_string "> ";
        let str = read_line () in
          try
            match Parser.toplevel Lexer.lexeme (Lexing.from_string str) with
              | Syntax.Assignment (v, e) -> 
                  let e' = Eval.eval !env e in
                    env := (v, e')::!env ;
                    print_endline (v ^ " = " ^ (Syntax.string_of_expression e'))
              | Syntax.Expression e -> print_endline (Syntax.string_of_expression (Eval.eval !env e))
              | Syntax.Horn e -> (
                  match Eval.horn !env e with
                    | None      -> print_endline "Formula not satisfiable."
                    | Some ps   -> print_endline (match ps with
                         | []   -> "Formula satisfiable for all literals F."
                         | _    -> "Formula satisfiable for " ^ (print_ps ps) ^ "T.")
              )
              | Syntax.SAT e -> (
                  match Eval.sat !env e with
                    | None          -> print_endline "Formula not satisfiable."
                    | Some pns -> print_endline (match pns with
                         | ([], []) -> "Formula trivially satisfiable."
                         | (ps, []) -> "Formula satisfied for " ^ (print_ps ps) ^ "T."
                         | ([], ns) -> "Formula satisfied for " ^ (print_ps ns) ^ "F."
                         | (ps, ns) -> "Formula satisfied for " ^ (print_ps ps) ^ "T and " ^ (print_ps ns) ^ "F."
                    )
              )
          with
        | Failure str -> print_endline ("Error: " ^ str)
        | Parsing.Parse_error -> print_endline "Syntax error."
      done 
    with
      End_of_file -> print_endline "\nGood bye."
;;
