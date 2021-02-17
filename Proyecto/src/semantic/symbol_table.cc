

#include "symbol_table.h"
#include <iostream>


tabla_simbolos::tabla_simbolos(const tabla_simbolos& tabla) {
	
	simbolos = tabla.simbolos;
}


int tabla_simbolos::busca(std::string etiqueta) {
	for(int i = 0; i < simbolos.size(); i++)
		if(simbolos[i].id == etiqueta) return i;
	return -1;
}


void tabla_simbolos::inserta(simbolo s) {
	simbolos.push_back(s);
}


int tabla_simbolos::get_direccion(std::string etiqueta) {
	return simbolos[busca(etiqueta)].direccion;
}


tipo tabla_simbolos::get_tipo(std::string etiqueta) {
	return simbolos[busca(etiqueta)].t;
}


void tabla_simbolos::clear() {
	simbolos.clear();
}

void imprime_tabla(tabla_simbolos tabla) {
	std::cout << "Tabla de símbolos:" << std::endl;
	for(auto s : tabla.simbolos)
		std::cout << s.id << " " << s.t.tipo << " " << s.direccion << std::endl;
	std::cout << std::endl;
}
