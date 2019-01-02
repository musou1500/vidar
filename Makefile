vidar.img: ipl.bin vidar.sys
	mformat -f 1440 -C -B ipl.bin -i vidar.img ::/
	mcopy -i vidar.img vidar.sys ::

ipl.bin: ipl.s
	gcc -m32 ipl.s -nostdlib -T./ipl.ls -o ipl.bin

vidar.bin: vidar.s
	gcc -m32 vidar.s -nostdlib -T./vidar.ls -o vidar.bin

func.o: func.s
	as --32 func.s -o func.o

bootpack.o: bootpack.c
	gcc -fno-pic -m32 bootpack.c -nostdlib -Wl,--oformat=binary -c -o bootpack.o 

bootpack.bin: func.o bootpack.o
	ld -m elf_i386 -o bootpack.bin -e vidar_main --oformat=binary bootpack.o func.o

vidar.sys: vidar.bin bootpack.bin
	cat vidar.bin bootpack.bin > vidar.sys

run: vidar.img
	qemu-system-i386 -vga std -drive file=vidar.img,format=raw,if=floppy

clean:
	rm bootpack.bin bootpack.o vidar.bin vidar.sys func.o ipl.bin vidar.img


format:
	clang-format-6.0 -i bootpack.c;

