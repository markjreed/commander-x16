#CONTROLCODES 1

## CONVERT TO SIGNED RANGE
 DEF FN SW(W)=W + 65536 * (W > 32767)
## CONVERT TO UNSIGNED RANGE
 DEF FN UW(W)=W-65536*(W<0)
DEF FN Lo.Byte(X)=(FN SW(X)) AND $FF
DEF FN Hi.Byte(X)=INT(FN UW(X)/256)

GOSUB VERIFY.GOOD.LOAD
Build.Display = -1
POKE 2, 0
## Set USR to SHELLSORT.BIN
USave1 = PEEK($0311):USave2=PEEK($0312)
POKE $0311,0: POKE $0312,4
GOTO SKIPPEEKS
START.AGAIN:
 Build.Display=0
 GLASS.LOADED%=(PEEK(2)=255)
 POKE 2, 0
SKIPPEEKS:
IF Build.Display THEN GOSUB HIDETEXT

ARROWS$=CHR$($80)+CHR$($18)+CHR$($80)+CHR$($19)

#INCLUDE "BOOKS.DEF"
PCM.VOLUME = PEEK(R13H)
GOSUB GetCWD
IF CWD$="/" THEN InRootDir% = -1

  SkipArt%=PEEK(R12L)
  POKE R12L, 0
  GOSUB HOURGLASS.ON
  GOSUB LoadDCharsCP437
  DEVICE=8
  STAT.LINE=1:STAT.MSG$="** Loading Folder **":GOSUB SHOW.STATMSG
  GOSUB GetCWD
  GOSUB VMsgBox
  LOCATE 19, 6:COLOR VGA.WHITE:PRINT "Loading";
  COLOR VGA.YELLOW:PRINT ":";:COLOR VGA.LITEGREEN
  PRINT LEFT$(CWD$,18);
  IF LEN(CWD$)>18 THEN LOCATE 20,6:PRINT MID$(CWD$,19,25);
  GOSUB LOADDIR
  GOSUB CLEAR.STATMSG

IF Build.Display THEN GOSUB HIDETEXT

COLOR VGA.MEDGRAY, VGA.BLACK2
IF Build.Display THEN CH%=176:GOSUB FILL.TEXTSCREEN


IF NOT Build.Display THEN Start.Screen.Draw
  GOSUB LOAD.TITLE.SPRITES:GOSUB SHOW.SPRITE.TITLE:GOSUB BOTTOM.BOX
  BCol=15:GOSUB BOTTOM.LINE

Start.Screen.Draw:
 GOSUB SBACKGROUND:GOT.SELECTED=0
 IF NOT REDRAW THEN GOSUB DirMenu.INIT
 IF GOT.SELECTED THEN GOSUB SCREEN.ADJUST:SkipArt%=$FF
 GOSUB SHOWDIRLIST:GOSUB SHOW.ControlBar
 IF SkipArt%=$FF THEN SKIP.THE.ART
 F$="ART.BMX":GOSUB FILEEXISTS
 IF FE% THEN BMXFILE$=F$:GOSUB HOURGLASS.ON:GOSUB LOAD.SPRITE.IMAGE:GOSUB HOURGLASS.OFF
SKIP.THE.ART:
 GOSUB SHOW.CURFOLDER
 IF Build.Display THEN MOUSE 1:Mouse.Loaded=0
 GOSUB My.Mouse.Cursor
GOSUB SHOWTEXT
GOSUB SHOW.SELECTED:GOSUB HOURGLASS.OFF
REDRAW=0:Build.Display=0


HANDLEINPUT:
 GET X$
 ## MOUSE Handler
 DBL.CLICK=0:SYS $760
 Button=PEEK(A.REG):SCROLL=PEEK(X.REG):IF SCROLL > 0 THEN SCROLL=FN SIGNED.BYTE(SCROLL)
 IF SCROLL < 0 THEN X$=CHR$(145)
 IF SCROLL > 0 THEN X$=CHR$(17)
 IF Button=0  THEN SKIP.BTN.STUFF
 Mouse.X=PEEK(R14):Mouse.Y=PEEK(R15):TIMEWAIT=TI+20
