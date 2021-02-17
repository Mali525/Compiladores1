#ifndef CODEGEN_CODE_GENERATOR_H
#define CODEGEN_CODE_GENERATOR_H

#include <vector>
#include "intermediate_code.h"
#include "symbol_table.h"

using namespace std;


class CodeGenerator {
public:
    tabla_simbolos tb;
    std::string ruta;


    void escribe_asm(std::vector<cuadrupla> cuadruplas);

    void genera_asm(cuadrupla c, std::ofstream &escribe_codigo);

    
};

#endif
