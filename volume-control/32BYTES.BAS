## CONVERT TO SIGNED RANGE
  DEF FN SW(W)=W + 65536 * (W > 32767)
## CONVERT TO UNSIGNED RANGE
  DEF FN UW(W)=W-65536*(W<0)

  DEF FN Lo.Byte(X)=(FN SW(X)) AND $FF
  DEF FN Hi.Byte(X)=INT(FN UW(X)/256)

CLS
PRINT 
PRINT "VALID VALUES 0- 4,294,967,295 (WITHOUT COMMAS)":PRINT
INPUT "ENTER A 32 BIT INTEGER VALUE";TARG
PRINT:PRINT TARG:PRINT:PRINT
HIWORD = INT(TARG/65536)
LOWORD = TARG - (HIWORD*65536)
B0 = FN Lo.Byte(LOWORD)
B1 = FN Hi.Byte(LOWORD)
B2 = FN Lo.Byte(HIWORD)
B3 = FN Hi.Byte(HIWORD) 

PRINT HEX$(B3);HEX$(B2);HEX$(B1);HEX$(B0)
PRINT
PRINT
PRINT HEX$(HIWORD);HEX$(LOWORD)
PRINT
PRINT
END



