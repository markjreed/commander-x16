OPTION NOBASICLOADER
OPTION STARTADDRESS = $A000


CONST PCM_FIFO = $9F3D
CONST AUDIO_CTRL = $9F3B
CONST AUDIO_RATE = $9F3C
CONST STEREO_ON  = %00010000
CONST STEREO_OFF = %11101111
CONST BIT16_ON = %00100000
CONST FIFO_EMPTY = %01000000
CONST FIFO_FULL = %10000000
CONST AFLOW_ON = %00001000
CONST TRUE = $FF
CONST FALSE = 0
CONST R0 = 2
CONST R0L = 2
CONST R0H = 3
CONST R1 = 4
CONST R1L = 4
CONST R1H = 5
CONST R2 = 6
CONST R2L = 6
CONST R2H = 7
CONST R3 = 8
CONST R3L = 8
CONST R3H = 9
CONST R4 = $0A
CONST R4L = $0A
CONST R4H = $0B
CONST R5 = $0C
CONST R5L = $0C
CONST R5H = $0D
CONST R6 = $0E
CONST R6L = $0F
CONST R7 = $10
CONST R7L = $10
CONST R7H = $11
CONST R8 = $12
CONST R8L = $12
CONST R8H = $13
CONST R9 = $14
CONST R9L = $14
CONST R9H = $15
CONST R10 = $16
CONST R10L = $16
CONST R10H = $17
CONST R11 = $18
CONST R11L = $18
CONST R11H = $19
CONST R12 = $1A
CONST R12L = $1A
CONST R12H = $1B
CONST R13 = $1C
CONST R13L = $1C
CONST R13H = $1D
CONST R14 = $1E
CONST R14L = $1E
CONST R14H = $1F
CONST R15 = $20
CONST R15L = $20
CONST R15H = $21
CONST MACPTR = $FF44
CONST CHKIN = $FFC6
CONST CHKOUT = $FFC9
CONST CLRCHN = $FFCC
CONST CHROUT = $FFD2
CONST CHRIN = $FFCF
CONST READST = $FFB7
CONST RDTIM = $FFDE
CONST SETTIM = $FFDB
CONST LAYER1_OFF = 223
CONST LAYER1_ON = 32


DIM CTRL AS BYTE @$9F3B
DIM FIFO AS BYTE @$9F3D
DIM VERA_ISR AS BYTE @$9F27
DIM DC_VIDEO AS BYTE @$9F29
DIM loop_ctr1 AS BYTE FAST
DIM TextVisible AS BYTE
DIM PCM_LFN AS BYTE 
DIM FSCNT AS BYTE 
DIM ControlProc AS WORD 
DIM OutTake AS WORD
DIM BLength AS BYTE
DIM PCM_CFG_VAR AS BYTE 
DIM PCM_VOLUME AS BYTE 
DIM PlayDone AS BYTE
DIM PCM_V_RATE AS BYTE
DIM SCRATCHBANK AS BYTE
DIM Is_Host_FS AS BYTE
DIM I AS BYTE FAST
DIM C AS BYTE FAST
DIM L AS BYTE FAST
DIM _Key AS BYTE
DIM SAVETIME AS LONG
DIM Jifs AS LONG
DIM Mins AS LONG
DIM Secs AS LONG




FUNCTION READTIME AS LONG() STATIC
 DIM TMP AS LONG
 ASM
   jsr {RDTIM}
   sta {TMP}
   stx {TMP}+1
   sty {TMP}+2
 END ASM
 RETURN TMP
END FUNCTION

SUB SetTimer(NewTimer AS LONG) STATIC
 ASM
   lda {NewTimer}
   ldy {NewTimer}+1
   ldx {NewTimer}+2
   jsr {SETTIM}
 END ASM
END SUB

SUB ZeroTimer() STATIC
  ASM
   lda #0
   tax
   tay
   jsr {SETTIM}
 END ASM
END SUB


SUB TextToggle() STATIC
 IF TextVisible=255 THEN
    DC_VIDEO = DC_VIDEO AND LAYER1_OFF
    TextVisible = 0
 ELSE
    DC_VIDEO = DC_VIDEO OR LAYER1_ON
    TextVisible = 255
 END IF
END SUB



SUB FILL_AUDIO_FIFO() STATIC
    ASM
      ldx {PCM_LFN}
      jsr {CHKIN}
      ldx #17
      sta {loop_ctr1}
loopf ldx #$3D
      ldy #$9f
      lda #240
      sec
      jsr {MACPTR}
      jsr {READST}
      bne donef
      dec {loop_ctr1}
      bne loopf
      clc
      bcc fendf
donef lda $FF
      sta {PlayDone}
fendf jsr {CLRCHN}
    END ASM
END SUB

SUB TWEAK_AUDIO_FIFO() static
    ASM
      ldx {PCM_LFN}
      jsr {CHKIN}
      ldx {FSCNT}
      stx {loop_ctr1}
loop2 ldx #$3D
      ldy #$9f
      lda #0
      sec
      jsr {MACPTR}
      jsr {READST}
      bne done2
      dec {loop_ctr1}
      bne loop2
      jmp fend2
done2 lda $FF
      sta {PlayDone}
