(* Parsing *)
let split re = Str.split (Str.regexp re)

let partition delim s =
  match Str.bounded_split (Str.regexp delim) s 2 with
  | [a; b] -> (a, b)
  | _ -> raise (Failure "Delim not found")

let parse_game_id s = partition " " s |> snd |> int_of_string

let parse_stones s =
  let (count, color) = partition " " s in
  match (int_of_string count, color) with
  | (c, "red"  ) -> (c, 0, 0)
  | (c, "green") -> (0, c, 0)
  | (c, "blue" ) -> (0, 0, c)
  | _ -> raise (Failure "parse_stones")

let parse_picks s = split ", " s
                |> List.map parse_stones
                |> List.fold_left
                     (fun (r, g, b) (r', g', b') -> (r + r', g + g', b + b'))
                     (0, 0, 0)

let parse_bag s = split "; " s |> List.map parse_picks

let parse_game s =
  let prefix, bag_desc = partition ": " s in
  parse_game_id prefix, parse_bag bag_desc

(* Solving *)
let sum = List.fold_left (+) 0
let maximum = List.fold_left max 0

let rec zip3 =
  List.fold_left (fun (rs, gs, bs) (r, g, b) -> (r::rs, g::gs, b::bs)) ([], [], [])

let bag_max bag =
  let (rs, gs, bs) = zip3 bag in (maximum rs, maximum gs, maximum bs)

let part1 (game_id, bag) =
  let r, g, b = bag_max bag in
  if r <= 12 && g <= 13 && b <= 14 then game_id else 0

let part2 (game_id, bag) = let r, g, b = bag_max bag in r*g*b

let read_lines c = Seq.of_dispenser @@ fun () -> In_channel.input_line c

let () = 
  let games = read_lines stdin |> Seq.map parse_game |> List.of_seq in
  Printf.printf "Part 1: %d\nPart 2: %d\n"
    (List.map part1 games |> sum)
    (List.map part2 games |> sum)
