CSRCS = 

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

font.c:
	./font2c.py ./hankaku.txt > font.c

font.o: font.c
	gcc -fno-pic -m32 font.c -nostdlib -Wl,--oformat=binary -c -o font.o 

bootpack.bin: func.o bootpack.o font.o
	ld -m elf_i386 -o bootpack.bin --script=bootpack.ls bootpack.o font.o func.o

vidar.sys: vidar.bin bootpack.bin
	cat vidar.bin bootpack.bin > vidar.sys

run: vidar.img
	qemu-system-i386 -vga std -drive file=vidar.img,format=raw,if=floppy

clean:
	rm *.bin *.o vidar.sys vidar.img font.c

format:
	clang-format-6.0 -i bootpack.c;

