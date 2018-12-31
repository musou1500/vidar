.intel_syntax noprefix
.equ BOTPAK,0x00280000
.equ DSKCAC,0x00100000
.equ DSKCAC0,0x00008000

.equ CYLS,0x0ff0
.equ LEDS,0x0ff1
.equ VMODE,0x0ff2
.equ SCRNX,0x0ff4
.equ SCRNY,0x0ff6
.equ VRAM,0x0ff8

.text
.code16

# 画面モードを設定
mov al,0x13
mov ah,0x00
int 0x10

# 画面モードに関する情報を保存しておく
mov byte ptr [VMODE],8
mov word ptr [SCRNX],320
mov word ptr [SCRNY],200
mov dword ptr [VRAM],0x000a0000
mov ah,0x02
int 0x16

# キーボードのLED状態
mov [LEDS],al

# PICが一切の割り込みを受け付けないようにする
#	AT互換機の仕様では、PICの初期化をするなら、
#	こいつをCLI前にやっておかないと、たまにハングアップする
#	PICの初期化はあとでやる
mov al,0xff
out 0x21,al
nop
out 0xa1,al
cli

# CPUから1MB以上のメモリにアクセスできるように、A20GATEを設定
call waitkbdout
mov al,0xd1
out 0x64,al
# enable A20
call waitkbdout
out 0x60,al
call waitkbdout

# プロテクトモード移行
lgdt [GDTR0]
mov eax, cr0
and eax,0x7fffffff
mov cr0,eax
jmp pipelineflush

pipelineflush:
  mov ax,1*8
  mov ds, ax
  mov es,ax
  mov fs,ax
  mov gs,ax
  mov ss,ax

  # bootpackの転送
  mov esi,bootpack
  mov edi,BOTPAK
  mov ecx,512*1024/4
  call memcpy

  # ディスクデータを本来の位置へ転送
  # ブートセクタ
  mov esi,0x7c00
  mov edi,DSKCAC
  mov ecx, 512/4
  call memcpy

  # 残り
  mov esi,DSKCAC0+512
  mov edi,DSKCAC+512
  mov ecx,0
  mov cl,byte [CYLS]
  imul ecx,512*18*2/4
  sub ecx,512/4
  call memcpy

  # bootpackを起動
  mov ebx, BOTPAK
  mov ecx,[ebx+16]
  add ecx,3
  shr ecx,2
  jz skip
  mov esi,[ebx + 20]
  add esi, ebx
  mov edi,[ebx+12]
  call memcpy

skip:
  mov esp,[ebx + 12]
  jmp 2*8:0x0000001b

waitkbdout:
  in al,0x64
  and al,0x02
  jnz waitkbdout
  ret

memcpy:
  mov eax,[esi]
  add esi,4
  mov [edi],eax
  add edi,4
  sub ecx,1
  jnz memcpy
  ret

.align 8
GDT0:
  .skip 8,0x00
  .word 0xffff,0x0000,0x9200,0x00cf
  .word 0xffff,0x0000,0x9a28,0x0047
  .word 0
GDTR0:
  .word 8 * 3 - 1
  .int GDT0
.align 8
bootpack:
