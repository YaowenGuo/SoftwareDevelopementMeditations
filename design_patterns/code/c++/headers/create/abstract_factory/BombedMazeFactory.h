//
// Created by Albert on 2020/12/4.
//

#ifndef DESIGN_PATTERNS_C_HEADERS_CREATE_ABSTRACT_FACTORY_BOMBEDMAZEFACTORY_H
#define DESIGN_PATTERNS_C_HEADERS_CREATE_ABSTRACT_FACTORY_BOMBEDMAZEFACTORY_H
#include "MazeFactory.h"

class BombedMazeFactory: public MazeFactory {
public:
  BombedMazeFactory();
  Wall* makeWall() const;
  Room* makeRoom(int num) const;
};

#endif //DESIGN_PATTERNS_C_HEADERS_CREATE_ABSTRACT_FACTORY_BOMBEDMAZEFACTORY_H
