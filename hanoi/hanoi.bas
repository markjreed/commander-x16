100 REM TOWERS OF HANOI IN BASIC
110 ND =  8: REM NUMBER OF DISCS (MAXIMUM 8 FOR THIS SOLUTION)
120 BG = 15: REM BACKGROUND COLOR
130 TK = 11: REM "BLACK" FOR TEXT (REALLY DARK GREY, SINCE COLOR 0 = TRANSPARENT)
140 PC = 70: REM PEG COLOR
150 REM
150 REM THE PEGS ARE LABELED A,B,C, NORMALLY IN PLAIN TEXT. BUT
160 REM WHEN THE DISCS ARE FULLY STACKED ON A PEG, ITS LABEL LIGHTS UP
170 REM WHITE ON GREEN. THE LABEL OF A PEG WITH THE BOTTOM OF AN INCOMPLETE STACK
180 REM LIGHTS UP WHITE ON ORANGE (WHITE ON YELLOW WASN"T LEGIBLE). AND THE LABEL
190 REM OF THE PEG CHOSEN AS THE TARGET OF THE CURRENT CYCLE LIGHTS UP WHITE ON
200 REM RED (UNTIL IT HOLDS THE BOTTOM DISC AND SWITCHES TO ORANGE).
210 FC =  5: REM GREEN BACKGROUND FOR FULL STACK
220 IC =  8: REM ORANGE BACKGROUND FOR INCOMPLETE STACK
230 TC =  2: REM RED BACKGROUND FOR TARGET PEG
240 REM
240 REM WHEN A DISC IS MOVED INTO ITS PROPER PLACE (HEIGHT), A TONE PLAYS,
250 REM IN AN ASCENDING MAJOR SCALE COVERING AN OCTAVE FROM THE LARGEST TO
260 REM THE SMALLEST DISC. THE N$ ARRAY HOLDS THE FMPLAY STRINGS FOR EACH NOTE,
270 REM DESCENDING SINCE THE DISCS ARE NUMBERED IN ASCENDING SIZE ORDER.
280 DIM N$(7)
290 FOR I = 0 TO 7: READ N$(I): NEXT I
300 DATA O5C, O4B, O4A, O4G, O4F, O4E, O4D, O4C
310 REM
310 REM THE P ARRAY HOLDS THE LOCATIONS OF THE DISCS. P(N,0) IS THE HEIGHT
320 REM OF THE STACK ON PEG N (0-2); P(N,1) IS THE NUMBER OF THE BOTTOMMOST
330 REM DISC, P(N,2) THE SECOND DISC, AND SO ON UP TO P(N,P(N,0)).
340 DIM P(2, ND)
350 REM
360 REM WE START WITH ALL THE DISCS ON PEG A (0), PROPERLY STACKED
370 P(0, 0) = ND : FOR I = 1 TO ND: P(0, I) = ND - I : NEXT
380 REM
390 REM THE SUBROUTINE THAT COMPUTES THE SEQUENCE OF MOVES IS RECURSIVE.
400 REM SINCE BASIC ONLY HAS GLOBAL VARIABLES, EACH OF THE VARIABLES THAT
410 REM WOULD NORMALLY BE LOCAL TO THAT ROUTINE, INCLUDING ITS PARAMETERS,
420 REM IS REPRESENTED BY A GLOBAL ARRAY. THE CURRENT SET OF VALUES FOR A
430 REM GIVEN ACTIVATION OF THE ROUTINE IS INDICATED BY A SINGLE GLOBAL
440 REM STACK POINTER, SP. SP HOLDS THE INDEX WHERE THE NEXT SET OF VALUES
450 REM WILL GO - THE CURRENT SET IS ALWAYS AT SP-1 - SO IT STARTS AT 0.
450 SP = 0
450 REM TO SOLVE THE PROBLEM FOR N DISCS, WE NEED N LEVELS OF STACK.
460 DIM N(ND) : REM THE NUMBER OF DISCS TO MOVE AT THIS STEP
470 DIM F(ND) : REM THE PEG TO MOVE THE DISCS FROM
480 DIM T(ND) : REM THE PEG TO MOVE THE DISCS TO
490 DIM V(ND) : REM THE THIRD "VIA" PEG, WHICH IS COMPUTED AND CACHED HERE.
500 REM
390 REM THE FOREGOING SETUP ALL HAPPENS FAST ENOUGH THAT WE DIDN'T NEED
400 REM A LOADING SCREEN OR ANYTHING, BUT READING THE SPRITE DATA INTO
410 REM VIDEO RAM TAKES A WHILE. SO THE NEXT STEP IS TO SET UP THE SCREEN AND
420 REM PREPARE A SIMPLE PSEUDO-ANIMATION AS A PROGRESS INDICATOR.
430 SCREEN 128: RECT 0, 0, 319, 239, BG: REM CLEAR THE SCREEN
440 COLOR BG, 0: CLS: REM SET TEXT COLOR TO MATCH THE BACKGROUND
450 FOR I = 1 to 16: REM DRAW A BLOCK OF INVERSE SPACES TO COVER THE BITMAP
460   LOCATE  9 + I, 4
470   PRINT CHR$(18);RPT$(32, 33)
480 NEXT I
490 REM
500 REM NOW WE CAN DRAW THE PEGS INVISIBLY. LET'S SET UP SOME COORDINATES
510 BX = 60  : REM BASE X: THE X-COORDINATE OF THE CENTER OF PEG 0
520 DEF FN PX(P) = BX + P * 96 : REM X-COORDINATE OF THE CENTER OF PEG P
523 DEF FN LC(P) =  8 + P * 12 : REM TEXT COLUMN FOR PEG P'S LABEL
527 LR = 22: REM TEXT ROW FOR PEG LABELS
530 BY = 162 : REM BASE Y: THE Y-COORDINATE OF BOTTOMS OF THE PEGS
540 Y0 = BY - 72 : REM Y-COORDINATE OF THE TOPS OF THE PEGS
550 Y1 = BY +  1 : REM Y-COORDINATE OF THE TOPS OF THE PEGS' BASES
560 Y2 = BY + 15 : REM Y-COORDINATE OF THE BOTTOMS OF THE PEGS' BASES
570 REM
580 REM NOW DRAW AND LABEL THE PEGS
590 COLOR TK, 0
600 FOR P=0 TO 2
610 :  CX = FN PX(P): REM CENTER LINE
620 :  X0 = CX - 33 : REM LEFT EDGE OF BASE
630 :  X1 = CX -  2 : REM LEFT EDGE OF PEG
640 :  X2 = X1 +  4 : REM RIGHT EDGE OF PEG
650 :  X3 = X0 + 66 : REM RIGHT EDGE OF BASE
660 :  FRAME X0, Y1, X3, Y2, 0 : REM BLACK OUTLINE FOR BASE
670 :  RECT X0 + 1, Y1 + 1, X3 - 1, Y2 - 1, PC: REM BASE RECTANGLE
680 :  FRAME X1, Y0, X2, Y1, 0 : REM BLACK OUTLINE FOR PEG
690 :  RECT  CX - 1, Y0 + 1, CX, BY, PC : REM PEG RECTANGLE
700 :  LOCATE LR, FN LC(P)
710 :  PRINT CHR$(65 + P)
720 NEXT P
730 REM
740 REM NOW WE CAN GO LOAD IN THE SPRITE DATA, SCROLLING THE INVERSE-VIDEO
750 REM BLOCK UP TWO LINES PER SPRITE TO REVEAL THE PEGS AS WE GO
760 GOSUB 1000
320 AP = 0: GOSUB 900 :  REM DISPLAY STATE
330 DIM N(8), F(8), T(8), V(8) : REM VARS FOR RECURSIVE SOLUTION
340 N(0) = ND
350 REM LOOP OVER MOVING DISCS TO THE NEXT PEG
360 FOR E=0 TO 1 STEP 0
370 : FOR P=0 TO 1
380 :   F = P : T = F + 1: GOSUB 460
385 :   FMDRUM 1, 33
387 :   LOCATE 22, 8 + 12 * T: COLOR 1, FC: PRINT CHR$(65 + T)
390 : NEXT P
400 : FOR P=2 TO 1 STEP -1
410 :   F = P : T = F - 1: GOSUB 460
415 :   FMDRUM 1, 33
417 :   LOCATE 22, 8 + 12 * T: COLOR 1, FC: PRINT CHR$(65 + T)
420 : NEXT P
430 : GET K$: IF K$ <> "" THEN E = 1
440 NEXT E
450 END
460 FOR Q = 0 TO 10000 : NEXT Q
470 TP = T: LOCATE 22, 8 + 12 * T: COLOR 1, TC: PRINT CHR$(65 + T)
520 F(0) = F : T(0) = T : SP = 1 : GOSUB 550
530 RETURN
540 REM RECURSIVE SOLUTION FOR HANOI
550 IF N(SP - 1) = 0 THEN RETURN
560 V(SP - 1) = 3 - F(SP - 1) - T(SP - 1) : REM VIA PEG
570 N(SP) = N(SP - 1) - 1 : F(SP) = F(SP - 1) : T(SP) = V(SP - 1)
580 SP = SP + 1 : GOSUB 550 : SP = SP - 1
590 F = F(SP - 1) : T = T(SP - 1) : GOSUB 700 : REM MOVE ONE DISK
600 N(SP) = N(SP - 1) - 1 : F(SP) = V(SP - 1) : T(SP) = T(SP - 1)
610 SP = SP + 1 : GOSUB 550 : SP = SP - 1
620 RETURN
700 REM MOVE ONE DISK FROM F TO T
710 H1 = P(F, 0) : REM STARTING HEIGHT
720 D = P(F, H1) : REM WHICH DISK TO MOVE
730 H2 = P(T, 0) : REM TARGET HEIGHT BEFORE MOVE
740 H2 = H2 + 1 : P(T, H2) = D : P(T, 0)=H2 : P(F, 0) = H1 - 1 : REM MOVE DISK
750 REM NOW ANIMATE THE MOVE
755 IF F = AP THEN LOCATE 22, 8 + 12 * F: COLOR 1, IC: PRINT CHR$(65 + AP)
760 X1 = BX + F * 96 - 32 - (D < 2) * 16 : REM OLD X
770 X2 = BX + T * 96 - 32 - (D < 2) * 16 : REM NEW X
780 Y0 = BY + 1 - H1 * 8 : REM STARTING Y
790 Y1 = BY + 1 - 16 * 8 : REM Y USED FOR HORIZONTAL MOVE
800 Y2 = BY + 1 - H2 * 8 : REM ENDING Y
805 SPRITE D+1,3,1
807 IF H1=1 AND F<>TP THEN LOCATE 22, 8+12*F : COLOR TK, 0: PRINT CHR$(65 + F)
810 FOR Y = Y0 TO Y1 STEP  -1 :  MOVSPR D+1, X1, Y : NEXT Y : REM LIFT
820 FOR X = X1 TO X2 STEP T-F :  MOVSPR D+1, X, Y : NEXT X
830 FOR TT = 0 TO Y2 - Y1 : REM DROP
840 : Y = Y1 + TT * TT : IF Y>= Y2 THEN Y = Y2 : TT = Y2 - Y1
850 : MOVSPR D+1, X2, Y : FOR Q =0 TO 9 : NEXT Q
860 NEXT TT
861 FMDRUM 1, 26 - 10 * (H2 = 1):IF H2 <> ND-D THEN SPRITE D+1,3,1:GOTO 870
863 IF AP <> T THEN LOCATE 22, 8 + 12 * AP: COLOR TK, 0: PRINT CHR$(65 + AP)
865 AP = T: LOCATE 22, 8 + 12 * AP: COLOR 1, IC: PRINT CHR$(65 + AP)
867 O=4-(D=0):SPRITE D+1,3,0:FMPLAY 0,"O"+MID$(STR$(O),2)+N$(D)
870 RETURN
900 FOR I=0 TO 2
905 : LOCATE 22, 8 + 12 * I: COLOR TK, 0 : IF I=AP THEN COLOR 1, FC
907 : PRINT CHR$(65 + I)
910 : IF P(I, 0) = 0 THEN 980
920 : FOR J = 1 TO P(I, 0)
930 :   D = P(I, J)
940 :   X = BX + I * 96 - 32 - (D < 2) * 16
950 :   Y = BY + 1 - J * 8
960 :   MOVSPR D+1, X, Y : SPRITE D+1, 3
970 : NEXT J
980 NEXT I
990 RETURN
999 REM LOAD SPRITE DATA
1000 A = $3100:REM START OUR DATA HERE (MOUSE POINTER USES $3000-$30FF)
1010 LOCATE 30
1020 FOR I=1 TO 8
1030 : SPRMEM I, 1, A, 0
1040 : READ W, H, D: REM WIDTH 0-3, HEIGHT 0-3, DEPTH 0-1
1050 : FOR J=1 TO 2
1060 :   FOR K=1 TO 2^(H+2)
1070 :     FOR L=1 TO 2^(W+DEPTH+2)
1080 :       READ B
1090 :       VPOKE 1, A, B
1100 :       A = A + 1
1110 :     NEXT L
1120 :   NEXT K
1130 :   PRINT
1140 : NEXT J
1150 : SPRITE I, 0, 0, 0, W, H, D
1160 NEXT I
1170 RETURN
1180 DATA 2, 0, 0:REM SPRITE 1 - 32x8x4
1190 DATA   0,  0,  0,  0,  0,  0,187,187,187,187,  0,  0,  0,  0,  0,  0
1200 DATA   0,  0,  0,  0,187,187,187, 17, 17,187,187,187,  0,  0,  0,  0
1210 DATA   0,  0,  0,187,187, 17, 17, 17, 17, 17, 17,187,187,  0,  0,  0
1220 DATA   0,  0, 11,177, 17, 17, 17, 17, 17, 17, 17, 17, 27,176,  0,  0
1230 DATA   0,  0, 11,177, 17, 17, 17, 17, 17, 17, 17, 17, 27,176,  0,  0
1240 DATA   0,  0,  0,187,187, 17, 17, 17, 17, 17, 17,187,187,  0,  0,  0
1250 DATA   0,  0,  0,  0,187,187,187, 17, 17,187,187,187,  0,  0,  0,  0
1260 DATA   0,  0,  0,  0,  0,  0,187,187,187,187,  0,  0,  0,  0,  0,  0
1270 DATA 2, 0, 0:REM SPRITE 2, 32x8x4
1280 DATA   0,  0,  0,  0, 11,187,187,187,187,187,187,176,  0,  0,  0,  0
1290 DATA   0,  0, 11,187,187,178, 34, 34, 34, 34, 43,187,187,176,  0,  0
1300 DATA   0, 11,187,178, 34, 34, 34, 34, 34, 34, 34, 34, 43,187,176,  0
1310 DATA   0,187, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34,187,  0
1320 DATA   0,187, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34, 34,187,  0
1330 DATA   0, 11,187,178, 34, 34, 34, 34, 34, 34, 34, 34, 43,187,176,  0
1340 DATA   0,  0, 11,187,187,178, 34, 34, 34, 34, 43,187,187,176,  0,  0
1350 DATA   0,  0,  0,  0, 11,187,187,187,187,187,187,176,  0,  0,  0,  0
1360 DATA 3, 0, 0:REM SPRITE 3, 64x8x4
1370 DATA   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,187,187,187,187,187
1380 DATA 187,187,187,187,187,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
1410 DATA   0,  0,  0,  0,  0,  0,  0,  0,  0,187,187,187, 51, 51, 51, 51
1420 DATA  51, 51, 51, 51,187,187,187,  0,  0,  0,  0,  0,  0,  0,  0,  0
1430 DATA   0,  0,  0,  0,  0,  0,  0,  0,187,187, 51, 51, 51, 51, 51, 51
1440 DATA  51, 51, 51, 51, 51, 51,187,187,  0,  0,  0,  0,  0,  0,  0,  0
1450 DATA   0,  0,  0,  0,  0,  0,  0, 11,179, 51, 51, 51, 51, 51, 51, 51
1460 DATA  51, 51, 51, 51, 51, 51, 51, 59,176,  0,  0,  0,  0,  0,  0,  0
1470 DATA   0,  0,  0,  0,  0,  0,  0, 11,179, 51, 51, 51, 51, 51, 51, 51
1480 DATA  51, 51, 51, 51, 51, 51, 51, 59,176,  0,  0,  0,  0,  0,  0,  0
1490 DATA   0,  0,  0,  0,  0,  0,  0,  0,187,187, 51, 51, 51, 51, 51, 51
1500 DATA  51, 51, 51, 51, 51, 51,187,187,  0,  0,  0,  0,  0,  0,  0,  0
1510 DATA   0,  0,  0,  0,  0,  0,  0,  0,  0,187,187,187, 51, 51, 51, 51
1520 DATA  51, 51, 51, 51,187,187,187,  0,  0,  0,  0,  0,  0,  0,  0,  0
1530 DATA   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,187,187,187,187,187
1540 DATA 187,187,187,187,187,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
1550 DATA 3, 0, 0:REM SPRITE 4, 64x8x4
1560 DATA   0,  0,  0,  0,  0,  0,  0,  0,  0, 11,187,187,187,187,187,187
1570 DATA 187,187,187,187,187,187,176,  0,  0,  0,  0,  0,  0,  0,  0,  0
1580 DATA   0,  0,  0,  0,  0,  0,  0, 11,187,187,180, 68, 68, 68, 68, 68
1590 DATA  68, 68, 68, 68, 68, 75,187,187,176,  0,  0,  0,  0,  0,  0,  0
1600 DATA   0,  0,  0,  0,  0,  0, 11,187,180, 68, 68, 68, 68, 68, 68, 68
1610 DATA  68, 68, 68, 68, 68, 68, 68, 75,187,176,  0,  0,  0,  0,  0,  0
1620 DATA   0,  0,  0,  0,  0,  0,187, 68, 68, 68, 68, 68, 68, 68, 68, 68
1630 DATA  68, 68, 68, 68, 68, 68, 68, 68, 68,187,  0,  0,  0,  0,  0,  0
1640 DATA   0,  0,  0,  0,  0,  0,187, 68, 68, 68, 68, 68, 68, 68, 68, 68
1650 DATA  68, 68, 68, 68, 68, 68, 68, 68, 68,187,  0,  0,  0,  0,  0,  0
1660 DATA   0,  0,  0,  0,  0,  0, 11,187,180, 68, 68, 68, 68, 68, 68, 68
1670 DATA  68, 68, 68, 68, 68, 68, 68, 75,187,176,  0,  0,  0,  0,  0,  0
1680 DATA   0,  0,  0,  0,  0,  0,  0, 11,187,187,180, 68, 68, 68, 68, 68
1690 DATA  68, 68, 68, 68, 68, 75,187,187,176,  0,  0,  0,  0,  0,  0,  0
1700 DATA   0,  0,  0,  0,  0,  0,  0,  0,  0, 11,187,187,187,187,187,187
1710 DATA 187,187,187,187,187,187,176,  0,  0,  0,  0,  0,  0,  0,  0,  0
1720 DATA 3, 0, 0:REM SPRITE 5, 64x8x4
1730 DATA   0,  0,  0,  0,  0,  0,  0,  0,187,187,187,187,187,187,187,187
1740 DATA 187,187,187,187,187,187,187,187,  0,  0,  0,  0,  0,  0,  0,  0
1750 DATA   0,  0,  0,  0,  0,  0,187,187,187, 85, 85, 85, 85, 85, 85, 85
1760 DATA  85, 85, 85, 85, 85, 85, 85,187,187,187,  0,  0,  0,  0,  0,  0
1770 DATA   0,  0,  0,  0,  0,187,187, 85, 85, 85, 85, 85, 85, 85, 85, 85
1780 DATA  85, 85, 85, 85, 85, 85, 85, 85, 85,187,187,  0,  0,  0,  0,  0
1790 DATA   0,  0,  0,  0, 11,181, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85
1800 DATA  85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 91,176,  0,  0,  0,  0
1810 DATA   0,  0,  0,  0, 11,181, 85, 85, 85, 85, 85, 85, 85, 85, 85, 85
1820 DATA  85, 85, 85, 85, 85, 85, 85, 85, 85, 85, 91,176,  0,  0,  0,  0
1830 DATA   0,  0,  0,  0,  0,187,187, 85, 85, 85, 85, 85, 85, 85, 85, 85
1840 DATA  85, 85, 85, 85, 85, 85, 85, 85, 85,187,187,  0,  0,  0,  0,  0
1850 DATA   0,  0,  0,  0,  0,  0,187,187,187, 85, 85, 85, 85, 85, 85, 85
1860 DATA  85, 85, 85, 85, 85, 85, 85,187,187,187,  0,  0,  0,  0,  0,  0
1870 DATA   0,  0,  0,  0,  0,  0,  0,  0,187,187,187,187,187,187,187,187
1880 DATA 187,187,187,187,187,187,187,187,  0,  0,  0,  0,  0,  0,  0,  0
1890 DATA 3, 0, 0:REM SPRITE 6, 64x8x4
1900 DATA   0,  0,  0,  0,  0,  0, 11,187,187,187,187,187,187,187,187,187
1910 DATA 187,187,187,187,187,187,187,187,187,176,  0,  0,  0,  0,  0,  0
1920 DATA   0,  0,  0,  0, 11,187,187,182,102,102,102,102,102,102,102,102
1930 DATA 102,102,102,102,102,102,102,102,107,187,187,176,  0,  0,  0,  0
1940 DATA   0,  0,  0, 11,187,182,102,102,102,102,102,102,102,102,102,102
1950 DATA 102,102,102,102,102,102,102,102,102,102,107,187,176,  0,  0,  0
1960 DATA   0,  0,  0,187,102,102,102,102,102,102,102,102,102,102,102,102
1970 DATA 102,102,102,102,102,102,102,102,102,102,102,102,187,  0,  0,  0
1980 DATA   0,  0,  0,187,102,102,102,102,102,102,102,102,102,102,102,102
1990 DATA 102,102,102,102,102,102,102,102,102,102,102,102,187,  0,  0,  0
2000 DATA   0,  0,  0, 11,187,182,102,102,102,102,102,102,102,102,102,102
2010 DATA 102,102,102,102,102,102,102,102,102,102,107,187,176,  0,  0,  0
2020 DATA   0,  0,  0,  0, 11,187,187,182,102,102,102,102,102,102,102,102
2030 DATA 102,102,102,102,102,102,102,102,107,187,187,176,  0,  0,  0,  0
2040 DATA   0,  0,  0,  0,  0,  0, 11,187,187,187,187,187,187,187,187,187
2050 DATA 187,187,187,187,187,187,187,187,187,176,  0,  0,  0,  0,  0,  0
2060 DATA 3, 0, 0:REM SPRITE 7, 64x8x4
2070 DATA   0,  0,  0,  0,  0,187,187,187,187,187,187,187,187,187,187,187
2080 DATA 187,187,187,187,187,187,187,187,187,187,187,  0,  0,  0,  0,  0
2090 DATA   0,  0,  0,187,187,187,119,119,119,119,119,119,119,119,119,119
2100 DATA 119,119,119,119,119,119,119,119,119,119,187,187,187,  0,  0,  0
2110 DATA   0,  0,187,187,119,119,119,119,119,119,119,119,119,119,119,119
2120 DATA 119,119,119,119,119,119,119,119,119,119,119,119,187,187,  0,  0
2130 DATA   0, 11,183,119,119,119,119,119,119,119,119,119,119,119,119,119
2140 DATA 119,119,119,119,119,119,119,119,119,119,119,119,119,123,176,  0
2150 DATA   0, 11,183,119,119,119,119,119,119,119,119,119,119,119,119,119
2160 DATA 119,119,119,119,119,119,119,119,119,119,119,119,119,123,176,  0
2170 DATA   0,  0,187,187,119,119,119,119,119,119,119,119,119,119,119,119
2180 DATA 119,119,119,119,119,119,119,119,119,119,119,119,187,187,  0,  0
2190 DATA   0,  0,  0,187,187,187,119,119,119,119,119,119,119,119,119,119
2200 DATA 119,119,119,119,119,119,119,119,119,119,187,187,187,  0,  0,  0
2210 DATA   0,  0,  0,  0,  0,187,187,187,187,187,187,187,187,187,187,187
2220 DATA 187,187,187,187,187,187,187,187,187,187,187,  0,  0,  0,  0,  0
2330 DATA 3, 0, 0:REM SPRITE 8, 64x8x4
2340 DATA   0,  0,  0, 11,187,187,187,187,187,187,187,187,187,187,187,187
2350 DATA 187,187,187,187,187,187,187,187,187,187,187,187,176,  0,  0,  0
2360 DATA   0, 11,187,187,184,136,136,136,136,136,136,136,136,136,136,136
2370 DATA 136,136,136,136,136,136,136,136,136,136,136,139,187,187,176,  0
2380 DATA  11,187,184,136,136,136,136,136,136,136,136,136,136,136,136,136
2390 DATA 136,136,136,136,136,136,136,136,136,136,136,136,136,139,187,176
2400 DATA 187,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136
2410 DATA 136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,187
2420 DATA 187,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136
2430 DATA 136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,187
2440 DATA  11,187,184,136,136,136,136,136,136,136,136,136,136,136,136,136
2450 DATA 136,136,136,136,136,136,136,136,136,136,136,136,136,139,187,176
2460 DATA   0, 11,187,187,184,136,136,136,136,136,136,136,136,136,136,136
2470 DATA 136,136,136,136,136,136,136,136,136,136,136,139,187,187,176,  0
2480 DATA   0,  0,  0, 11,187,187,187,187,187,187,187,187,187,187,187,187
2490 DATA 187,187,187,187,187,187,187,187,187,187,187,187,176,  0,  0,  0
