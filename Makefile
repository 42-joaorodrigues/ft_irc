NAME		= ircserv
BONUS_NAME	= ircbot
CC			= c++
FLAGS		= -Werror -Wextra -Wall -std=c++98
RM			= rm -rf

# Server files
SRC			= src/main.cpp src/Server.cpp src/Client.cpp src/Channel.cpp
OBJ			= $(SRC:%.cpp=obj/%.o)

# Bot files
BONUS_SRC	= src/Bot.cpp src/botMain.cpp
BONUS_OBJ	= $(BONUS_SRC:%.cpp=obj/%.o)

all: $(NAME)

obj/%.o : %.cpp
	mkdir -p $(dir $@)
	$(CC) $(FLAGS) -c $< -o $@ -I inc

$(NAME): $(OBJ)
	$(CC) $(FLAGS) $(OBJ) -o $@

bonus: $(BONUS_NAME)

$(BONUS_NAME): $(BONUS_OBJ)
	$(CC) $(FLAGS) $(BONUS_OBJ) -o $@

clean:
	$(RM) obj

fclean: clean
	$(RM) $(NAME) $(BONUS_NAME)

re: fclean all

.PHONY: all clean fclean re