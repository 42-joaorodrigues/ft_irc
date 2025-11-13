NAME		= ircserv
BOT			= ircbot
CC			= c++
FLAGS		= -Werror -Wextra -Wall -std=c++98
RM			= rm -rf

# Server files
SRC			= src/main.cpp src/Server.cpp src/Client.cpp src/Channel.cpp src/FileTransfer.cpp
OBJ			= $(SRC:%.cpp=obj/%.o)

# Bot files
BONUS_SRC	= src/Bot.cpp src/main_bonus.cpp
BONUS_OBJ	= $(BONUS_SRC:%.cpp=obj/%.o)

all: $(NAME)

obj/%.o : %.cpp
	mkdir -p $(dir $@)
	$(CC) $(FLAGS) -c $< -o $@ -I inc

$(NAME): $(OBJ)
	$(CC) $(FLAGS) $(OBJ) -o $@

bonus: all $(BOT)

$(BOT): $(BONUS_OBJ)
	$(CC) $(FLAGS) $(BONUS_OBJ) -o $@

clean:
	$(RM) obj

fclean: clean
	$(RM) $(NAME) $(BOT)

re: fclean all

.PHONY: all clean fclean re