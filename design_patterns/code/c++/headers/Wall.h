#include "MapSite.h"
#include "create/prototype/Cloneable.h"

#ifndef __HEADER_Wall__
#define __HEADER_Wall__

class Wall : public MapSite {
public:
  Wall();
  Wall(const Wall &);
  Wall* clone() const;
};

#endif
