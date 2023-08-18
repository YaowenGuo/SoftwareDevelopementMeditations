/******************* Abstract Factory ***********************/
#ifndef __HEADER_MAZE_FACTORY__
#define __HEADER_MAZE_FACTORY__

#include "../../Maze.h"
#include "../../Room.h"
#include "../../Door.h"
#include "../../Wall.h"

class MazeFactory {

public:
  Maze* makeMaze() const;
  virtual Wall* makeWall() const;
  virtual Room* makeRoom(int number) const;
  static Door* makeDoor(Room*, Room*) ;

  // ----- Singleton Start ------
  static MazeFactory* instance();

protected:
  MazeFactory();
private:
  static MazeFactory* _instance;
  // ---- Singleton end -----------
};

#endif
