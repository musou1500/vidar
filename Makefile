ipl.bin: ipl.s
	nasm ipl.s -o ipl.bin

vidar.sys: vidar.s
	nasm vidar.s -o vidar.sys

vidar.img: ipl.bin vidar.sys
	dd if=/dev/zero of=vidar.img bs=512  count=2880
	dd conv=notrunc if=ipl.bin of=vidar.img
	mcopy -i vidar.img vidar.sys ::/

run: vidar.img
	qemu-system-i386 -drive file=vidar.img,format=raw,if=floppy

clean:
	rm vidar.img ipl.bin
