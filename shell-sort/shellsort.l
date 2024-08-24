ca65 V2.18 - N/A
Main file   : loader.asm
Current file: loader.asm

000000r 1               ; USR() function to sort a BASIC string array.
000000r 1               
000000r 1               ; MIT License
000000r 1               
000000r 1               ; Copyright (c) 2024 Mark J. Reed
000000r 1               ;
000000r 1               ; Permission is hereby granted, free of charge, to any person obtaining a copy
000000r 1               ; of this software and associated documentation files (the "Software"), to deal
000000r 1               ; in the Software without restriction, including without limitation the rights
000000r 1               ; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
000000r 1               ; copies of the Software, and to permit persons to whom the Software is
000000r 1               ; furnished to do so, subject to the following conditions:
000000r 1               ;
000000r 1               ; The above copyright notice and this permission notice shall be included in all
000000r 1               ; copies or substantial portions of the Software.
000000r 1               ;
000000r 1               ; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
000000r 1               ; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
000000r 1               ; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
000000r 1               ; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
000000r 1               ; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
000000r 1               ; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
000000r 1               ; SOFTWARE.
000000r 1               ;
000000r 1               .include "cx16.inc"
000000r 2               ;
000000r 2               ; CX16 r37 definitions
000000r 2               ;
000000r 2               
000000r 2               ; ---------------------------------------------------------------------------
000000r 2               ; Constants
000000r 2               
000000r 2               .enum COLOR
000000r 2                 BLACK         = $00
000000r 2                 WHITE
000000r 2                 RED
000000r 2                 CYAN
000000r 2                 VIOLET
000000r 2                 PURPLE        = VIOLET
000000r 2                 GREEN
000000r 2                 BLUE
000000r 2                 YELLOW
000000r 2                 ORANGE
000000r 2                 BROWN
000000r 2                 PINK
000000r 2                 LIGHTRED      = PINK
000000r 2                 GRAY1
000000r 2                 GRAY2
000000r 2                 LIGHTGREEN
000000r 2                 LIGHTBLUE
000000r 2                 GRAY3
000000r 2               .endenum
000000r 2               
000000r 2               ; Special characters
000000r 2               .enum CH
000000r 2               COLOR_SWAP      = $01
000000r 2               STOP            = $03
000000r 2               UNDERLINE
000000r 2               WHITE
000000r 2               BOLD
000000r 2               BELL
000000r 2               BACKSPACE
000000r 2               TAB
000000r 2               LINEFEED
000000r 2               ITALIC
000000r 2               OUTLINE
000000r 2               ENTER
000000r 2               FONT_LOWER
000000r 2               FONT_ISO
000000r 2               F9
000000r 2               CURS_DOWN
000000r 2               REVERSE
000000r 2               HOME
000000r 2               DEL
000000r 2               F10
000000r 2               F11
000000r 2               F12
000000r 2               SHIFT_TAB
000000r 2               RED             = $1C
000000r 2               CURS_RIGHT
000000r 2               GREEN
000000r 2               BLUE
000000r 2               LIRA            = $5C
000000r 2               ORANGE          = $81
000000r 2               RUN             = $83
000000r 2               HELP
000000r 2               F1
000000r 2               F3
000000r 2               F5
000000r 2               F7
000000r 2               F2
000000r 2               F4
000000r 2               F6
000000r 2               F8
000000r 2               SHIFT_ENTER
000000r 2               FONT_UPPER
000000r 2               FONT_PET
000000r 2               BLACK
000000r 2               CURS_UP
000000r 2               ATTR_CLEAR
000000r 2               SCRN_CLEAR
000000r 2               INS
000000r 2               BROWN
000000r 2               PINK
000000r 2               LIGHTRED        = PINK
000000r 2               GRAY1
000000r 2               GRAY2
000000r 2               LIGHTGREEN
000000r 2               LIGHTBLUE
000000r 2               GRAY3
000000r 2               PURPLE
000000r 2               VIOLET          = PURPLE
000000r 2               CURS_LEFT
000000r 2               YELLOW
000000r 2               CYAN
000000r 2               SHIFT_SPACE
000000r 2               LTEE            = $AB
000000r 2               LLCORNER        = $AD
000000r 2               URCORNER
000000r 2               ULCORNER        = $B0
000000r 2               BTEE
000000r 2               TTEE
000000r 2               RTEE
000000r 2               LRCORNER        = $BD
000000r 2               HLINE           = $C0
000000r 2               CROSS           = $DB
000000r 2               VLINE           = $DD
000000r 2               PI
000000r 2               .endenum
000000r 2               
000000r 2               ; ---------------------------------------------------------------------------
000000r 2               ; Zero page
000000r 2               
000000r 2               ; GEOS and graphics pseudo-registers
000000r 2               .struct gREG
000000r 2                               .org    $02
000000r 2                 .union
000000r 2                 r0            .word
000000r 2                 .struct
000000r 2                 r0L           .byte
000000r 2                 r0H           .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2                 .union
000000r 2                 r1            .word
000000r 2                 .struct
000000r 2                 r1L           .byte
000000r 2                 r1H           .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2                 .union
000000r 2                 r2            .word
000000r 2                 .struct
000000r 2                 r2L           .byte
000000r 2                 r2H           .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2                 .union
000000r 2                 r3            .word
000000r 2                 .struct
000000r 2                 r3L           .byte
000000r 2                 r3H           .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2                 .union
000000r 2                 r4            .word
000000r 2                 .struct
000000r 2                 r4L           .byte
000000r 2                 r4H           .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2                 .union
000000r 2                 r5            .word
000000r 2                 .struct
000000r 2                 r5L           .byte
000000r 2                 r5H           .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2                 .union
000000r 2                 r6            .word
000000r 2                 .struct
000000r 2                 r6L           .byte
000000r 2                 r6H           .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2                 .union
000000r 2                 r7            .word
000000r 2                 .struct
000000r 2                 r7L           .byte
000000r 2                 r7H           .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2                 .union
000000r 2                 r8            .word
000000r 2                 .struct
000000r 2                 r8L           .byte
000000r 2                 r8H           .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2                 .union
000000r 2                 r9            .word
000000r 2                 .struct
000000r 2                 r9L           .byte
000000r 2                 r9H           .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2                 .union
000000r 2                 r10           .word
000000r 2                 .struct
000000r 2                 r10L          .byte
000000r 2                 r10H          .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2                 .union
000000r 2                 r11           .word
000000r 2                 .struct
000000r 2                 r11L          .byte
000000r 2                 r11H          .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2                 .union
000000r 2                 r12           .word
000000r 2                 .struct
000000r 2                 r12L          .byte
000000r 2                 r12H          .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2                 .union
000000r 2                 r13           .word
000000r 2                 .struct
000000r 2                 r13L          .byte
000000r 2                 r13H          .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2                 .union
000000r 2                 r14           .word
000000r 2                 .struct
000000r 2                 r14L          .byte
000000r 2                 r14H          .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2                 .union
000000r 2                 r15           .word
000000r 2                 .struct
000000r 2                 r15L          .byte
000000r 2                 r15H          .byte
000000r 2                 .endstruct
000000r 2                 .endunion
000000r 2               .endstruct
000000r 2               
000000r 2               ; Kernal
000000r 2               KTEMP2          := $80          ; 2 bytes for temporary storage
000000r 2               IMPARM          := $82          ; Pointer for PRIMM function
000000r 2               FNAM            := $8C          ; Pointer to filename
000000r 2               
000000r 2               ; BASIC
000000r 2               TXTPTR          := $EE          ; Pointer into BASIC source code
000000r 2               
000000r 2               ; Page two
000000r 2               
000000r 2               BASIC_BUF       := $0200        ; Location of command-line
000000r 2               BASIC_BUF_LEN   = 81            ; Maximum length of command-line
000000r 2               
000000r 2               SCREEN_MODE     := $0261        ; Current screen mode (set by SCREEN_SET_MODE)
000000r 2               SCREEN_PTR      := $0262        ; Pointer to current row on text screen (16 bits)
000000r 2               STATUS          := $0286        ; Status from previous I/O operation
000000r 2               IN_DEV          := $028A        ; Current input device number
000000r 2               OUT_DEV         := $028B        ; Current output device number
000000r 2               FNAM_LEN        := $028E        ; Length of filename
000000r 2               SECADR          := $0290        ; Secondary address
000000r 2               DEVNUM          := $0291        ; Device number
000000r 2               CURS_COLOR      := $0373        ; Color under the cursor
000000r 2               CHARCOLOR       := $0376        ; Cursor's color nybbles (high: background, low: foreground)
000000r 2               RVS             := $0377        ; Reverse flag
000000r 2               CURS_FLAG       := $037B        ; 1 = cursor off
000000r 2               CURS_BLINK      := $037C        ; Blink counter
000000r 2               CURS_CHAR       := $037D        ; Character under the cursor
000000r 2               CURS_STATE      := $037E        ; Cursor blink state
000000r 2               CURS_X          := $0380        ; Cursor column
000000r 2               CURS_Y          := $0383        ; Cursor row
000000r 2               LLEN            := $0386        ; Line length
000000r 2               NLINES          := $0387        ; Number of screen lines
000000r 2               
000000r 2               ; BASIC
000000r 2               VARTAB          := $03E2        ; Pointer to start of BASIC variables
000000r 2               MEMSIZE         := $03EA        ; Pointer to highest BASIC RAM location (+1)
000000r 2               
000000r 2               ; ---------------------------------------------------------------------------
000000r 2               ; Vector and other locations
000000r 2               
000000r 2               IRQVec          := $0314
000000r 2               BRKVec          := $0316
000000r 2               NMIVec          := $0318
000000r 2               
000000r 2               ; ---------------------------------------------------------------------------
000000r 2               ; I/O locations
000000r 2               
000000r 2               ; Video Enhanced Retro Adapter
000000r 2               ; Has audio and SPI.
000000r 2               .scope  VERA
000000r 2               
000000r 2                 ; External registers
000000r 2               
000000r 2                 .struct
000000r 2                               .org    $9F20
000000r 2                 ADDR          .faraddr        ; Address for data port access
000000r 2                 DATA0         .byte           ; First data port
000000r 2                 DATA1         .byte           ; Second data port
000000r 2                 CTRL          .byte           ; Control register
000000r 2                 IRQ_EN        .byte           ; Interrupt enable bits
000000r 2                 IRQ_FLAGS     .byte           ; Interrupt flags
000000r 2                 IRQ_RASTER    .byte           ; Line where IRQ will occur
000000r 2                 .endstruct
000000r 2                 .enum                         ; Address automatic increment amounts
000000r 2                 DEC0          =       (($00 << 1) | $01) << 3
000000r 2                 DEC1          =       (($01 << 1) | $01) << 3
000000r 2                 DEC2          =       (($02 << 1) | $01) << 3
000000r 2                 DEC4          =       (($03 << 1) | $01) << 3
000000r 2                 DEC8          =       (($04 << 1) | $01) << 3
000000r 2                 DEC16         =       (($05 << 1) | $01) << 3
000000r 2                 DEC32         =       (($06 << 1) | $01) << 3
000000r 2                 DEC64         =       (($07 << 1) | $01) << 3
000000r 2                 DEC128        =       (($08 << 1) | $01) << 3
000000r 2                 DEC256        =       (($09 << 1) | $01) << 3
000000r 2                 DEC512        =       (($0A << 1) | $01) << 3
000000r 2                 DEC40         =       (($0B << 1) | $01) << 3
000000r 2                 DEC80         =       (($0C << 1) | $01) << 3
000000r 2                 DEC160        =       (($0D << 1) | $01) << 3
000000r 2                 DEC320        =       (($0E << 1) | $01) << 3
000000r 2                 DEC640        =       (($0F << 1) | $01) << 3
000000r 2                 INC0          =       (($00 << 1) | $00) << 3
000000r 2                 INC1          =       (($01 << 1) | $00) << 3
000000r 2                 INC2          =       (($02 << 1) | $00) << 3
000000r 2                 INC4          =       (($03 << 1) | $00) << 3
000000r 2                 INC8          =       (($04 << 1) | $00) << 3
000000r 2                 INC16         =       (($05 << 1) | $00) << 3
000000r 2                 INC32         =       (($06 << 1) | $00) << 3
000000r 2                 INC64         =       (($07 << 1) | $00) << 3
000000r 2                 INC128        =       (($08 << 1) | $00) << 3
000000r 2                 INC256        =       (($09 << 1) | $00) << 3
000000r 2                 INC512        =       (($0A << 1) | $00) << 3
000000r 2                 INC40         =       (($0B << 1) | $00) << 3
000000r 2                 INC80         =       (($0C << 1) | $00) << 3
000000r 2                 INC160        =       (($0D << 1) | $00) << 3
000000r 2                 INC320        =       (($0E << 1) | $00) << 3
000000r 2                 INC640        =       (($0F << 1) | $00) << 3
000000r 2                 .endenum
000000r 2                 .enum                         ; Interrupt request flags
000000r 2                 VERT_SYNC     =       %00000001
000000r 2                 RASTER_IRQ    =       %00000010
000000r 2                 SPR_COLLIDED  =       %00000100
000000r 2                 AUDIO_LOW     =       %00001000
000000r 2                 .endenum
000000r 2                 .scope        DISP            ; Display controller
000000r 2                   SELECT1     =       %00000010
000000r 2                   .union
000000r 2                               .org    $9F29
000000r 2                   .struct
000000r 2                   ; These four registers are visible when the DCSEL flag = %0
000000r 2                   VIDEO       .byte
000000r 2                   HSCALE      .byte
000000r 2                   VSCALE      .byte
000000r 2                   FRAME       .byte
000000r 2                   .endstruct
000000r 2                   .struct
000000r 2                   ; These four registers are visible when the DCSEL flag = %1
000000r 2                   HSTART      .byte
000000r 2                   HSTOP       .byte
000000r 2                   VSTART      .byte
000000r 2                   VSTOP       .byte
000000r 2                   .endstruct
000000r 2                   .endunion
000000r 2                   .enum       MODE            ; Output mode
000000r 2                     DISABLE   =       $00
000000r 2                     VGA
000000r 2                     NTSC
000000r 2                     RGB                       ; Interlaced, composite sync
000000r 2                   .endenum
000000r 2                   .enum       DISABLE
000000r 2                   COLOR       =       %00000100       ; NTSC monochrome
000000r 2                   .endenum
000000r 2                   .enum       ENABLE
000000r 2                     LAYER0    =       %00010000
000000r 2                     LAYER1    =       %00100000
000000r 2                     SPRITES   =       %01000000
000000r 2                   .endenum
000000r 2                 .endscope
000000r 2                 .struct       L0              ; Display layer 0
000000r 2                               .org    $9F2D
000000r 2                   CONFIG      .byte
000000r 2                   MAP_BASE    .byte
000000r 2                   TILE_BASE   .byte
000000r 2                   HSCROLL     .word
000000r 2                   VSCROLL     .word
000000r 2                 .endstruct
000000r 2                 .struct       L1              ; Display layer 1
000000r 2                               .org    $9F34
000000r 2                   CONFIG      .byte
000000r 2                   MAP_BASE    .byte
000000r 2                   TILE_BASE   .byte
000000r 2                   HSCROLL     .word
000000r 2                   VSCROLL     .word
000000r 2                 .endstruct
000000r 2                 .enum                         ; Layer display modes
000000r 2                 TILE1BPP      =       %00000000 | $00
000000r 2                 TILE2BPP
000000r 2                 TILE4BPP
000000r 2                 TILE8BPP
000000r 2                 T256C         =       %00001000
000000r 2                 BITMAP1BPP    =       %00000100 | $00
000000r 2                 BITMAP2BPP
000000r 2                 BITMAP4BPP
000000r 2                 BITMAP8BPP
000000r 2                 .endenum
000000r 2                 .enum         MAP             ; Map geometry
000000r 2                   WIDTH32     =       $00 << 4
000000r 2                   WIDTH64     =       $01 << 4
000000r 2                   WIDTH128    =       $02 << 4
000000r 2                   WIDTH256    =       $03 << 4
000000r 2                   HEIGHT32    =       $00 << 6
000000r 2                   HEIGHT64    =       $01 << 6
000000r 2                   HEIGHT128   =       $02 << 6
000000r 2                   HEIGHT256   =       $03 << 6
000000r 2                 .endenum
000000r 2                 .enum         TILE            ; Tile geometry
000000r 2                   WIDTH8      =       $00
000000r 2                   WIDTH16     =       $01
000000r 2                   WIDTH320    =       WIDTH8
000000r 2                   WIDTH640    =       WIDTH16
000000r 2                   HEIGHT8     =       $00 << 1
000000r 2                   HEIGHT16    =       $01 << 1
000000r 2                 .endenum
000000r 2                 .scope        PCM             ; Pulse-Code Modulator
000000r 2                   .struct
000000r 2                               .org    $9F3B
000000r 2                   CTRL        .byte
000000r 2                   RATE        .byte
000000r 2                   DATA        .byte
000000r 2                   .endstruct
000000r 2                   .enum
000000r 2                   STEREO      =       %00010000
000000r 2                   BITS16      =       %00100000
000000r 2                   RESET       =       %10000000
000000r 2                   .endenum
000000r 2                 .endscope
000000r 2                 .scope        SPI
000000r 2                   .struct
000000r 2                               .org    $9F3E
000000r 2                   DATA        .byte
000000r 2                   CTRL        .byte
000000r 2                   .endstruct
000000r 2                   .enum
000000r 2                   SELECT      =       %00000001
000000r 2                   SLOW        =       %00000010
000000r 2                   .endenum
000000r 2                 .endscope
000000r 2               
000000r 2                 ; Internal RAM and registers
000000r 2               
000000r 2                 .struct
000000r 2                               .org    $000000
000000r 2                 VRAM          .res    $020000 ; 128 Kibibytes
000000r 2                 .endstruct
000000r 2                 .scope        PSG             ; Programmable Sound Generator
000000r 2                   .struct
000000r 2                   PITCH       .word
000000r 2                   VOL         .byte           ; Left, right channels; volume
000000r 2                   WAVEFORM    .byte           ; Wave shape, pulse width
000000r 2                   .endstruct
000000r 2                   LEFT        =       %01 << 6
000000r 2                   RIGHT       =       %10 << 6
000000r 2                   .enum
000000r 2                   PULSE       =       $00 << 6
000000r 2                   SAWTOOTH    =       $01 << 6
000000r 2                   TRIANGLE    =       $02 << 6
000000r 2                   NOISE       =       $03 << 6
000000r 2                   .endenum
000000r 2                   .struct
000000r 2                               .org    $01F9C0
000000r 2                   VOICES      .res    $10 * 4
000000r 2                   .endstruct
000000r 2                 .endscope
000000r 2                 .struct
000000r 2                               .org    $01FA00
000000r 2                 PALETTE       .word   $0100
000000r 2                 .endstruct
000000r 2                 .scope        SPRITE
000000r 2                   .struct                     ; Sprite attributes
000000r 2                   ADDR        .addr           ; Address and color mode
000000r 2                   XX          .word           ; Co-ordinates
000000r 2                   YY          .word
000000r 2                   Z_FLIP      .byte           ; Collision mask, Z-depth, flip bits
000000r 2                   SIZE_PAL    .byte
000000r 2                   .endstruct
000000r 2                   .enum       FLIP
000000r 2                     NONE      =       %00000000
000000r 2                     HORIZ
000000r 2                     VERT
000000r 2                     BOTH
000000r 2                   .endenum
000000r 2                   .enum       DEPTH
000000r 2                     DISABLE   =       $00 << 2
000000r 2                     CANVAS    =       $01 << 2
000000r 2                     LAYER0    =       $02 << 2
000000r 2                     LAYER1    =       $03 << 2
000000r 2                   .endenum
000000r 2                   .enum                       ; Sprite geometry
000000r 2                   WIDTH8      =       $00 << 4
000000r 2                   WIDTH16     =       $01 << 4
000000r 2                   WIDTH32     =       $02 << 4
000000r 2                   WIDTH64     =       $03 << 4
000000r 2                   HEIGHT8     =       $00 << 6
000000r 2                   HEIGHT16    =       $01 << 6
000000r 2                   HEIGHT32    =       $02 << 6
000000r 2                   HEIGHT64    =       $03 << 6
000000r 2                   COLORS16    =       $00 << 7
000000r 2                   COLORS256   =       $01 << 7
000000r 2                   .endenum
000000r 2                 .endscope
000000r 2                 .struct
000000r 2                               .org    $01FC00
000000r 2                 SPRITES       .res    128 * 8
000000r 2                 .endstruct
000000r 2               .endscope
000000r 2               
000000r 2               ; 65C22
000000r 2               .struct VIA1                    ; Versatile Interface Adapter
000000r 2                       .org    $9F60
000000r 2                 PRB   .byte                   ; ROM bank, IEC  (Port Register B)
000000r 2                 PRA   .byte                   ; RAM bank  (Port Register A)
000000r 2                 DDRB  .byte                   ; (Data Direction Register B)
000000r 2                 DDRA  .byte                   ; (Data Direction Register A)
000000r 2                 T1    .word                   ; (Timer 1)
000000r 2                 T1L   .word                   ; (Timer 1 Latch)
000000r 2                 T2    .word                   ; (Timer 2)
000000r 2                 SR    .byte                   ; (Shift Register)
000000r 2                 ACR   .byte                   ; (Auxiliary Control Register)
000000r 2                 PCR   .byte                   ; (Peripheral Control Register)
000000r 2                 IFR   .byte                   ; (Interrupt Flags Register)
000000r 2                 IER   .byte                   ; (Interrupt Enable Register)
000000r 2                 PRA2  .byte                   ; RAM bank  (Port Register A without handshaking)
000000r 2               .endstruct
000000r 2               
000000r 2               ; 65C22
000000r 2               .struct VIA2
000000r 2                       .org    $9F70
000000r 2                 PRB   .byte                   ; Mouse communication ?
000000r 2                 PRA   .byte                   ; NES controller communication
000000r 2                 DDRB  .byte
000000r 2                 DDRA  .byte
000000r 2                 T1    .word
000000r 2                 T1L   .word
000000r 2                 T2    .word
000000r 2                 SR    .byte
000000r 2                 ACR   .byte
000000r 2                 PCR   .byte
000000r 2                 IFR   .byte
000000r 2                 IER   .byte
000000r 2                 PRA2  .byte
000000r 2               .endstruct
000000r 2               
000000r 2               ; Real-Time Clock
000000r 2               
000000r 2               ; X16 Emulator device
000000r 2               ; This device doesn't exist on the real machine.
000000r 2               .struct EMULATOR
000000r 2                               .org    $9FB0
000000r 2                 DEBUG         .byte           ; Boolean: debugging enabled
000000r 2                 VERALOG       .byte           ; Boolean: log VERA activity
000000r 2                 KEYBOARDLOG   .byte           ; Boolean: log keyboard data
000000r 2                 ECHO          .byte           ; Type of echo that's enabled
000000r 2                 SAVEXIT       .byte           ; Boolean: save on exit
000000r 2                 GIFREC        .byte           ; Method of recording GIF movie
000000r 2                               .org    $9FBD
000000r 2                 KEYMAP        .byte           ; Current keyboard layout number (Read-Only)
000000r 2                 DETECT        .byte   2       ; If is "16" string, then running on emulator (RO)
000000r 2               .endstruct
000000r 2               
000000r 2               ; ---------------------------------------------------------------------------
000000r 2               ; Banked RAM and ROM
000000r 2               
000000r 2               KEY_COUNT       := $A00A        ; (bank 0) Number of keys in input buffer
000000r 2               TIMER           := $A037        ; (bank 0) 60 Hz. timer (3 bytes, big-endian)
000000r 2               
000000r 2               .struct BANK
000000r 2                       .org    $A000
000000r 2                 RAM   .res    $2000           ; 8 Kibibyte window into 512 Kibibytes or 2048 Kibibytes
000000r 2                 ROM   .res    $4000           ; 16 Kibibyte window into 128 Kibibytes
000000r 2               .endstruct
000000r 2               
000000r 1               .include "cbm_kernal.inc"
000000r 2               ;
000000r 2               ; Olli Savia <ops@iki.fi>
000000r 2               ; Greg King
000000r 2               ;
000000r 2               ; Commodore-compatibles Kernal functions
000000r 2               ;
000000r 2               
000000r 2               .if .def(__CX16__)
000000r 2                 ; CX16 extended jump table
000000r 2                 ENTROPY_GET                   := $FECF
000000r 2                 KEYBRD_BUF_PUT                := $FED2
000000r 2                 CONSOLE_SET_PAGE_MSG          := $FED5
000000r 2                 CONSOLE_PUT_IMAGE             := $FED8
000000r 2                 CONSOLE_INIT                  := $FEDB
000000r 2                 CONSOLE_PUT_CHAR              := $FEDE
000000r 2                 CONSOLE_GET_CHAR              := $FEE1
000000r 2                 MEMORY_FILL                   := $FEE4
000000r 2                 MEMORY_COPY                   := $FEE7
000000r 2                 MEMORY_CRC                    := $FEEA
000000r 2                 MEMORY_DECOMPRESS             := $FEED
000000r 2                 SPRITE_SET_IMAGE              := $FEF0
000000r 2                 SPRITE_SET_POSITION           := $FEF3
000000r 2                 FB_INIT                       := $FEF6
000000r 2                 FB_GET_INFO                   := $FEF9
000000r 2                 FB_SET_PALETTE                := $FEFC
000000r 2                 FB_CURSOR_POSITION            := $FEFF
000000r 2                 FB_CURSOR_NEXT_LINE           := $FF02
000000r 2                 FB_GET_PIXEL                  := $FF05
000000r 2                 FB_GET_PIXELS                 := $FF08
000000r 2                 FB_SET_PIXEL                  := $FF0B
000000r 2                 FB_SET_PIXELS                 := $FF0E
000000r 2                 FB_SET_8_PIXELS               := $FF11
000000r 2                 FB_SET_8_PIXELS_OPAQUE        := $FF14
000000r 2                 FB_FILL_PIXELS                := $FF17
000000r 2                 FB_FILTER_PIXELS              := $FF1A
000000r 2                 FB_MOVE_PIXELS                := $FF1D
000000r 2                 GRAPH_INIT                    := $FF20
000000r 2                 GRAPH_CLEAR                   := $FF23
000000r 2                 GRAPH_SET_WINDOW              := $FF26
000000r 2                 GRAPH_SET_COLORS              := $FF29
000000r 2                 GRAPH_DRAW_LINE               := $FF2C
000000r 2                 GRAPH_DRAW_RECT               := $FF2F
000000r 2                 GRAPH_MOVE_RECT               := $FF32
000000r 2                 GRAPH_DRAW_OVAL               := $FF35
000000r 2                 GRAPH_DRAW_IMAGE              := $FF38
000000r 2                 GRAPH_SET_FONT                := $FF3B
000000r 2                 GRAPH_GET_CHAR_SIZE           := $FF3E
000000r 2                 GRAPH_PUT_CHAR                := $FF41
000000r 2                 RESTORE_BASIC                 := $FF47
000000r 2                 CLOCK_SET_DATE_TIME           := $FF4D
000000r 2                 CLOCK_GET_DATE_TIME           := $FF50
000000r 2                 JOYSTICK_SCAN                 := $FF53
000000r 2                 JOYSTICK_GET                  := $FF56
000000r 2                 SCREEN_SET_MODE               := $FF5F
000000r 2                 SCREEN_SET_CHARSET            := $FF62
000000r 2                 MOUSE_CONFIG                  := $FF68
000000r 2                 MOUSE_GET                     := $FF6B
000000r 2               .endif
000000r 2               
000000r 2               .if .def(__C128__)
000000r 2                 ; C128 extended jump table
000000r 2                 C64MODE      := $FF4D
000000r 2                 SWAPPER      := $FF5F
000000r 2                 SETBNK       := $FF68
000000r 2               .endif
000000r 2               
000000r 2               .if .def(__C128__) || .def(__CX16__)
000000r 2                 ; Extended jump table
000000r 2                 CLSALL       := $FF4A
000000r 2                 LKUPLA       := $FF59
000000r 2                 LKUPSA       := $FF5C
000000r 2                 PFKEY        := $FF65
000000r 2                 JSRFAR       := $FF6E
000000r 2                 INDFET       := $FF74
000000r 2                 INDSTA       := $FF77
000000r 2                 INDCMP       := $FF7A
000000r 2                 PRIMM        := $FF7D
000000r 2               .endif
000000r 2               
000000r 2               .if .def(__C64__) || .def(__C128__) || .def(__C16__) || .def(__CX16__)
000000r 2                 CINT         := $FF81
000000r 2                 IOINIT       := $FF84
000000r 2                 RAMTAS       := $FF87
000000r 2               .elseif .def(__VIC20__)
000000r 2                 CINT         := $E518         ; No entries are in the Kernal jump table of the VIC-20 for these three (3) functions.
000000r 2                 IOINIT       := $FDF9         ; The entries for these functions have been set to point directly to the functions
000000r 2                 RAMTAS       := $FD8D         ; in the Kernal, to maintain compatibility with the other Commodore platforms.
000000r 2               .elseif .def(__CBM510__) || .def(__CBM610__)
000000r 2                 IOINIT       := $FF7B
000000r 2                 CINT         := $FF7E
000000r 2               .endif
000000r 2               
000000r 2               .if .def(__VIC20__) || .def(__C64__) || .def(__C128__) || .def(__C16__) || .def(__CX16__)
000000r 2                 RESTOR       := $FF8A
000000r 2                 VECTOR       := $FF8D
000000r 2               .elseif .def(__CBM510__) || .def(__CBM610__)
000000r 2                 VECTOR       := $FF84
000000r 2                 RESTOR       := $FF87
000000r 2               .endif
000000r 2               
000000r 2               .if .def(__CBM510__) || .def(__CBM610__) || .def(__VIC20__) || .def(__C64__) || .def(__C128__) || .def(__C16__) || .def(__CX16__)
000000r 2                 SETMSG       := $FF90
000000r 2                 SECOND       := $FF93
000000r 2                 TKSA         := $FF96
000000r 2                 MEMTOP       := $FF99
000000r 2                 MEMBOT       := $FF9C
000000r 2                 SCNKEY       := $FF9F
000000r 2                 SETTMO       := $FFA2
000000r 2                 ACPTR        := $FFA5
000000r 2                 CIOUT        := $FFA8
000000r 2                 UNTLK        := $FFAB
000000r 2                 UNLSN        := $FFAE
000000r 2                 LISTEN       := $FFB1
000000r 2                 TALK         := $FFB4
000000r 2                 READST       := $FFB7
000000r 2                 SETLFS       := $FFBA
000000r 2                 SETNAM       := $FFBD
000000r 2                 OPEN         := $FFC0
000000r 2                 CLOSE        := $FFC3
000000r 2               .endif
000000r 2               
000000r 2               ; Available on all platforms including PET
000000r 2               CHKIN          := $FFC6
000000r 2               CKOUT          := $FFC9
000000r 2               CHKOUT         := $FFC9
000000r 2               CLRCH          := $FFCC
000000r 2               CLRCHN         := $FFCC
000000r 2               BASIN          := $FFCF
000000r 2               CHRIN          := $FFCF
000000r 2               BSOUT          := $FFD2
000000r 2               CHROUT         := $FFD2
000000r 2               
000000r 2               .if .def(__CBM510__) || .def(__CBM610__) || .def(__VIC20__) || .def(__C64__) || .def(__C128__) || .def(__C16__) || .def(__CX16__)
000000r 2                 LOAD         := $FFD5
000000r 2                 SAVE         := $FFD8
000000r 2                 SETTIM       := $FFDB
000000r 2                 RDTIM        := $FFDE
000000r 2               .endif
000000r 2               
000000r 2               ; Available on all platforms including PET
000000r 2               STOP           := $FFE1
000000r 2               GETIN          := $FFE4
000000r 2               CLALL          := $FFE7
000000r 2               UDTIM          := $FFEA
000000r 2               
000000r 2               .if .def(__CBM510__) || .def(__CBM610__) || .def(__VIC20__) || .def(__C64__) || .def(__C128__) || .def(__C16__) || .def(__CX16__)
000000r 2                 SCREEN       := $FFED
000000r 2                 PLOT         := $FFF0
000000r 2                 IOBASE       := $FFF3
000000r 2               .endif
000000r 2               
000000r 2               ; ---------------------------------------------------------------------------
000000r 2               ; Kernal routines, direct entries
000000r 2               ;
000000r 2               ; Unlike the above, these are not standard functions with entries in the jump
000000r 2               ; table. They do not exist in all Kernals, and where they do the entry point is
000000r 2               ; specific to that particular machine and possibly even Kernal version.
000000r 2               ;
000000r 2               ; This list is not comprehensive: missing items for particular machines
000000r 2               ; should be added as needed.
000000r 2               ;
000000r 2               ; UPDCRAMPTR: Updates the color RAM pointer to match the screen RAM pointer.
000000r 2               ;
000000r 2               
000000r 2               .if .def(__VIC20__)
000000r 2                 CLRSCR       := $E55F
000000r 2                 KBDREAD      := $E5CF
000000r 2                 UPDCRAMPTR   := $EAB2
000000r 2               .elseif .def(__C64__)
000000r 2                 CLRSCR       := $E544
000000r 2                 KBDREAD      := $E5B4
000000r 2                 NMIEXIT      := $FEBC
000000r 2                 UPDCRAMPTR   := $EA24
000000r 2               .elseif .def(__C128__)
000000r 2                 CLRSCR       := $C142
000000r 2                 KBDREAD      := $C006
000000r 2                 NMIEXIT      := $FF33
000000r 2                 NEWLINE      := $C363
000000r 2                 PRINT        := $C322
000000r 2                 CURS_SET     := $CD57
000000r 2                 CURS_ON      := $CD6F
000000r 2                 CURS_OFF     := $CD9F
000000r 2               .elseif .def(__C16__)
000000r 2                 CLRSCR       := $D88B
000000r 2                 KBDREAD      := $D8C1
000000r 2               .endif
000000r 2               
000000r 1               
000000r 1               usrpok          = $0311                ; put handler addr here
000000r 1               golden          = $0400                ; where we install it
000000r 1               GETADR          = $fe0c                ; parse float usr() arg into int in YA
000000r 1               
000000r 1               ; main routine copies the sort routine into golden RAM and sets the USR vector
000000r 1               ; to point to it.
000000r 1               main:
000000r 1  A9 rr                        lda #<copy
000002r 1  85 02                        sta gREG::r0L
000004r 1  A9 rr                        lda #>copy
000006r 1  85 03                        sta gREG::r0H
000008r 1  A9 00                        lda #<golden
00000Ar 1  85 04                        sta gREG::r1L
00000Cr 1  A9 04                        lda #>golden
00000Er 1  85 05                        sta gREG::r1H
000010r 1  A9 56                        lda #<end_code
000012r 1  38                           sec
000013r 1  E9 00                        sbc #<start_code
000015r 1  85 06                        sta gREG::r2L
000017r 1  A9 05                        lda #>end_code
000019r 1  E9 04                        sbc #>start_code
00001Br 1  85 07                        sta gREG::r2H
00001Dr 1  20 E7 FE                     jsr MEMORY_COPY
000020r 1  A9 00                        lda #<golden
000022r 1  8D 11 03                     sta usrpok
000025r 1  A9 04                        lda #>golden
000027r 1  8D 12 03                     sta usrpok+1
00002Ar 1  60                           rts
00002Br 1               
00002Br 1               .segment "ZEROPAGE"
000000r 1  xx xx        ptr:            .res 2                 ; generic utility pointer
000002r 1  xx xx        base:           .res 2                 ; address of basic array
000004r 1  xx xx        count:          .res 2                 ; number of elements
000006r 1  xx           g:              .res 1                 ; current index into gaps table
000007r 1  xx xx        gap:            .res 2                 ; current gap (gaps[g])
000009r 1  xx xx        i:              .res 2                 ; current index in outer loop
00000Br 1  xx xx        i_addr:         .res 2                 ; address of a[i]
00000Dr 1  xx xx        j:              .res 2                 ; current index in inner loop
00000Fr 1  xx xx        j_addr:         .res 2                 ; address of a[j]
000011r 1  xx xx        k:              .res 2                 ; k = j - gap
000013r 1  xx xx        k_addr:         .res 2                 ; address of a[k]
000015r 1               
000015r 1               ; 3-byte string descriptors: length + address of first char
000015r 1  xx xx xx     temp1:          .res 3                 ; temporary string descriptor 1
000018r 1  xx xx xx     temp2:          .res 3                 ; temporary string descriptor 2
00001Br 1               
00001Br 1               .segment "CODE"
00002Br 1               copy:                                  ;  copy starting here
00002Br 1               .org golden                            ;  assemble for here
000400  1  4C 13 04     start_code:     jmp sort
000403  1               
000403  1               ; Marcin Ciura's gap sequence for Shell's sort
000403  1  BD 02 2D 01  gaps:           .word 701, 301, 132, 57, 23, 10, 4, 1
000407  1  84 00 39 00  
00040B  1  17 00 0A 00  
000413  1               
000413  1               sort:           ; get array base address (USR parameter)
000413  1  20 0C FE                     jsr GETADR
000416  1  85 rr                        sta base+1
000418  1  84 rr                        sty base
00041A  1               
00041A  1                               ; subtract 2 to get address where size is stored
00041A  1  98                           tya
00041B  1  38                           sec
00041C  1  E9 02                        sbc #$02
00041E  1  85 rr                        sta ptr
000420  1  A5 rr                        lda base+1
000422  1  E9 00                        sbc #$00
000424  1  85 rr                        sta ptr+1
000426  1               
000426  1                               ; read the size (which is stored big-endian)
000426  1  A0 00                        ldy #$00
000428  1  B1 rr                        lda (ptr),y
00042A  1  85 rr                        sta count+1
00042C  1  C8                           iny
00042D  1  B1 rr                        lda (ptr),y
00042F  1  85 rr                        sta count
000431  1               
000431  1               
000431  1               ; outermost loop:  g=0
000431  1  64 rr                        stz g
000433  1               
000433  1               ; gap = gaps[g]
000433  1  A5 rr        outer_loop:     lda g
000435  1  0A                           asl
000436  1  AA                           tax
000437  1  BD 03 04                     lda gaps, x
00043A  1  85 rr                        sta gap
00043C  1  E8                           inx
00043D  1  BD 03 04                     lda gaps,x
000440  1  85 rr                        sta gap+1
000442  1               
000442  1               ; for i in gap to count-1
000442  1  A5 rr                        lda gap
000444  1  85 rr                        sta i
000446  1  A5 rr                        lda gap+1
000448  1  85 rr                        sta i+1
00044A  1               
00044A  1  A5 rr        middle_loop:    lda i+1
00044C  1  C5 rr                        cmp count+1
00044E  1  90 0B                        bcc middle_body
000450  1  D0 06                        bne j_middle_done
000452  1  A5 rr                        lda i
000454  1  C5 rr                        cmp count
000456  1  90 03                        bcc middle_body
000458  1               
000458  1  4C 32 05     j_middle_done:  jmp middle_done
00045B  1               
00045B  1               middle_body:    ; compute the address of the i'th element
00045B  1  A5 rr                        lda base
00045D  1  85 rr                        sta i_addr
00045F  1  A5 rr                        lda base+1
000461  1  85 rr                        sta i_addr+1
000463  1  A2 03                        ldx #$03
000465  1               
000465  1  A5 rr        add_loop_i:     lda i_addr
000467  1  18                           clc
000468  1  65 rr                        adc i
00046A  1  85 rr                        sta i_addr
00046C  1  A5 rr                        lda i_addr+1
00046E  1  65 rr                        adc i+1
000470  1  85 rr                        sta i_addr+1
000472  1  CA                           dex
000473  1  D0 F0                        bne add_loop_i
000475  1               
000475  1                               ; save that element in temp1
000475  1  A0 00                        ldy #0
000477  1  B1 rr        copy_loop_i:    lda (i_addr),y
000479  1  99 rr rr                     sta temp1,y
00047C  1  C8                           iny
00047D  1  C0 03                        cpy #$03
00047F  1  90 F6                        bcc copy_loop_i
000481  1               
000481  1  A5 rr                        lda i
000483  1  85 rr                        sta j
000485  1  A5 rr                        lda i+1
000487  1  85 rr                        sta j+1
000489  1               
000489  1               ; inner loop: while j >= gap
000489  1  A5 rr        inner_loop:     lda j+1
00048B  1  C5 rr                        cmp gap+1
00048D  1  90 74                        bcc inner_done
00048F  1  D0 06                        bne inner_body
000491  1  A5 rr                        lda j
000493  1  C5 rr                        cmp gap
000495  1  90 6C                        bcc inner_done
000497  1               
000497  1  A5 rr        inner_body:     lda j                  ; k = j - gap
000499  1  38                           sec
00049A  1  E5 rr                        sbc gap
00049C  1  85 rr                        sta k
00049E  1  A5 rr                        lda j+1
0004A0  1  E5 rr                        sbc gap+1
0004A2  1  85 rr                        sta k+1
0004A4  1               
0004A4  1                               ; compute the address of the k'th element
0004A4  1  A5 rr                        lda base
0004A6  1  85 rr                        sta k_addr
0004A8  1  A5 rr                        lda base+1
0004AA  1  85 rr                        sta k_addr+1
0004AC  1  A2 03                        ldx #$03
0004AE  1               
0004AE  1  A5 rr        add_loop_k:     lda k_addr
0004B0  1  18                           clc
0004B1  1  65 rr                        adc k
0004B3  1  85 rr                        sta k_addr
0004B5  1  A5 rr                        lda k_addr+1
0004B7  1  65 rr                        adc k+1
0004B9  1  85 rr                        sta k_addr+1
0004BB  1  CA                           dex
0004BC  1  D0 F0                        bne add_loop_k
0004BE  1               
0004BE  1  A0 00                        ldy #$00
0004C0  1  B1 rr        copy_loop_k:    lda (k_addr),y
0004C2  1  99 rr rr                     sta temp2,y
0004C5  1  C8                           iny
0004C6  1  C0 03                        cpy #$03
0004C8  1  90 F6                        bcc copy_loop_k
0004CA  1               
0004CA  1  20 3E 05                     jsr compare
0004CD  1  B0 34                        bcs inner_done
0004CF  1               
0004CF  1               ; to copy a[k] to a[j], we need the address of a[j]
0004CF  1  A5 rr                        lda base
0004D1  1  85 rr                        sta j_addr
0004D3  1  A5 rr                        lda base+1
0004D5  1  85 rr                        sta j_addr+1
0004D7  1  A2 03                        ldx #$03
0004D9  1               
0004D9  1  A5 rr        add_loop_j:     lda j_addr
0004DB  1  18                           clc
0004DC  1  65 rr                        adc j
0004DE  1  85 rr                        sta j_addr
0004E0  1  A5 rr                        lda j_addr+1
0004E2  1  65 rr                        adc j+1
0004E4  1  85 rr                        sta j_addr+1
0004E6  1  CA                           dex
0004E7  1  D0 F0                        bne add_loop_j
0004E9  1               
0004E9  1               ; do the copy a[j] = a[k]
0004E9  1  A0 00                        ldy #$00
0004EB  1  B1 rr        copy_loop_j:    lda (k_addr),y
0004ED  1  91 rr                        sta (j_addr),y
0004EF  1  C8                           iny
0004F0  1  C0 03                        cpy #$03
0004F2  1  90 F7                        bcc copy_loop_j
0004F4  1               
0004F4  1               ; decrement j by gap and loop
0004F4  1  A5 rr                        lda j
0004F6  1  38                           sec
0004F7  1  E5 rr                        sbc gap
0004F9  1  85 rr                        sta j
0004FB  1  A5 rr                        lda j+1
0004FD  1  E5 rr                        sbc gap+1
0004FF  1  85 rr                        sta j+1
000501  1  80 86                        bra inner_loop
000503  1               
000503  1               inner_done:
000503  1               
000503  1               ; finally, copy temp (our original a[i]) to a[j]. That means we need the
000503  1               ; address of a[j], which we might not have yet because the loop body may not
000503  1               ; have executed even once.  So we (again) compute the address of the j'th
000503  1               ; element:
000503  1  A5 rr                        lda base
000505  1  85 rr                        sta j_addr
000507  1  A5 rr                        lda base+1
000509  1  85 rr                        sta j_addr+1
00050B  1  A2 03                        ldx #$03
00050D  1               
00050D  1  A5 rr        add_loop_j2:    lda j_addr
00050F  1  18                           clc
000510  1  65 rr                        adc j
000512  1  85 rr                        sta j_addr
000514  1  A5 rr                        lda j_addr+1
000516  1  65 rr                        adc j+1
000518  1  85 rr                        sta j_addr+1
00051A  1  CA                           dex
00051B  1  D0 F0                        bne add_loop_j2
00051D  1               
00051D  1               ; and do the copy
00051D  1  A0 00                        ldy #$00
00051F  1  B9 rr rr     copy_loop_j2:   lda temp1,y
000522  1  91 rr                        sta (j_addr),y
000524  1  C8                           iny
000525  1  C0 03                        cpy #$03
000527  1  90 F6                        bcc copy_loop_j2
000529  1               
000529  1  E6 rr                        inc i
00052B  1  D0 02                        bne j_middle_loop
00052D  1  E6 rr                        inc i+1
00052F  1  4C 4A 04     j_middle_loop:  jmp middle_loop
000532  1               
000532  1               ; if the gap isn't already down to 1, go back and repeat for the next gap size
000532  1  A5 rr        middle_done:    lda gap
000534  1  C9 01                        cmp #$01
000536  1  F0 05                        beq all_done
000538  1  E6 rr                        inc g
00053A  1  4C 33 04                     jmp outer_loop
00053D  1               
00053D  1  60           all_done:       rts
00053E  1               
00053E  1               ; compare the two strings whose descriptors are in temp1 and temp2.
00053E  1               ; set flags as with CMP, with temp1 string treated as the accumulator:
00053E  1               ;   Z set if strings are equal
00053E  1               ;   Carry clear if string in temp1 sorts before string in temp2
00053E  1               ;   Carry set if strings are equal or temp1 sorts after temp2
00053E  1  A0 00        compare:        ldy #$00
000540  1               
000540  1  C4 rr        compare_loop:   cpy temp1
000542  1  B0 0D                        bcs compare_done
000544  1  C4 rr                        cpy temp2
000546  1  B0 09                        bcs compare_done
000548  1  B1 rr                        lda (temp1+1),y
00054A  1  D1 rr                        cmp (temp2+1),y
00054C  1  D0 07                        bne not_equal
00054E  1  C8                           iny
00054F  1  D0 EF                        bne compare_loop
000551  1               
000551  1  A4 rr        compare_done:   ldy temp1
000553  1  C4 rr                        cpy temp2
000555  1  60           not_equal:      rts
000556  1               
000556  1               end_code:
000556  1               
