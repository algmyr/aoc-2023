import Data.Char (isDigit)
import Data.List (tails, transpose)
import Data.List.NonEmpty (toList, groupWith)

grid_map :: (a -> b) -> [[a]] -> [[b]]
grid_map f grid = map (map f) grid

grid_zip :: [[a]] -> [[b]] -> [[(a, b)]]
grid_zip a b = zipWith zip a b

triples :: [Bool] -> [[Bool]]
triples seq = take (length seq) ((map (take 3) . tails) (False:seq))

convolve row = map or (triples row)

expand_mask :: [[Bool]] -> [[Bool]]
expand_mask mask = transpose $ map convolve (transpose (map convolve mask))

group_if_digits line = map toList (groupWith (\a -> (isDigit (fst a))) line)

extract_valid_numbers values = map (to_int.(map fst)) $
                               filter (all (isDigit.fst)) $
                               filter (any snd) values

to_int s = read s :: Integer

part1 lines = sum numbers
  where
    numbers = extract_valid_numbers grouped
    grouped = concat $ map group_if_digits $ grid_zip lines symbol_adjacent
    symbol_adjacent = expand_mask symbols
    symbols = grid_map (\c -> c /= '.' && not (isDigit c)) lines

main = do
  inp <- lines <$> getContents
  print $ part1 inp
