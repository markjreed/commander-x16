%import conv
%import string
%import textio
%import textbox
%import dates

tui {
%option merge
    str[12] month_titles = [
        "January  ", "February ", "March    ", "April    ",
        "May      ", "June     ", "July     ", "August   ",
        "September", "October  ", "November ", "December "
    ]

    str[7] weekday_headings = [
        "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
    ]

    sub datepicker(ubyte x, ubyte y, ubyte week_start, word default_value) -> word {
         bool done  = false
         uword year, old_year, yr
         word dy
         ubyte month, day, col1
         word first, next
         word result = default_value
         ubyte i, j, d, days
         ubyte key
         ubyte cursor = 0
         ubyte[5] yrbuf

         void tui.textbox(x, y, 31, 17, "")
         txt.plot(x + 1, y + 1)
         txt.chrout('<')
         txt.plot(x + 29, y + 1)
         txt.chrout('>')

         txt.plot(x + 2, y + 3)
         for i in 0 to 6 {
             txt.print(weekday_headings[ (i + week_start) % 7 ])
             txt.chrout(' ')
         }

         while not done {
             old_year = year
             year = dates.year(result)
             month = dates.month(result)
             day = dates.day(result)
             first = dates.new(year, month, 1)
             next  = dates.new(year, month+1, 1)
             days  = (next - first) as ubyte
             col1 =  lsb(dates.remainder(dates.weekday(first) - week_start, 7))
             dates.weekday(dates.new(year, month, 1))
             txt.plot(x + 3, y + 1)
             txt.print(month_titles[month-1])
             txt.plot(x + 24, y + 1)
             txt.print_uw(year)
             if cursor == 5 {
                 txt.chrout(18)
                 txt.chrout(' ')
             } else if cursor > 0 {
                 txt.chrout(' ')
                 txt.chrout(157)
                 txt.chrout(157)
                 yr = year
                 if cursor < 4 {
                     for i in 3 to cursor step -1 {
                         txt.chrout(157)
                         yr /= 10
                     }
                 }
                 txt.chrout(18)
                 txt.chrout(lsb(yr % 10 + '0'))
                 txt.chrout(18|128)
             } else {
                 txt.chrout(' ')
             }
             for i in 0 to 5 {
                 txt.plot(x + 2, y + 5 + 2 * i)
                 for j in 0 to 6 {
                     txt.chrout(' ')
                     d = i * 7 + 1 - col1 + j
                     if d < 1 or d > days {
                        txt.print("  ")
                     } else {
                        if cursor == 0 and d == day txt.chrout(18)
                        if d < 10 {
                          txt.chrout(' ')
                        }
                        txt.print_ub(d)
                        txt.chrout(18|128)
                     }
                     txt.chrout(' ')
                 }
             }
             tui.center(26, "Move with cursor, tab, PgUp/Down")
             tui.center(28, "Or type new year or month initial")
             key = txt.waitkey()
             if cursor == 0 {
                 when key {
                       9 -> { result = dates.new(year + 1, month, day) }
                      17 -> { result += 7 }
                      24 -> { result = dates.new(year - 1, month, day) }
                      29 -> { result += 1 }
                     '1','2' -> {
                         cursor = 2
                         year = (year % 1000) + 1000 * (key - '0')
                         if year <= dates.MIN_YEAR {
                             year = dates.MIN_YEAR + 1
                         }
                         if year >= dates.MAX_YEAR {
                             year = dates.MAX_YEAR - 1
                         }
                         result = dates.new(year, month, day)
                     }
                     2,'>' -> {
                         month += 1
                         if month > 12 {
                             month = 1
                             year += 1
                         }
                         result = dates.new(year, month, 1)
                     }
                     130,'<' -> {
                         month -= 1
                         if month < 1 {
                             month = 12
                             year -= 1
                         }
                         result = dates.new(year, month, 1)
                     }
                     'a' -> {
                         if month == 4 {
                             month = 8
                         } else {
                             month = 4
                         }
                         result = dates.new(year, month, 1)
                     }
                     'd' -> { result = dates.new(year, 12, 1) }
                     'f' -> { result = dates.new(year,  2, 1) }
                     'j' -> {
                         if month == 1 {
                             month = 6
                         } else if month == 6 {
                             month = 7
                         } else {
                             month = 1
                         }
                         result = dates.new(year, month, 1)
                     }
                     'm' -> {
                         if month == 3 {
                             month = 5
                         } else {
                             month = 3
                         }
                         result = dates.new(year, month, 1)
                     }
                     'n' -> { result = dates.new(year, 11, 1) }
                     'o' -> { result = dates.new(year, 10, 1) }
                     's' -> { result = dates.new(year,  9, 1) }
                     145 -> { result -= 7 }
                     157 -> { result -= 1 }
                      13 -> { done = true }
                 }
             } else if cursor < 5 {
                 void string.copy(conv.str_uw(year), yrbuf)
                 when key {
                     9,13,17,24,145 -> { cursor = 0 }
                     27 -> {
                         year = old_year
                         result = dates.new(year, month, day)
                         cursor = 0
                     }
                     29 -> { cursor += 1 }
                     '0','1','2','3','4','5','6','7','8','9' -> {
                         dy = (key as word) - (yrbuf[cursor - 1] as word)
                         if cursor < 4 {
                             for i in cursor to 3 {
                                 dy *= 10
                             }
                         }
                         year = (year as word + dy) as uword
                         if year <= dates.MIN_YEAR {
                             year = dates.MIN_YEAR + 1
                         }
                         if year >= dates.MAX_YEAR {
                             year = dates.MAX_YEAR - 1
                         }
                         result = dates.new(year, month, day)
                         cursor += 1
                     }
                     20,157 -> { cursor -= 1 }
                 }
             } else {
                 when key {
                     9,13,17,24,145 -> { cursor = 0 }
                     27 -> {
                          year = old_year
                          result = dates.new(year, month, day)
                          cursor = 0
                     }
                     20,157 -> { cursor -= 1 }
                 }
             }
         }
         void tui.clear_rect(0, 26, 39, 3)
         void tui.clear_rect(x, y, 31, 17)
         txt.plot(x, y)
         return result
    }
}
