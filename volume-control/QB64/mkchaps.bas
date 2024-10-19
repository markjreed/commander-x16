$Console
$ScreenHide
_Source _Console
_Dest _Console

ChDir _StartDir$
Input "How many chapter Directorys "; NumDirs
Print

For I = 1 To NumDirs
    Suffix$ = Str$(I)
    L = Len(Suffix$)
    Suffix$ = Right$(Suffix$, L - 1)
    dName$ = "CHAP" + Suffix$
    Print "Making: "; dName$
    MkDir dName$
Next

Print: Print

System




