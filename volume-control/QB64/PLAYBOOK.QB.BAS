$Console
$ScreenHide
_Source _Console
_Dest _Console
_Title "Volume Control - Book Player"

Type WaveHeaderType
    RiffID As String * 4 'should be 'RIFF'
    RiffLength As _Unsigned Long
    'rept. chunk id and size then chunk data
    WavID As String * 4 'should be 'WAVE'
    FmtID As String * 4
    FmtLength As Long
    'FMT ' chunk - common fields
    wavformattag As Integer ' word - format category e.g. 0x0001=PCM
    Channels As Integer ' word - number of Channels 1=mono 2=stereo
    SamplesPerSec As Long 'dword - sampling rate e.g. 44100Hz
    avgBytesPerSec As Long 'dword - to estimate buffer size
    blockalign As Integer ' word - buffer size must be int. multiple of this
    FmtSpecific As Integer ' word
    DataID As String * 4
    DataLength As _Unsigned Long
End Type

Common Shared Slash$
Common Shared Title$
Common Shared Author$
Common Shared SubTitle$
Common Shared YEAR$
Common Shared PLAYFILE$
Common Shared BOOKFILE$
Common Shared CHAPTER
Common Shared CHAPTERS
Common Shared BytesPerSecond
Common Shared BytesPerSecond_VERA

Dim Shared DChars%(10)
Dim Shared Book_WavHeader As WaveHeaderType


Slash$ = "/"

Const BLACK = 0
Const VGA_BLUE = 1
Const VGA_GREEN = 2
Const VGA_CYAN = 3
Const VGA_RED = 4
Const VGA_MAGENTA = 5
Const VGA_ORANGE = 6
Const VGA_MEDGRAY = 7
Const VGA_DARKGRAY = 8
Const VGA_LITEBLUE = 9
Const VGA_LITEGREEN = 10
Const VGA_LITECYAN = 11
Const VGA_LITERED = 12
Const VGA_LITEMAGENTA = 13
Const VGA_BLACK2 = 13
Const VGA_YELLOW = 14
Const VGA_WHITE = 15

dcharacters:
Data &hC9,&hCD,&hBB,&hBA,&hBA,&hC8,&hCD,&hBC

MyRoot$ = _CWD$
ChDir _StartDir$


If _CommandCount <> 1 Then
    Print "Usage: PLAYBOOK  ..BOOKFOLDER.."
    System
End If

If Not Is_ABook_Folder(Command$(1)) Then
    Print Command$(1); " Is not a valid Volume Control Book!"; Chr$(7)
    System
End If

LoadDChars

$ScreenShow
Screen 0
_Dest 0
Width 40, 30
_Font 15
_Blink Off
Color BLACK, VGA_ORANGE: Cls

Color VGA_ORANGE + 16, VGA_DARKGRAY
TEXTBOX 4, 3, 24, 36


Locate 29, 1
Color BLACK, BLACK
Print rpt$(32, 40);
Locate 30, 1
Print rpt$(32, 40);
Color VGA_GREEN
Locate 3, 1
For i = 1 To _CommandCount
    Print Command$(i),
Next
Print
Print "."
Print ".."
Print "..."; rpt$(177, 3);

Input A$
System

Sub TEXTBOX (Y As Integer, X As Integer, H As Integer, W As Integer)
    Locate Y, X: Print Chr$(DChars%(1)); rpt$(DChars%(2), W - 2); Chr$(DChars%(3));
    If H = 2 Then GoTo SKIPMID
    BStart = Y + 1: BEnd = Y + (H - 2)
    For Y2 = BStart To BEnd: Locate Y2, X: Print Chr$(DChars%(4)); rpt$(32, W - 2); Chr$(DChars%(5));: Next
    SKIPMID:
    Locate Y + H - 1, X: Print Chr$(DChars%(6)); rpt$(DChars%(7), W - 2); Chr$(DChars%(8));
End Sub

Sub LoadDChars ()
    Restore dcharacters
    For I = 1 To 8
        Read DChars%(I)
    Next
End Sub

Function rpt$ (ChrCode As _Unsigned _Byte, length As _Unsigned _Byte)
    tmp$ = ""
    For I = 1 To length
        tmp$ = tmp$ + Chr$(ChrCode)
    Next
    rpt = tmp$
End Function

Function Is_ABook_Folder% (Target$)
    tmp% = 0
    Target$ = _Trim$(Target$)

    If _DirExists(Target$) Then
        Test$ = Target$
        If Right$(Test$, 1) <> Slash$ Then
            Test$ = Test$ + Slash$
        End If
        Test$ = Test$ + "BOOK.DESC"
        tmp% = _FileExists(Test$)
    End If
    Is_ABook_Folder = tmp%
End Function

Sub LOADBOOK ()
    LOADBOOK:
    GOT.SINGLE = 0
    SUCCESS = 0
    Open "BOOK.DESC" For Input As #5
    SubTitle$ = ""
    Input #5, Title$
    Input #5, Author$
    Line Input #5, TMP$
    If TMP$ = "ENDDESC" Then GoTo ENDLOADBOOK
    YEAR$ = TMP$
    Line Input #5, TMP$
    If TMP$ = "ENDDESC" Then GoTo ENDLOADBOOK
    SubTitle$ = TMP$
    ENDLOADBOOK:
    SUCCESS = TRUE
    Close 5
    If _FileExists("BOOK.CHAPS") Then
        Open "BOOK.CHAPS" For Input As #5
        Input #5, S$
        S$ = _Trim$(S$)
        If S$ = "NONE" Then GoTo GOT_A_SINGLE
        CHAPTERS = Val(S$)
        If CHAPTERS = 0 Then CHAPTERS = -1
        GoTo DONE_LOAD_BOOK
        GOT_A_SINGLE:
        GOT_SINGLE = -1
        CHAPTERS = -2
        SINGLE.CHAPTER = -1
        Input #5, BOOKFILE$
        PLAYFILE$ = BOOKFILE$
        DONE_LOAD_BOOK:
        Close 5
        Exit Sub
    End If
    COUNT_Chapters
End Sub

Sub COUNT_Chapters ()
End Sub

Sub WriteBookMark ()
End Sub






