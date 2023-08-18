#ifndef __HEADER_MAP_SITE__
#define __HEADER_MAP_SITE__
#include "create/prototype/Cloneable.h"

enum Direction { North, South, East, West };

class MapSite : public Cloneable {
public:
  bool enter() {
	return false;
  };
};

#endif
