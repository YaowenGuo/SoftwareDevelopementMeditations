#include "create/abstract_factory/MazeFactory.h"
#include "create/prototype/MazePrototypeFactory.h"
#include "Maze.h"
#include "create/builder/MazeBuilder.h"
/********************** Use Abstract Factory **********************/

class MazeGame {
public:
  Maze* createMaze(MazeFactory &);


  // Prototype implement Abstract Factory. --- start
  Maze* createMaze(MazePrototypeFactory &);
  // Prototype implement Abstract Factory. --- end


  // ------ Builder start ----------
  Maze* createMaze(MazeBuilder &builder);
  // ------ Builder end ------------
  Maze* createComplexMaze(MazeBuilder &builder);
};
