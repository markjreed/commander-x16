EMU_OPTS := -rtc -scale 2 

langtons-ant.prg: langtons-ant.p8
	p8compile -target cx16 $<

run: langtons-ant.prg
	x16emu $(EMU_OPTS) -prg $< -rtc -run