WAITB:
 IF MB=1 THEN WAITB
 FOR I=0 TO -1 STEP 0
    IF MB=1 THEN DBL.CLICK=TRUE:GOTO GOT.DBLCLICK
    I=TI>TIMEWAIT
 NEXT
GOT.DBLCLICK:
 IF (Mouse.X<4) OR (Mouse.X>30) THEN SKIP.BTN.STUFF
 IF (Mouse.Y<6) OR (Mouse.Y>37) THEN SKIP.BTN.STUFF
 IF (Mouse.Y)> D.Real.End + D.Screen.Adj THEN SKIP.BTN.STUFF
 NEW.SELECTED = Mouse.Y - D.Screen.Adj
 IF (NEW.SELECTED=SELECTED) OR DBL.CLICK THEN SKIP.REFRESH
 GOSUB CLEAR.SELECTED:SELECTED=NEW.SELECTED:GOSUB SHOW.SELECTED
SKIP.REFRESH:
 IF DBL.CLICK THEN SELECTED=NEW.SELECTED:X$="{CR}":GOTO SKIP.BTN.STUFF
 GOTO HANDLEINPUT
SKIP.BTN.STUFF:
 IF X$="" THEN HANDLEINPUT
 X=ASC(X$)
 IF X=133 AND Got.Book.Mark THEN GOSUB SCRATCH.BOOKMARK:REDRAW=-1:GOSUB SHOWDIRLIST:GOSUB SHOW.SELECTED:GOTO HANDLEINPUT
 IF X=145 THEN GOSUB LIST.UP:GOTO HANDLEINPUT
 IF X=17 THEN GOSUB LIST.DOWN:GOTO HANDLEINPUT
 IF X=27 THEN CLEANUP.AND.END
 IF (X=23 AND IsBook%(SELECTED)) THEN GOSUB NUKE.THE.BOOK:REDRAW=-1:GOSUB SHOWDIRLIST:GOSUB SHOW.SELECTED:GOTO HANDLEINPUT
 IF X<>13 THEN FMDRUM 7,87:GOTO HANDLEINPUT

 IF IsBook%(SELECTED) THEN DOBOOK
 COMMAND$="CD:"+DList$(SELECTED):GOSUB DOS.CMD
 IF GLASS.LOADED% THEN POKE R0L, $FF
 POKE R12L,$FF:POKE R12H, ABS(SPRITES.POSITIONED)
 CLR
 SPRITES.POSITIONED=PEEK($1B):IF SPRITES.POSITIONED=1 THEN SPRITES.POSITIONED=-1
 GOSUB DO.DEFINES:GOSUB GET.PROGRAMROOT:GOTO START.AGAIN

CLEANUP.AND.END:
  GOSUB ASK.2.QUIT
  IF NOT USER.QUIT THEN REDRAW=-1:GOSUB SHOWDIRLIST:GOSUB SHOW.SELECTED:GOTO HANDLEINPUT
  MOUSE 0:SPRITE 0,0
  POKE $0311,USave1: POKE $0312,USave2
  GOSUB TITLE.OFF:GOSUB IMAGE.SPRITES.OFF
  COMMAND$="CD:"+MyRootDir$:GOSUB DOS.CMD
  BANK SAVEBANK:POKE $A000,0
  PF$=MyRootDir$+"/DPAL.BIN":GOSUB SETDEFAULTPALETTE
## RESTORE BREAK HANDLER
  SYS $064B
  COLOR 1,6:SCREEN 0:BANNER:PRINT:END

LIST.UP:
 IF SELECTED=0 THEN BOING.RETURN
 IF (SELECTED=1) AND InRootDir% THEN BOING.RETURN
 IF CWD$="/" AND SELECTED = 1 THEN BOING.RETURN
 GOSUB CLEAR.SELECTED
 SELECTED = SELECTED - 1:GOSUB SHOW.SELECTED
 RETURN

LIST.DOWN:
 IF SELECTED = DD THEN BOING.RETURN
 GOSUB CLEAR.SELECTED
 SELECTED = SELECTED + 1:GOSUB SHOW.SELECTED
 RETURN

DirMenu.INIT:
  GOSUB CHECK.STORED.SELECT
  C.SELECTED=SELECTED
  D.Real.Start = 0
  IF InRootDir% THEN D.Real.Start = 1
  SELECTED = D.Real.Start
  D.Screen.Adj = 6 - D.Real.Start
  D.Screen.End = 32
  D.Real.End = 32
  IF DD<32 THEN D.Real.End = DD
  RETURN

