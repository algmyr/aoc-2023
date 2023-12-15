data class Beam(val x : Int, val y : Int, val dir : Int) {
  fun turnLeft(): Beam {
    return Beam(x, y, (dir + 1) % 4)
  }
  fun turnRight(): Beam {
    return Beam(x, y, (dir + 3) % 4)
  }
  fun move(): Beam {
    val dx = arrayOf(1, 0, -1, 0)
    val dy = arrayOf(0, -1, 0, 1)
    return Beam(x + dx[dir], y + dy[dir], dir)
  }
  fun stop(): Beam {
    return Beam(x, y, -1)
  }
}

fun simulate(lines: List<String>, start: Beam): Int {
  val height = lines.size
  val width = lines[0].length
  val isInside = {beam: Beam -> beam.x in 0..<width && beam.y in 0..<height}
  val valueAt = {beam: Beam -> if (!isInside(beam)) 'Q' else lines[beam.y][beam.x]}

  val beams = ArrayDeque(listOf(start))
  val seen = mutableSetOf<Beam>()
  while (beams.isNotEmpty()) {
    var cur = beams.removeLast()
    if (seen.contains(cur)) continue
    if (isInside(cur)) seen.add(cur)
    cur = cur.move()

    beams.addAll(
      when (valueAt(cur)) {
        '|' -> if (cur.dir%2 == 0) listOf(cur.turnLeft(), cur.turnRight()) else listOf(cur)
        '-' -> if (cur.dir%2 == 1) listOf(cur.turnLeft(), cur.turnRight()) else listOf(cur)
        '/' ->  if (cur.dir%2 == 0) listOf(cur.turnLeft()) else listOf(cur.turnRight())
        '\\' -> if (cur.dir%2 == 0) listOf(cur.turnRight()) else listOf(cur.turnLeft())
        'Q' -> listOf()
        else -> listOf(cur)
      }
    )
  }

  return seen.map{it.stop()}.distinct().size
}

fun main() {
  val lines = generateSequence{readLine()}.toList()
  val height = lines.size
  val width = lines[0].length

  println("Part 1: ${simulate(lines, Beam(-1, 0, 0))}")

  val best = listOf(
    (0..<width).map({Beam(-1, it, 0)}),
    (0..<width).map({Beam(width, it, 2)}),
    (0..<height).map({Beam(it, -1, 3)}),
    (0..<height).map({Beam(it, height, 1)}),
  ).flatten().map{simulate(lines, it)}.max()
  println("Part 2: $best")
}
