#include "func.h"
enum {
  COL_BLACK = 0,
  COL_L_RED,
  COL_L_GREEN,
  COL_L_YELLOW,
  COL_L_BLUE,
  COL_L_PURPLE,
  COL_L_AQUA,
  COL_WHITE,
  COL_L_GRAY,
  COL_D_RED,
  COL_D_GREEN,
  COL_D_YELLOW,
  COL_D_BLUE,
  COL_D_PURPLE,
  COL_D_AQUA,
  COL_D_GRAY,
};

void init_palette(void);
void set_palette(int start, int end, unsigned char *rgb);
void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1);

void vidar_main(void) {
  char *p;

  init_palette();
  p = (char *) 0xa0000;

  boxfill8(p, 320, COL_L_RED, 20, 20, 120, 120);
  boxfill8(p, 320, COL_L_GREEN, 70, 50, 170, 150);
  boxfill8(p, 320, COL_L_BLUE, 120, 80, 220, 180);

  for(;;) {
    io_hlt();
  }
}

void init_palette(void)
{
  // staticにすると，色が正しく表示されないので，仕方なくローカル変数を使っている．
  // ブートのときに意図しない領域に書き込みを行っているのかもしれない
  unsigned char table_rgb[] = {
    0x00, 0x00, 0x00,	/*  0:黒 */
    0xff, 0x00, 0x00,	/*  1:明るい赤 */
    0x00, 0xff, 0x00,	/*  2:明るい緑 */
    0xff, 0xff, 0x00,	/*  3:明るい黄色 */
    0x00, 0x00, 0xff,	/*  4:明るい青 */
    0xff, 0x00, 0xff,	/*  5:明るい紫 */
    0x00, 0xff, 0xff,	/*  6:明るい水色 */
    0xff, 0xff, 0xff,	/*  7:白 */
    0xc6, 0xc6, 0xc6,	/*  8:明るい灰色 */
    0x84, 0x00, 0x00,	/*  9:暗い赤 */
    0x00, 0x84, 0x00,	/* 10:暗い緑 */
    0x84, 0x84, 0x00,	/* 11:暗い黄色 */
    0x00, 0x00, 0x84,	/* 12:暗い青 */
    0x84, 0x00, 0x84,	/* 13:暗い紫 */
    0x00, 0x84, 0x84,	/* 14:暗い水色 */
    0x84, 0x84, 0x84	/* 15:暗い灰色 */
  };

	int eflags;
	eflags = io_load_eflags();
	io_cli();
  io_out8(0x03c8, 0);
	for (int i = 0; i < 16; i++) {
    io_out8(0x03c9, table_rgb[i * 3]);
    io_out8(0x03c9, table_rgb[i * 3 + 1]);
    io_out8(0x03c9, table_rgb[i * 3 + 2]);
	}
	io_store_eflags(eflags);
	return;
}

void set_palette(int start, int end, unsigned char *rgb)
{

	return;
}

void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0, int x1, int y1) {
  for (int y = y0; y <= y1; y++) {
    for (int x = x0; x <= x1; x++) {
      vram[y * xsize + x] = c;
    }
  }

  return;
}
