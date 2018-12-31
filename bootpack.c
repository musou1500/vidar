void io_hlt(void);
void write_mem8(int addr, int data);

void vidar_main(void) {
  int i;
  for (int i = 0xa0000; i <= 0xaffff; i++) {
    write_mem8(i, 15);
  }

  while(1)
    io_hlt();
}
