EMU_OPTS := -rtc -scale 2 

langton.prg: langton.p8
	p8compile -target cx16 $<

run: langton.prg
	x16emu $(EMU_OPTS) -prg $< -rtc -run
