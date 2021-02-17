#include <stdio.h>
#include <stdlib.h>

#include "types.h"
#include "semantic.tab.h"


extern "C" int yylex();
%}
%option yylineno
%option noyywrap

%x comentarioMulLinea
%x cadena
digito [0-9]
entero [1-9]{digito}*
id [_]*[a-zA-Z_][a-zA-Z0-9_]*
%%
\n { } /*Salto de linea*/
[ \t] {} /*Espacio en blanco */
\'.\' { yylval.cadena_ -> valor = std::string(yytext);
\'.[^\'] {printf("Caracter invalido en linea %d\n",yylineno);}

\" BEGIN(cadena);
<cadena>\n {} /*Salto de linea*/
<cadena>[^\"]* {}
<cadena>[\"] {BEGIN(INITIAL);
			  yylval.cadena_ -> valor = std::string(yytext);
			  yylval.cadena_ -> tipo = CADENA; return CADENA;} /*Cadena terminada*/

"¡*" BEGIN(comentarioMulLinea);
<comentarioMulLinea>[^"*¿"] {}
<comentarioMulLinea>"*¿" {BEGIN(INITIAL); return COMENTARIO;}
{entero} {yylval.numero_ = new numero(); yylval.numero_ -> valor = std::string(yytext);
		yylval.numero_ -> tipo = INT; return ENTERO;}
"int" {return INT;} 
"double" {return DOUB;}
"float" {return FLOAT;}
"char" {return CHAR;}
"void" {return VOID;}
"struct" {return STRUCT;}
"if" {return IF;}
"else" {return ELSE;}
"while" {return WHILE;}
"do" {return DO;}
"switch" {return SWITCH;}
"return" {return RETURN;}
"break" {return BREAK;}
"case" {return CASE;}
"default" {return DEFAULT;}
"true" {return TRU;}
"false" {return FALS;}
"func" {return FUNC;}
"print" {return PRINT;}
{id} { yylval.id_ = new std::string(yytext); return ID;}
"+" {return MAS;}
"-" {return RES;}
"*" {return MULT;}
"/" {return DIV;}
"%" {return MOD;}
"(" {return LPAR;}
")" {return RPAR;}
"[" {return LCOR;}
"]" {return RCOR;}
"{" {return LLAV;}
"}" {return RLAV;}
"==" {return EQ;}
"<=" {return LEQ;}
">=" {return GEQ;}
"<" {return MEN;}
">" {return MAY;}
"!=" {return DIF;}
"=" {return ASIGN;}
":" {return PUNTOS;}
";" {return TERM;}
"," {return COMA;}
"||" {return OR;}
"&&" {return AND;}
"!" {return NOT;}
. {printf("\x1b[Aqui hay un error %d por culpa de %s\x1b[0m \n",yylineno,yytext);exit(0);}
%%
