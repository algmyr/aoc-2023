sub zip {
  my @lines = @_;
  my @zipped;
  my $len = length($lines[0]);
  for (my $i = 0; $i < $len; $i++) {
    my $line = '';
    for (@lines) {
      $line .= substr($_, $i, 1);
    }
    if ($line =~ m/^\s*$/) {
      next;
    }
    push (@zipped, $line);
  }
  return @zipped;
}

sub positions {
  my @positions;
  my $i = 0;
  for (@_) {
    for (1..$_ =~ tr/#//) {
      push (@positions, $i);
    }
    ++$i;
  }
  return @positions;
}

sub distance {
  my $sum = 0;
  for (my $i = 0; $i < @_; $i++) {
    for (my $j = $i+1; $j < @_; $j++) {
      $sum += abs($_[$i] - $_[$j]);
    }
  }
  return $sum;
}

sub empty_positions {
  my @positions;
  my $i = 0;
  for (@_) {
    if ($_ =~ m/^\.*$/) {
      push (@positions, $i);
    }
    ++$i;
  }
  return @positions;
}

sub solve_1d {
  my $boost_factor = shift;
  my @x = positions(@_);
  my @x_empty = empty_positions(@_);

  my $i = 0;
  my $boost = 0;
  my @x_expanded;
  for (@x) {
    while ($i < @x_empty && $x_empty[$i] < $_) {
      $boost += ($boost_factor - 1);
      ++$i;
    }
    push (@x_expanded, $_ + $boost);
  }

  return distance(@x_expanded);
}

chomp(@a = <>);
my $expand = 2;
print "Part 1: ", solve_1d($expand, @a) + solve_1d($expand, zip(@a)), "\n";
my $expand = 1000000;
print "Part 2: ", solve_1d($expand, @a) + solve_1d($expand, zip(@a)), "\n";
