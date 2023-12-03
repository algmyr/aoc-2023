ghc -dynamic --make main || exit 1
ghc -dynamic --make main2 || exit 1
echo -n "Part 1: "
./main < input
echo -n "Part 2: "
./main2 < input
