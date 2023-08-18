#include "MapSite.h"
#include "create/prototype/Cloneable.h"
#ifndef __HEADER_ROOM__
#define __HEADER_ROOM__

#define MAP_SIDE_SIZE 4
class Room : public MapSite {
public:
  Room(int roomNo);
  Room(const Room &);

  MapSite* getSide(Direction) const;
  Room* clone() const;

  void setSide(Direction, MapSite*);
  void setNum(int num);
private:
  MapSite* _side[MAP_SIDE_SIZE];
  int _roomNumber;
};

#endif
