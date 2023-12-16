table.unpack = unpack or table.unpack

INF = 999999

function Input()
  local grid = {}
  while true do
    local line = io.read()
    if line == nil then break end

    local row = {}
    for c in line:gmatch(".") do
      table.insert(row, tonumber(c))
    end
    table.insert(grid, row)
  end

  local height = #grid
  local width = #grid[1]
  return width, height, function(x, y)
    if x < 1 or x > width or y < 1 or y > height then
      return INF
    end
    return grid[y][x]
  end
end

function QueueInit()
  return {data = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}}}
end

function QueuePop(queue)
  local value = queue.data[1]
  table.remove(queue.data, 1)
  queue.data[10] = {}
  return value
end

function QueuePush(queue, offset, item)
  local b = queue.data[offset]
  b[#b + 1] = item
end

function Key(x, y, t, dir)
  return x + 256*(y + 256*(t + 16*dir))
end

function Solve(target_x, target_y, get_num, min_step, max_step)
  local queue = QueueInit()
  QueuePush(queue, 1, {0, 0, 1, 1})
  QueuePush(queue, 1, {3, 0, 1, 1})

  local expand = function(last_dir, t, dir, x, y)
    if math.abs(dir - last_dir) == 2 then return end
    local cost = get_num(x, y)
    if cost == INF then return end
    if t > max_step then return end

    if last_dir ~= dir and t >= min_step then
      QueuePush(queue, cost, {dir, 1, x, y})
    elseif last_dir == dir then
      QueuePush(queue, cost, {dir, t + 1, x, y})
    end
  end

  local cost = 0
  local visited = {}
  while true do
    local layer = QueuePop(queue)
    for _, pos in ipairs(layer) do
      local last_dir, t, x, y = table.unpack(pos)

      local key = Key(x, y, t, last_dir)
      if visited[key] == nil then
        visited[key] = 1
        if x == target_x and y == target_y and t >= min_step then
          return cost
        end
        expand(last_dir, t, 0, x + 1, y)
        expand(last_dir, t, 1, x, y - 1)
        expand(last_dir, t, 2, x - 1, y)
        expand(last_dir, t, 3, x, y + 1)
      end
    end
    cost = cost + 1
  end
end

local target_x, target_y, get_num = Input()
print('Part 1:', Solve(target_x, target_y, get_num, 0, 3))
print('Part 2:', Solve(target_x, target_y, get_num, 4, 10))
