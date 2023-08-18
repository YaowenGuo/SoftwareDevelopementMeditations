//
// Created by Albert on 2020/12/4.
//

#ifndef DESIGN_PATTERNS_C_HEADERS_ENCHANCEDROOM_H
#define DESIGN_PATTERNS_C_HEADERS_ENCHANCEDROOM_H
#include "Room.h"
#include "Spell.h"

class EnchantedRoom: public Room {
public:
  EnchantedRoom(int roomNo, Spell*);
};

#endif //DESIGN_PATTERNS_C_HEADERS_ENCHANCEDROOM_H
