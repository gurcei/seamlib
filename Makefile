all:
	# cp /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/11.D81 .
	c1541 -attach COMMANDO.D81 -read commando commando.prg
	petcat -65 -o commando.bas -- commando.prg
	# c1541 -attach MA110.D81 -read gurce.asm,s

read11:
	c1541 -attach SPRING.D81 -read 11.defaults -read 11.edit -read 11.parse -read 11.post -read 11.settings -read autoboot.c65 -read readme,s
	petcat -65 -o 11.defaults.bas -- 11.defaults
	petcat -65 -o 11.edit.bas -- 11.edit
	petcat -65 -o 11.parse.bas -- 11.parse
	petcat -65 -o 11.post.bas -- 11.post
	petcat -65 -o 11.settings.bas -- 11.settings
	petcat -65 -o autoboot.c65.bas -- autoboot.c65

FORCE: ;

tod81:
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -delete asmhelper -write asmhelper.prg asmhelper
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -delete chars.bin -write chars.bin
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -delete moana3.bin -write moana3.bin

fromd81:
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -read moana4.bin,s
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -read dragon.p,s
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -read game.pal
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -read 11.defaults
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -read changelog,s
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -read 11.tokenize
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -read readme,s
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -read b65support.bin
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -read 11.post
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -read 11.settings
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -read 11.parse
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -read autoboot.c65 11boot.c65
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -read chars.bin
	c1541 -attach /c/Users/phuon/AppData/Roaming/xemu-lgb/mega65/hdos/112.D81 -read 11.edit

author:
	c1541 -format spring,gi d81 SPRING.D81
	c1541 -attach "SPRING.D81" -write 11boot.c65 -write 11.tokenize -write 11.defaults -write 11.edit -write 11.post -write 11.parse -write 11.settings -write readme readme,s -write changelog changelog,s -write b65support.bin
	c1541 -attach "SPRING.D81" -write PALETTE.EL palette.el,s -write SEAMDRAW.EL seamdraw.el,s -write SEAMLIB.EL seamlib.el,s -write MELODY.EL melody.el,s -write AUTOBOOT.EL autoboot.el,s
	c1541 -attach "SPRING.D81" -write moana4.bin moana4.bin,s -write game.pal -write dragon.p dragon.p,s -write chars.bin -write asmhelper.prg asmhelper -write asmhelper.a asmhelper.a,s -write 999999.bin

test-author:
	c1541 -format spring,gi d81 TEST.D81
	c1541 -attach TEST.D81 -write todo.txt todo1.txt
	c1541 -attach TEST.D81 -write todo.txt todo2.txt
	c1541 -attach TEST.D81 -write autoboot.el autoboot.el,s

test-xemu:
	/c/projs/xemu/build/bin/xmega65.native -rom /c/projs/mega65-rom/newrom.bin -hdosvirt -uartmon :4510 -8 TEST.D81 &> /dev/null &

xemu:
	/c/projs/xemu/build/bin/xmega65.native -rom /c/projs/mega65-rom/newrom.bin -hdosvirt -uartmon :4510 -8 SPRING.D81 &> /dev/null &

asmhelper.prg: asmhelper.a
	acme --cpu m65 -v4 -l asmhelper.sym -r asmhelper.rep asmhelper.a
	c1541 -attach SPRING.D81 -delete asmhelper -write asmhelper.prg asmhelper