BOING.RETURN:
 FMDRUM 7,87:RETURN

SHOW.SELECTED:
  Real.Y = SELECTED+D.Screen.Adj
  IF Real.Y < 6 THEN D.Screen.Adj = D.Screen.Adj+1:D.Real.Start=D.Real.Start-1:GOSUB SHOWDIRLIST:GOTO SHOW.SELECTED
  IF Real.Y > 37 THEN D.Screen.Adj = D.Screen.Adj-1:D.Real.Start=D.Real.Start+1:GOSUB SHOWDIRLIST:GOTO SHOW.SELECTED
  COLOR VGA.YELLOW,VGA.BLACK2
  LOCATE Real.Y, 4:PRINT CHR$($E9);
  IF NOT IsBook%(SELECTED) THEN Not.Book
     GOSUB SHOW.BOOKINFO
     COLOR BLACK, BOOK.COLOR
     GOTO Is.Book
Not.Book:
    GOSUB CLEAR.BOX
    COLOR BLACK, FOLDER.COLOR
Is.Book:
  LOCATE Real.Y, 5
  PRINT DList$(SELECTED);
  IF REDRAW THEN REDRAW=0:GOTO SHOW.CURFOLDER
  IF SELECTED <> 0 AND (DList$(SELECTED) <> "/") THEN GOSUB CHECK.FOR.ART
  GOTO SHOW.CURFOLDER

SCREEN.ADJUST:
 SELECTED=C.SELECTED
ADJ.LOOP:
 Real.Y = SELECTED + D.Screen.Adj
 IF Real.Y<37 THEN RETURN
 D.Real.Start = SELECTED - 31
 D.Screen.Adj = 6 - D.Real.Start
 RETURN

CLEAR.SELECTED:
  GOSUB IMAGE.SPRITES.OFF
  GOSUB CLEAR.BookBar
  Real.Y = SELECTED+D.Screen.Adj
  COLOR VGA.YELLOW,VGA.BLACK2
  LOCATE Real.Y, 4:PRINT " ";
  COLOR FOLDER.COLOR, VGA.BLACK2
  IF IsBook%(SELECTED) THEN COLOR BOOK.COLOR, VGA.BLACK2
  LOCATE Real.Y, 5
  PRINT DList$(SELECTED);
  RETURN


SHOW.CURFOLDER:
  SLINE=STAT.LINE
  STAT.LINE=3
  tmp$=DList$(SELECTED)
  tmp2$=CWD$
  STAT.MSG$="Selected Folder: {LIGHT BLUE}"
  IF IsBook%(SELECTED) THEN STAT.MSG$="  Selected Book: {LIGHT RED}"
  IF tmp$=".." THEN tmp$=" ..":GOTO SkipSlash
  IF tmp2$<>"/" THEN tmp2$=tmp2$+"/"
  IF IsBook%(SELECTED) THEN tmp2$=DList$(SELECTED)
  STAT.MSG$=STAT.MSG$+tmp2$
SkipSlash:
  IF NOT IsBook%(SELECTED) THEN STAT.MSG$=STAT.MSG$+tmp$
  GOSUB SHOW.STATMSG
  STAT.LINE=1:STAT.MSG$=" Current Folder: {GREY 2}"+CWD$:GOSUB SHOW.STATMSG
  STAT.LINE=SLINE
RETURN


DOBOOK:
 PRG$="PLAYBOOK.PRG"
 GOTO EXECUTE.PROGRAM


    REM LOAD DISK DIRECTORY INTO BASIC VARIABLES
    REM BEFORE CALLING, SET DEVICE TO DISK DEVICE IF NOT 8
    REM ON RETURN, DD WILL BE THE NUMBER OF ENTRIES IN THE DIRECTORY
    REM DD$(0, 0) WILL BE THE VOLUME/DIRECTORY NAME
    REM DD$(I, 0) WILL BE THE FILENAME FROM ENTRY # I (1 <= I <= DD)
    REM DD$(I, 1) WILL BE THE THREE-LETTER FILE TYPE (PRG, DIR)
    REM DD%(I) WILL BE THE SIZE IN BLOCKS
    REM IF DD IS 0 ON ENTRY, THE ARRAYS WILL BE CREATED BY THE ROUTINE
    REM IF DD IS NONZERO, ARRAYS MUST ALREADY BE ALLOCATED (AND BIG ENOUGH)
    REM
