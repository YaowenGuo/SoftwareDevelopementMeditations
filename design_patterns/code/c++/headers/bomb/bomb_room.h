#ifndef DESIGN_PATTERNS_BOMB_ROOM_H
#define DESIGN_PATTERNS_BOMB_ROOM_H

#include "../Room.h"
class RoomWithABomb : public Room {
public:
  RoomWithABomb(int roomNo, bool hasBomb = false);

private:
  bool _hasBomb;
};
#endif // DESIGN_PATTERNS_BOMB_ROOM_H
