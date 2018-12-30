boot.bin: boot.s
	nasm boot.s -o boot.bin

run: boot.bin
	qemu-system-i386 -drive file=boot.bin,format=raw,if=floppy

clean:
	rm boot.bin
