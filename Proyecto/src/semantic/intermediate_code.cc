#include <iostream>
#include "intermediate_code.h"
#include "intermediate_code.h"

std::string op_str(operaciones op) {
	if(op == LABEL)          return "LABEL";
	if(op == SUMA)           return "SUMA";
	if(op == RESTA)          return "RESTA";
	if(op == MULTIPLICACION) return "MULTIPLICACION";
	if(op == DIVISION)       return "DIVISION";
	if(op == MODULO)         return "MODULO";
	if(op == AMPLIAR)        return "AMPLIAR";
	if(op == REDUCIR)        return "REDUCIR";
	if(op == GOTO)           return "GOTO";
	if(op == IF_MEN_GOTO)    return "IF_MEN_GOTO";
	if(op == IF_MAY_GOTO)    return "IF_MAY_GOTO";
	if(op == IF_LEQ_GOTO)    return "IF_LEQ_GOTO";
	if(op == IF_GEQ_GOTO)    return "IF_GEQ_GOTO";
	if(op == IF_DIF_GOTO)    return "IF_DIF_GOTO";
	if(op == IF_EQ_GOTO)     return "IF_EQ_GOTO";
	if(op == PRINT_DIR)      return "PRINT_DIR";
	if(op == PARAM)          return "PARAM";
	if(op == CALL)           return "CALL";
	return "";
}

cuadrupla cuadrupla_label(std::string label) {
	cuadrupla c;
	c.operacion = LABEL;
	c.resultado = label;
	return c;
}

cuadrupla cuadrupla_goto(std::string next) {
	cuadrupla c;
	c.operacion = GOTO;
	c.resultado = next;
	return c;
}

cuadrupla cuadrupla_print_dir(std::string direccion) {
	cuadrupla c;
	c.operacion = PRINT_DIR;
	c.operando1 = direccion;
	return c;
}

cuadrupla cuadrupla_if_rel_goto(std::string addr1, 
	                              relacionales rel, 
	                              std::string addr2, 
	                              std::string label) {
	cuadrupla c;
	operaciones op;
	if(rel == REL_MEN) op = IF_MEN_GOTO;
	if(rel == REL_MAY) op = IF_MAY_GOTO;
	if(rel == REL_LEQ) op = IF_LEQ_GOTO;
	if(rel == REL_GEQ) op = IF_GEQ_GOTO;
	if(rel == REL_DIF) op = IF_DIF_GOTO;
	if(rel == REL_EQ)  op = IF_EQ_GOTO;
	c.operacion = op;
	c.operando1 = addr1;
	c.operando2 = addr2;
	c.resultado = label;
	return c;
}

cuadrupla cuadrupla_param(std::string direccion) {
	cuadrupla c;
	c.operacion = PARAM;
	c.operando1 = direccion;
	return c;
}

cuadrupla cuadrupla_call(std::string label) {
	cuadrupla c;
	c.operacion = CALL;
	c.operando1 = label;
	return c;
}
cuadrupla cuadrupla_asig(std::string x, std::string y) {
	cuadrupla c;
	c.operacion = ASIG;
	c.operando1 = y;
	c.resultado = y;
	return c;
}

void print_codigo(std::vector<cuadrupla> codigo) {
	std::cout << "operacion / operando1 / operando2 / resultado" << std::endl;
	for(auto c : codigo) {
		std::cout << op_str(c.operacion) << " " << "(" << c.operacion << ") / ";
		std::cout << c.operando1 << " / ";
		std::cout << c.operando2 << " / ";
		std::cout << c.resultado << " / ";
		std::cout << std::endl;
	}
}
