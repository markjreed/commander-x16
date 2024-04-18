%zeropage basicsafe
%import datepicker
%import dates
%import floats
%import graphics
%import string
%import textio
%import tui

main {
    ubyte[] cycle_lengths = [ 23, 28, 33 ]
    str[]   cycle_names   = [ " Physical", " Emotional", " Mental  " ]
    ubyte[] cycle_colors  = [ 2, 4, 6 ]
    const uword chart_x      =   0
    const ubyte chart_y      =  76
    const uword chart_width  = 320
    const ubyte chart_height = 119
    const ubyte chart_zero   = chart_y + chart_height / 2 + 1
    const ubyte chart_max    = chart_zero - chart_y - 4
    const uword day_width    =   8
    const uword day_offset   =  28

    sub today() -> word {
        uword year_month
        uword day_hour
        uword min_sec
        uword jiffy_weekday
        year_month, day_hour, min_sec, jiffy_weekday = cx16.clock_get_date_time()
        uword year = 1900 + lsb(year_month)
        ubyte month = msb(year_month)
        ubyte day = lsb(day_hour)
        return dates.new(year, month, day)
    }

    sub chart(word birthday, word target) {
        txt.plot(0, 4)
        uword date = dates.long_string(target, true)
        txt.print("Marker: ") txt.print(date)
        ubyte i
        for i in string.length(date) to 32 { txt.chrout(' ') }
        txt.nl()
        uword days = (target - birthday) as uword
        txt.print("Day #") txt.print_uw(days) txt.nl()
        txt.nl()

        graphics.colors(1, 1)
        graphics.fillrect(chart_x, chart_y, chart_width, chart_height)

        uword x1 = chart_x + day_offset
        ubyte y1 = chart_zero - chart_max
        ubyte y2 = chart_zero + chart_max
        graphics.colors(12, 1)
        graphics.line(x1, y1, x1, y2)

        x1 = chart_x
        uword x2 = chart_x + chart_width - 1
        y1 = chart_zero
        graphics.line(x1, y1, x2, y1)
        txt.color2(11, 0)
        txt.plot(3, 16)
        ubyte day = dates.day(target)
        if day > 9 { txt.print_ub(day / 10) } else { txt.chrout(' ') }
        txt.plot(3, 17)
        txt.print_ub(day % 10)
        for i in 1 to 5 {
            day = dates.day(target + i * 7)
            txt.plot(3 + i * 7, 16)
            if day > 9 { txt.print_ub(day / 10) } else { txt.chrout(' ') }
            txt.plot(3 + i * 7, 17)
            txt.print_ub(day % 10)
        }
        txt.plot(0, 8)
        for i in 0 to 39 {
            graphics.line(day_width * (i as uword) + day_offset, chart_zero - 3,
                          day_width * (i as uword) + day_offset, chart_zero + 3)
        }
        ubyte i, j
        float θ, sine
        txt.nl()
        for i in 0 to 2 {
            txt.color2(cycle_colors[i], 1)
            for j in 0 to 1 {
                txt.chrout(32)
            }
            for j in 0 to 1 {
                txt.chrout(192)
            }
            txt.print(cycle_names[i])
            day = (days % cycle_lengths[i]) as ubyte
            if day == 0 day = cycle_lengths[i]

            graphics.colors(cycle_colors[i], cycle_colors[i])
            θ = (day as float - 3.5) / cycle_lengths[i] as float * 2 * floats.π
            sine = floats.sin(θ)
            x1 = 0
            y1 = (chart_zero as float - (chart_max as float) * sine) as ubyte
            graphics.plot(x1, y1)
            for j in 0 to 40  {
                θ = ((day - 3 + j + cycle_lengths[i]) % cycle_lengths[i]) as float / cycle_lengths[i] as float * 2 * floats.π
                sine = floats.sin(θ)
                x2 =  4 + 8 * (j as uword) 
                if x2 > 319 {
                    θ *= 319.0 / (x2 as float)
                    sine = floats.sin(θ)
                    x2 = 319
                }
                y2 = (chart_zero as float - (chart_max as float) * sine) as ubyte
                graphics.line(x1, y1, x2, y2)
                x1 = x2 
                y1 = y2
            }
        }
    }

    sub start() {
        graphics.enable_bitmap_mode()
        graphics.clear_screen(1, 0)
        txt.lowercase()

        bool done = false
        while not done {
            txt.color2(2, 0)
            txt.clear_screen()
            txt.color2(1, 2)
            txt.print("****      Biorhythm Calculator      ****")
            txt.color2(13, 0)
            txt.plot(0, 2)
            txt.print("Enter birthdate:")
            graphics.colors(0, 0)
            graphics.fillrect(32, 24, 248, 136)

            word birthday = tui.datepicker(4, 3, 0, 0)
            if tui.canceled {
                txt.print("Aborted.")
                txt.nl()
                sys.exit(0)
            }
            txt.plot(0, 2)
            txt.print("Birthdate: ") txt.chrout(' ')
            txt.print(dates.long_string(birthday, true)) txt.nl()

            bool same_person = true
            while same_person and not done {
                txt.color2(13, 0)
                txt.plot(0, 4)
                txt.print("Enter chart date:")
                graphics.colors(0, 0)
                graphics.fillrect(32, 48, 248, 136)
                word target = tui.datepicker(4, 6, 0, today())
                if tui.canceled {
                    txt.print("Aborted.")
                    txt.nl()
                    sys.exit(0)
                }

                bool scrolling = true
                while scrolling and same_person and not done {
                    txt.color2(13, 0)
                    txt.plot(0, 4)
                    chart(birthday, target)

                    txt.color2(13, 0)
                    tui.center(26, "<- -> Move by week")
                    tui.center(28, "New [D]ate  New [P]erson  [Q]uit")
                    ubyte key = txt.waitkey()
                    when key {
                        'q' -> done = true
                        29  -> target += 30
                       157  -> target -= 30
                        'd' -> scrolling = false
                        'p' -> same_person = false
                    }
                }
            }
        }
    }
}
