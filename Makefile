all:
	# cp /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/11.D81 .
	c1541 -attach COMMANDO.D81 -read commando commando.prg
	petcat -65 -o commando.bas -- commando.prg
	# c1541 -attach MA110.D81 -read gurce.asm,s

FORCE: ;

tod81:
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -delete asmhelper -write asmhelper.prg asmhelper
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -delete chars.bin -write chars.bin
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -delete moana3.bin -write moana3.bin

fromd81:
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -read moana3.bin,s

xemu:
	/c/projs/xemu/build/bin/xmega65.native -rom /c/projs/mega65-rom/newrom.bin -hdosvirt -uartmon :4510 -8 /C/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 &> /dev/null &

asmhelper.prg: asmhelper.a
	acme --cpu m65 -v4 -l asmhelper.sym -r asmhelper.rep asmhelper.a
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -delete asmhelper -write asmhelper.prg asmhelper
