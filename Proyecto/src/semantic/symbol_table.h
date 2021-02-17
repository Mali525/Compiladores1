#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <string>
#include <vector>
#include "types.h"

class simbolo {
	public:
		std::string id;
		tipo t;
		int direccion;
};

class tabla_simbolos {
	public:
		std::vector<simbolo> simbolos;

	
		tabla_simbolos() = default;
		
		tabla_simbolos(const tabla_simbolos& tabla);
		
		int busca(std::string);
	
		void inserta(simbolo);
    
		int get_direccion(std::string);
	
		tipo get_tipo(std::string);
		
		void clear();
};

void imprime_tabla(tabla_simbolos);

#endif