LOADDIR:
     CLOSE 1
     REM DEVICE = DEVICE - (DEVICE = 0) * 8
     DEVICE=8
     IF DD THEN START.DIR.LOAD
     OPEN 1, DEVICE, 0, "$=D"
     OPEN 15, DEVICE, 15
     INPUT#15, DS, DS$, T, S
     CLOSE 15
     IF DS THEN DD = -1: RETURN
     BINPUT#1, LA$, 2: REM SKIP LOAD ADDRESS
     IF ST AND 64 THEN DS$="UNEXPECTED EOF 1": DD = -1: RETURN
     FOR I = 0 TO -1 STEP 0
       BINPUT#1, LL$, 2: REM SKIP NEXT-LINE POINTER
       IF ST AND 64 THEN DONE.COUNT
       BINPUT#1, SZ$, 2: REM SKIP SIZE
       IF ST AND 64 THEN DS$="UNEXPECTED EOF 2":DD = -1: RETURN
       LINPUT#1, LI$, 0
       DD = DD + 1
       I=( (ST AND 64)<>0 )
     NEXT
     DD=DD-1
DONE.COUNT:
     CLOSE 1
     DIM X
     DIM P
     DIM IsBook%(DD):IsBook%(0) = 0
     DIM DList$(DD-1)
     P = POINTER(DList$(0))
     UBOUND = (PEEK(POINTER(DList$(0))-2)*256 + (PEEK(POINTER(DList$(0))-1)))-1
     ## USE IF I NEED FILE SIZE DIM DD%(DD)

START.DIR.LOAD:
     OPEN 1, DEVICE, 0, "$=D"
     BINPUT#1, LA$, 2: REM SKIP LOAD ADDRESS
     IF ST AND 64 THEN D$ = "UNEXPECTED EOF 3": DD = -1: RETURN
     DD = 0
StartReadingDIR:
     FOR I = 0 TO -1 STEP 0
        BINPUT#1, LL$, 2:REM SKIP NEXT-LINE POINTER
        IF ST AND 64 THEN DONE.DIR.LOAD
        GET#1, L$:L = ASC(L$): REM LOW BYTE OF SIZE
        IF ST AND 64 THEN DS$ = "UNEXPECTED EOF 4": DD = -1: RETURN
        GET#1, H$:H = ASC(H$):REM HIGH BYTE OF SIZE
        IF ST AND 64 THEN DS$ = "UNEXPECTED EOF 5": DD = -1: RETURN
        ## USE IF I NEED FILE SIZE DD%(DD) = FN SW(256*H + L)
        LINPUT#1, X$, 34:REM SKIP TO FIRST QUOTE
        IF ST AND 64 THEN DONE.DIR.LOAD
        LINPUT#1, X$, 34
        IF X$<>"." AND X$<>".." THEN DList$(DD)=X$:GOTO CONT.D.LOAD :REM GET FILE NAME
        LINPUT#1, X$, 0
        GOTO SKIP.OVER.ENTRY
   CONT.D.LOAD:
        DIndx = DD
        IF ST AND 64 THEN DS$ = "UNEXPECTED EOF 7": DD = -1: RETURN
        LINPUT#1, X$, 0:REM GET REST OF LINE
        IF ST AND 64 THEN DS$ = "UNEXPECTED EOF 8": DD = -1: RETURN
        DD = DD + 1
  SKIP.OVER.ENTRY:
      NEXT

DONE.DIR.LOAD:
     IF DD<UBOUND THEN FOR I=DD TO UBOUND:DList$(I)=CHR$(160):NEXT
     CLOSE 1
     DD = DD - 1
     DList$(0) = ".."
     IF InRootDir% THEN DList$(0)=CHR$(160)
     IsBook%(0)=0

Sort.Directory:
 X = USR(POINTER(DList$(0)))
 FOR DIndx = 1 TO DD
    F$=DList$(DIndx)+"/"+"BOOK.DESC":GOSUB FILEEXISTS
    IsBook%(DIndx) = FE%
 NEXT
