def magic(s) {
  def digits = s.findAll(/\d/)
  digits[0].toInteger()*10 + digits[-1].toInteger()
}

def part1(lines) {
  lines.sum { magic(it) }
}

def part2(lines) {
  lines.collect{
    it.replace("one", "o1e")
      .replace("two", "t2o")
      .replace("three", "t3e")
      .replace("four", "4")
      .replace("five", "5e")
      .replace("six", "6")
      .replace("seven", "7n")
      .replace("eight", "e8t")
      .replace("nine", "n9e")
  }.sum{ magic(it) }
}


def br = new BufferedReader(new InputStreamReader(System.in))
def lines = br.readLines()
println "Part 1: ${part1 lines}"
println "Part 2: ${part2 lines}"
