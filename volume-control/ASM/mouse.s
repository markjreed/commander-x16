R14=$1E
R14L=$1E
R14H=$1F

R15=$20
R15L=$20
R15H=$21
mouse_get = $FF6B


  ldx #R14
  jsr mouse_get
  phx
  ldx #3
div8:
 lsr R15H
 ror R15L
 lsr R14H
 ror R14L
 dex
 bne div8
 inc R14L
 inc R15L
 plx
 rts
 


