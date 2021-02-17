
#include "backpatch.h"
std::vector<std::string> merge(std::vector<std::string> v1,
	                             std::vector<std::string> v2) {
	v1.insert( v1.end(), v2.begin(), v2.end() );
	return v1;
}
std::vector<cuadrupla> backpatch(std::vector<std::string> etiquetas,
	                               std::string reemplazo,
	                               std::vector<cuadrupla> codigo) {
	std::vector<cuadrupla> copia_codigo(codigo);
	for(int i = 0; i < codigo.size(); i++)
	for(auto etiqueta : etiquetas) {
		if(etiqueta == codigo[i].resultado)
			copia_codigo[i].resultado = reemplazo;
	}
	return copia_codigo;
}
