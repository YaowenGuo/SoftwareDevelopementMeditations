# OBJS = Main.o Door.o Wall.o Room.o Maze.o MazeGame.o MazeFactory.o
#
# COMPILER = javac
#
# main.class: $(OBJS)
# 	COMPILER $(OBJS) -o main
# Main.o: ./source/Main.cpp
#  	COMPILER -c $<
# %.o: ./source/%.cpp ./include/%.h
# 	COMPILER -c $<
#
# # %.o: %.asm
# # 	$(ASM) $(ASM_KERNEL_FLAGS) -o $@ $<
#
# clean:
# 	rm ./*.class

IDIR =.
LIBS =-cp ../JAR/junit-4.10.jar:../..
JAVAPATH = /usr/lib/jdk/jdk1.80_131
CC = javac
CFLAGS =$(LIBS)

all: ConvertCSVTest.java
	$(CC) $(CFLAGS) ConvertCSVTest.java

clean:
	rm *.class
