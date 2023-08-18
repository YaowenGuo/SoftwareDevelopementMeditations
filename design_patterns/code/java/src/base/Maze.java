package base;
/**
* We don't care how to save data and how to search data in Design patterns. 
* They are target of Data structure and algorithm. So we don't need to 
* focus on how to save a room and find it.
*/
public class Maze implements Cloneable {
    public void addRoom(Room room) {
        // Add a room in some way.
    }

    public Room roomNo(int roomNum) {
        // A search mathod to get target room.
        return null;
    }

    @Override
    public Maze clone() {
        return new Maze();
    }
}
