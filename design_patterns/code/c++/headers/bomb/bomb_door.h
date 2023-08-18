#include "../Door.h"

#ifndef DESIGN_PATTERNS_BOMB_DOOR_H
#define DESIGN_PATTERNS_BOMB_DOOR_H

/**
 * A Door with a Bomb
 */
class BombDoor : public Door {
public:
  BombDoor(Room* = 0, Room* = 0, bool = false);
private:
  bool _bomb;
};

#endif //DESIGN_PATTERNS_BOMB_DOOR_H
