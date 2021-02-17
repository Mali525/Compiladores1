%{
  #include <stdio.h>
  #include "gram.tab.h"
  void yyerror(char *msg);
  extern int yylex();
%}

%union{
  struct{
  int ival;
  int tipo;
  }numero;
}

%token ENTERO
%token CADENA
%token ID
%token TERM
%token LPAR
%token INT
%token FLOAT
%token DOUB
%token CHAR
%token VOID
%token FUNC
%token IF
%token ELSE
%token WHILE
%token RETURN
%token BREAK
%token PRINT
%token SWITCH
%token DO
%token COMA
%token TRU
%token FALS
%token DEFAULT
%token CASE
%token PUNTOS
%token ASIGN
%token STRUCT
%left NOT
%left AND
%left OR
%left MEN
%left MAY
%left LEQ
%left GEQ
%left DIF
%left EQ
%left MAS
%left RES
%left MULT
%left DIV
%left MOD
%nonassoc LPAR RPAR
%nonassoc LCOR RCOR
%nonassoc LLAV RLAV

%start programa

%%
programa : declaraciones funciones {printf("Sin errores\n");};

declaraciones :
  /* vacio */
  |tipo lista TERM

tipo : INT ;
  | FLOAT;
  | DOUB;
  | CHAR;
  | VOID;
  | STRUCT LLAV declaraciones RLAV;

lista : lista COMA ID arreglo
  | ID arreglo

arreglo :
  /* vacio */
  | LCOR numeros RCOR arreglo ;

funciones :
  /* vacio */
  |FUNC tipo ID LPAR argumentos RPAR LLAV declaraciones sentencia RLAV funciones ;

argumentos :
  /* vacio */
  | lista_argumentos

lista_argumentos : lista_argumentos COMA tipo ID parte_arreglo ;
  | tipo ID parte_arreglo ;

parte_arreglo :
  /* vacio */
  | LCOR RCOR parte_arreglo;

sentencia : sentencia sentencia
  | IF LPAR condicion RPAR sentencia ;
  | IF LPAR condicion RPAR sentencia ELSE sentencia ;
  | WHILE LPAR condicion RPAR sentencia ;
  | DO sentencia WHILE LPAR condicion RPAR TERM ;
  | parte_izquierda ASIGN expresion TERM ;
  | RETURN expresion TERM ;
  | RETURN TERM ;
  | LLAV sentencia RLAV ;
  | SWITCH LPAR expresion RPAR LLAV casos predeterminado RLAV ;
  | BREAK TERM ;
  | PRINT expresion ;

casos :
    /* vacio */
    | CASE PUNTOS numeros sentencia predeterminado ;

predeterminado :
  /* vacio */
  | DEFAULT PUNTOS sentencia ;

parte_izquierda : ID ;
  | var_arreglo ;

var_arreglo : ID LCOR expresion RCOR ;
  | var_arreglo LCOR expresion RCOR ;

expresion : expresion MAS expresion ;
  | expresion RES expresion ;
  | expresion MULT expresion ;
  | expresion DIV expresion ;
  | expresion MOD expresion ;
  | var_arreglo ;
  | CADENA ;
  | numeros ;
  | ID LPAR parametros RPAR ;

numeros : ENTERO ;

parametros :
  /* vacio */
  | lista_param ;

lista_param : lista_param COMA expresion ;
  | expresion ;

condicion : condicion OR condicion ;
  | condicion AND condicion ;
  | NOT condicion ;
  | LPAR condicion RPAR ;
  | expresion relacional ;
  | expresion ;
  | TRU ;
  | FALS ;

relacional : MEN ; | MAY ; | LEQ ; | GEQ ; | DIF ; | EQ ;
%%

void yyerror(char *msg) { printf("ERROR: %s\n",msg); }
