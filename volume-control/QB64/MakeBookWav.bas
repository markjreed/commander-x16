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

$Console
$ScreenHide
_Source _Console
_Dest _Console

Dim Header As WaveHeaderType
Dim Buffer As String * 65536
Dim BuffCounter As _Unsigned Long
Dim FileCounter As _Unsigned Long

Dim B As _Unsigned _Byte

Header.RiffID = "RIFF"
Header.WavID = "WAVE"
Header.FmtID = "fmt "
Header.FmtLength = 16
Header.DataID = "data"

Header.wavformattag = 1
Header.Channels = 1
Header.FmtSpecific = 16



ChDir _StartDir$

InFile$ = Get_InAudioFile

If UCase$(Right$(InFile$, 4)) = ".AAX" Then
    IsAudibleFile = -1
    Print
    Print "Get your Audible Decode Bytes at ": Print
    Print "https://audible-tools.kamsker.at/540e44c56078a08912d24ff7db4968fe34b16000"
    Print
    DecodeString$ = _InputBox$("THIS IS An Audible Audio File", "This requires a decode string" + Chr$(13) + "This web site can provide that" + Chr$(13) + "   https://audible-tools.kamsker.at/540e44c56078a08912d24ff7db4968fe34b16000")
    If DecodeString$ = "" Then System
End If




SampleRate$ = GetOutputSampleRate

Header.SamplesPerSec = Val(SampleRate$)
Header.avgBytesPerSec = Header.SamplesPerSec * 2
Header.blockalign = 2


fcmd$ = "ffmpeg -y "
If IsAudibleFile Then fcmd$ = fcmd$ + "-activation_bytes " + DecodeString$
fcmd$ = fcmd$ + " -i '" + InFile$ + "' -f s16le -ac 1 -ar " + SampleRate$ + " -acodec pcm_s16le out.raw"
Print "Executing: "; fcmd$
_Delay .25
Shell fcmd$

OutFile$ = _InputBox$("OUTPUT WAVE", "Enter Output Name", "CHAP")

If GetFileExt(OutFile$) = "" Then OutFile$ = OutFile$ + ".WAV"

If _FileExists(OutFile$) Then
    CHOICE = _MessageBox("FILE EXISTS", OutFile$ + " exists.  OverWrite ?", "yesno", "warning", 0)
    If CHOICE <> 1 Then System
    Kill OutFile$
End If

Open "out.raw" For Binary As #1
Open OutFile$ For Binary As #2

FSize = LOF(1)

BufferCount = Int(FSize / 65536)
ByteCount = FSize - (BufferCount * 65536)

Header.RiffLength = FSize + 36
Header.DataLength = Header.RiffLength - 44
Print "Writing: "; OutFile$

Put #2, , Header

If BufferCount > 0 Then
    For FileCounter = 1 To BufferCount
        Get #1, , Buffer
        Put #2, , Buffer
    Next FileCounter
End If

If ByteCount > 0 Then
    For FileCounter = 1 To ByteCount
        Get #1, , B
        Put #2, , B
    Next FileCounter
End If

Print
Kill "out.raw"
Print "DONE !"
Print
System


Function Get_InAudioFile$
    FName$ = _OpenFileDialog$("Select Input Audio File", "", "*.wav|*.WAV|*.mp3|*.MP3|*.m4a|*.M4A|*.aiff|*.AIFF|*.flac|*.FLAC|*.wma|*.WMA|*.aac|*.AAC|*.aax|*.AAX|*.ogg|*.OGG", "Audio", 0)
    If FName$ = "" Then System
    Get_InAudioFile$ = FName$
End Function

Function GetOutputSampleRate$
    AGAIN:
    RATE$ = _InputBox$("AUDIO SAMPLE RATE", "Output Sample Rate", "16000")
    If RATE$ = "" Then System
    If Not IsNum(RATE$) Then Print Chr$(7): GoTo AGAIN
    GetOutputSampleRate = RATE$
End Function

Function GetFileExt$ (FName$)
    DOT$ = "."
    L = Len(FName$)
    TMP$ = ""
    If InStr(1, FName$, DOT$) = 0 Then GoTo Skipall
    For I = L To 1 Step -1
        C$ = Mid$(FName$, I, 1)
        TMP$ = C$ + TMP$
        If C$ = DOT$ Then Exit For
    Next I
    Skipall:
    GetFileExt = TMP$
End Function

Function GetFileName$ (FName$)

    $If WINDOWS Then
        SLASH$ = "\"
    $Else
        SLASH$ = "/"
    $End If

    TMP$ = ""
    T$ = GetFileExt(FName$)
    CUT = Len(T$)
    L = Len(FName$)
    TName$ = Left$(FName$, L - CUT)
    If InStr(1, TName$, SLASH$) = 0 Then
        TMP$ = TName$
        GoTo Skiploop
    End If
    For I = Len(TName$) To 1 Step -1
        C$ = Mid$(TName$, I, 1)
        If C$ <> SLASH$ Then
            TMP$ = C$ + TMP$
        Else
            Exit For
        End If
    Next I
    Skiploop:
    GetFileName = TMP$
End Function

Function GetFilePath$ (FName$)
    t1$ = GetFileExt(FName$)
    t2$ = GetFileName(FName$)
    L = Len(FName$) - (Len(t1$) + Len(t2$))
    GetFilePath$ = Left$(FName$, L)
End Function

Function IsNum%% (PassedText As String)
    text$ = PassedText
    special$ = UCase$(Left$(text$, 2))
    Select Case special$
        Case "&H", "&B", "&O"
            'check for symbols on right side of value
            r3$ = Right$(text$, 3)
            Select Case r3$
                Case "~&&", "~%%", "~%&" 'unsigned int64, unsigned byte, unsigned offset
                    text$ = Left$(text$, Len(text$) - 3)
                Case Else
                    r2$ = Right$(text$, 2)
                    Select Case r2$
                        Case "~&", "##", "%&", "%%", "~%", "&&" 'unsigned long, float, offset, byte, unsigned integer, int64
                            text$ = Left$(text$, Len(text$) - 2)
                        Case Else
                            r$ = Right$(text$, 1)
                            Select Case r$
                                Case "&", "#", "%", "!" 'long, double, integer, single
                                    text$ = Left$(text$, Len(text$) - 1)
                            End Select
                    End Select
            End Select
            check$ = "0123456789ABCDEF"
            If special$ = "&O" Then check$ = "01234567"
            If special$ = "&B" Then check$ = "01"
            temp$ = Mid$(UCase$(text$), 2)
            For i = 1 To Len(temp$)
                If InStr(check$, Mid$(temp$, i, 1)) = 0 Then Exit For
            Next
            If i <= Len(temp$) Then IsNum = -1
        Case Else
            If _Trim$(Str$(Val(text$))) = text$ Then IsNum = -1
    End Select
End Function

