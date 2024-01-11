langton.prg: langton.p8
	p8compile -target cx16 $<

run: langton.prg
	x16emu -prg $< -rtc -run
