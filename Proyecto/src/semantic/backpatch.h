#ifndef BACKPATCH_H
#define BACKPATCH_H

#include <string>
#include <vector>

#include "intermediate_code.h"

std::vector<std::string> merge(std::vector<std::string>, std::vector<std::string>);

std::vector<cuadrupla> backpatch(std::vector<std::string>, std::string, std::vector<cuadrupla>);

#endif
