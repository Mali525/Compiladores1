#ifndef TYPES_H
#define TYPES_H

#include <string>
#include <vector>
#include <map>
#include "intermediate_code.h"

class simbolo;

class tipo {
	public:
		int tipo;
		int dim;
		std::vector<int> dimensiones;
		std::map<std::string,std::pair<int,int>> datos_struct;
};

class expresion {
	public:
		int tipo;
		std::string direccion;
		std::vector<cuadrupla> code;
};

class numero {
	public:
		int tipo;
		std::string valor;
};

class cadena {
	public:
		int tipo;
		std::string valor;
};

class var_arg{
	public:
		std::vector<int> tams;
		int direccion_base;
		expresion exp;
};

class sentencia {
	public:
		std::string next;
		std::vector<cuadrupla> code;
		std::vector<std::string> next_list;
};

class asignacion {
	public:
		std::string izquierda;
		expresion derecha;
};

class condicion {
	public:
		std::string t;
		std::string f;
		std::vector<cuadrupla> code;
		std::vector<std::string> trues;
		std::vector<std::string> falses;
};

class funcion {
	public:
		std::vector<simbolo> argumentos;
		int tipo_r;
		std::string etiqueta;
};

#endif
