.export save
VERA_LADDR := $9F20
VERA_MADDR := $9F21
VERA_HADDR := $9F22
VERA_DATA0 := $9F23
VERA_DATA1 := $9F24
VERA_CTRL  := $9F25
R15L = $20
SETLFS := $FFBA
CHKOUT := $FFC9
CLRCHN := $FFCC
MCIOUT := $FEB1
FB_cursor_position = $FEFF
FB_cursor_nextline = $FF02
BITMAP_END := $012C
.org $0600
save:
  jsr CHKOUT
  jsr FB_cursor_position
@loop:
	ldx #$23
	ldy #$9F
	lda #64
	sec
	jsr MCIOUT
    dec R15L
    beq @done
    jsr FB_cursor_nextline
    bra @loop
@done:
@error:
	jsr CLRCHN
	rts

