//
// Created by Albert on 2020/12/4.
//

#ifndef DESIGN_PATTERNS_C_HEADERS_DOORNEEDINGSPELL_H
#define DESIGN_PATTERNS_C_HEADERS_DOORNEEDINGSPELL_H
#include "Door.h"

class DoorNeedingSpell: public Door {
public:
  DoorNeedingSpell(Room* from, Room* to);
};

#endif //DESIGN_PATTERNS_C_HEADERS_DOORNEEDINGSPELL_H
