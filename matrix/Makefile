matrix.prg: matrix.p8
	prog8c -target cx16 $<

run: matrix.prg
	x16emu -prg $< -rtc -run
