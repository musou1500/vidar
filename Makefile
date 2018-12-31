vidar.img: ipl.bin vidar.sys
	mformat -f 1440 -C -B ipl.bin -i vidar.img ::/
	mcopy -i vidar.img vidar.sys ::

ipl.bin: ipl.s
	gcc ipl.s -nostdlib -T ./ipl.ls -o ipl.bin

vidar.sys: vidar.s
	gcc vidar.s -nostdlib -T ./vidar.ls -o vidar.sys

run: vidar.img
	qemu-system-i386 -drive file=vidar.img,format=raw,if=floppy

# bootpack.s:
	# gcc -m32 -masm=intel -fno-asynchronous-unwind-tables -S bootpack.c -o bootpack.s

# bootpack.o: bootpack.s
	# as --32 -o bootpack.o bootpack.s

clean:
	rm vidar.img ipl.bin bootpack.s bootpack.o
	# rm vidar.img ipl.bin bootpack.s bootpack.o
