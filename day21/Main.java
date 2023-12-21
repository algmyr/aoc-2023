import java.io.*;
import java.util.*;
import java.util.function.*;

List<String> parseInput() {
  var lines = new ArrayList<String>();
  try {
    var reader = new BufferedReader(new InputStreamReader(System.in));
    while (true) {
      String line = reader.readLine();
      if (line == null) break;
      lines.add(line);
    }
  } catch (IOException e) {
    System.out.println("Error: " + e);
    System.exit(1);
  }
  return lines;
}

Position makePos(int x, int y) {
  return new Position(x, y);
}

record Position(int x, int y) {}

int solve(List<String> lines, int start_x, int start_y, int n_steps) {
  int height = lines.size();
  int width = lines.get(0).length();
  
  // Set of positions
  var positions = new HashSet<Position>();
  positions.add(makePos(start_x, start_y));
  for (int i = 0; i < n_steps; ++i) {
    var newPositions = new HashSet<Position>();
    Consumer<Position> tryMove = p -> {
      if (lines.get(Math.floorMod(p.y, width)).charAt(Math.floorMod(p.x, height)) == '#')
        return;
      newPositions.add(p);
    };

    for (var pos : positions) {
      tryMove.accept(makePos(pos.x + 1, pos.y));
      tryMove.accept(makePos(pos.x - 1, pos.y));
      tryMove.accept(makePos(pos.x, pos.y + 1));
      tryMove.accept(makePos(pos.x, pos.y - 1));
    }
    positions = newPositions;
  }
  return positions.size();
}

void main() {
  var lines = parseInput();

  int s_y = -1;
  int s_x = -1;

  for (int i = 0; i < lines.size(); i++) {
    int j = lines.get(i).indexOf('S');
    if (j != -1) {
      s_y = i;
      s_x = j;
      break;
    }
  }

  // This is inefficient, but let's do a difference table
  // extrapolation like in day 9 for fun.
  System.out.println("Part 1: " + solve(lines, s_x, s_y, 64));
  var seq = new int[4];
  for (int i = 0; i < 4; ++i) {
    seq[i] = solve(lines, s_x, s_y, 131*i + 65);
  }

  // Difference table column
  var column = new long[4];
  column[0] = seq[3];
  seq[3] = seq[3] - seq[2];
  seq[2] = seq[2] - seq[1];
  seq[1] = seq[1] - seq[0];
  column[1] = seq[3];
  seq[3] = seq[3] - seq[2];
  seq[2] = seq[2] - seq[1];
  column[2] = seq[3];
  seq[3] = seq[3] - seq[2];
  column[3] = seq[3];
  assert(column[3] == 0);

  assert((26501365 - 65)/131 == 202300);
  assert((26501365 - 65)%131 == 0);

  // We are at n=4, we want to get to n=202301
  for (int i = 4; i < 202301; ++i) {
    column[2] = column[2] + column[3];
    column[1] = column[1] + column[2];
    column[0] = column[0] + column[1];
  }
  System.out.println("Part 2: " + column[0]);
}
