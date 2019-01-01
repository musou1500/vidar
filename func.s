.intel_syntax noprefix
.code32
.globl io_hlt
.globl io_cli
.globl write_mem8
.globl io_sti
.globl io_stihlt
.globl io_out8
.globl io_load_eflags
.globl io_store_eflags

.text
io_hlt:
  hlt
  ret

io_cli:
  cli
  ret

io_sti:
  sti
  ret

io_stihlt:
  sti
  hlt
  ret

io_out8:
  mov edx,[esp+4]
  mov al,[esp+8]
  out dx,al
  ret

io_load_eflags:
  pushfd
  pop eax
  ret

io_store_eflags:
  mov eax,[esp+4]
  push eax
  popfd
  ret
