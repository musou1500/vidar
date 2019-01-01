# intel_syntaxで頑張ろうとしたが，うまくいかず原因もわからなかったので今はコピペで済ます．あとで治す．
# http://cyberbird.indiesj.com/x86%E3%80%80os%E8%87%AA%E4%BD%9C%E5%85%A5%E9%96%80/os%E8%87%AA%E4%BD%9C%E5%85%A5%E9%96%80%20onlinux%203%E6%97%A5%E7%9B%AE

.equ BOTPAK,	0x00280000
.equ DSKCAC,	0x00100000
.equ DSKCAC0,	0x00008000

.equ CYLS,		0x0ff0
.equ LEDS,		0x0ff1
.equ VMODE,		0x0ff2
.equ SCRNX,		0x0ff4
.equ SCRNY,		0x0ff6
.equ VRAM,		0x0ff8

.text
.code16
head:
	movb $0x13, %al
	movb $0x00, %ah
	int $0x10

	movb $0x08, (VMODE)
	movw $320, (SCRNX)
	movw $200, (SCRNY)
	movl $0x000a0000, (VRAM)

	movb $0x02, %ah
	int $0x16
	movb %al, (LEDS)

# 32ビットプロテクトモードへ移行
	# PICへの割り込み禁止
	movb $0xff, %al
	outb %al, $0x21
	nop
	outb %al, $0xa1
	cli							# CPUレベルでも割り込み禁止

	# A20信号線をON
	call waitkbdout
	movb $0xd1, %al
	outb %al, $0x64
	call waitkbdout
	movb $0xdf, %al
	outb %al, $0x60				# enable A20
	call waitkbdout

.arch i486						# 32bitネイティブコード
	lgdtl (GDTR0)				# 暫定GDTを設定
	movl %cr0, %eax
	andl $0x7fffffff, %eax		# bit31を0に(ページング禁止)
	orl $0x00000001, %eax		# bit0を1に(プロテクトモード移行)
	movl %eax, %cr0
	jmp pipelineflash
pipelineflash:
	movw $1*8, %ax				# 読み書き可能セグメント32bit
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %fs
	movw %ax, %gs
	movw %ax, %ss

# bootpackの転送
	movl $bootpack, %esi
	movl $BOTPAK, %edi
	movl $512*1024/4, %ecx
	call memcpy

# ブートセクタの転送
	movl $0x7c00, %esi
	movl $DSKCAC, %edi
	movl $512/4, %ecx
	call memcpy

# 残り
	movl $DSKCAC0+512, %esi
	movl $DSKCAC+512, %edi
	movl $0x00, %ecx
	movb (CYLS), %cl
	imull $512*18*2/4, %ecx
	subl $512/4, %ecx
	call memcpy

# start bootpack
	movl $BOTPAK, %ebx
	movl $0x11a8, %ecx
	addl $3, %ecx
	shrl $2, %ecx
	jz skip
	movl $0x10c8, %esi
	addl %ebx, %esi
	movl $0x00310000, %edi
	call memcpy
skip:
	movl $0x00310000, %esp
	ljmpl $2*8, $0x00000000

###########################
# function

waitkbdout:
	inb $0x64, %al
	andb $0x02, %al
	inb $0x60, %al
	jnz waitkbdout
	ret

memcpy:
	movl (%esi), %eax
	addl $4, %esi
	movl %eax, (%edi)
	addl $4, %edi
	subl $1, %ecx
	jnz memcpy
	ret

##########################
# GDT
.align 8
GDT0:
.skip 8, 0x00
	.word 0xffff, 0x0000, 0x9200, 0x00cf	# 読み書き可能セグメント32bit
	.word 0xffff, 0x0000, 0x9a28, 0x0047	# 実行可能セグメント32bit

	.word 0x0000
GDTR0:
	.word 8*3-1
	.int GDT0

.align 8
bootpack:
# .intel_syntax noprefix
# .equ BOTPAK,0x00280000
# .equ DSKCAC,0x00100000
# .equ DSKCAC0,0x00008000
# 
# .equ CYLS,0x0ff0
# .equ LEDS,0x0ff1
# .equ VMODE,0x0ff2
# .equ SCRNX,0x0ff4
# .equ SCRNY,0x0ff6
# .equ VRAM,0x0ff8
# 
# .text
# .code16
# 
# # 画面モードを設定
# haed:
#   mov al,0x13
#   mov ah,0x00
#   int 0x10
# 
#   # 画面モードに関する情報を保存しておく
#   mov byte ptr [VMODE],0x08
#   mov word ptr [SCRNX],320
#   mov word ptr [SCRNY],200
#   mov dword ptr [VRAM],0x000a0000
#   mov ah,0x02
#   int 0x16
# 
#   # キーボードのLED状態
#   mov byte ptr [LEDS],al
# 
#   # PICが一切の割り込みを受け付けないようにする
#   #	AT互換機の仕様では、PICの初期化をするなら、
#   #	こいつをCLI前にやっておかないと、たまにハングアップする
#   #	PICの初期化はあとでやる
#   mov al,0xff
#   out 0x21,al
#   nop
#   out 0xa1,al
#   cli
# 
#   # CPUから1MB以上のメモリにアクセスできるように、A20GATEを設定
#   call waitkbdout
#   mov al,0xd1
#   out 0x64,al
#   # enable A20
#   call waitkbdout
#   mov al,0xdf
#   out 0x60,al
#   call waitkbdout
# 
# # プロテクトモード移行
# .arch i486
# lgdt [GDTR0]
# mov eax,cr0
# and eax,0x7fffffff
# or eax,0x00000001
# mov cr0,eax
# jmp pipelineflush
# 
# pipelineflush:
#   mov ax,1*8
#   mov ds,ax
#   mov es,ax
#   mov fs,ax
#   mov gs,ax
#   mov ss,ax
# 
#   # bootpackの転送
#   mov esi,bootpack
#   mov edi,BOTPAK
#   mov ecx,512*1024/4
#   call memcpy
# 
#   # ディスクデータを本来の位置へ転送
#   # ブートセクタ
#   mov esi,0x7c00
#   mov edi,DSKCAC
#   mov ecx,512/4
#   call memcpy
# 
#   # 残り
#   mov esi,DSKCAC0+512
#   mov edi,DSKCAC+512
#   mov ecx,0
#   mov cl,byte ptr [CYLS]
#   imul ecx,512*18*2/4
#   sub ecx,512/4
#   call memcpy
# 
#   # bootpackを起動
#   mov ebx,BOTPAK
#   mov ecx,0x11a8
#   add ecx,3
#   shr ecx,2
#   jz skip
#   mov esi,0x10c8
#   add esi,ebx
#   mov edi,0x00310000
#   call memcpy
# 
# skip:
#   mov esp,0x00310000
#   jmp 2*8:0x00000000
# 
# waitkbdout:
#   in al,0x64
#   and al,0x02
#   in al,0x60
#   jnz waitkbdout
#   ret
# 
# memcpy:
#   mov eax,[esi]
#   add esi,4
#   mov [edi],eax
#   add edi,4
#   sub ecx,1
#   jnz memcpy
#   ret
# 
# .align 8
# GDT0:
#   .skip 8,0x00
#   .word 0xffff,0x0000,0x9200,0x00cf
#   .word 0xffff,0x0000,0x9a28,0x0047
#   .word 0x0000
# GDTR0:
#   .word 8 * 3 - 1
#   .int GDT0
# .align 8
# bootpack:
