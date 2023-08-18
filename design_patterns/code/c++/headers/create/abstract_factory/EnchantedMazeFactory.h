//
// Created by Albert on 2020/12/4.
//

#ifndef DESIGN_PATTERNS_C_SRC_CREATE_ABSTRACT_FACTORY_ENCHANTEDMAZEFACTORY_H
#define DESIGN_PATTERNS_C_SRC_CREATE_ABSTRACT_FACTORY_ENCHANTEDMAZEFACTORY_H
#include "MazeFactory.h"
#include "../../Room.h"
#include "../../Door.h"
#include "../../EnchantedRoom.h"
#include "../../DoorNeedingSpell.h"

class EnchantedMazeFactory : public MazeFactory {
public:
  EnchantedMazeFactory();
  virtual Room* makeRoom(int num) const {
	return new EnchantedRoom(num, castSpell());
  }

  virtual Door* makeDoor(Room* from, Room* to) const;

private:
  Spell* castSpell() const;
};

#endif //DESIGN_PATTERNS_C_SRC_CREATE_ABSTRACT_FACTORY_ENCHANTEDMAZEFACTORY_H
