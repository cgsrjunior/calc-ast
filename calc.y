%{
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
int yyerror (char const *s);
extern int yylex (void);
%}

%code requires { #include "asd.h" }

%token<valor> NUMBER
%token PLUS TIMES
%token LEFT RIGHT
%token END
%token END_OF_FILE

%union {
  double valor;
  asd_tree_t *arvore;
}


%type<arvore> E
%type<arvore> T
%type<arvore> F

%define parse.error verbose
%start Input

%%

Input: /* A entrada vazia é válida */;
Input: Input Line

Line: END
Line: END_OF_FILE { return EOF; }
Line: E END { printf("Expressão aritmética reconhecida com sucesso.\n"); asd_print_graphviz($1); asd_free($1); }

E: E PLUS T { $$ = asd_new($1->label + $3->label); asd_add_child($$, $1); asd_add_child($$, $3); }
E: T { $$ = $1; }

E: E TIMES T { $$ = asd_new($1->label * $3->label); asd_add_child($$, $1); asd_add_child($$, $3); }
T: F { $$ = $1; }

F: LEFT E RIGHT { $$ = $2; }
F: NUMBER { $$ = asd_new($1); }

%%

extern void yylex_destroy(void);
int yyerror(char const *s) {
  printf("%s\n", s);
  return 1;
}

int main() {
  int ret;
  do {
     ret = yyparse();
  } while(ret != EOF);
  printf("Fim.\n");
  yylex_destroy();
  return 0;
}
