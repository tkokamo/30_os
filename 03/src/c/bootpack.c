#include "func.h"

void init_pallete(void);
void set_pallete(int start, int end, unsigned char *rgb);

void Main(void)
{
  unsigned char *p;
  int i;

  init_pallete();

  p = (char *) 0xa0000; // vram ranges from 0xa0000 to 0xaffff

  for (i = 0; i <= 0xffff; i++) {
    p[i] = i & 0x0f;
  }

  for (;;)
    io_hlt();
  
}


void init_palette(void)
{
  static unsigned char table_rgb[] = {
    0x00, 0x00, 0x00, //black
    0xff, 0x00, 0x00, //light red
    0x00, 0xff, 0x00, //light green
    0xff, 0xff, 0x00, //light yellow
    0x00, 0x00, 0xff, //light blue
    0xff, 0x00, 0xff, //light purple
    0x00, 0xff, 0xff, //light skyblue
    0xff, 0xff, 0xff, //white
    0xc6, 0xc6, 0xc6, //light gray
    0x84, 0x00, 0x00, //dark red
    0x00, 0x84, 0x00, //dark green
    0x84, 0x84, 0x00, //dark yellow
    0x00, 0x00, 0x84, //dark blue
    0x84, 0x00, 0x84, //dark purple
    0x00, 0x84, 0x84, //dark skyblue
    0x84, 0x84, 0x84  //dark gray
  };
  set_pallete(0, 15, table_rgb);
  return;
}

void set_palette(int start, int end, unsigned char *rgb)
{
  int i, eflags;
  eflags = io_load_eflags(); // save eflags value
  io_cli();
  io_out8(0x03c8, start);
  for (i = start; i <= end; i++) {
    io_out8(0x03c9, rgb[0] / 4);
    io_out8(0x03c9, rgb[1] / 4);
    io_out8(0x03c9, rgb[2] / 4);
    rgb += 8;
  }
  io_store_eflags(eflags); // store eflags
  return ;
}
