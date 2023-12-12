defmodule Aoc do
  def twoscan(line, f) do
    f.(line)
      |> Enum.chunk_every(2, 2, :discard)
      |> Enum.scan(fn x, acc -> Enum.concat(acc, x) end)
      |> Enum.map(&f.(&1))
  end

  def count(start, delta) do Stream.iterate(start, &(&1+delta)) end

  def segments(line) do
    Enum.concat(
      Enum.zip(count(1, 1), line |> twoscan(&(&1))),
      Enum.zip(count(length(line)-1, -1), line |> twoscan(&Enum.reverse/1))
    )
  end

  def mismatches(line) do
    Enum.zip(line, Enum.reverse(line)) |> Enum.count(fn {a, b} -> a != b end)
  end

  def transpose(a) do Enum.zip(a) |> Enum.map(&Tuple.to_list/1) end

  def find_mirror(lines, t) do
    lines
      |> Enum.map(&segments/1)
      |> transpose
      |> Enum.map(&Enum.unzip/1)
      |> Enum.filter(fn {_, x} -> Enum.map(x, &mismatches/1) |> Enum.sum == 2*t end)
      |> Enum.map(&elem(&1, 0) |> Enum.at(0))
      |> Enum.sum
  end

  def solve(lines, t) do
    (lines |> find_mirror(t)) + (lines |> transpose |> find_mirror(t)) * 100
  end
end

input = IO.read(:stdio, :all)
  |> String.trim
  |> String.split("\n\n")
  |> Enum.map(fn x -> x |> String.split("\n") |> Enum.map(&String.graphemes/1) end)

input |> Enum.map(fn x -> Aoc.solve(x, 0) end) |> Enum.sum |> IO.inspect(label: "Part 1")
input |> Enum.map(fn x -> Aoc.solve(x, 1) end) |> Enum.sum |> IO.inspect(label: "Part 2")
