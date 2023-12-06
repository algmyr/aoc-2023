let read () =
    System.Console.ReadLine().Split(' ', System.StringSplitOptions.RemoveEmptyEntries)
    |> Seq.tail |> Seq.map double

let solve t d =
    let Δ = t*t/4.0 - d
    (ceil (t/2.0 + sqrt Δ - 1.0)) - (floor (t/2.0 - sqrt Δ + 1.0)) + 1.0 |> int

let numcat nums = nums |> Seq.map (int >> string) |> String.concat "" |> double

let times = read ()
let distances = read ()
Seq.map2 solve times distances |> Seq.reduce (*) |> printfn "Part 1: %A"
solve (numcat times) (numcat distances) |> printfn "Part 2: %A"
