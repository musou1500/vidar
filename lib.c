#include "lib.h"
#include <assert.h>
#include <stdarg.h>
#include <stdio.h>

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

static int nth_digit(int num, int n) {
  for (int i = 0; i <= n; i++) {
    if (n == i) {
      return num % 10;
    } else {
      num /= 10;
    }
  }
}

char *itoa(int n, char *buf, int radix) {
  int nlen = 0;
  int i = 0;
  do {
    nlen++;
    i++;
  } while (n > powi(10, i));

  for (i = 0; i < nlen; i++) {
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

char *strcpy(char *s1, const char *s2) {
  int i = 0;
  for (char c = *s2; c != '\0'; i++, c = *(s2 + i)) {
    *(s1 + i) = c;
  }

  *(s1 + i) = '\0';
  return s1;
}

int sprintf(char *s, const char *format, ...) {
  const char *p = format;
  va_list ap;
  va_start(ap, format);
  char buf[32];
  int w_len = 0;
  while (*p != '\0') {
    if (*p == '%') {
      int num = va_arg(ap, int);
      p++;
      switch (*p) {
      case 'd':
        itoa(num, buf, 10);
        int num_len = strlen(buf);
        strcpy(s, buf);
        s += num_len;
        w_len += num_len;
        break;
      }
      p += 2;
    } else {
      *s = *p;
      s++;
      p++;
      w_len++;
    }
  }
  va_end(ap);

  *s = '\0';
  s++;
  return w_len;
}
