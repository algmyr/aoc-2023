def coords(input)
  x = 0
  y = 0
  xs = [x]
  ys = [y]
  for d, n in input do
    y += n if d == 'D'
    y -= n if d == 'U'
    x += n if d == 'R'
    x -= n if d == 'L'
    xs.push(x)
    ys.push(y)
  end
  [xs, ys]
end

def intervals(x)
  x = x.sort.uniq
  ranges = [[x[0], x[0] + 1]]
  x.each_cons(2) {|l, r|
    ranges.push([l + 1, r]) if r - l != 1
    ranges.push([r, r + 1])
  }
  ranges
end

def int_size(l, r)
  r - l
end

def fill_in_grid(xs, ys, x_int, y_int)
  i = 0
  j = 0
  # go to start
  i += 1 while y_int[i][0] != ys[0]
  j += 1 while x_int[j][0] != xs[0]

  res = 0
  grid = (0..y_int.size).map{|_| ('.'*x_int.size).chars}
  for ((x0, y0), (x1, y1)) in xs.zip(ys).each_cons(2) do
    if x0 == x1 then
      # Vert
      if y0 < y1 then
        while true do
          l, r = y_int[i]
          break if r-1 == y1
          grid[i][j] = '#'
          res += r - l
          i += 1
        end
      else
        while true do
          l, r = y_int[i]
          break if l == y1
          grid[i][j] = '#'
          res += r - l
          i -= 1
        end
      end
    else
      # Horz
      if x0 < x1 then
        while true do
          l, r = x_int[j]
          break if r-1 == x1
          grid[i][j] = '#'
          res += r - l
          j += 1
        end
      else
        while true do
          l, r = x_int[j]
          break if l == x1
          grid[i][j] = '#'
          res += r - l
          j -= 1
        end
      end
    end
  end
  [res, grid]
end

def flood_fill(grid, x_int, y_int)
  si = 0
  sj = 0
  sj += 1 while grid[0][sj] != '#'
  # Inside, assuming not .##
  #                      .##
  area = 0
  stack = [[si+1, sj+1]]
  while !stack.empty? do
    i, j = stack.pop()
    if grid[i][j] != '#' then
      grid[i][j] = '#'
      xl, xr = x_int[j]
      yl, yr = y_int[i]
      area += (xr - xl)*(yr - yl)
      stack.push([i-1, j], [i+1, j], [i, j-1], [i, j+1])
    end
  end
  area
end

def solve(input)
  xs, ys = coords(input)
  x_int = intervals(xs)
  y_int = intervals(ys)
  contour, grid = fill_in_grid(xs, ys, x_int, y_int)
  insides = flood_fill(grid, x_int, y_int)
  contour + insides
end

input = $<.map{|s| s.split}.map{|(a,b,c)| [a, b.to_i, c[2..-2]]}
res1 = solve(input.map{|(d, n, _)| [d, n]})
puts "Part 1: #{res1}"
res2 = solve(input.map{|(_, _, h)| ['RDLU'[h[-1].to_i(16)], h[..-2].to_i(16)]})
puts "Part 2: #{res2}"