RETURN

IS.BOOK.DIR:
   F$=DList$(DIndx)+"/"+"BOOK.DESC":GOSUB FILEEXISTS
   Is.A.Book% = FE%
   RETURN

SHOWDIRLIST:
 COLOR VGA.WHITE, VGA.BLACK2
 D.Real.End = D.Real.Start + 32
 IF D.Real.End > DD THEN D.Real.End = DD
 FOR I = D.Real.Start TO D.Real.End
     LOCATE I+D.Screen.Adj, 4
     COLOR FOLDER.COLOR
     IF IsBook%(I) THEN COLOR BOOK.COLOR
     PRINT " ";LEFT$(DList$(I),27);
     L=LEN(DList$(I))
     IF L<27 THEN PRINT RPT$(32,27-L);
     PRINT " ";
 NEXT
 IF (D.Real.End-D.Real.Start) < 32 THEN FOR I = D.Real.End+1 TO 32:LOCATE I+D.Screen.Adj,4:PRINT RPT$(32,29);:NEXT
 RETURN


CHECK.FOR.ART:
 REM CLOSE ALL SYS $FF4A
 SLINE=STAT.LINE:STAT.LINE=1
 STAT.MSG$="Checking for ART":GOSUB SHOW.STATMSG
 SaveCWD$=CWD$
 COMMAND$="CD:"+DList$(SELECTED):GOSUB DOS.CMD
 F$="ART.BMX":GOSUB FILEEXISTS
 IF NOT FE% THEN ART.CHECK.DONE
    STAT.LINE=2:STAT.MSG$="** Folder Art found. **":GOSUB SHOW.STATMSG
    STAT.LINE=3:STAT.MSG$="** Loading ART **"
    BMXFILE$="ART.BMX":GOSUB HOURGLASS.ON:GOSUB LOAD.SPRITE.IMAGE:GOSUB HOURGLASS.OFF
ART.CHECK.DONE:
 COMMAND$="CD:..":GOSUB DOS.CMD
 CWD$=SaveCWD$
 FOR STAT.LINE=1 TO 3:GOSUB CLEAR.STATMSG:NEXT
 STAT.LINE=SLINE:RETURN


#INCLUDE "VCTITLE.BI"
#INCLUDE "HANDLESPRITES.BI"

SHOW.BOOKINFO:
 GOSUB LOAD.BOOKINFO
 COLOR VGA.RED,VGA.BLACK2
 GOSUB BOOK.BOX
 LOCATE 43,12
 PRINT "{GREY 1}Title: {LIGHT BLUE}";Title$
 LOCATE 45,7
 PRINT "{GREY 1}Written by: {LIGHT BLUE}";Author$;
 REM COLOR VGA.LITEGREEN
 IF YEAR$<>"" THEN PRINT "{GREY 1}  Published:{LIGHT BLUE} ";YEAR$;
 IF SUBTITLE$="" THEN DONE.BOOK.INFO
 COLOR VGA.YELLOW:LOCATE 48,7
 L=LEN(SUBTITLE$)
 PRINT LEFT$(SUBTITLE$, 69);
 IF L > 69 THEN LOCATE 49,7:PRINT LEFT$(RIGHT$(SUBTITLE$,L-69),69);
DONE.BOOK.INFO:
 IF Got.Book.Mark THEN GOSUB MarkBar:GOTO SkipClrMark
 GOSUB CLEAR.BOOKMARK.BOX
SkipClrMark:
 GOTO SHOW.BookBar



LOAD.BOOKINFO:
   Show.BookMark%=0
   SUBTITLE$="":TITLE$="":AUTHOR$="":YEAR$="":SUBTITLE$=""
   OPEN 5,DEVICE,5,DList$(SELECTED)+"/BOOK.DESC,S,R"
   INPUT# 5, TITLE$:INPUT# 5, AUTHOR$
   LINPUT# 5, TMP$:IF TMP$="ENDDESC" THEN ENDLOADBOOK
   YEAR$=TMP$
   LINPUT# 5, TMP$:IF TMP$="ENDDESC" THEN ENDLOADBOOK
   SUBTITLE$=TMP$
