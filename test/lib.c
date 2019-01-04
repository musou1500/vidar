#include "../lib.h"

int main(int argc, const char *argv[])
{

  char buf[32];
  // powi
  assert(powi(10, 0) == 1);
  assert(powi(10, 1) == 10);
  assert(powi(10, 2) == 100);
  assert(strlen("hello") == 5);
  
  // strcpy
  char *src = "nyaa";
  strcpy(buf, src);
  assert(strcmp(src, buf) == 0);

  // nth_digit
  assert(nth_digit(114514, 0) == 4);
  assert(nth_digit(114514, 1) == 1);
  assert(nth_digit(114514, 2) == 5);
  
  // itoa
  itoa(114514, buf, 10);
  printf("%s\n", buf);
  assert(strcmp(buf, "114514") == 0);
  return 0;
}

