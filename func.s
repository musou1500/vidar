.intel_syntax noprefix
.code32
.globl io_hlt
.globl write_mem8
.text
io_hlt:
  hlt
  ret
write_mem8:
  mov ecx,[esp + 4]
  mov al,[esp + 8]
  mov [ecx],al
  ret
