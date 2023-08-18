#include "MapSite.h"
#include "Room.h"
#include "create/prototype/Cloneable.h"
#ifndef __HEADER_DOOR__
#define __HEADER_DOOR__

class Door : public MapSite {
public:
  Door(Room* = 0, Room* = 0);
  Door(const Door &);

  Room* otherSideFrom(Room*);
  Door* clone() const;

  Door* setRoom(Room*, Room*);

private:
  Room* _room1;
  Room* _room2;
  bool _isOpen;
};
#endif
