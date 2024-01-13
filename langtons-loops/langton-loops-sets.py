import argh
import rules
import sys
import tkinter

cell_size     = 4
canvas_width  = 320
canvas_height = 240

state_colors = [ 'black',  'blue',   'red',   'green',
                 'yellow', 'magenta','white', 'cyan' ]

color_states = { color: i for i, color in enumerate(state_colors) }

loop = [ [ 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0 ],
         [ 0, 2, 1, 7, 0, 1, 4, 0, 1, 4, 2, 0, 0, 0, 0, 0 ],
         [ 0, 2, 0, 2, 2, 2, 2, 2, 2, 0, 2, 0, 0, 0, 0, 0 ],
         [ 0, 2, 7, 2, 0, 0, 0, 0, 2, 1, 2, 0, 0, 0, 0, 0 ],
         [ 0, 2, 1, 2, 0, 0, 0, 0, 2, 1, 2, 0, 0, 0, 0, 0 ],
         [ 0, 2, 0, 2, 0, 0, 0, 0, 2, 1, 2, 0, 0, 0, 0, 0 ],
         [ 0, 2, 7, 2, 0, 0, 0, 0, 2, 1, 2, 0, 0, 0, 0, 0 ],
         [ 0, 2, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 0 ],
         [ 0, 2, 0, 7, 1, 0, 7, 1, 0, 7, 1, 1, 1, 1, 1, 2 ],
         [ 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0 ] ]

transition_table = {}

def main():
    cell_width  = canvas_width  // cell_size
    cell_height = canvas_height // cell_size 
    corner_x = -32
    corner_y = -25
    items = []
    states = {}
    for y, row in enumerate(loop):
        items.append([])
        for x, state in enumerate(row):
            states[f'{x},{y}'] = state

    tk = tkinter.Tk()
    c = tkinter.Canvas(tk, width=canvas_width, height=canvas_height, background='black')
    items = []
    for i in range(cell_height):
        y = i + corner_y
        items.append([])
        for j in range(cell_width):
            x = i + corner_x
            state = states.get(f'{x},{y}',0)
            item = c.create_rectangle(j*cell_size, i*cell_size,
                                      (j+1)*cell_size-1, (i+1)*cell_size-1,
                                      outline=state_colors[state],
                                      fill=state_colors[state])
            items[i].append(item)

    for rule in rules.rules:
        self, *neighbors = [s for s in rule[0:-1]]
        for r in range(4):
            key = "".join([self, neighbors[r%4], neighbors[(r+1)%4],
                                 neighbors[(r+2)%4], neighbors[(r+3)%4]])
            transition_table[key] = int(rule[-1:])

    c.pack()

    while True:
        buffer = {}
        to_scan = set()
        for coords, state in states.items():
            x, y = [int(v) for v in coords.split(',')]
            for d in range(-1,2):
                to_scan.add(f'{x+d},{y}')
                to_scan.add(f'{x},{y+d}')

        for coords in to_scan:
            self = states.get(coords, 0)
            x, y = [int(v) for v in coords.split(',')]
            n = states.get(f'{x},{y-1}',0)
            e = states.get(f'{x+1},{y}',0)
            s = states.get(f'{x},{y+1}',0)
            w = states.get(f'{x-1},{y}',0)
            key = f'{self}{n}{e}{s}{w}'
            if key in transition_table:
                buffer[coords] = transition_table[key]
            else:
                buffer[coords] = self

        states = buffer
        for i in range(cell_height):
            y = i + corner_y
            for j in range(cell_width):
                x = j + corner_x
                state = states.get(f'{x},{y}', 0)
                color = state_colors[state]
                c.itemconfigure(items[i][j], outline=color, fill=color)

        tk.update()

if __name__ == '__main__':
    argh.dispatch_command(main)


#    sub set_state(ubyte x, ubyte y, ubyte state) {
#        gfx2.fillrect(x as uword * cell_size, y as uword * cell_size,
#                      cell_size, cell_size, state_colors[state])
#    }
#
#    sub get_state(ubyte x, ubyte y) -> ubyte {
#        uword pixel_x = x as uword * cell_size + cell_size>>1
#        uword pixel_y = y as uword * cell_size + cell_size>>1
#        return color_states[gfx2.pget(pixel_x, pixel_y)]
#    }
#
#    sub set_offscreen_state(ubyte x, ubyte y, ubyte state) {
#        @(new_grid + y as uword * grid_width as uword + x as uword) = state
#    }
#
#    sub get_offscreen_state(ubyte x, ubyte y) -> ubyte {
#        return @(new_grid + y as uword * grid_width as uword + x as uword)
#    }
#
#    sub copy_grid() {
#        ubyte x, y
#        for y in 0 to grid_height - 1 {
#            for x in 0 to grid_width - 1 {
#                set_state(x, y, get_offscreen_state(x, y))
#            }
#        }
#    }
#
#    sub start() {
#        ubyte x, y, i, key
#        ubyte[6] state_string
#        uword rule
#        ubyte new_state
#        bool found
#
#        gfx2.screen_mode(1)     ; 320 x 240 x 8bpp
#        gfx2.clear_screen(0)
#        i = 0
#        for y in 47 to 56 {
#            for x in 2 to 17 {
#                set_state(x, y, loop[i])
#                i += 1
#            }
#        }
#        state_string[5] = 0
#        do {
#            for y in 1 to grid_height - 2 {
#                emudbg.console_value1(y)
#                for x in 1 to grid_width - 2 {
#                   state_string[0] = '0' + get_state(x, y)
#                   state_string[1] = '0' + get_state(x, y-1)
#                   state_string[2] = '0' + get_state(x+1, y)
#                   state_string[3] = '0' + get_state(x, y+1)
#                   state_string[4] = '0' + get_state(x-1, y)
#                   found = false
#                   for i in 0 to len(langton.rules) {
#                       rule = &langton.rules[i]
#                       new_state = rule[5] - '0'
#                       rule[5] = 0
#                       if string.compare(state_string, rule) == 0 {
#                           set_offscreen_state(x, y, new_state)
#                           found = true
#                       }
#                       rule[5] = new_state + '0'
#                       if found { break }
#                   }
#                   if not found {
#                       set_offscreen_state(x, y, get_state(x, y))
#                   }
#                }
#            }   
#            copy_grid()
#            key = cbm.GETIN()
#        } until key
#    }
#}
