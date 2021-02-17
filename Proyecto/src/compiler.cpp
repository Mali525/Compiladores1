/**
 * Principal del compilador.
 */
#include <iostream>
#include <fstream>
#include <map>
#include <stack>
#include <queue>
#include <set>
#include "SimpleCodeGenerator.h"

class CodeGenerator;

extern tabla_simbolos tabla_de_simbolos;
extern vector<cuadrupla> codigo_intermedio;

extern void yyerror(char *msg);
extern int yyparse();
extern int yywrap();
extern FILE *yyin;

/**
 * Aquí se realiza el análisis del archivo de entrada.
 */
int main(int argc, char **argv)
{
	using namespace std;

	if(argc < 2) return -1;
	FILE *f = fopen(argv[1], "r");
	if(!f) return -1;
	yyin = f;
	std::cout << "Compilando: " << argv[1] << std::endl;
	yyparse();
	std::cout << std::endl;

	CodeGenerator codifier;
	codifier.ruta = std::string(argv[2]);
	codifier.tb = tabla_de_simbolos;

	std::cout << "Código resultante: ";
	std::cout << codifier.ruta << std::endl;
	codifier.escribe_asm(codigo_intermedio);
	std::cout << "Hecho!" << std::endl;

	fclose(f);
}
