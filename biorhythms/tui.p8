%import string
%import syslib
%import textio

tui {
    %option merge
    sub center(ubyte line, str message) {
        ubyte width, height, length, col
        width, height = cbm.SCREEN()
        length = string.length(message) 
        col = 0
        if length < width {
            col = (width - length) / 2
        }
        txt.plot(col, line)
        txt.print(message)
    }
}
