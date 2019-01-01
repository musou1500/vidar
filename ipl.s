.intel_syntax noprefix
.equ CYLS,10

.text
.code16
  jmp entry
  .byte 0x90

  .ascii "VIDAR   "
  .word 512
  .byte 1
  .word 1
  .byte 2
  .word 224
  .word 2880
  .byte 0xf0
  .word 9
  .word 18
  .word 2
  .int 0
  .int 2880
  .byte 0,0,0x29
  .int 0xffffffff
  .ascii "VIDAR      "
  .ascii "FAT12   "
.skip 18, 0x00

# プログラム本体
entry:
  mov ax, 0
  mov ss, ax
  mov sp, 0x7c00
  mov ds, ax
  mov es,ax

  # ディスクを読む
  mov ax,0x0820
  mov es,ax

  # シリンダ，ヘッダ，セクタ
  mov ch,0
  mov dh,0
  mov cl,2
readloop:
  # リトライ回数
  mov si,0
retry:
  mov ah,0x02
  mov al,1
  mov bx,0
  mov dl,0x00
  int 0x13
  jnc next
  add si,1
  cmp si,5
  jae error
  mov ah,0x00
  mov dl,0x00
  int 0x13
  jmp retry
next:
  mov ax,es
  add ax,0x0020
  mov es,ax
  add cl,1
  cmp cl,18
  jbe readloop
  mov cl,1
  add dh,1
  cmp dh,2
  jb readloop
  mov dh,0
  add ch,1
  cmp ch,CYLS
  jb readloop
  mov [0x0ff0],ch
  jmp 0xc200
fin:
  hlt
  jmp fin
error:
  mov SI,msg
putloop:
  mov al, [si]
  add si, 1
  cmp al, 0
  je fin
  mov ah, 0x0e
  mov bx, 15
  int 0x10
  jmp putloop
msg:
  # メッセージ部分
  .byte 0x0a, 0x0a
  .ascii "load error"
  .byte 0x0a
  .byte 0