ENDLOADBOOK:
   CLOSE 5:NOCHAPTERS=0
   F$=DList$(SELECTED)+"/BOOK.CHAPS":GOSUB FILEEXISTS
   IF NOT FE% THEN SKIP.THE.CHAPTERS
   OPEN 5,DEVICE,5,F$+",S,R":INPUT# 5, S$:GOSUB TRIM
   IF S$="NONE" THEN NOCHAPTERS=-1:GOTO SKIP.THE.CHAPTERS
   CHAPTERS=VAL(S$):IF CHAPTERS=0 THEN CHAPTERS=-1
SKIP.THE.CHAPTERS:
   CLOSE 5:Got.Book.Mark=.
   F$=DList$(SELECTED)+"/BOOK.MARK":GOSUB FILEEXISTS
   IF NOT FE% THEN RETURN
   Got.Book.Mark=FE%

Get.Book.Mark:
   OPEN 5,DEVICE,5,F$
   INPUT# 5,S$:GOSUB TRIM
   IF S$="SINGLE" THEN CHAPTER.NUMBER=-1:GOTO SKIPCVAL
   IF S$="INTRO" THEN CHAPTER.NUMBER=-2:GOTO SKIPCVAL
   IF S$="EPILOGUE" THEN CHAPTER.NUMBER=-3:GOTO SKIPCVAL
   CHAPTER.NUMBER = VAL(S$)
SKIPCVAL:
   INPUT# 5, S$:GOSUB TRIM:CLOSE 5
   SEEKTIMER=VAL(S$)
   B.Seconds=INT(SEEKTIMER/60)
   B.Mins = INT(B.Seconds/60)
   B.Seconds = B.Seconds - (B.Mins*60)
   B.Hours = INT(B.Mins/60)
   B.Mins = B.Mins - (B.Hours*60)
   RETURN

MarkBar:
   COLOR VGA.WHITE,VGA.BLACK2
   X = 36:Y=2:W=34:H=4:GOSUB TEXTBOX
   LOCATE 3,37:PRINT "{LIGHT BLUE}Book Mark: ";
   IF CHAPTER.NUMBER > 0 THEN PRINT "{GREY 1}CHAP:{GREY 2}";CHAPTER.NUMBER;:GOTO PRINT.THE.MARKER
   IF CHAPTER.NUMBER = -1 THEN PRINT "{GREY 1} Main Book{GREY 2}";:GOTO PRINT.THE.MARKER
   IF CHAPTER.NUMBER = -2 THEN PRINT "{GREY 1} Book Intro{GREY 2}";:GOTO PRINT.THE.MARKER
   IF CHAPTER.NUMBER = -3 THEN PRINT "{GREY 1} Epilogue{GREY 2}";:GOTO PRINT.THE.MARKER
PRINT.THE.MARKER:
   LOCATE 4,37
   Sec$="Seconds"
   Min$="Minutes"
   Hr$="Hour ":IF B.Hours > 1 THEN Hr$="Hours "
   IF B.Hours > 0 THEN PRINT "{GREY 2}";B.Hours;"{GREY 1}";Hr$;
   IF B.Mins=1 THEN Min$=LEFT$(Min$,LEN(Min$)-1)
   IF B.Seconds=1 THEN Sec$=LEFT$(Sec$,LEN(Sec$)-1)
   PRINT "{GREY 2}";B.Mins;"{GREY 1}";Min$;"{GREY 2}";B.Seconds;"{GREY 1}";Sec$;
   RETURN


SHOW.BookBar:
 COLOR VGA.LITERED,VGA.BLACK2
 IF NOT Got.Book.Mark THEN Skip.BookMark.Show
 LOCATE 60,2
 PRINT "{GREY 1}[{LIGHT RED}F1{GREY 1}] - {GREY 2}Delete Book Mark";
Skip.BookMark.Show:
 LOCATE 59,57
 PRINT "{GREY 2}BOOK     ";
 LOCATE 60,33
 PRINT "{GREY 1}[{LIGHT RED}F12{GREY 1}] - **{LIGHT BLUE} DELETE BOOK{GREY 1} **";
 RETURN

CLEAR.BookBar:
 GOSUB REFRESH.ControlBar
 LOCATE 60,1:PRINT RPT$(32,79);
 RETURN

SHOW.ControlBar:
 COLOR VGA.WHITE,VGA.BLACK2
 LOCATE 59,67
 PRINT "[{LIGHT RED}ESC{GREY 1}] -{GREY 2} Exit";
 LOCATE 59,2
 PRINT "{GREY 1}[{LIGHT RED}";ARROWS$;"{GREY 1}] -{GREY 2} Folder Navigation";

REFRESH.ControlBar:
  COLOR VGA.WHITE,VGA.BLACK2
  LOCATE 59,31:PRINT "[{LIGHT RED}ENTER{GREY 1}] -{GREY 2} Choose ";CHR$(1);"SELECTED";CHR$(1);" Folder";
 RETURN

SBACKGROUND:
  STAT.MSG$=RPT$(177,44):COLOR VGA.WHITE,VGA.BLACK2
  FOR Y = 7 TO 37:LOCATE Y, 35:PRINT STAT.MSG$;:NEXT
  RETURN



BOTTOM.LINE:
 POKE VERA.LOWADDR, 1
 POKE VERA.MIDADDR, $EA
 REM POKE VERA.MIDADDR, $3B
 POKE VERA.HIGHADDR, %00100001
 POKE A.REG, $50 OR BCOL
 POKE R0L, $23
 POKE R0H, $9F
 POKE R1L, 0
 POKE R1H, 1
 SYS MEM.FILL
 POKE VERA.LOWADDR, 0
 POKE VERA.MIDADDR, $EA
 REM POKE VERA.MIDADDR, $3B
 POKE VERA.HIGHADDR, %00100001
 POKE A.REG, 32
 POKE R0L, $23
 POKE R0H, $9F
 POKE R1L, 0
 POKE R1H, 1
 SYS MEM.FILL
 RETURN

SCRATCH.BOOKMARK:
  GOSUB ASK.2.DELETE.BOOKMARK
  IF NOT YES% THEN RETURN
  COMMAND$="S:"+DList$(SELECTED)+"/BOOK.MARK"
  GOSUB DOS.CMD
  COLOR VGA.GREEN,VGA.BLACK2
  STAT.MSG$ = "{RED}BOOK Mark {LIGHT RED}Deleted."
  LOCATE 19,7:PRINT STAT.MSG$;
  LOCATE 20,7:PRINT RPT$(32,25);
  LOCATE 21,7:PRINT RPT$(32,25);
  LOCATE 22,7:PRINT "ANY KEY TO CONTINUE.";
  GOTO GET.AnyKey

NUKE.THE.BOOK:
 GOSUB ASK.2.NUKE
 IF YES% THEN PRG$="NUKEBOOK.PRG":GOTO EXECUTE.PROGRAM
 RETURN

ASK.2.NUKE:
  GOSUB VMsgBox
  LOCATE 19,7:PRINT "{RED}REMOVE SELECTED BOOK {LIGHT BLUE}?"
  LOCATE 20,7:PRINT "{LIGHT RED}";LEFT$(DList$(SELECTED),25);
  GOSUB GET.Yes.No
  RETURN

ASK.2.DELETE.BOOKMARK:
  GOSUB VMsgBox
  LOCATE 19,7:PRINT "{RED}REMOVE BOOK MARK"
  LOCATE 20,7:PRINT "{RED}For: {LIGHT RED}";LEFT$(DList$(SELECTED),22);
  GOTO GET.Yes.No

ASK.2.QUIT:
 USER.QUIT=0:GOSUB VMsgBox
 LOCATE 20,7:PRINT "{RED}QUIT ";
 PRINT "{LIGHT RED}Volume Control ";
 GOSUB GET.Yes.No:DO.QUIT=YES%
 USER.QUIT=DO.QUIT
 RETURN

VMsgBox:
 GOSUB SaveCursor.AndColor
 COLOR VGA.RED, VGA.BLACK2
 X=4:Y=17:H=8:W=29:GOTO TEXTBOX

GET.Yes.No:
 LOCATE 22, 9
 COLOR VGA.MEDGRAY
 PRINT "({LIGHT BLUE}Y{LIGHT RED}/{LIGHT BLUE}N{YEL})";
 GOTIT = FALSE
 COLOR VGA.WHITE, VGA.DARKGRAY
 LOCATE 22, 14:PRINT "{LIGHT BLUE} ";
GETIT:
 GET X$:IF X$="" THEN GETIT
 IF X$="{ESC}" THEN GOTIT=TRUE:Q$="N":X$="{CR}"
 IF X$="y" THEN X$="Y"
 IF X$="n" THEN X$="N"
 IF X$<>"Y" AND X$<>"N" AND X$<>"{CR}" THEN FMDRUM 7,87
 IF X$="Y" OR X$="N" THEN GOTIT = TRUE:Q$=X$:LOCATE 22,14:PRINT X$;
 IF X$<>"{CR}" OR NOT (GOTIT) THEN GETIT
 YES% = (Q$="Y")
 RETURN

BOOK.BOX:
 X=5:Y=41:W=72:H=10:GOSUB TEXTBOX
 RETURN

CLEAR.BOX:
  COLOR VGA.MEDGRAY, VGA.BLACK2:I=PEEK(COLOR.BYTE)
  POKE VERA.LOWADDR, 0:POKE VERA.MIDADDR, $D8
  POKE VERA.HIGHADDR, %00100001:POKE A.REG, 176:POKE R0L,$23:POKE R0H,$9F
  POKE R1L, 0:POKE R1H, $05:SYS MEM.FILL
  POKE VERA.LOWADDR,1:POKE VERA.MIDADDR,$D8
  POKE VERA.HIGHADDR,%00100001:POKE A.REG,I:POKE R0L,$23:POKE R0H,$9F:POKE R1L,0
  POKE R1H, $05:SYS MEM.FILL
CLEAR.BOOKMARK.BOX:
  COLOR VGA.MEDGRAY, VGA.BLACK2
  FOR Y = 2 TO 5:LOCATE Y,36:PRINT RPT$(176,36);:NEXT
 RETURN

BOTTOM.BOX:
  COLOR VGA.ORANGE, BLACK
  LOCATE 53,2:PRINT CHR$(219);
  FOR Y = 54 TO 56:LOCATE Y,79:PRINT CHR$(222);:LOCATE Y,2:PRINT CHR$(221);:NEXT
  LOCATE 57,2:PRINT CHR$(219);
  LOCATE 53,79:PRINT CHR$(219);
  LOCATE 57,79:PRINT CHR$(219);
  LOCATE 53,3:PRINT RPT$(223,76);
  LOCATE 57,3:PRINT RPT$(220,76);
  FOR I=54 TO 56:LOCATE I,3:PRINT RPT$(32,76);:NEXT
RETURN

SHOW.STATMSG:
  GOSUB CLEAR.STATMSG
  COLOR VGA.WHITE, BLACK
  LOCATE 53+STAT.LINE,4
  PRINT STAT.MSG$;"                 "
GOTO RestoreCursor.AndColor

CLEAR.STATMSG:
  GOSUB SaveCursor.AndColor
  COLOR VGA.WHITE,BLACK
  LOCATE 53+STAT.LINE, 4
  PRINT RPT$(32,70);
GOTO RestoreCursor.AndColor

EXECUTE.PROGRAM:
  GOSUB STORE.SELECTED
  POKE $0311,USave1: POKE $0312,USave2
  TargetDir$=DList$(SELECTED)
  GOSUB STORE.TARGETDIR
  GOSUB IMAGE.SPRITES.OFF
  GOSUB TITLE.OFF
  COLOR VGA.WHITE, BLACK:CLS
  POKE R13H, PCM.VOLUME
LOAD MyRootDir$+"/"+PRG$

STORE.SELECTED:
   BANK SAVEBANK:SAddr=$A500
   S$="SELECTED":GOSUB POKE.STRING
   S.Select%=SELECTED
   POKE $A400, PEEK(POINTER(S.Select%)):POKE $A401, PEEK(POINTER(S.Select%)+1)
RETURN

CHECK.STORED.SELECT:
   BANK SAVEBANK
   SAddr = $A500:GOSUB PEEK.STRING
   GOT.SELECTED = (S$="SELECTED")
   IF NOT GOT.SELECTED THEN SELECTED=0:RETURN
   POKE $A500, 0:POKE $A501, 0
   S.Select%=0:POKE POINTER(S.Select%), PEEK($A400)
   POKE POINTER(S.Select%)+1, PEEK($A401)
   SELECTED = S.Select%
RETURN
#INCLUDE "BOOKS.BI"
