def prop(op: (Int, Int) => Int)(last: List[Int], y: Int) =
  last.foldLeft(y::Nil)((next, ly) => op(next.head, ly) :: next)
      .dropWhile(_ == 0).reverse

@main def aoc() =
  val input = Iterator.continually{io.StdIn.readLine()}
                      .takeWhile(_ != null)
                      .map(_.split(" ").map(_.toInt).toList)
                      .toList
  println(s"Part 1: ${input.map(_.foldLeft(Nil)(prop(_ - _))).map(_.sum).sum}")
  println(s"Part 2: ${input.map(_.reverse.foldLeft(Nil)(prop(-_ - -_)).reduceRight(_ - _)).sum}")
