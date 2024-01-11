matrix.prg: matrix.p8
	p8compile -target cx16 $<

run: matrix.prg
	x16emu -prg $< -rtc -run
