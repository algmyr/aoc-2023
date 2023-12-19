using Helpers;
using System.Collections.Generic;

namespace AoC {
  using Rules = Dictionary<String, Rule>;
  using Values = Dictionary<String, int>;
  using InterValues = Dictionary<String, Interval>;

  class Program {
    static Tuple<Rules, List<Values>> ParseInput() {
      var rules = new Rules();

      while (true) {
        var line = Console.ReadLine();
        if (line == "" || line == null) {
          break;
        }

        var rule = new Rule();

        (var name, var rest) = line.Partition('{');
        rule.label = name;
        var rules_strs = rest.Trim("{}".ToCharArray()).Split(",");
        foreach (var rule_str in rules_strs) {
          (var cond, var label) = rule_str.Partition(':');
          if (cond == "") {
            cond = "true";
          }
          rule.conditions.Add(cond);
          rule.labels.Add(label);
        }
        rules[name] = rule;
      }

      var values_list = new List<Values>();

      while (true) {
        var line = Console.ReadLine();
        if (line == null) {
          break;
        }
        var values = new Values();
        foreach (var s in line.Trim("{}".ToCharArray()).Split(",")) {
          (var name, var value) = s.Partition('=');
          values[name] = int.Parse(value);
        }
        values_list.Add(values);
      }

      return Tuple.Create(rules, values_list);
    }

    static int Part1(Rules rules, List<Values> values_list) {
      var res = 0;
      foreach (var values in values_list) {
        var cur = "in";
        while (cur != "A" && cur != "R") {
          cur = rules[cur].Eval(values);
        }
        if (cur == "A") {
          res += values.Sum(x => x.Value);
        }
      }
      return res;
    }

    static long Part2(Rules rules) {
      var res = 0L;
      var stack = new Stack<Tuple<String, InterValues>>();
      stack.Push(Tuple.Create("in", new InterValues{
        {"x", Interval.All()},
        {"m", Interval.All()},
        {"a", Interval.All()},
        {"s", Interval.All()},
      }));
      while (stack.Count > 0) {
        var (cur, values) = stack.Pop();
        if (cur == "A") {
          res += values.Aggregate(1L, (acc, x) => acc*(long)x.Value.Size());
        } else if (cur != "R") {
          foreach (var (label, vals) in rules[cur].EvalIntervals(values)) {
            stack.Push(Tuple.Create(label, vals));
          }
        }
      }
      return res;
    }

    static void Main(string[] args) {
      var (rules, values_list) = ParseInput();

      Console.WriteLine($"Part 1: {Part1(rules, values_list)}");
      Console.WriteLine($"Part 2: {Part2(rules)}");
    }
  }

  class Interval {
    public int start;
    public int end;

    private Interval(int start, int end) {
      this.start = start;
      this.end = end;
    }

    public static Interval All() {
      return new Interval(1, 4000);
    }

    public static Interval Lt(int value) {
      return new Interval(1, value - 1);
    }

    public static Interval Gt(int value) {
      return new Interval(value + 1, 4000);
    }

    public Interval Intersect(Interval other) {
      return new Interval(Math.Max(start, other.start), Math.Min(end, other.end));
    }

    public int Size() {
      return Math.Max(0, end - start + 1);
    }

    public override String ToString() {
      return $"[{start}, {end}]";
    }
  }

  class Rule {
    public String label = "";
    public List<String> conditions = new List<String>();
    public List<String> labels = new List<String>();
    
    public String Eval(Values values) {
      for (var i = 0; i < conditions.Count; i++) {
        var cond = conditions[i];
        var label = labels[i];
        if (cond == "true") {
          return label;
        } else if (cond.Contains("<")) {
          (var lhs, var rhs) = cond.Partition('<');
          if (values[lhs] < int.Parse(rhs)) {
            return label;
          }
        } else if (cond.Contains(">")) {
          (var lhs, var rhs) = cond.Partition('>');
          if (values[lhs] > int.Parse(rhs)) {
            return label;
          }
        }
      }
      return "";
    }

    public List<Tuple<String, InterValues>> EvalIntervals(InterValues values) {
      var res = new List<Tuple<String, InterValues>>();
      foreach (var (cond, label) in conditions.Zip(labels)) {
        if (cond == "true") {
          res.Add(Tuple.Create(label, values));
        } else if (cond.Contains("<")) {
          (var lhs, var rhs) = cond.Partition('<');
          var value = int.Parse(rhs);
          var lt = Interval.Lt(value);
          var geq = Interval.Gt(value - 1);
          var copy = values.ToDictionary(x => x.Key, x => x.Value);
          copy[lhs] = copy[lhs].Intersect(lt);
          res.Add(Tuple.Create(label, copy));
          values[lhs] = values[lhs].Intersect(geq);
        } else if (cond.Contains(">")) {
          (var lhs, var rhs) = cond.Partition('>');
          var value = int.Parse(rhs);
          var gt = Interval.Gt(value);
          var leq = Interval.Lt(value + 1);
          var copy = values.ToDictionary(x => x.Key, x => x.Value);
          copy[lhs] = copy[lhs].Intersect(gt);
          res.Add(Tuple.Create(label, copy));
          values[lhs] = values[lhs].Intersect(leq);
        }
      }
      return res;
    }
  }
}
