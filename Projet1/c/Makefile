CC = gcc
CFLAGS = -Wall 

SRC = headerParser.c
OBJ = headerParser

all: $(OBJ)

$(OBJ): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(OBJ)

clean:
	rm -f $(OBJ)

fclean: clean
	rm -f *~

re: fclean all
