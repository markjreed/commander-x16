; Make it rain PETSCII, Matrix-style, on the CX16
; Mark J. Reed, 2023

%import math
%import palette
%import syslib
%import textio
%option no_sysinit
%zeropage basicsafe


main {
    ; the bit in the VERA layer configuration register that toggles 256-color
    ; text mode
    const ubyte T256C = 8

    ; number of colors and names for them
    const ubyte color_range = 3
    const ubyte GREEN  = 0
    const ubyte YELLOW = 1
    const ubyte PURPLE = 2

    ; range of possible speeds for individual drops
    const ubyte speed_range = 4

    ; color gradients from the default palette
    ubyte[] greens   = [ $01, $8f, $88, $8e, $87, $8d, $86, $8c,
                         $85, $8b, $84, $8a, $83, $89, $82, $00 ]
    ubyte[] yellows  = [ $01, $50, $57, $4f, $56, $4e, $55, $4d,
                         $54, $4c, $53, $4b, $52, $4a, $51, $00 ]
    ubyte[] purples  = [ $01, $e3, $dc, $e2, $db, $e1, $da, $e0,
                         $d9, $df, $d8, $de, $d7, $dd, $d6, $00 ]


    ; Y coordinate of the bottom of the drop in each column (1 to height, 0=no drop there)
    ubyte[80] bottom

    ; speed of each drop
    ubyte[80] speed

    ; color of each drop
    ubyte[80] color

    ; a place to save colors from the palette so they can be restored
    uword[256] @split saved_colors

    ; flag indicating whether colors have been saved above or not
    bool saved

    ; dimensions of the screen
    ubyte width, height

    ; ye standard loop control variables
    ubyte i, j, j1, j2, dj

    ; user input
    ubyte key

    ; a clock for managing drop speed
    ubyte ticks

    ; count of columns currently missing drops
    ubyte available

    ; delay between ticks to adjust overall run speed
    ubyte delay  = 1

    ; get screen size from KERNAL
    asmsub get_screen() {
        %asm{{
              jsr cbm.SCREEN
              stx p8v_width
              sty p8v_height
        }}
    }

    ; look up a palette color
    sub get_color(ubyte index) -> uword {
        ubyte low, high
        low  = cx16.vpeek(1, $fa00 + (index as uword << 1))
        high = cx16.vpeek(1, $fa01 + (index as uword << 1))
        return mkword(high, low)
    }

    ; switch to all-green theme
    sub all_green() {
        for i in 0 to len(greens) {
            if not saved {
                saved_colors[yellows[i]] = get_color(yellows[i])
                saved_colors[purples[i]] = get_color(purples[i])
            }
            palette.set_color(yellows[i], get_color(greens[i]))
            palette.set_color(purples[i], get_color(greens[i]))
        }
        saved = true
    }

    ; switch to Mardi Gras theme
    sub mardi_gras() {
        if saved {
            for i in 0 to len(greens) {
                palette.set_color(yellows[i], saved_colors[yellows[i]])
                palette.set_color(purples[i], saved_colors[purples[i]])
            }
        }
    }

    sub start() {
        ; seed RNG from RTC
        void cx16.clock_get_date_time()
        math.rndseed(cx16.r2, cx16.r1)

        ; enable 256-color text mode
        cx16.VERA_L1_CONFIG = (cx16.VERA_L1_CONFIG & ~T256C) | T256C

        ; get screen dimensions - works in non-default resolutions
        get_screen()
        txt.clear_screen()

        ; initialize all drops to offscreen
        for i in 0 to width - 1 {
            bottom[i] = 0
        }

        ; start at time 0
        ticks = 0

        ; default to all green
        all_green()

        do {
           for i in 0 to width - 1 {

               ; update all the drops moving fast enough to move this tick
               if bottom[i] and ticks % speed_range < speed[i] {

                   ; determine the visible portion of the trail
                   j1 = bottom[i]

                   if j1 <= height {
                       ; if the bottom of drop is visible, put a random white character there
                       txt.setcc(i, j1-1, math.rnd()>>1, 1)
                   } else {
                       ; otherwise cut off at the bottom of the screen
                       j1 = height
                   }

                   j2 = j1 - len(greens) + 1
                   if j2 < 1 or j2 >= 96 {
                      j2 = 1
                   }

                   ; color the rest of the trail
                   for j in j2 to j1 {
                       dj = bottom[i] - j
                       if dj >= 128 {
                           dj = 0
                       }
                       if dj >= len(greens) {
                           dj = len(greens) - 1
                       }
                       when color[i] {
                           GREEN  -> txt.setclr(i, j-1, greens[dj])
                           YELLOW -> txt.setclr(i, j-1, yellows[dj])
                           PURPLE -> txt.setclr(i, j-1, purples[dj])
                       }
                   }
                   bottom[i] = bottom[i] + 1

                   ; turn this drop off if it's fallen offscreen
                   if bottom[i] >= height + len(greens) {
                       bottom[i] = 0
                   }
               }
           }

           ; flip a coin to see if we add a new drop
           if math.rnd() < 128 {

               ; pick randomly from the columns not already in use
               available = 0
               for i in 0 to width -1 {
                   if bottom[i] == 0 { available += 1 }
               }
               if available {
                   i = math.rnd() % available
                   for j in 0 to width - 1 {
                       if bottom[j] == 0 {
                           if i==0 {
                               i = j
                               break
                           } else {
                               i -= 1
                           }
                       }
                   }

                   ; start at the top
                   bottom[i] = 1

                   ; assign a random speed and color
                   speed[i] = math.rnd() % speed_range + 1
                   color[i] = math.rnd() % color_range
               }
           }

           ; sleep until next tick
           sys.wait(delay)
           ticks += 1

           ; handle any keypress that came in
           key = cbm.GETIN()
           when key {
               '0' -> { delay=0 key=0 }
               '+' -> { if delay { delay-- } key = 0 }
               '-' -> { if delay < $ff { delay++ } key = 0 }
               'g' -> { all_green() key = 0 }
               'm' -> { mardi_gras() key = 0 }
           }
        } until key != 0

        ; clean up
        txt.color2(5,0)
        txt.clear_screen()
        mardi_gras()
    }
}
