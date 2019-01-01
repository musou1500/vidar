.intel_syntax noprefix
.code32
.globl io_hlt
.globl write_mem8
.text
io_hlt:
  hlt
  ret
