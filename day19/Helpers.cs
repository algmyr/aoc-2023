namespace Helpers {
  public static class Extensions {
    public static Tuple<String, String> Partition(this String s, Char c) {
      var i = s.IndexOf(c);
      if (i == -1) {
        return Tuple.Create("", s);
      }
      return Tuple.Create(s.Substring(0, i), s.Substring(i + 1));
    }
  }
}
