   SCROLL_LINE_START = 3       ;First line of block to scroll
    SCROLL_COL = 5              ;x offset of the block to scroll
    SCROLL_WIDTH = 10           ;amount of consequtive chars to scroll
    SCROLL_LINES = 19           ;amount of lines to scroll (boxheight minus 1 line)
    SCROLL:
        ;Set VERA Addre for reading
        lda #%00000000  ;addr sel 0
        sta VERA_CTRL
        jsr PlotVERA
        inc VERA_addr_high  ;we start reading one line below the first write line

        ;Set VERA Addr for writing
        lda #%00000001  ;addr sel 1 for dataport1
        sta VERA_CTRL
        jsr PlotVERA
        
        ldy #SCROLL_LINES
        RowLoop:
            ldx #SCROLL_WIDTH
            ColLoop:
                lda VERA_data0
                sta VERA_data1
                dex
                bne ColLoop
            
            
            ;Reset read pointer to begining of next line
            lda #%00000000  ;addr sel 0
            sta VERA_CTRL       
            jsr AdvanceToNextLine     
            lda #%00000001  ;addr sel 0
            sta VERA_CTRL       
            jsr AdvanceToNextLine 
            dey
            bne RowLoop
        
        ;Set vera back to addr0
        lda #%00000000  ;addr sel 0
        sta VERA_CTRL
    rts
    
    AdvanceToNextLine:
        inc VERA_addr_high
        lda #SCROLL_COL ;column
        asl     ;times 2
        sta VERA_addr_low          
    
    rts
    
    PlotVERA:
        ;Set read pointer/address
        lda #SCROLL_COL ;column
        asl     ;times 2
        sta VERA_addr_low
        clc
        lda #$B0               
        adc #SCROLL_LINE_START
        sta VERA_addr_high
        lda #$21                ;advance by 2 bytes, we dont scroll the color byte
        sta VERA_addr_bank     
    rts

