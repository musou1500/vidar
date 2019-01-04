#include "lib.h"
#include <stdarg.h>
#include <stdio.h>
#include <stdbool.h>

static int powi(int n, int m) {
  if (m == 0) {
    return 1;
  }

  int res = n;
  for (int i = 1; i < m; i++) {
    res *= n;
  }
  return res;
}

int nth_digit(int num, int n) {
  if (num < 0) {
    num *= -1;
  }

  for (int i = 0; i <= n; i++) {
    if (n == i) {
      return num % 10;
    } else {
      num /= 10;
    }
  }

  return 0;
}

char *itoa(int n, char *buf, int radix) {
  bool is_negative = n < 0;
  if (is_negative) {
    n *= -1;
  }

  int nlen = 0;
  int i = 0;
  do {
    nlen++;
    i++;
  } while (n > powi(10, i));
  
  if (is_negative) {
    buf[0] = '-';
    nlen++;
  }

  for (i = is_negative ? 1 : 0; i < nlen; i++) {
    // 0 in ascii: 48
    buf[i] = nth_digit(n, nlen - (i + 1)) + 48;
  }
  buf[i] = '\0';
  return buf;
}

int strlen(char *s) {
  int i = 0;
  while (*(s + i) != '\0')
    i++;
  return i;
}

char *strcpy(char *dst, const char *src) {
  int i = 0;
  for (char c = *src; c != '\0'; i++, c = *(src + i)) {
    *(dst + i) = c;
  }

  *(dst + i) = '\0';
  return dst;
}

int sprintf(char *dst, const char *format, ...) {
  // buffer for itoa
  char buf[32];

  // written size
  int w_len = 0;

  va_list ap;
  va_start(ap, format);
  
  while (*format != '\0') {
    if (*format == '%') {
      format++;
      int num, num_len;
      switch (*format) {
      case 'd':
        // convert num to str
        num = va_arg(ap, int);
        itoa(num, buf, 10);
        num_len = strlen(buf);

        // copy to dst
        strcpy(dst, buf);
        dst += num_len;
        w_len += num_len;
        format++;
        break;
      }
    } else {
      *dst = *format;
      dst++;
      format++;
      w_len++;
    }
  }

  va_end(ap);
  *dst = '\0';
  w_len++;
  return w_len;
}

#ifdef TEST
#include <assert.h>

static bool str_eq(char *a, char *b) {
  while (*a != '\0' || *b != '\0') {
    if (*a != *b) {
      return false;
    }

    a++;
    b++;
  }

  return true;
}

int main(int argc, const char *argv[])
{
  // powi
  char buf[32];
  assert(powi(10, 0) == 1);
  assert(powi(10, 1) == 10);
  assert(powi(10, 2) == 100);
  assert(strlen("hello") == 5);

  // strcpy
  char *src = "nyaa";
  strcpy(buf, src);
  assert(str_eq("nyaa", buf));
  strcpy(buf + 4, src);
  assert(str_eq("nyaanyaa", buf));

  // nth_digit
  assert(nth_digit(114514, 0) == 4);
  assert(nth_digit(114514, 1) == 1);
  assert(nth_digit(114514, 2) == 5);
  assert(nth_digit(114514, 2) == 5);
  assert(nth_digit(-114514, 2) == 5);
  
  // itoa
  itoa(114514, buf, 10);
  assert(str_eq(buf, "114514"));
  itoa(-114514, buf, 10);
  assert(str_eq(buf, "-114514"));
  
  // sprintf
  sprintf(buf, "scrnx");
  assert(str_eq(buf, "scrnx"));
  sprintf(buf, "scrnx = %d scrny = %d", 320, 200);
  assert(str_eq(buf, "scrnx = 320 scrny = 200"));
  return 0;
}
#endif
