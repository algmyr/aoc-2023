let rec read_lines c =
  let line = In_channel.input_line c in
  match line with
  | None -> []
  | Some line -> line::read_lines c

let split1 re s = match Str.split re s with
  | a::b::[] -> (a, b)
  | _ -> raise (Failure "split1")

(* Parsing *)
let parse_game_id s = Str.string_after s 5 |> int_of_string

let parse_stones s =
  let (count, color) = split1 (Str.regexp " ") s in
  match (int_of_string count, color) with
  | (c, "red"  ) -> (c, 0, 0)
  | (c, "green") -> (0, c, 0)
  | (c, "blue" ) -> (0, 0, c)
  | _ -> raise (Failure "parse_stones")

let parse_picks s = Str.split (Str.regexp ", ") s
                |> List.map parse_stones
                |> List.fold_left
                     (fun (r, g, b) (r', g', b') -> (r + r', g + g', b + b'))
                     (0, 0, 0)

let parse_bag s = Str.split (Str.regexp "; ") s |> List.map parse_picks

let parse_game s =
  let prefix, bag_desc = split1 (Str.regexp ": ") s in
  (parse_game_id prefix, parse_bag bag_desc)

(* Solving *)
let maximum = List.fold_left max 0

let rec zip3 = function
  | [] -> ([], [], [])
  | (r, g, b)::t -> let (rs, gs, bs) = zip3 t in (r::rs, g::gs, b::bs)

let bag_max bag =
  let (rs, gs, bs) = zip3 bag in (maximum rs, maximum gs, maximum bs)

let part1 (game_id, bag) =
  let (r, g, b) = bag_max bag in
  if r <= 12 && g <= 13 && b <= 14 then game_id else 0

let part2 (game_id, bag) = let (r, g, b) = bag_max bag in r*g*b

let solve games f = games |> List.map f |> List.fold_left (+) 0

let () = 
  let lines = read_lines stdin in
  let games = lines |> List.map parse_game in
  Printf.printf "Part 1: %d\nPart 2: %d\n" (solve games part1) (solve games part2)
