import argh
import math
import rules
import sys
import time
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

tk = tkinter.Tk()
quitting = False
def on_close():
    global quitting
    quitting = True

tk.protocol('WM_DELETE_WINDOW', on_close)

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

    start = time.time()
    generation = 0
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

    done = False
    while not quitting and not done:
        buffer = {}
        to_scan = set()
        done = True

        for coords, state in states.items():
            x, y = [int(v) for v in coords.split(',')]
            for d in range(-1,2):
                to_scan.add(f'{x+d},{y}')
                to_scan.add(f'{x},{y+d}')

        min_x = min_y = math.inf
        max_x = max_y = -math.inf
        for coords in to_scan:
            self = states.get(coords, 0)
            x, y = [int(v) for v in coords.split(',')]
            n = states.get(f'{x},{y-1}',0)
            e = states.get(f'{x+1},{y}',0)
            s = states.get(f'{x},{y+1}',0)
            w = states.get(f'{x-1},{y}',0)
            key = f'{self}{n}{e}{s}{w}'
            if key in transition_table:
                new = transition_table[key]
                if (new != self and 
                    y >=corner_y and y < corner_y + cell_height and
                    x >=corner_x and x < corner_x + cell_width):
                    done = False
            else:
                new = self
            if new:
                if x < min_x: min_x = x 
                if x > max_x: max_x = x 
                if y < min_y: min_y = y 
                if y > max_y: max_y = y 
                buffer[coords] = new

        states = buffer
        for i in range(cell_height):
            y = i + corner_y
            for j in range(cell_width):
                x = j + corner_x
                state = states.get(f'{x},{y}', 0)
                color = state_colors[state]
                c.itemconfigure(items[i][j], outline=color, fill=color)

        generation += 1
        tk.update()


    end = time.time()
    print(f'Finished in {end - start} seconds after {generation} generations')
    print(f'Final tally: {len(states)} cells with nonzero states')
    print(f'Bounding box: {min_x},{min_y} to {max_x},{max_y}')

    while not quitting:
        tk.update()

    tk.destroy()

if __name__ == '__main__':
    argh.dispatch_command(main)

