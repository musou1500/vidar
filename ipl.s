CYLS EQU 10
ORG 0x7c00
JMP entry
DB 0x90

db "VIDAR   "
dw 512
db 1
dw 1
db 2
dw 224
dw 2880
db 0xf0
dw 9
dw 18
dw 2
dd 0
dd 2880
db 0,0,0x29
dd 0xffffffff
db "VIDAR      "
db "FAT12   "
resb 18

; プログラム本体
entry:
  mov ax, 0
  mov ss, ax
  mov sp, 0x7c00
  mov ds, ax

  ; ディスクを読む
  mov ax,0x0820
  mov es,ax

  ; シリンダ，ヘッダ，セクタ
  mov ch,0
  mov dh,0
  mov cl,2
readloop:
  ; リトライ回数
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
  add ax,512/16
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
  ; メッセージ部分
  db 0x0a, 0x0a
  db "load error"
  db 0x0a
  db 0

resb 0x7dfe-0x7c00-($-$$)
db 0x55,0xaa

