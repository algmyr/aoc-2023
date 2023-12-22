mutable struct Stick
  start::Vector{Int}
  direction::Vector{Int}
  length::Int
  height::Int
  z::Int
  id::Int
end

function coords(stick)
  x, y = stick.start
  dx, dy = stick.direction
  ((x + dx * i, y + dy * i) for i = 0:stick.length-1)
end

function parse_line(line::String)::Stick
  nums = parse.(Int, split(line, r"[,~]"))
  p1 = nums[1:3]
  p2 = nums[4:6]
  if p1[3] > p2[3]
    p1, p2 = p2, p1
  end
  @assert p1[3] <= p2[3]
  @assert sum(p1 .== p2) >= 2

  z = p1[3]
  height = p2[3] - z + 1
  p1 = p1[1:2] .+ 1
  p2 = p2[1:2] .+ 1
  start = p1
  direction = (p2 .- p1) / max(1, sum(abs.(p2 .- p1)))
  direction = if sum(direction) == 0
                [1, 0]
              else
                direction
              end
  length = abs.(sum(p2 .- p1)) + 1
  Stick(start, direction, length, height, z, -1)
end

function drop_stick(stick, heights, whom)
  maxi = -1
  support = Vector{Int}()
  for (x, y) = coords(stick)
    if maxi < heights[x, y]
      maxi = heights[x, y]
      support = []
      if whom[x, y] != -1
        push!(support, whom[x, y])
      end
    elseif maxi == heights[x, y]
      if whom[x, y] != -1
        push!(support, whom[x, y])
      end
    end
  end
  maxi, unique(support)
end

function main()
  sticks = [parse_line(line) for line = readlines()]
  for (i, stick) in enumerate(sticks)
    stick.id = i
  end
  sticks = sort(sticks, by = x -> x.z)

  # Drop the sticks.
  supported_by = [[] for _ = 1:length(sticks)]
  n = 10
  heights = ones(Int, n, n)
  whom = fill(-1, n, n)
  for stick in sticks
    maxi, support = drop_stick(stick, heights, whom)
    supported_by[stick.id] = unique(support)

    stick.z = maxi + 1
    for (x, y) = coords(stick)
      heights[x, y] = maxi + stick.height
      whom[x, y] = stick.id
    end
  end

  needed = Set(value[1] for value in supported_by if length(value) == 1)
  println("Part 1: ", length(sticks) - length(needed))

  # Invert the graph.
  supporting = [Vector{Int}() for _ = 1:length(sticks)]
  for (i, support) in enumerate(supported_by)
    for s in support
      push!(supporting[s], i)
    end
  end

  res2 = 0
  for need in needed
      closure = Set{Int}(need)
      todo = Vector{Int}(supporting[need])
      while !isempty(todo)
        i = pop!(todo)

        # Is this piece supported? If so, bail.
        if !all(s in closure for s in supported_by[i])
          continue
        end

        # Otherwise, add it to the closure and continue.
        push!(closure, i)
        append!(todo, supporting[i])
      end
      res2 += length(closure) - 1
  end
  println("Part 2: ", res2)
end

main()
