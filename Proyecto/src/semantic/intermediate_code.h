#ifndef INTERMEDIATE_CODE_H
#define INTERMEDIATE_CODE_H

#include <string>
#include <vector>

enum operaciones { 
	LABEL, 
	SUMA, 
	RESTA, 
	MULTIPLICACION, 
	DIVISION, 
	MODULO, 
	AMPLIAR, 
	REDUCIR,
	GOTO,
	IF_MEN_GOTO,
	IF_MAY_GOTO,
	IF_LEQ_GOTO,
	IF_GEQ_GOTO,
	IF_DIF_GOTO,
	IF_EQ_GOTO,
	PRINT_DIR,
	PARAM,
	CALL,
	ASIG,
	NEG,
};

std::string op_str(operaciones);

enum relacionales {
	REL_MEN,
	REL_MAY,
	REL_LEQ,
	REL_GEQ,
	REL_DIF,
	REL_EQ,
};

class cuadrupla {
	public:
		operaciones operacion;
		std::string operando1;
		std::string operando2;
		std::string resultado;
};


cuadrupla cuadrupla_label(std::string label);

cuadrupla cuadrupla_goto(std::string label);

cuadrupla cuadrupla_print_dir(std::string direccion);

cuadrupla cuadrupla_param(std::string direccion);

cuadrupla cuadrupla_call(std::string direccion);

cuadrupla cuadrupla_if_rel_goto(std::string, relacionales rel, std::string, std::string);

cuadrupla cuadrupla_asig(std::string, std::string);

void print_codigo(std::vector<cuadrupla>);

#endif
