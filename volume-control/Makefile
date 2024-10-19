.PRECIOUS: %.PRG

%.PRG: %.BAS ; 
	bash -c 'x16emu -bas <(echo "BASLOAD \"$<\""; echo "SAVE \"@0:$@\""; echo POWEROFF)' 

%.BIN: %.PRG ;
	dd if="$<" of="$@" bs=1 skip=2

%.PRG: %.XCB ;
	xcbasic3 "$<" "$@"
