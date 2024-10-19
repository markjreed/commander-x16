ChDir _StartDir$

Open "HOURGLASS.BIN" For Binary As #2
If _FileExists("HOUR2.BIN") Then Kill "HOUR2.BIN"
NumBytes = LOF(2)

Dim B As _Unsigned _Byte

Open "HOUR2.BIN" For Binary As #4

For i = 1 To NumBytes
    Get #2, , B
    If B = 1 Then B = 15
    Put #4, , B
Next i
Close 2
Close 4


