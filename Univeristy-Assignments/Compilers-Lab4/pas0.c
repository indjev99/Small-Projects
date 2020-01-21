/* pas0.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern void pmain();

static int save_argc;
static char **save_argv;
static FILE *infile;

int main(int argc, char **argv) {
     save_argc = argc;
     save_argv = argv;
     infile = stdin;
     pmain();
     return 0;
}

int argc(void) {
     return save_argc;
}

void argv(int n, char *s) {
     strcpy(s, save_argv[n]);
}

void print_string(char *s, int n) {
     printf("%.*s", n, s);
}

void print_num(int n) {
     printf("%d", n);
}

void print_char(int c) {
     printf("%c", c);
}

void newline(void) {
     printf("\n");
}

void read_char(char *c) {
     int c0 = fgetc(infile);
     *c = (c0 == EOF ? 127 : c0);
}

int open_in(char *s) {
     FILE *f = fopen(s, "r");
     if (f == NULL) return 0;
     if (infile != stdin) fclose(infile);
     infile = f;
     return 1;
}

void close_in(void) {
     if (infile == stdin) return;
     fclose(infile);
     infile = stdin;
}

void check(int n) {
     fprintf(stderr, "Array bound error on line %d\n", n);
     exit(2);
}

void nullcheck(int n) {
     fprintf(stderr, "Null pointer check on line %d\n", n);
     exit(2);
}

void *new(int n) {
     char *q = malloc(n);
     if (q == NULL) {
          fprintf(stderr, "Out of memory space\n");
          exit(2);
     }
     return q;
}

int int_div(int a, int b) {
     int quo = a / b, rem = a % b;
     if (rem != 0 && (rem ^ b) < 0) quo--;
     return quo;
}

int int_mod(int a, int b) {
     int rem = a % b;
     if (rem != 0 && (rem ^ b) < 0) rem += b;
     return rem;
}

