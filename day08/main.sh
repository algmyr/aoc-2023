#!/bin/bash
read ins
read
declare -A lookup
while read line; do
  s=( $line )
  lookup[${s[0]}L]=${s[1]}
  lookup[${s[0]}R]=${s[2]}
done < <(tr -d '=(,)' | tr -s ' ')

function solve() {
  i=0
  steps=0
  cur="$1"
  target="$2"
  n=${#target}
  while [[ ${cur: -$n} != $target ]]; do
    c=${ins:$i:1}
    (( steps++ ))
    (( i = (i + 1) % ${#ins} ))

    cur=${lookup[$cur$c]}
  done
  echo "$steps"
}

echo "Part 1: $(solve AAA ZZZ)"

function gcd() {
  ! (( $1 % $2 )) && echo $2 || gcd $2 $(( $1 % $2 ))
}

curs=( $(echo "${!lookup[@]}" | grep -o '\b[A-Z][A-Z]A') )
res=1
for cur in "${curs[@]}"; do
  len=$(solve $cur Z)
  g=$(gcd $res $len)
  (( res = res*len/g ))
done
echo "Part 2: $res"
