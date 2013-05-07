
all:
	g++ -o extract_mouth2 extract_mouth.cpp `pkg-config --cflags opencv` `pkg-config --libs opencv`
