100 REM TOWERS OF HANOI IN BASIC
110 ND =  8: REM NUMBER OF DISCS
120 BG = 15: REM BACKGROUND COLOR
130 BK = 11: REM CLOSEST THING TO BLACK WITH 0=TRANSPARENT
140 PC = 70: REM PEG COLOR
150 FC =  5: REM FROM-PEG BACKGROUND COLOR
160 TC =  2: REM TO-PEG BACKGROUND COLOR
163 DIM N$(7):FORI=0TO7:READ N$(I):NEXT I
167 DATA C, B, A, G, F, E, D, C
170 SCREEN 128: RECT 0, 0, 319, 239, BG
180 COLOR BG, 0:CLS
190 FOR I=1 TO 12
200 :  LOCATE 11+I,4:PRINT CHR$(18)RPT$(32,33)
210 NEXT I
220 BX = 60 : BY = 162 : Y0 = BY - 72 : Y1 = BY + 1 : Y2 = BY + 15
230 FOR I=0 TO 2
240 :  CX = BX + I * 96 : X1 = CX - 33 : X2 = X1 + 66
250 : FRAME X1, Y1, X2, Y2, 0 : RECT X1 + 1, Y1 + 1, X2 - 1, Y2 - 1, PC
260 : FRAME CX - 2, Y0, CX + 1, BY + 1, 0 : RECT  CX - 1, Y0 + 1, CX, BY, PC
270 NEXT I
280 COLOR BK
290 DIM P(2, ND) : REM DISKS ON EACH PEG
300 P(0, 0) = ND : FOR I = 1 TO ND : P(0, I) = ND - I : NEXT : REM START SETUP
310 GOSUB 1000 : REM INITIALIZE SPRITES
320 GOSUB 900 :  REM DISPLAY STATE
330 DIM N(8), F(8), T(8), V(8) : REM VARS FOR RECURSIVE SOLUTION
340 N(0) = ND
350 REM LOOP OVER MOVING DISCS TO THE NEXT PEG
360 FOR E=0 TO 1 STEP 0
370 : FOR P=0 TO 1 
380 :   F = P : T = F + 1: GOSUB 460
385 :   FMDRUM 1, 33
390 : NEXT P
400 : FOR P=2 TO 1 STEP -1
410 :   F = P : T = F - 1: GOSUB 460
415 :   FMDRUM 1, 33
420 : NEXT P
430 : GET K$: IF K$ <> "" THEN E = 1
440 NEXT E
450 END
460 FOR L=0 TO 2
470   LOCATE 22, 8 + 12 * L: COLOR BK, 0 : PRINT CHR$(65 + L)
480 NEXT L
490 FOR Q = 0 TO 10000 : NEXT Q
500 LOCATE 22, 8 + 12 * F : COLOR 1, FC : PRINT CHR$(65 + F)
510 LOCATE 22, 8 + 12 * T : COLOR 1, TC : PRINT CHR$(65 + T)
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
760 X1 = BX + F * 96 - 32 - (D < 2) * 16 : REM OLD X
770 X2 = BX + T * 96 - 32 - (D < 2) * 16 : REM NEW X
780 Y0 = BY + 1 - H1 * 8 : REM STARTING Y
790 Y1 = BY + 1 - 16 * 8 : REM Y USED FOR HORIZONTAL MOVE
800 Y2 = BY + 1 - H2 * 8 : REM ENDING Y
810 FOR Y = Y0 TO Y1 STEP  -1 :  MOVSPR D+1, X1, Y : NEXT Y : REM LIFT
820 FOR X = X1 TO X2 STEP T-F :  MOVSPR D+1, X, Y : NEXT X
830 FOR T = 0 TO Y2 - Y1 : REM DROP
840 : Y = Y1 + T * T : IF Y>= Y2 THEN Y = Y2 : T = Y2 - Y1
850 : MOVSPR D+1, X2, Y : FOR Q =0 TO 9 : NEXT Q
860 NEXT
863 FMDRUM 1, 26 - 10 * (H2 = 1):IF H2 <> ND-D THEN 870
865 O=4-(D=0):FMPLAY 0,"O"+MID$(STR$(O),2)+N$(D)
870 RETURN
900 FOR I=0 TO 2
910 : IF P(I, 0) = 0 THEN 980
920 : FOR J = 1 TO P(I, 0)
930 :   D = P(I, J)
940 :   X = BX + I * 96 - 32 - (D < 2) * 16
950 :   Y = BY + 1 - J * 8
960 :   MOVSPR D+1, X, Y : SPRITE D+1, 3
970 : NEXT J
980 NEXT I
990 RETURN
999 REM INITIALIZE SPRITE DATA
1000 A = $3000
1010 LOCATE 30:FOR I=1 TO 8: SPRITE I, 0: NEXT I
1020 FOR I = 1 TO 12
1030 : FOR J = 1 TO 150
1040 :   READ B
1050 :   IF B = -1 THEN J = 150: GOTO 1070
1060 :   VPOKE 1, A, B: A = A + 1
1070 : NEXT J
1080 : PRINT
1090 NEXT I
1100 SPRMEM 1, 1, $3000, 0
1110 SPRITE 1, 0, 0, 0, 2, 0, 0
1120 SPRMEM 2, 1, $3080, 0
1130 SPRITE 2, 0, 0, 0, 2, 0, 0
1140 SPRMEM 3, 1, $3100, 0
1150 SPRITE 3, 0, 0, 0, 3, 0, 0
1160 SPRMEM 4, 1, $3200, 0
1170 SPRITE 4, 0, 0, 0, 3, 0, 0
1180 SPRMEM 5, 1, $3300, 0
1190 SPRITE 5, 0, 0, 0, 3, 0, 0
1200 SPRMEM 6, 1, $3400, 0
1210 SPRITE 6, 0, 0, 0, 3, 0, 0
1220 SPRMEM 7, 1, $3500, 0
1230 SPRITE 7, 0, 0, 0, 3, 0, 0
1240 SPRMEM 8, 1, $3600, 0
1250 SPRITE 8, 0, 0, 0, 3, 0, 0
1260 RETURN
1270 DATA 0,0,0,0,0,0,187,187,187,187,0,0,0,0,0,0,0,0,0,0,187,187,187,17,17,187
1280 DATA 187,187,0,0,0,0,0,0,0,187,187,17,17,17,17,17,17,187,187,0,0,0,0,0,11
1290 DATA 177,17,17,17,17,17,17,17,17,27,176,0,0,0,0,11,177,17,17,17,17,17,17
1300 DATA 17,17,27,176,0,0,0,0,0,187,187,17,17,17,17,17,17,187,187,0,0,0,0,0,0
1310 DATA 0,187,187,187,17,17,187,187,187,0,0,0,0,0,0,0,0,0,0,187,187,187,187,0
1320 DATA 0,0,0,0,0,0,0,0,0,11,187,187,187,187,187,187,176,0,0,0,0,0,0,11,187
1330 DATA 187,178,34,34,34,34,43,187,187,176,0,0,0,11,187,178,34,34,34,34,34,34
1340 DATA 34,34,43,187,176,0,0,187,34,34,34,34,34,34,34,34,34,34,34,34,187,0,0
1350 DATA 187,34,34,34,34,34,34,34,34,34,34,34,34,187,0,0,11,187,178,34,34,34
1360 DATA 34,34,34,34,34,43,187,176,0,0,0,11,187,187,178,34,34,34,34,43,187,187
1370 DATA 176,0,0,0,0,0,0,11,187,187,187,187,187,187,176,0,0,0,0,0,0,0,0,0,0,0
1380 DATA 0,0,0,0,187,187,187,187,187,187,187,187,187,187,0,0,0,0,0,0,0,0,0,0,0
1390 DATA 0,0,0,0,0,0,0,0,0,187,187,187,51,51,51,51,51,51,51,51,187,187,187,0,0
1400 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,187,187,51,51,51,51,51,51,51,51,51,51
1410 DATA 51,51,187,187,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,179,51,51,51,51,51,51
1420 DATA 51,51,51,51,51,51,51,51,59,176,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,179,51
1430 DATA 51,51,51,51,51,51,51,51,51,51,51,51,51,59,176,0,0,0,0,0,0,0,0,0,0,0,0
1440 DATA 0,0,0,187,187,51,51,51,51,51,51,51,51,51,51,51,51,187,187,0,0,0,0,0,0
1450 DATA 0,0,0,0,0,0,0,0,0,0,0,187,187,187,51,51,51,51,51,51,51,51,187,187,187
1460 DATA 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,187,187,187,187,187,187,187
1470 DATA 187,187,187,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,187,187,187
1480 DATA 187,187,187,187,187,187,187,187,187,176,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
1490 DATA 0,11,187,187,180,68,68,68,68,68,68,68,68,68,68,75,187,187,176,0,0,0,0
1500 DATA 0,0,0,0,0,0,0,0,0,11,187,180,68,68,68,68,68,68,68,68,68,68,68,68,68
1510 DATA 68,75,187,176,0,0,0,0,0,0,0,0,0,0,0,0,187,68,68,68,68,68,68,68,68,68
1520 DATA 68,68,68,68,68,68,68,68,68,187,0,0,0,0,0,0,0,0,0,0,0,0,187,68,68,68
1530 DATA 68,68,68,68,68,68,68,68,68,68,68,68,68,68,68,187,0,0,0,0,0,0,0,0,0,0
1540 DATA 0,0,11,187,180,68,68,68,68,68,68,68,68,68,68,68,68,68,68,75,187,176,0
1550 DATA 0,0,0,0,0,0,0,0,0,0,0,0,11,187,187,180,68,68,68,68,68,68,68,68,68,68
1560 DATA 75,187,187,176,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,187,187,187,187,187
1570 DATA 187,187,187,187,187,187,187,176,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,187
1580 DATA 187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,0,0,0,0,0
1590 DATA 0,0,0,0,0,0,0,0,0,187,187,187,85,85,85,85,85,85,85,85,85,85,85,85,85
1600 DATA 85,187,187,187,0,0,0,0,0,0,0,0,0,0,0,187,187,85,85,85,85,85,85,85,85
1610 DATA 85,85,85,85,85,85,85,85,85,85,187,187,0,0,0,0,0,0,0,0,0,11,181,85,85
1620 DATA 85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,91,176,0,0,0,0
1630 DATA 0,0,0,0,11,181,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85
1640 DATA 85,85,91,176,0,0,0,0,0,0,0,0,0,187,187,85,85,85,85,85,85,85,85,85,85
1650 DATA 85,85,85,85,85,85,85,85,187,187,0,0,0,0,0,0,0,0,0,0,0,187,187,187,85
1660 DATA 85,85,85,85,85,85,85,85,85,85,85,85,85,187,187,187,0,0,0,0,0,0,0,0,0
1670 DATA 0,0,0,0,0,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187
1680 DATA 187,0,0,0,0,0,0,0,0,0,0,0,0,0,0,11,187,187,187,187,187,187,187,187
1690 DATA 187,187,187,187,187,187,187,187,187,187,176,0,0,0,0,0,0,0,0,0,0,11
1700 DATA 187,187,182,102,102,102,102,102,102,102,102,102,102,102,102,102,102
1710 DATA 102,102,107,187,187,176,0,0,0,0,0,0,0,11,187,182,102,102,102,102,102
1720 DATA 102,102,102,102,102,102,102,102,102,102,102,102,102,102,102,107,187
1730 DATA 176,0,0,0,0,0,0,187,102,102,102,102,102,102,102,102,102,102,102,102
1740 DATA 102,102,102,102,102,102,102,102,102,102,102,102,187,0,0,0,0,0,0,187
1750 DATA 102,102,102,102,102,102,102,102,102,102,102,102,102,102,102,102,102
1760 DATA 102,102,102,102,102,102,102,187,0,0,0,0,0,0,11,187,182,102,102,102
1770 DATA 102,102,102,102,102,102,102,102,102,102,102,102,102,102,102,102,102
1780 DATA 107,187,176,0,0,0,0,0,0,0,11,187,187,182,102,102,102,102,102,102,102
1790 DATA 102,102,102,102,102,102,102,102,102,107,187,187,176,0,0,0,0,0,0,0,0,0
1800 DATA 0,11,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187
1810 DATA 187,187,176,0,0,0,0,0,0,0,0,0,0,0,187,187,187,187,187,187,187,187,187
1820 DATA 187,187,187,187,187,187,187,187,187,187,187,187,187,0,0,0,0,0,0,0,0
1830 DATA 187,187,187,119,119,119,119,119,119,119,119,119,119,119,119,119,119
1840 DATA 119,119,119,119,119,119,187,187,187,0,0,0,0,0,187,187,119,119,119,119
1850 DATA 119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119
1860 DATA 119,119,119,187,187,0,0,0,11,183,119,119,119,119,119,119,119,119,119
1870 DATA 119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119
1880 DATA 123,176,0,0,11,183,119,119,119,119,119,119,119,119,119,119,119,119
1890 DATA 119,119,119,119,119,119,119,119,119,119,119,119,119,119,123,176,0,0,0
1900 DATA 187,187,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119
1910 DATA 119,119,119,119,119,119,119,119,119,187,187,0,0,0,0,0,187,187,187,119
1920 DATA 119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119,119
1930 DATA 119,119,187,187,187,0,0,0,0,0,0,0,0,187,187,187,187,187,187,187,187
1940 DATA 187,187,187,187,187,187,187,187,187,187,187,187,187,187,0,0,0,0,0,0,0
1950 DATA 0,11,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187
1960 DATA 187,187,187,187,187,187,187,187,176,0,0,0,0,11,187,187,184,136,136
1970 DATA 136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136
1980 DATA 136,136,136,139,187,187,176,0,11,187,184,136,136,136,136,136,136,136
1990 DATA 136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136
2000 DATA 136,136,139,187,176,187,136,136,136,136,136,136,136,136,136,136,136
2010 DATA 136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136
2020 DATA 136,136,187,187,136,136,136,136,136,136,136,136,136,136,136,136,136
2030 DATA 136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136,136
2040 DATA 187,11,187,184,136,136,136,136,136,136,136,136,136,136,136,136,136
2050 DATA 136,136,136,136,136,136,136,136,136,136,136,136,136,139,187,176,0,11
2060 DATA 187,187,184,136,136,136,136,136,136,136,136,136,136,136,136,136,136
2070 DATA 136,136,136,136,136,136,136,136,139,187,187,176,0,0,0,0,11,187,187
2080 DATA 187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187,187
2090 DATA 187,187,187,187,187,176,0,0,0,-1
