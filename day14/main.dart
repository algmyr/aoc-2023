import 'dart:io';
import 'dart:collection';

typedef Vector = List<int>;
typedef Matrix = List<Vector>;

extension on Iterable<int> {
  int sum() {
    return this.reduce((a, b) => a + b);
  }
}

extension on Matrix {
  Matrix rot90() {
    Matrix output = [];
    for (var i = 0; i < this[0].length; i++) {
      output.add([]);
    }
    for (var line in this) {
      for (var i = 0; i < line.length; i++) {
        output[i].add(line[line.length - i - 1]);
      }
    }
    return output;
  }

  Matrix rot270() {
    Matrix output = [];
    for (var i = 0; i < this[0].length; i++) {
      output.add([]);
    }
    for (var line in this.reversed) {
      for (var i = 0; i < line.length; i++) {
        output[i].add(line[i]);
      }
    }
    return output;
  }

  String stringify() {
    return this.map((line) => String.fromCharCodes(line)).join("\n");
  }
}

const EMPTY = 46;
const WALL = 35;
const ROCK = 79;
Vector gravity(Vector s) {
  var last = 0;
  for (var i = 0; i < s.length; i++) {
    if (s[i] == ROCK) {
      s[i] = EMPTY;
      s[last] = ROCK;
      last++;
    } else if (s[i] == WALL) {
      last = i + 1;
    }
  }
  return s;
}

int score(Vector s) {
  var score = 0;
  for (var i = 0; i < s.length; i++) {
    if (s[i] == ROCK) {
      score += s.length - i;
    }
  }
  return score;
}

int part1(Matrix mat) {
  return mat.rot90().map(gravity).map(score).sum();
}

Matrix cycle(Matrix mat) {
  mat = mat.map(gravity).toList().rot270();
  mat = mat.map(gravity).toList().rot270();
  mat = mat.map(gravity).toList().rot270();
  return mat.map(gravity).toList().rot270();
}

int part2(Matrix mat) {
  mat = mat.rot90();
  var togo = 1000000000;
  var seen = <String, int>{};
  while (!seen.containsKey(mat.stringify())) {
    seen[mat.stringify()] = togo--;
    mat = cycle(mat);
  }

  // Skip to end.
  var cycle_len = (seen[mat.stringify()]??0) - togo;
  togo = togo % cycle_len;
  while (togo > 0) {
    mat = cycle(mat);
    --togo;
  }
  return mat.map(score).sum();
}

void main() {
  Matrix input = [];
  while (true) {
    var line = stdin.readLineSync();
    if (line == null) {
      break;
    }
    input.add(line.runes.toList());
  }

  print("Part 1: ${part1(input)}");
  print("Part 2: ${part2(input)}");
}
