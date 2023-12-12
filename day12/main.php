<?php
$f = fopen('php://stdin', 'r');

function solve($s, $nums) {
  # DP formulation:
  #   How many ways can we put the first `i` segments into the first `j` spaces.
  #   Also keep track of whether it's a forced blank.
  #
  #   dp[i][j][forced]
  $dp = array_fill(0, count($nums) + 1, array_fill(0, strlen($s) + 1, array_fill(0, 2, 0)));
  $dp[0][0][0] = 1;

  $M = strlen($s);
  $N = count($nums);
  for ($j = 0; $j < $M; $j++) {
    for ($i = 0; $i <= $N; $i++) {
      $c = $s[$j];

      if ($c != '#') {
        # We can blank on this space, disallowed+allowed => allowed.
        $dp[$i][$j+1][0] += $dp[$i][$j][0] + $dp[$i][$j][1];
      }

      # Bail if no more segments.
      if ($i == count($nums)) continue;

      $n = $nums[$i];
      // Do we even fit? If not, bail.
      if ($j + $n > strlen($s)) {
        continue;
      }
      if ($c != '.') {
        # Not a forced blank, so we can try starting a segment.
        # Check if all spaces we would cover are non-blank.
        $ok = true;
        for ($delta = 0; $delta < $n; ++$delta) {
          if ($s[$j+$delta] == '.') {
            $ok = false;
            break;
          }
        }
        if ($ok) {
          $dp[$i+1][$j+$n][1] += $dp[$i][$j][0];
        }
      }
    }
  }
  return $dp[count($nums)][strlen($s)][0] + $dp[count($nums)][strlen($s)][1];
}

$res1 = 0;
$res2 = 0;
while ($line = fgets($f)) {
  list($s, $nums) = explode(' ', $line);
  $nums = explode(',', $nums);
  $nums = array_map('intval', $nums);

  $res1 += solve($s, $nums) . "\n";

  $s = $s . '?' . $s . '?' . $s . '?' . $s . '?' . $s;
  $nums = array_merge($nums, $nums, $nums, $nums, $nums);
  $res2 += solve($s, $nums) . "\n";
}
echo "Part 1: " . $res1 . "\n";
echo "Part 2: " . $res2 . "\n";

fclose($f);
?>
