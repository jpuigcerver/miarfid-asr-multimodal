
all:
	g++ -o extract_mouth extract_mouth.cpp `pkg-config --cflags opencv` `pkg-config --libs opencv`
