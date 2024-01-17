%import rules
%import colors
%import conv
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
    ubyte min_i, max_i, min_j, max_j

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
        cx16.memory_fill(new_states, state_size, 0)

        row_offset = (height - loop_height) / 2
        col_offset = (width  - loop_width)  / 2
        min_i = row_offset
        max_i = row_offset + loop_height
        min_j = col_offset
        max_j = col_offset + loop_width
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

    sub next_state(ubyte self, uword neighbors) -> ubyte {
        ubyte k, min_k, r, new, key
        uword min_value, value, rule
        ubyte[6] selector
        bool match

        selector[0]  = self + '0'
        selector[5]  = 0
        min_value = 9999
        for k in 0 to 3 {
            selector[1 +      k  % 4] = neighbors[0] + '0'
            selector[1 + (1 + k) % 4] = neighbors[1] + '0'
            selector[1 + (2 + k) % 4] = neighbors[2] + '0'
            selector[1 + (3 + k) % 4] = neighbors[3] + '0'
            void conv.any2uword(&selector[1])
            if cx16.r15 < min_value {
                min_k = k
                min_value = cx16.r15
            }
        }
        selector[1 +      min_k  % 4] = neighbors[0] + '0'
        selector[1 + (1 + min_k) % 4] = neighbors[1] + '0'
        selector[1 + (2 + min_k) % 4] = neighbors[2] + '0'
        selector[1 + (3 + min_k) % 4] = neighbors[3] + '0'
        for r in 0 to len(langton.rules) {
            rule = langton.rules[r]
            new = rule[5]
            rule[5] = 0
            match = string.compare(selector, rule) == 0
            rule[5] = new
            if match {
                return new - '0'
            }
        }
    }

    sub next_generation() {
        ubyte i, j, self, new
        ubyte[4] neighbors

        if min_i < 2 { min_i = 2 }
        if max_i > height - 3 { max_i = height - 3 }
        if min_j < 2 { min_j = 2 }
        if max_j > width - 3 { max_i = width - 3 }

        cx16.memory_copy(states, new_states, state_size)
        for i in min_i-1 to max_i+1 {
            for j in min_j-1 to max_j+1 {
                 self = get_state(states, i, j)
                 neighbors[0] = get_state(states, i-1, j)
                 neighbors[1] = get_state(states, i, j+1)
                 neighbors[2] = get_state(states, i+1, j)
                 neighbors[3] = get_state(states, i, j-1)
                 new = next_state(self, neighbors)
                 set_state(new_states, i, j, new)
                 if new {
                     if i < min_i { min_i = i }
                     if i > max_i { max_i = i }
                     if j < min_j { min_j = j }
                     if j > max_j { max_j = j }
                 }
             }
         }
         cx16.memory_copy(new_states, states, state_size)
    }

    sub start() {
        ubyte key
        init_state()
        render_state()
        do {
           next_generation()
           key = cbm.GETIN()
           render_state()
        } until key
    }
}
