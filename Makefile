CSRCS = bootpack.c font.c lib.c
COBJS=$(CSRCS:.c=.o)

vidar.img: ipl.bin vidar.sys
	mformat -f 1440 -C -B ipl.bin -i vidar.img ::/
	mcopy -i vidar.img vidar.sys ::

ipl.bin: ipl.s
	gcc -m32 ipl.s -nostdlib -T./ipl.ls -o ipl.bin

vidar.bin: vidar.s
	gcc -m32 vidar.s -nostdlib -T./vidar.ls -o vidar.bin

func.o: func.s
	as --32 func.s -o func.o

$(COBJS): $(CSRCS)
	gcc -fno-pic -m32 $(CSRCS) -nostdlib -Wl,--oformat=binary -c

font.c:
	./font2c.py ./hankaku.txt > font.c

bootpack.bin: func.o bootpack.o font.o
	ld -m elf_i386 -o bootpack.bin --script=bootpack.ls $(COBJS) func.o

vidar.sys: vidar.bin bootpack.bin
	cat vidar.bin bootpack.bin > vidar.sys

run: vidar.img
	qemu-system-i386 -vga std -drive file=vidar.img,format=raw,if=floppy

clean:
	rm *.bin *.o vidar.sys vidar.img font.c

format:
	clang-format-6.0 -i bootpack.c lib.c;

