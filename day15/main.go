package main

import "fmt"
import "strings"
import "strconv"

func hash(s string) int {
  var sum int
  for _, c := range s {
    sum = (sum + int(c))*17 % 256
  }
  return sum
}

func part1(program []string) int {
  var res int
  for _, part := range program {
    res += hash(part)
  }
  return res
}

func bucket_remove(b *[]string, to_remove string) {
  for j, label := range *b {
    if label == to_remove {
      *b = append((*b)[:j], (*b)[j+1:]...)
      break
    }
  }
}

func part2(program []string) int {
  strengths := make(map[string]int)
  buckets := make([][]string, 256)

  for _, part := range program {
    if part[len(part)-1] == '-' {
      to_remove := part[:len(part)-1]
      bucket_remove(&buckets[hash(to_remove)], to_remove)
      delete(strengths, to_remove)
    } else {
      r := strings.Split(part, "=")
      label := r[0]
      strength, _ := strconv.Atoi(r[1])
      if _, ok := strengths[label]; !ok {
        buckets[hash(label)] = append(buckets[hash(label)], label)
      }
      strengths[label] = strength
    }
  }

  var res int
  for i, b := range buckets {
    for j, label := range b {
      res += strengths[label] * (i+1) * (j+1)
    }
  }

  return res
}

func main() {
  var s string
  fmt.Scanln(&s)
  program := strings.Split(s, ",")
  fmt.Println("Part 1:", part1(program))
  fmt.Println("Part 2:", part2(program))
}
