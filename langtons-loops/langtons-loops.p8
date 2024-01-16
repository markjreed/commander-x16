%import rules
%import colors
%import string
%import textio
%import syslib
%zeropage basicsafe

main {
    const ubyte height        = 60
    const ubyte width         = 80
    const uword states        = $a000
    const uword state_size    = (height as uword) * ((width / 2) as uword)
    const uword new_states    = $a000 + state_size
    const ubyte inverse_space = $a0

    sub get_state(uword buffer, ubyte i, ubyte j) -> ubyte {
        ubyte pair = buffer[(i as uword) * ((width/2) as uword) + ((j/2) as uword)]
        if j & 1 {
            return pair & $0f
        } else {
            return pair >> 4
        }
    }

    sub set_state(uword buffer, ubyte i, ubyte j, ubyte state) {
        uword addr = buffer + (i as uword) * ((width/2) as uword) + ((j/2) as uword)
        if j & 1 {
            @(addr) = (@(addr) & $f0) | (state & $0f)
        } else {
            @(addr) = (@(addr) & $0f) | (state << 4)
        }
    }

    sub init_state() {
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

        const ubyte loop_width = 16
        const ubyte loop_height = len(loop) / loop_width
        ubyte i, j, row_offset, col_offset, state

        cx16.memory_fill(states, state_size, 0)

        row_offset = (height - loop_height) / 2
        col_offset = (width  - loop_width)  / 2
        for i in 0 to loop_height - 1 {
            for j in 0 to loop_width - 1 {
                state = loop[i * loop_width + j]
                set_state(states, i + row_offset, j + col_offset, state)
            }
        }
    }

    sub render_state() {
        ubyte i, j
        ubyte[] state_colors = [
            color.attr.BLACK, color.attr.BLUE,   color.attr.RED,
            color.attr.GREEN, color.attr.YELLOW, color.attr.MAGENTA,
            color.attr.WHITE, color.attr.CYAN
        ]

        for i in 0 to height - 1 {
            for j in 0 to width - 1 {
                txt.setcc(j, i, inverse_space, 
                          state_colors[get_state(states,i,j)])
            }
        }
    }

    sub start() {
        init_state()
        render_state()
    }
}
