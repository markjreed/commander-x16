100 FOR A=$0400 TO $0555
110 : READ B
120 : POKE A, B
130 NEXT A
140 POKE $0311,0: POKE $0312,4: REM SET USR() TO POINT TO $0400
150 DIM A$(99)
160 FOR I=0 TO 99: READ A$(I): NEXT I: REM LOAD WORD LIST
170 T0 = TI: X = USR(POINTER(A$(0))): T1 = TI
180 REM DISPLAY SORTED DOWN THE COLUMNS
190 FOR I=0 TO 12
200 : FOR J=0 TO 7
210 :  W = J * 13 + I: IF W < 100 THEN PRINT A$(W),
220 : NEXT J
230 NEXT I
240 PRINT: PRINT
250 PRINT "SORTED 100 WORDS IN" T1 - T0 "JIFFIES."
260 REM CODE
270 DATA 76, 19, 4, 189, 2, 45, 1, 132, 0, 57, 0, 23, 0, 10, 0, 4, 0, 1, 0, 32
280 DATA 12, 254, 133, 37, 132, 36, 152, 56, 233, 2, 133, 34, 165, 37, 233, 0
290 DATA 133, 35, 160, 0, 177, 34, 133, 39, 200, 177, 34, 133, 38, 100, 40, 165
300 DATA 40, 10, 170, 189, 3, 4, 133, 41, 232, 189, 3, 4, 133, 42, 165, 41, 133
310 DATA 43, 165, 42, 133, 44, 165, 44, 197, 39, 144, 11, 208, 6, 165, 43, 197
320 DATA 38, 144, 3, 76, 50, 5, 165, 36, 133, 45, 165, 37, 133, 46, 162, 3, 165
330 DATA 45, 24, 101, 43, 133, 45, 165, 46, 101, 44, 133, 46, 202, 208, 240
340 DATA 160, 0, 177, 45, 153, 55, 0, 200, 192, 3, 144, 246, 165, 43, 133, 47
350 DATA 165, 44, 133, 48, 165, 48, 197, 42, 144, 116, 208, 6, 165, 47, 197
360 DATA 41, 144, 108, 165, 47, 56, 229, 41, 133, 51, 165, 48, 229, 42, 133
370 DATA 52, 165, 36, 133, 53, 165, 37, 133, 54, 162, 3, 165, 53, 24, 101, 51
380 DATA 133, 53, 165, 54, 101, 52, 133, 54, 202, 208, 240, 160, 0, 177, 53
390 DATA 153, 58, 0, 200, 192, 3, 144, 246, 32, 62, 5, 176, 52, 165, 36, 133
400 DATA 49, 165, 37, 133, 50, 162, 3, 165, 49, 24, 101, 47, 133, 49, 165, 50
410 DATA 101, 48, 133, 50, 202, 208, 240, 160, 0, 177, 53, 145, 49, 200, 192
420 DATA 3, 144, 247, 165, 47, 56, 229, 41, 133, 47, 165, 48, 229, 42, 133, 48
430 DATA 128, 134, 165, 36, 133, 49, 165, 37, 133, 50, 162, 3, 165, 49, 24, 101
440 DATA 47, 133, 49, 165, 50, 101, 48, 133, 50, 202, 208, 240, 160, 0, 185
450 DATA 55, 0, 145, 49, 200, 192, 3, 144, 246, 230, 43, 208, 2, 230, 44, 76
460 DATA 74, 4, 165, 41, 201, 1, 240, 5, 230, 40, 76, 51, 4, 96, 160, 0, 196
470 DATA 55, 176, 13, 196, 58, 176, 9, 177, 56, 209, 59, 208, 7, 200, 208, 239
480 DATA 164, 55, 196, 58, 96
490 REM 100 RANDOM WORDS COURTESY OF WORDLE
500 DATA FIEND, TOUGH, WIDER, AIDER, MAYOR, CREEK, BURLY, AWARD, ARENA, TRYST
510 DATA VAULT, FLUTE, TRIED, TEMPO, HINGE, SAINT, CLASP, CLOAK, EXERT, GLADE
520 DATA LEAST, LEANT, STANK, AXIAL, BROIL, UNDID, CIRCA, WACKY, FEVER, GAWKY
530 DATA BATON, SPICE, ARISE, DRIED, ARSON, LOGIC, SCOWL, RISEN, MACRO, NIGHT
540 DATA BLAST, MOUNT, SHOUT, BLANK, PADDY, PROVE, STICK, UNITE, RIDGE, FICUS
550 DATA DWELT, SKIRT, SHAME, SONIC, ALBUM, AMEND, SPORE, SOOTY, BUSED, WOMAN
560 DATA DOGMA, CIGAR, WATER, MAMBO, SWEEP, THREW, KNEED, CHARM, POLAR, INLET
570 DATA TOPIC, SHARK, PESKY, CROAK, DROWN, SENSE, PLUMB, SPOKE, SAUCE, INDEX
580 DATA VOUCH, LUPUS, SPINY, GULLY, WIELD, AWOKE, SINGE, LAYER, IRATE, VITAL
590 DATA RISER, SEDAN, TROVE, STOOD, OUNCE, MANGA, VERVE, WEIRD, AGORA, DRAWL
