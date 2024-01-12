%import emudbg
%import gfx2
%import rules
%import colors
%import string
%import syslib

main {
    const uword cell_size = 4
    const ubyte grid_width  = 320 / cell_size
    const ubyte grid_height = 240 / cell_size
    const uword new_grid = $a000

    ubyte[] state_colors = [ color.attr.BLACK, color.attr.BLUE,    color.attr.RED,
                             color.attr.GREEN, color.attr.YELLOW,  color.attr.MAGENTA,
                             color.attr.WHITE, color.attr.CYAN  ]
    ubyte[] color_states = [ 0, 6, 2, 7, 5, 3, 1, 4 ]

    ubyte[] loop    = [ 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 
                        0, 2, 1, 7, 0, 1, 4, 0, 1, 4, 2, 0, 0, 0, 0, 0,
                        0, 2, 0, 2, 2, 2, 2, 2, 2, 0, 2, 0, 0, 0, 0, 0,
                        0, 2, 7, 2, 0, 0, 0, 0, 2, 1, 2, 0, 0, 0, 0, 0,
                        0, 2, 1, 2, 0, 0, 0, 0, 2, 1, 2, 0, 0, 0, 0, 0,
                        0, 2, 0, 2, 0, 0, 0, 0, 2, 1, 2, 0, 0, 0, 0, 0,
                        0, 2, 7, 2, 0, 0, 0, 0, 2, 1, 2, 0, 0, 0, 0, 0,
                        0, 2, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 0,
                        0, 2, 0, 7, 1, 0, 7, 1, 0, 7, 1, 1, 1, 1, 1, 2,
                        0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0 ]


    sub set_state(ubyte x, ubyte y, ubyte state) {
        gfx2.fillrect(x as uword * cell_size, y as uword * cell_size,
                      cell_size, cell_size, state_colors[state])
    }

    sub get_state(ubyte x, ubyte y) -> ubyte {
        uword pixel_x = x as uword * cell_size + cell_size>>1
        uword pixel_y = y as uword * cell_size + cell_size>>1
        return color_states[gfx2.pget(pixel_x, pixel_y)]
    }

    sub set_offscreen_state(ubyte x, ubyte y, ubyte state) {
        @(new_grid + y as uword * grid_width as uword + x as uword) = state
    }

    sub get_offscreen_state(ubyte x, ubyte y) -> ubyte {
        return @(new_grid + y as uword * grid_width as uword + x as uword)
    }

    sub copy_grid() {
        ubyte x, y
        for y in 0 to grid_height - 1 {
            for x in 0 to grid_width - 1 {
                set_state(x, y, get_offscreen_state(x, y))
            }
        }
    }

    sub start() {
        ubyte x, y, i, key
        ubyte[6] state_string
        uword rule
        ubyte new_state
        bool found

        gfx2.screen_mode(1)     ; 320 x 240 x 8bpp
        gfx2.clear_screen(0)
        i = 0
        for y in 47 to 56 {
            for x in 2 to 17 {
                set_state(x, y, loop[i])
                i += 1
            }
        }
        state_string[5] = 0
        do {
            for y in 1 to grid_height - 2 {
                emudbg.console_value1(y)
                for x in 1 to grid_width - 2 {
                   state_string[0] = '0' + get_state(x, y)
                   state_string[1] = '0' + get_state(x, y-1)
                   state_string[2] = '0' + get_state(x+1, y)
                   state_string[3] = '0' + get_state(x, y+1)
                   state_string[4] = '0' + get_state(x-1, y)
                   found = false
                   for i in 0 to len(langton.rules) {
                       rule = &langton.rules[i]
                       new_state = rule[5] - '0'
                       rule[5] = 0
                       if string.compare(state_string, rule) == 0 {
                           set_offscreen_state(x, y, new_state)
                           found = true
                       }
                       rule[5] = new_state + '0'
                       if found { break }
                   }
                   if not found {
                       set_offscreen_state(x, y, get_state(x, y))
                   }
                }
            }   
            copy_grid()
            key = cbm.GETIN()
        } until key
    }
}
