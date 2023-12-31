const assert = require('node:assert').strict;

// BitSet stuffing bits in a double.
class BitSet {
  constructor(data) {
    this.data = data;
  }

  add(i) {
    let hi = Math.trunc(this.data / 0x100000000);
    if (i < 32) {
      this.data = (this.data | (1 << i)) >>> 0;
      this.data += hi * 0x100000000;
      return;
    }
    let hi_mod = hi | (1 << (i - 32));
    this.data = this.data - hi * 0x100000000 + hi_mod * 0x100000000;
  }

  has(i) {
    if (i < 32) {
      return !!(this.data & (1 << i));
    }
    let hi = Math.trunc(this.data / 0x100000000);
    return !!(hi & (1 << (i - 32)));
  }
}

function find_graph(grid, ignore_arrows) {
  const get = (x, y) => {
    if (y < 0 || y >= grid.length) return '#';
    const row = grid[y];
    if (x < 0 || x >= row.length) return '#';
    return row[x];
  };
  const set = (x, y, value) => { grid[y][x] = value; };

  const start_x = grid[0].indexOf('.');

  // Explore to build graph.
  const junction_by_coord = new Map();
  const junction_at = (x, y) => {
    const key = [x, y].toString();
    if (!junction_by_coord.has(key)) {
      junction_by_coord.set(key, junction_by_coord.size);
      return [true, junction_by_coord.get(key)];
    }
    return [false, junction_by_coord.get(key)];
  };

  const stack = [[start_x, 0, 0, 0, junction_at(start_x, 0)[1], 0, 0]];
  const conn = [[]];

  while (stack.length) {
    let [x, y, dist, directed, last_node, last_dx, last_dy] = stack.pop();
    const on = get(x, y);
    if (on === '#' || on === '!') continue;

    const n_adj = (get(x, y - 1) !== '#') + (get(x, y + 1) !== '#') +
                  (get(x - 1, y) !== '#') + (get(x + 1, y) !== '#');

    if (y === grid.length - 1) {
      // End.
      let [created, new_node] = junction_at(x, y);
      if (created)
        conn.push([]);
      if (directed >= 0 || ignore_arrows) {
        conn[last_node].push([new_node, dist]);
      }
      if (directed <= 0 || ignore_arrows) {
        conn[new_node].push([last_node, dist]);
      }
      continue;
    }

    if (n_adj > 2) {
      // Junction.
      set(x-last_dx, y-last_dy, '!');
      let [created, new_node] = junction_at(x, y);
      if (created)
        conn.push([]);
      if (directed >= 0 || ignore_arrows) {
        conn[last_node].push([new_node, dist]);
      }
      if (directed <= 0 || ignore_arrows) {
        conn[new_node].push([last_node, dist]);
      }
      last_node = new_node;
      dist = 0;
      directed = 0;
    }

    const rectify = (dx, dy, withh, against) => {
      if (last_dx === dx && last_dy === dy) {
        if (on === withh) {
          assert(directed >= 0);
          return 1;
        }
        if (on === against) {
          assert(directed <= 0);
          return -1;
        }
      }
      return directed;
    };

    // console.log('rectify', x, y, last_dx, last_dy, directed);
    directed = rectify(1, 0, '>', '<');
    directed = rectify(-1, 0, '<', '>');
    directed = rectify(0, 1, 'v', '^');
    directed = rectify(0, -1, '^', 'v');

    const next = (dx, dy) => {
      if (dx === -last_dx && dy === -last_dy) return;
      stack.push([x + dx, y + dy, dist + 1, directed, last_node, dx, dy]);
    };
    next(1, 0);
    next(-1, 0);
    next(0, 1);
    next(0, -1)
  }

  return [conn, junction_by_coord.size];
}

function dump_graphviz(conn) {
  console.log('digraph {');
  for (let i = 0; i < conn.length; i++) {
    for (const [j, dist] of conn[i]) {
      console.log(`  ${i} -> ${j} [label="${dist}"];`);
    }
  }
  console.log('}');
}

function longest_distance(conn, start, target) {
  // Brute force explore to find longest path.
  
  let dreamy_upper_bound = 0;
  // For all nodes, for all edges...
  for (let i = 0; i < conn.length; i++) {
    let dists = [];
    for (const [j, dist] of conn[i]) {
      dists.push(dist);
    }
    dists.sort((a, b) => b - a);
    if (dists.length == 1) dists.push(dists[0]);
    dreamy_upper_bound += dists[0] + dists[1];
  }
  dreamy_upper_bound /= 2;

  const stack = [[start, 0, new BitSet(0), 0, 0]];
  let best = 0;

  while (stack.length) {
    const [cur, dist, visited, rejected, last_d] = stack.pop();
    if (visited.has(cur)) continue;
    visited.add(cur);

    if (dreamy_upper_bound && dist + dreamy_upper_bound - rejected < best) {
      continue;
    }

    if (cur === target) {
      best = Math.max(best, dist);
      continue;
    }

    let tot = 0;
    for (const [next, d] of conn[cur]) {
      tot += d;
    }

    let found = conn[cur].find(([next, d]) => next === target);
    if (found) {
      best = Math.max(best, dist + found[1]);
      continue;
    }
    for (const [next, d] of conn[cur]) {
      stack.push([next, dist + d, new BitSet(visited.data), rejected + tot - last_d - d, d]);
    }
  }

  return best
}

function solve(data, ignore_arrows) {
  const grid = data.trim().split('\n').map(l => l.split(''));
  const [conn, n_junctions] = find_graph(grid, ignore_arrows);
  return longest_distance(conn, 0, n_junctions - 1);
}

const fs = require('fs');
const data = fs.readFileSync(0, 'utf-8');
console.log(`Part 1: ${solve(data, false)}`);
console.log(`Part 2: ${solve(data, true)}`);
