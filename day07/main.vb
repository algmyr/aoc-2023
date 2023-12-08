Module RouletteMeetsVBAndCriesHeavily
  public Structure Entry
    Public hand As Integer()
    Public score As Integer
    Public counts() As Integer
    Public Function SortKey() As Integer
      REM Bit packing is fun. Abuses that the non-top counts <= 2.
      REM This is 31 bit integer packed as 3|2|2|2|2|4|4|4|4|4.
      Return (
        counts(0) << 28 Or counts(1) << 26 Or counts(2) << 24 Or counts(3) << 22 Or counts(4) << 20 Or
        hand(0) << 16 Or hand(1) << 12 Or hand(2) << 8 Or hand(3) << 4 Or hand(4)
      )
    End Function
  End Structure

  Function ParseLine(ByVal line As String) As Entry
    Dim s = line.Split(" ")
    Dim hand = (FROM c IN s(0) SELECT "??23456789TJQKA".IndexOf(c)).ToArray()
    Dim counts = (
      FROM c IN hand GROUP BY c INTO Count SELECT Count ORDER BY Count DESCENDING
    ).Concat({0, 0, 0, 0}).Take(5).ToArray()
    Return New Entry With {.hand = hand, .score = s(1), .counts = counts}
  End Function

  Function Solve(ByVal entries() as Entry) As Integer
    Return (
      FROM entry IN entries ORDER BY entry.SortKey() ASCENDING SELECT entry
    ).Select(Function(e, i) (i+1)*e.score).Sum()
  End Function

  Sub Jokrify(ByRef entries() As Entry)
    For Each entry In entries
      Dim count = (FROM c IN entry.hand WHERE c = 11 SELECT c).Count()
      If count = 0 Then
        Continue For
      End If

      For i = 0 To 4
        If entry.hand(i) = 11 Then
          entry.hand(i) = 0
        End If
      Next

      Dim shiftin_time = False
      For i = 0 To 4
        If shiftin_time Then
          entry.counts(i-1) = entry.counts(i)
        Else If entry.counts(i) = count Then
          shiftin_time = True
        End If
      Next
      entry.counts(4) = 0
      entry.counts(0) = entry.counts(0) + count
    Next
  End Sub

  Sub Main()
    Dim entries = (
      From s In System.IO.File.ReadLines("/dev/stdin") Select ParseLine(s)
    ).ToArray()
    Console.WriteLine("Part 1: " & Solve(entries))
    Jokrify(entries)
    Console.WriteLine("Part 2: " & Solve(entries))
  End Sub
End Module