fend2 jsr {CLRCHN}
    END ASM
END SUB

SUB PausePCMStream() STATIC
  POKE AUDIO_RATE, 0
  SAVETIME = READTIME()
  ASM
   lda {SAVETIME}
   sta {R14L}
   lda {SAVETIME}+1
   sta {R14H}
   lda {SAVETIME}+2
   sta {R15L}
   lda #$FF
   sta {R15H}
  END ASM
  PlayDone=$FF
END SUB

SUB PCM_SetVolume() STATIC
 DIM TMPB AS BYTE
 TMPB = PCM_CFG_VAR AND %11110000
 PCM_CFG_VAR = TMPB OR PCM_VOLUME
 POKE AUDIO_CTRL, PCM_CFG_VAR
END SUB

SUB VolumeDown() Static
 IF PCM_VOLUME > 1 THEN
    PCM_VOLUME=PCM_VOLUME-1
    CALL PCM_SetVolume()
 END IF
END SUB

SUB VolumeUp() Static
 IF PCM_VOLUME < 15 Then
    PCM_VOLUME = PCM_VOLUME+1
    CALL PCM_SetVolume()
 END IF
END SUB

SUB CONTPCM() STATIC
 PlayDone = 0
 TextVisible = PEEK(R13L)
 POKE AUDIO_RATE, PCM_V_RATE
 DO
   _Key = 0
   IF (VERA_ISR AND AFLOW_ON) = AFLOW_ON THEN
      CALL TWEAK_AUDIO_FIFO()
         ASM
           lda {ControlProc}+1
           beq skipcntrl+1
           jsr doCntrol
           jmp skipcntrl+1
doCntrol   jmp ({ControlProc})
skipcntrl  nop
         END ASM
   END IF
   IF _Key > 0 THEN
      IF _Key = 29 OR _Key = 157 THEN PlayDone = TRUE
      IF _Key = 27 OR _Key = 9 OR _Key=24 THEN PlayDone=TRUE
      IF _Key = 32 THEN Call PausePCMStream()
      IF _Key = 145 THEN Call VolumeUp()
      IF _Key = 17 THEN Call VolumeDown()
      IF _Key = 133 THEN CALL TextToggle()
   END IF
 LOOP UNTIL PlayDone

 POKE R2L, _Key
 POKE R13L, TextVisible
END SUB

SUB PLAYPCM() STATIC SHARED
   POKE R15H, 0
   POKE AUDIO_RATE, 0
   POKE AUDIO_CTRL, FIFO_FULL
   POKE AUDIO_CTRL, PCM_CFG_VAR
   CALL FILL_AUDIO_FIFO()
   POKE AUDIO_RATE, PCM_V_RATE
  DO UNTIL PlayDone
   _Key = 0
   IF (VERA_ISR AND AFLOW_ON) = AFLOW_ON THEN
         CALL TWEAK_AUDIO_FIFO()
         ASM
           lda {ControlProc}+1
           beq skipit+1
           jsr doCnt
           jmp skipit+1
doCnt:     jmp ({ControlProc})
skipit:    nop
         END ASM
   END IF
   IF _Key > 0 THEN
      IF _Key = 29 OR _Key = 157 THEN PlayDone = TRUE
      IF _Key = 27 OR _Key = 9 OR _Key=24 THEN PlayDone=TRUE
      IF _Key = 32 THEN Call PausePCMStream()
      IF _Key = 145 THEN Call VolumeUp()
      IF _Key = 17 THEN Call VolumeDown()
      IF _Key = 133 THEN CALL TextToggle()
   END IF
 LOOP
 POKE R2L, _Key
 POKE R13L, TextVisible
 _Key = 0
END SUB


DOCONTPLAY:
 PlayDone = 0
 TextVisible = PEEK(R13L)
 CALL CONTPCM()
 ASM
  rts
 END ASM
 END


GOSUB KEYCONTROL

DOSTARTPLAY:
       ASM
s_l:     stx {PCM_LFN}
         sta {FSCNT}
   END ASM
   PCM_V_RATE = PEEK(R0L)
   PCM_CFG_VAR = PEEK(R0H)
   PCM_VOLUME = PCM_CFG_VAR AND %00001111
   DoControl = PEEK(R1L)
   TextVisible = PEEK(R13L)
   BLength = 0
   IF DoControl THEN ControlProc = @KEYCONTROL2 ELSE ControlProc = 0
   PlayDone = 0 
   _Key = 0 
   CALL PLAYPCM()
   ASM
     rts
   END ASM
   END

KEYCONTROL2:
       ASM
         lda #176
         jsr {CHROUT}
         inc {BLength}
         lda {BLength}
         cmp #34
         bne lkey
         lda #0
         sta {BLength}
         clc
         ldx #24
         ldy #3
         jsr $FFF0
         lda #1
         jsr {CHROUT}
lkey:    jsr $FFE4
         sta {_Key}
         rts
    END ASM
  RETURN

KEYCONTROL:
  ASM
    jsr $FFE4
    sta {_Key}
    rts
  END ASM

FILLFIFO:
  CALL FILL_AUDIO_FIFO()
  ASM
   rts
  END ASM



