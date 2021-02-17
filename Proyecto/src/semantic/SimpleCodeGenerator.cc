

#include <fstream>
#include <iostream>
#include <string>
#include "SimpleCodeGenerator.h"

int casos(std::string op1, std::string op2);

std::string obtiene_offset(std::string elem);

bool es_numero(std::string op);

void CodeGenerator::escribe_asm(std::vector<cuadrupla> cuadruplas) {
    ofstream escribe_codigo;
    escribe_codigo.open(ruta.c_str(), ios::app);

    for (auto c : cuadruplas)
        genera_asm(c, escribe_codigo);

    escribe_codigo.close();
}

void CodeGenerator::genera_asm(cuadrupla c, std::ofstream &escribe_codigo) {
	auto op1 = c.operando1;
	auto op2 = c.operando2;
	auto res = c.resultado;

	int args_caso = casos(op1, op2);

	switch (c.operacion) {
		case LABEL:
			escribe_codigo << "_" << res << ":" << endl;
			return;

		case GOTO:
			escribe_codigo << "j   " << res << endl;
			return;

		case SUMA:
			switch (args_caso) {
				case 0:
					escribe_codigo << "li     $t0,   " << op1 << endl;
					escribe_codigo << "addi   $t0,   $t0,    " << op2 << endl;
					escribe_codigo << "sw     $t0,   " << obtiene_offset(res) << endl;
					return;

				case 1:
					escribe_codigo << "lw     $t0,   " << obtiene_offset(op1) << endl;
					escribe_codigo << "addi   $t0,   $t0,   " << op2 << endl;
					escribe_codigo << "sw     $t0,   " << obtiene_offset(res) << endl;
					return;

				case 2:
					escribe_codigo << "lw     $t0,   " << op2 << endl;
					escribe_codigo << "addi   $t0,   $t0,   " << op1 << endl;
					escribe_codigo << "sw     $t0,   " << obtiene_offset(res) << endl;
					return;

				case 3:
					escribe_codigo << "lw     $t0,   " << obtiene_offset(op1) << endl;
					escribe_codigo << "lw     $t1,   " << obtiene_offset(op2) << endl;
					escribe_codigo << "add    $t2,   $t0,   $t1" << endl;
					escribe_codigo << "sw     $t2,   " << obtiene_offset(res) << endl;
					return;

				default:
					std::cout << "Mal codigo intermedio SUMA" << endl;
					return;
			}

		case RESTA:

			switch (args_caso) {
				case 0:
					escribe_codigo << "li     $t0,   " << op1 << endl;
					escribe_codigo << "subi   $t0,   $t0,    " << op2 << endl;
					escribe_codigo << "sw     $t0,   " << obtiene_offset(res) << endl;
					return;

				case 1:
					escribe_codigo << "lw     $t0,   " << obtiene_offset(op1) << endl;
					escribe_codigo << "subi   $t0,   $t0,   " << op2 << endl;
					escribe_codigo << "sw     $t0,   " << obtiene_offset(res) << endl;
					return;

				case 2:
					escribe_codigo << "lw     $t0,   " << op2 << endl;
					escribe_codigo << "subi   $t0,   $t0,   " << op1 << endl;
					escribe_codigo << "sw     $t0,   " << obtiene_offset(res) << endl;
					return;

				case 3:
					escribe_codigo << "lw     $t0,   " << obtiene_offset(op1) << endl;
					escribe_codigo << "lw     $t1,   " << obtiene_offset(op2) << endl;
					escribe_codigo << "sub    $t2,   $t0,   $t1" << endl;
					escribe_codigo << "sw     $t2,   " << obtiene_offset(res) << endl;
					return;

				default:
					std::cout << "Mal codigo intermedio RESTA" << endl;
					return;
			}

		case MULTIPLICACION:

			switch (args_caso) {
				case 0:
					escribe_codigo << "li     $t0,   " << op1 << endl;
					escribe_codigo << "li     $t1,   " << op2 << endl;
					escribe_codigo << "mult   $t0,   $t1" << endl;
					escribe_codigo << "mflo   $t2" << endl;
					escribe_codigo << "sw     $t2,   " << obtiene_offset(res) << endl;
					return;

				case 1:
					escribe_codigo << "lw     $t0,   " << op1 << endl;
					escribe_codigo << "li     $t1,   " << op2 << endl;
					escribe_codigo << "mult   $t0,   $t1" << endl;
					escribe_codigo << "mflo   $t2" << endl;
					escribe_codigo << "sw     $t2,   " << obtiene_offset(res) << endl;
					return;

				case 2:
					escribe_codigo << "li     $t0,   " << op1 << endl;
					escribe_codigo << "lw     $t1,   " << op2 << endl;
					escribe_codigo << "mult   $t0,   $t1" << endl;
					escribe_codigo << "mflo   $t2" << endl;
					escribe_codigo << "sw     $t2,   " << obtiene_offset(res) << endl;
					return;

				case 3:
					escribe_codigo << "lw     $t0,   " << op1 << endl;
					escribe_codigo << "lw     $t1,   " << op2 << endl;
					escribe_codigo << "mult   $t0,   $t1" << endl;
					escribe_codigo << "mflo   $t2" << endl;
					escribe_codigo << "sw     $t2,   " << obtiene_offset(res) << endl;
					return;
			}

		case DIVISION:
			switch (args_caso) {
				case 0:
					escribe_codigo << "li     $t0,   " << op1 << endl;
					escribe_codigo << "li     $t1,   " << op2 << endl;
					escribe_codigo << "div    $t0,   $t1" << endl;
					escribe_codigo << "mflo   $t2" << endl;
					escribe_codigo << "sw     $t2,   " << obtiene_offset(res) << endl;
					return;

				case 1:
					escribe_codigo << "lw     $t0,   " << op1 << endl;
					escribe_codigo << "li     $t1,   " << op2 << endl;
					escribe_codigo << "div    $t0,   $t1" << endl;
					escribe_codigo << "mflo   $t2" << endl;
					escribe_codigo << "sw     $t2,   " << obtiene_offset(res) << endl;
					return;

				case 2:
					escribe_codigo << "li     $t0,   " << op1 << endl;
					escribe_codigo << "lw     $t1,   " << op2 << endl;
					escribe_codigo << "div    $t0,   $t1" << endl;
					escribe_codigo << "mflo   $t2" << endl;
					escribe_codigo << "sw     $t2,   " << obtiene_offset(res) << endl;
					return;

				case 3:
					escribe_codigo << "lw     $t0,   " << op1 << endl;
					escribe_codigo << "lw     $t1,   " << op2 << endl;
					escribe_codigo << "div    $t0,   $t1" << endl;
					escribe_codigo << "mflo   $t2" << endl;
					escribe_codigo << "sw     $t2,   " << obtiene_offset(res) << endl;
					return;
			}
	}
}

/**
 * Caso 1 : op1: constante, op2 : constante
 * Caso 2 : op1: identificador, op2: constante
 * Caso 3 : op1: constante, op2: identificador
 * Caso 4 : op1: identificador, op2: identificador
 * @param op1  operando
 * @param op2  oprando
 * @return
 */
int casos(std::string op1, std::string op2) {
    if (es_numero(op1) && es_numero(op2))
        return 0;
    if (!es_numero(op1) && es_numero(op2))
        return 1;
    if (es_numero(op1) && !es_numero(op2))
        return 2;
    if (!es_numero(op1) && !es_numero(op2))
        return 3;
    return -1;
}

bool es_numero(std::string line) {
	char* p;
	strtol(line.c_str(), &p, 10);
	return *p == 0;
}

std::string obtiene_offset(std::string s) { return s; }
