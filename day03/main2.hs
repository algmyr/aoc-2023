import Data.Char (isDigit)
import Data.List (tails, transpose)
import Data.List.NonEmpty (toList, groupWith)

-- Padding.
pad_row row = "." ++ row ++ "."

pad_grid grid =
  edge : map pad_row grid ++ [edge]
  where
    len = length (head grid)
    edge = replicate (len+2) '.'

-- Parsing.
empty = 0
gear = -1
other = -2

to_ints s = replicate (length s) (read $ reverse s)

parse_line' digits (x:xs) | isDigit x = parse_line' (x:digits) xs
                          | x == '.'  = to_ints digits++empty:parse_line' [] xs
                          | x == '*'  = to_ints digits++gear :parse_line' [] xs
                          | otherwise = to_ints digits++other:parse_line' [] xs
parse_line' digits [] = to_ints digits
parse_line digits = parse_line' "" digits

parse :: [String] -> [[Int]]
parse grid = map parse_line grid

-- Triples.
to_tuple [a, b, c] = (a, b, c)
triples :: [a] -> [(a, a, a)]
triples seq = map to_tuple $ take (length seq - 2) ((map (take 3) . tails) seq)

-- Main sol.
--
-- Idea: For each local neighborhood we can determine the answer.
--       Most of the annoying work is to get the 3x3 neighborhood.
if_pos x | x > 0 = [x]
         | otherwise = []

positives (a, b, c) = if_pos a ++ if_pos b ++ if_pos c

row_values (a, b, c)  | a>1 && b>1 && c>1 = [a]
                      | a>1 && b>1        = [a]
                      | b>1 && c>1        = [b]
                      | otherwise         = positives (a, b, c)

neighbor_values (a1, a2, a3)
                (b1, b2, b3)
                (c1, c2, c3)
  | b2 == gear = row_values (a1, a2, a3) ++
                 row_values (b1, b2, b3) ++
                 row_values (c1, c2, c3)
  | otherwise = []

solve1 (a, b, c) = zipWith3 neighbor_values (triples a) (triples b) (triples c)

part2 lines = sum $ map product $ filter ((==2).length) (concat geared)
  where
    geared = map solve1 (triples grid)
    grid = parse $ pad_grid lines

main = do
  inp <- lines <$> getContents
  print $ part2 inp
