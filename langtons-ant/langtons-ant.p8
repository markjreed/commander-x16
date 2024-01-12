%zeropage basicsafe

%import conv
%import gfx2
%import string
%import syslib
%import textio

main {
    const uword width = 640
    const uword height = 480

    ubyte delay
    ubyte[81] line
    str text_title = "langton's ant"
    str gfx_title  = sc:"langton's ant"
    str stars = "****"
    uword steps  = 0
    ubyte color

    str   status_line = sc:" initial:        current:       from (x:    , y:    )             steps:        "
    bool  status_initialized = false

    word[] dx = [  0, 1, 0, -1 ]
    word[] dy = [ -1, 0, 1,  0 ]
    str[] directions = [ "north", "east", "south", "west" ]
    str[] gfx_directions = [ sc:"north", sc:"east", sc:"south", sc:"west" ]
    ubyte length, left, key, direction
    uword text_x
    str gfx_stars = sc:"****"
    uword ant_x, ant_y

    sub banner(bool bitmap) {

        if not bitmap  {
            txt.color2(2, 1)
            txt.clear_screen()
            txt.chrout($12)
            txt.print(stars)
        } else {
            gfx2.clear_screen(1)
            gfx2.text_charset(2)
            gfx2.fillrect(0, 0, width-1, 8, 2)
            gfx2.text(0, 0, 1, gfx_stars)
            gfx2.text(width-32, 0, 1, gfx_stars)
        }
        text_x = 32
        length = string.length(text_title)
        left = (72 - length)/2
        if not bitmap {
            repeat left { 
                txt.chrout(' ')
            }
            txt.print(text_title)
            repeat 72 - length - left { 
                txt.chrout(' ') 
            }
            txt.print("****")
            txt.nl()
        } else {
            gfx2.text(32 + (left as uword) * 8, 0, 1, gfx_title)
        }
    }

    sub atoi(uword s) -> ubyte {
        ubyte result = 0
        ubyte digit
        while @(s) {
            digit = @(s)
            if digit < '0' or digit > '9' {
                return result
            }
            result = 10 * result + digit - '0'
            s = s + 1
        }
        return result
    }

    sub randomize_grid() {
        for ant_y in height/3 to 2*height/3 {
            for ant_x in width/3 to 2*width/3 {
                if math.rnd() & 1 { gfx2.plot(ant_x, ant_y, 0) }
            }
        }
    }

    sub update_status() {
        if not status_initialized {
            gfx2.fillrect(0, height-8, width-1, 8, 2)
            gfx2.text( 0, height - 8, 1, status_line)
            gfx2.text(80, height - 8, 1, gfx_directions[direction])
            status_initialized = true
        }
        gfx2.fillrect(208, height-8, 40, 8, 2)
        gfx2.text(208, height-8, 1, gfx_directions[direction])

        gfx2.fillrect(208, height-8, 40, 8, 2)
        gfx2.text(208, height-8, 1, gfx_directions[direction])

        conv.str_uw(ant_x)
        gfx2.fillrect(328, height-8, 24, 8, 2)
        gfx2.text(328, height-8, 1, conv.string_out)

        conv.str_uw(ant_y)
        gfx2.fillrect(392, height-8, 24, 8, 2)
        gfx2.text(392, height-8, 1, conv.string_out)

        conv.str_uw(steps)
        gfx2.fillrect(584, height-8, 40, 8, 2)
        gfx2.text(584, height-8, 1, conv.string_out)
    }

    sub start() {
        ; seed RNG from RTC
        void cx16.clock_get_date_time()
        math.rndseed(cx16.r2, cx16.r1)

        banner(false)
        txt.print("steps between status updates (1-255, bigger=faster): ")
        line[txt.input_chars(line)] = 0
        delay = atoi(line)
        if delay < 1 { delay = 64 }
        txt.print("(delay is ")
        txt.print_ub(delay)
        txt.print(")\n\n")
        txt.print("initial direction (nesw, default=random): ")
        direction = 4
        do {
            key = cbm.GETIN()
            when key {
                'n' -> { direction = 0 }
                'e' -> { direction = 1 }
                's' -> { direction = 2 }
                'w' -> { direction = 3 }
                13  -> { direction = math.rnd() % 4 txt.print("randomly ") }
            }
        } until direction < 4
        txt.print(directions[direction])
        txt.print("\n\n")
        txt.print("initial grid (e)mpty or (r)andom (er, default=empty): ")
        do {
            key = cbm.GETIN()
        } until key == 'e' or key == 'r' or key == 13
        gfx2.screen_mode(2)
        banner(true)
        if key == 'r' { randomize_grid() }
        ant_x = width / 2
        ant_y = height / 2
        while ant_x >= 0 and ant_x < width and ant_y >= 8 and ant_y < height-8 {
            color = gfx2.pget(ant_x, ant_y)
            gfx2.plot(ant_x, ant_y, 2)
            if color {
                ; white square, turn right
                direction = (direction + 1) % 4
            } else {
                ; black square, turn left
                direction = (direction + 3) % 4
            }
            gfx2.plot(ant_x, ant_y, 1 - color)
            ant_x = ant_x + dx[direction]
            ant_y = ant_y + dy[direction]
            steps = steps + 1
            if steps % delay == 0 { update_status() }
        }
        update_status()
        key = 0
        do {
            key = cbm.GETIN()
        } until key != 0
        gfx2.screen_mode(0)
        txt.color2(0,1)
        txt.clear_screen()
    }
}
