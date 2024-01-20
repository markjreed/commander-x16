EMU_OPTS := -rtc -scale 2 -warp

langtons-loops.prg: langtons-loops.p8
	p8compile -target cx16 $<

run: langtons-loops.prg
	x16emu $(EMU_OPTS) -prg $< -rtc -run
