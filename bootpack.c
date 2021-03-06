#include <stdarg.h>
#include <stdio.h>

#include "func.h"
#include "lib.h"

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

typedef struct {
  char cyls, leds, vmode, reserve;
  short scrnx, scrny;
  char *vram;
} BootInfo;

void init_palette(void);
void putfont8(char *vram, int xsize, int x, int y, char c, char *font);
void putfont8_s(char *vram, int xsize, int x, int y, char c, char *s);
void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0,
              int x1, int y1);
void init_screen(char *vram, int xsize, int ysize);

extern char font[4096];

void vidar_main(void) {
  BootInfo *binfo = (BootInfo *)0x0ff0;
  char *vram = binfo->vram;
  init_palette();

  int xsize = binfo->scrnx;
  int ysize = binfo->scrny;
  init_screen(vram, xsize, ysize);
  putfont8_s(binfo->vram, binfo->scrnx, 17, 31, COL_BLACK, "welcome to vidar");
  putfont8_s(binfo->vram, binfo->scrnx, 16, 30, COL_WHITE, "welcome to vidar");

  char s[32];
  sprintf(s, "scrnx = %d scrny = %d", binfo->scrnx, binfo->scrny);
  putfont8_s(binfo->vram, binfo->scrnx, 16, 64, COL_WHITE, s);

  for (;;) {
    io_hlt();
  }
}

void init_screen(char *vram, int xsize, int ysize) {
  boxfill8(vram, xsize, COL_D_GREEN, 0, 0, xsize - 1, ysize - 29);
  boxfill8(vram, xsize, COL_L_GRAY, 0, ysize - 28, xsize - 1, ysize - 28);
  boxfill8(vram, xsize, COL_WHITE, 0, ysize - 27, xsize - 1, ysize - 27);
  boxfill8(vram, xsize, COL_L_GRAY, 0, ysize - 26, xsize - 1, ysize - 1);

  boxfill8(vram, xsize, COL_WHITE, 3, ysize - 24, 59, ysize - 24);
  boxfill8(vram, xsize, COL_WHITE, 2, ysize - 24, 2, ysize - 4);
  boxfill8(vram, xsize, COL_D_GRAY, 3, ysize - 4, 59, ysize - 4);
  boxfill8(vram, xsize, COL_D_GRAY, 59, ysize - 23, 59, ysize - 5);
  boxfill8(vram, xsize, COL_BLACK, 2, ysize - 3, 59, ysize - 3);
  boxfill8(vram, xsize, COL_BLACK, 60, ysize - 24, 60, ysize - 3);

  boxfill8(vram, xsize, COL_D_GRAY, xsize - 47, ysize - 24, xsize - 4,
           ysize - 24);
  boxfill8(vram, xsize, COL_D_GRAY, xsize - 47, ysize - 23, xsize - 47,
           ysize - 4);
  boxfill8(vram, xsize, COL_WHITE, xsize - 47, ysize - 3, xsize - 4, ysize - 3);
  boxfill8(vram, xsize, COL_WHITE, xsize - 3, ysize - 24, xsize - 3, ysize - 3);
}

// staticにすると，色が正しく表示されないので，仕方なくローカル変数を使っている．
// ブートのときに意図しない領域に書き込みを行っているのかもしれない
static unsigned char table_rgb[] = {
    0x00, 0x00, 0x00, /*  0:黒 */
    0xff, 0x00, 0x00, /*  1:明るい赤 */
    0x00, 0xff, 0x00, /*  2:明るい緑 */
    0xff, 0xff, 0x00, /*  3:明るい黄色 */
    0x00, 0x00, 0xff, /*  4:明るい青 */
    0xff, 0x00, 0xff, /*  5:明るい紫 */
    0x00, 0xff, 0xff, /*  6:明るい水色 */
    0xff, 0xff, 0xff, /*  7:白 */
    0xc6, 0xc6, 0xc6, /*  8:明るい灰色 */
    0x84, 0x00, 0x00, /*  9:暗い赤 */
    0x00, 0x84, 0x00, /* 10:暗い緑 */
    0x84, 0x84, 0x00, /* 11:暗い黄色 */
    0x00, 0x00, 0x84, /* 12:暗い青 */
    0x84, 0x00, 0x84, /* 13:暗い紫 */
    0x00, 0x84, 0x84, /* 14:暗い水色 */
    0x84, 0x84, 0x84  /* 15:暗い灰色 */
};

void init_palette(void) {
  int eflags;
  eflags = io_load_eflags();
  io_cli();
  io_out8(0x03c8, 0);
  for (int i = 0; i < 16; i++) {
    io_out8(0x03c9, table_rgb[i * 3] / 4);
    io_out8(0x03c9, table_rgb[i * 3 + 1] / 4);
    io_out8(0x03c9, table_rgb[i * 3 + 2] / 4);
  }
  io_store_eflags(eflags);
  return;
}

void boxfill8(unsigned char *vram, int xsize, unsigned char c, int x0, int y0,
              int x1, int y1) {
  for (int y = y0; y <= y1; y++) {
    for (int x = x0; x <= x1; x++) {
      vram[y * xsize + x] = c;
    }
  }

  return;
}

void putfont8_s(char *vram, int xsize, int x, int y, char c, char *s) {
  while (*s != '\0') {
    putfont8(vram, xsize, x, y, c, font + *s * 16);
    s++;
    x += 8;
  }
}

void putfont8(char *vram, int xsize, int x, int y, char c, char *font) {
  int i;
  char *p, d /* data */;
  for (i = 0; i < 16; i++) {
    p = vram + (y + i) * xsize + x;
    d = font[i];
    if ((d & 0x80) != 0) {
      p[0] = c;
    }
    if ((d & 0x40) != 0) {
      p[1] = c;
    }
    if ((d & 0x20) != 0) {
      p[2] = c;
    }
    if ((d & 0x10) != 0) {
      p[3] = c;
    }
    if ((d & 0x08) != 0) {
      p[4] = c;
    }
    if ((d & 0x04) != 0) {
      p[5] = c;
    }
    if ((d & 0x02) != 0) {
      p[6] = c;
    }
    if ((d & 0x01) != 0) {
      p[7] = c;
    }
  }
  return;
}
