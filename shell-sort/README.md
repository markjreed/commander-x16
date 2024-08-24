# Shell's Sort

This is a companion routine to be used from a BASIC program. Called via 
the USR() function with an argument of the address of a BASIC string array,
it wil sort that array in place using [Shell's algorithm](https://en.wikipedia.org/wiki/Shellsort).

![demo](shellsort-demo.png)

|File |Description|
|--------|-----------|
| README.md  | This file |
| [loader.asm](loader.asm) | Assembly source for loader and function |
| [LOADER.PRG](LOADER.PRG) | RUNnable executable that installs the USR() function|
| [SHELLSORT.BIN](SHELLSORT.BIN)  | Assembled and BLOADable function handler
| [demo.bas](demo.bas)  | Source code: short BASIC demo that BLOADs the routine and sorts a 10-word array
| [pokedemo.bas](pokedemo.bas)  | Self-contained BASIC demo program that POKEs the handler into memory and sorts a 100-word array

