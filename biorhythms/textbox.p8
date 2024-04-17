%import string
%import textio

tui {
%option merge
    sub textbox(ubyte x, ubyte y, ubyte width, ubyte height, str title) -> bool {
        ubyte columns, rows

        if width < 3 or height < 3 return false
        columns, rows = cbm.SCREEN()

        if x + width >= columns or y + height >= rows return false

        ubyte i, j
        for i in 0 to height-1 {
            txt.plot(x, y + i)
            for j in 0 to width - 1 txt.chrout(' ')
        }

        for i in 0 to 1 { 
            txt.plot(x, y + i * (height - 1))
            txt.chrout(176 - i * 3)
            for j in 2 to width-1 {
                txt.chrout(192)
            }
            txt.chrout(174 + i * 15)
        }
        for i in 1 to height-2 {
           for j in 0 to 1 {
               txt.plot(x + j * (width - 1), y + i)
               txt.chrout(221)
           }
        }
        if title != 0 {
            ubyte[81] buffer
            ubyte titlen = string.copy(title, buffer)
            ubyte left
            if titlen >= width - 2 {
                buffer[width-2] = 0
                left = x + 1
            } else { 
                left = x + 1 + (width - 2 - titlen) / 2
            }
            txt.plot(left, y + 1)
            txt.print(buffer)
            if height > 3 {
                txt.plot(x, y + 2)
                txt.chrout(171)
                for j in 2 to width-1 {
                    txt.chrout(192)
                }
                txt.chrout(179)
            }
        }
        return true
    }

    sub clear_rect(ubyte x, ubyte y, ubyte width, ubyte height) -> bool {
        ubyte columns, rows, i, j

        if width < 3 or height < 3 return false
        columns, rows = cbm.SCREEN()

        if x + width >= columns or y + height >= rows return false

        for i in 0 to height-1 {
            txt.plot(x, y + i)
            for j in 1 to width {
                 txt.chrout(' ')
            }
        }
        return true
    }
}
