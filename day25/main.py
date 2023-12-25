from collections import defaultdict
from collections.abc import Mapping
import random
import sys


class DSU:
    """Disjoint Set Union."""

    def __init__(self, n: int):
        self.p = list(range(n))
        self.sz = [1] * n

    def find(self, x: int) -> int:
        """Find representative of x."""
        if self.p[x] != x:
            self.p[x] = self.find(self.p[x])
        return self.p[x]

    def union(self, x: int, y: int) -> None:
        """Merge x and y."""
        x, y = self.find(x), self.find(y)
        if x != y:
            if self.sz[x] < self.sz[y]:
                x, y = y, x
            self.p[y] = x
            self.sz[x] += self.sz[y]


def karger_min_cut(conn: Mapping[int, list[int]]) -> tuple[int, int]:
    """Karger's algorithm for minimum cut. Returns (min_cut, size_of_group)."""
    n = len(conn)
    edges = []
    for src, dsts in conn.items():
        for dst in dsts:
            if src < dst:
                edges.append((src, dst))
    random.shuffle(edges)

    dsu = DSU(len(conn))
    for u, v in edges:
        if n <= 2:
            break
        u = dsu.find(u)
        v = dsu.find(v)
        if u == v:
            continue
        dsu.union(u, v)
        n -= 1

    return sum(dsu.find(u) != dsu.find(v) for u, v in edges), dsu.sz[dsu.find(0)]


def _map_to_int(s: str, m: dict[str, int] = {}) -> int:  # noqa: B006
    if s in m:
        return m[s]
    m[s] = len(m)
    return m[s]


conn = defaultdict(list)
for s in sys.stdin.read().splitlines():
    src, dsts = s.split(': ')
    src = _map_to_int(src)
    dsts = map(_map_to_int, dsts.split())

    for dst in dsts:
        conn[src].append(dst)
        conn[dst].append(src)

while True:
    res, sz = karger_min_cut(conn)
    if res == 3:
        print('Part 1:', sz * (len(conn) - sz))
        break
