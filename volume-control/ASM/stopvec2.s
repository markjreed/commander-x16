IStopVec          = $0328
; This code is loaded from $620 to $666 either with
; BLOAD or POKE
; setStopVec is called with SYS $620 to disable CTRL/C stopping
; restoreStopVec is called with SYS $0653 to restore default
; handling

*=$620
setStopVec:
   nop
   lda #0
   sta $70
   lda IStopVec
   sta STOPHandler+1
   lda IStopVec+1
   sta STOPHandler+2
   sei
     lda #<STOPHandler
     sta IStopVec
     lda #>STOPHandler
     sta IStopVec+1
;ungate restoreStopVec
     lda setStopVec
     sta restoreStopVec
;gate this routine with an rts
     lda #$60
     sta setStopVec
   cli
rts

STOPHandler:
 jsr $FFFF        ; FFFF is a placeholder the system IStop Vector will be copied here.  
 lda #27
 sta $70
 rts

restoreStopVec:
    rts
    sei
      lda STOPHandler+1
      sta IStopVec
      lda STOPHandler+2
      sta IStopVec+1
;ungate setStopVec
      lda restoreStopVec
      sta setStopVec
;gate this routine with an rts
      lda #$60
      sta restoreStopVec
   cli
   rts
