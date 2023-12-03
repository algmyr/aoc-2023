from collections.abc import Iterable, Iterator
import itertools
import sys

PREAMBLE = """\
range_events([], []).
range_events([range(L, R)|Ranges], [[L, range_start]|[[R, range_end]|Events]]) :- range_events(Ranges, Events).

shift_events([], []).
shift_events([shifty(range(L, R), Shift)|Shifts], [[L, shift_start, Shift]|[[R, shift_end]|Events]]) :- shift_events(Shifts, Events).

shift_range(range(L, R), Shift, range(SL, SR)) :- SL is L+Shift, SR is R+Shift.

rangify_impl([], none, none, []).
rangify_impl([[X, range_start]|Events],        none, none, Ranges) :- rangify_impl(Events, range_start(X), none, Ranges).
rangify_impl([[X, range_start]|Events],        none, shift_start(_, Shift), Ranges) :- rangify_impl(Events, range_start(X), shift_start(X, Shift), Ranges).
rangify_impl([[X, shift_start, Shift]|Events], range_start(L), none, [range(L, X)|Ranges]) :- rangify_impl(Events, range_start(X), shift_start(X, Shift), Ranges).
rangify_impl([[X, shift_start, Shift]|Events], none, none, Ranges) :- rangify_impl(Events, none, shift_start(X, Shift), Ranges).

rangify_impl([[X, range_end]|Events], range_start(L), none, [range(L, X)|Ranges]) :-
  rangify_impl(Events, none, none, Ranges).
rangify_impl([[X, range_end]|Events], _, shift_start(SL, Shift), [R|Ranges]) :-
  shift_range(range(SL, X), Shift, R),
  rangify_impl(Events, none, shift_start(SL, Shift), Ranges).

rangify_impl([[_, shift_end]|Events], none, _, Ranges) :-
  rangify_impl(Events, none, none, Ranges).
rangify_impl([[X, shift_end]|Events], _, shift_start(SL, Shift), [R|Ranges]) :-
  shift_range(range(SL, X), Shift, R),
  rangify_impl(Events, range_start(X), none, Ranges).

empty_range(range(L, R)) :- L >= R.
rangify(Events, Ranges) :-
  rangify_impl(Events, none, none, RawRanges),
  exclude(empty_range, RawRanges, Ranges).

transform(Ranges, Shifts, Results) :-
  range_events(Ranges, REvents),
  shift_events(Shifts, SEvents),
  append(REvents, SEvents, Combined),
  sort(Combined, Sorted),
  rangify(Sorted, Results).

leftify([], []).
leftify([range(L, _)|Ranges], [L|LRanges]) :- leftify(Ranges, LRanges).

"""  # noqa: E501

def _chunks(it: Iterable, n: int) -> Iterator[list]:
    it = iter(it)
    while True:
        chunk = list(itertools.islice(it, n))
        if not chunk:
            break
        yield chunk

def _parse_triples(lines: Iterable[str]) -> Iterator[Iterator[int]]:
    for line in lines:
        yield map(int, line.split())

def _shiftys(lines: Iterable[str]) -> Iterator[str]:
    it = _parse_triples(lines)
    next(it)
    for dst, src, sz in it:
        start = src
        end = src + sz
        shift = dst - src
        yield f'shifty(range({start}, {end}), {shift})'

def _ranges(seeds: list[int]) -> Iterator[str]:
    for start, sz in _chunks(seeds, 2):
        yield f'range({start}, {start+sz})'

parts = iter(sys.stdin.read().split('\n\n'))

pre, seeds = next(parts).split(': ')
seeds = [int(x) for x in seeds.split()]
assert pre == 'seeds'
aoc_part = sys.argv[1]
assert aoc_part in {'1', '2'}
if sys.argv[1] == '1':
    ranges = '[' + ', '.join(f'range({s}, {s+1})' for s in seeds) + ']'
else:
    ranges = '[' + ', '.join(_ranges(seeds)) + ']'

print(PREAMBLE)
print(':-')
for i, part in enumerate(parts):
    print('transform(')
    print(f'  {ranges},')
    print('  [' + ', '.join(_shiftys(part.splitlines())) + '],')
    print(f'  Ranges{i}')
    print('),')
    ranges = f'Ranges{i}'
print(f'leftify({ranges}, Lefts),')
print('min_list(Lefts, Min),')
print(f'format("Part {aoc_part}: ~w\n", [Min]), halt.')
