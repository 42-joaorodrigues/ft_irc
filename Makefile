NAME	= ircserv
BOT		= ircbot
CC		= c++
FLAGS	= -Werror -Wextra -Wall -std=c++98
RM		= rm -rf

SRC		= src/main.cpp src/Server.cpp src/Client.cpp src/Channel.cpp src/FileTransfer.cpp
SRC_BOT		= src/Bot.cpp src/main_bonus.cpp
OBJ		= $(SRC:%.cpp=obj/%.o)
BOT_OBJ	= $(SRC_BOT:%.cpp=obj/%.o)

all: $(NAME)

obj/%.o : %.cpp
	mkdir -p $(dir $@)
	$(CC) $(FLAGS) -c $< -o $@ -I inc

$(NAME): $(OBJ)
	$(CC) $(FLAGS) $(OBJ) -o $(NAME)

bonus: $(SRC_BOT)

$(BOT): $(BOT_OBJ)
	$(CC) $(FLAGS) $(BOT_OBJ) -o $(BOT)

clean:
	$(RM) obj

fclean: clean
	$(RM) $(NAME) $(BOT)

re: fclean all

.PHONY: all clean fclean re