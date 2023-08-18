//
// Created by Albert on 2020/12/4.
//

#include "../../../headers/create/abstract_factory/EnchantedMazeFactory.h"


EnchantedMazeFactory::EnchantedMazeFactory() = default;

Spell* EnchantedMazeFactory::castSpell() const {
  return 0;
}
Door* EnchantedMazeFactory::makeDoor(Room* from, Room* to) const {
  return new DoorNeedingSpell(from, to);
}
