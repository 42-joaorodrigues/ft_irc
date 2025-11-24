###############################################################################
#                        ft_irc by joao-alm & viceda-s                        #
#                                                                             #
###############################################################################

#──────────────────────────────Compilation Settings───────────────────────────#

NAME	= ircserv
BOT		= ircbot
CC		= c++
FLAGS	= -Werror -Wextra -Wall -std=c++98
O_DIR	= obj/
RM		= rm -rf

all: $(HEADER) $(NAME)

#───────────────────────────────Animation Variables───────────────────────────#

YELLOW			= \033[38;2;255;248;147m# FFF893
PINK			= \033[38;2;231;133;190m# E785BE
GREEN			= \033[38;2;129;223;164m# 81DFA4
RESET			= \033[0m

HEADER			= $(O_DIR)/.header
BAR_SIZE		= 43
COMPILED_COUNT	= $(O_DIR)/.compiled_count

#────────────────────────────Mandatory Compilation────────────────────────────#

SERVER_SRC	= main.cpp Server.cpp Client.cpp Channel.cpp
SERVER_SRC	:= $(addprefix server/, $(SERVER_SRC))

FT_SRC		= FileTransfer.cpp

SRC			= $(SERVER_SRC) $(FT_SRC)
SRC			:= $(addprefix src/, $(SRC))
OBJ			= $(SRC:%.cpp=$(O_DIR)/mandatory/%.o)
INC			= -I inc/

OBJ_COUNT 	= $(words $(OBJ))

# Compile .c to .o
$(O_DIR)/mandatory/%.o: %.cpp
	@mkdir -p $(dir $@)
	@$(CC) $(FLAGS) -c $< -o $@ $(INC);
	@current=$$(cat $(COMPILED_COUNT) 2>/dev/null || echo 0); \
	bar_size=$(BAR_SIZE) \
	percent=$$(( ($$current * 100) / $(OBJ_COUNT) )); \
	filled=$$(( ($$current * bar_size) / $(OBJ_COUNT) )); \
	printf "%-12.12s %-10.10s " "Compiling" "$(NAME)"; \
	for j in $$(seq 1 $$filled); do printf "⣿"; done; \
	for j in $$(seq $$((filled + 1)) $$bar_size 2>/dev/null); do printf "⣀"; done; \
	printf " $$percent%%\r"; \
	next=$$(( $$current + 1 )); \
	echo $$next > $(COMPILED_COUNT)

# Compile ircserv
$(NAME): $(HEADER) $(OBJ)
	@$(CC) $(FLAGS) $(OBJ) -o $@
	@make .success ACTION="Compiling" OBJECT="$(NAME)" --no-print-directory
	@rm -f $(COMPILED_COUNT)

#────────────────────────────────Bonus Compilation────────────────────────────#

BOT_SRC		= Bot.cpp main_bonus.cpp
B_SRC		:= $(addprefix src/bot/, $(BOT_SRC))
B_OBJ		= $(B_SRC:%.cpp=$(O_DIR)/bonus/%.o)
B_INC			= -I inc/

B_OBJ_COUNT	= $(words $(B_OBJ))

# Compile .c to .o
$(O_DIR)/bonus/%.o: %.cpp
	@mkdir -p $(dir $@)
	@$(CC) $(FLAGS) -c $< -o $@ $(B_INC);
	@current=$$(cat $(COMPILED_COUNT) 2>/dev/null || echo 0); \
	bar_size=$(BAR_SIZE) \
	percent=$$(( ($$current * 100) / $(B_OBJ_COUNT) )); \
	filled=$$(( ($$current * bar_size) / $(OBJ_COUNT) )); \
	printf "%-12.12s %-10.10s " "Compiling" "$(BOT)"; \
	for j in $$(seq 1 $$filled); do printf "⣿"; done; \
	for j in $$(seq $$((filled + 1)) $$bar_size 2>/dev/null); do printf "⣀"; done; \
	printf " $$percent%%\r"; \
	next=$$(( $$current + 1 )); \
	echo $$next > $(COMPILED_COUNT)

bonus: $(BOT)

# Compile Bot
$(BOT): $(HEADER) $(B_OBJ)
	@$(CC) $(FLAGS) $(B_OBJ) -o $@
	@make .success ACTION="Compiling" OBJECT="$(BOT)" --no-print-directory
	@rm -f $(COMPILED_COUNT)

#────────────────────────────────Cleaning Commands────────────────────────────#

clean:
	@rm -rf $(O_DIR)
	@make .success ACTION="Cleaning" OBJECT="objects" --no-print-directory

fclean:
	@rm -rf $(O_DIR)
	@make .success ACTION="Cleaning" OBJECT="objects" --no-print-directory
	@rm -rf $(BOT)
	@make .success ACTION="Cleaning" OBJECT="$(BOT)" --no-print-directory
	@rm -rf $(NAME)
	@make .success ACTION="Cleaning" OBJECT="$(NAME)" --no-print-directory

re: fclean all bonus

#─────────────────────────────────Animation Rules─────────────────────────────#

YELLOW	= \033[38;2;255;248;147m# FFF893
PINK	= \033[38;2;231;133;190m# E785BE
GREEN	= \033[38;2;129;223;164m# 81DFA4
RESET	= \033[0m

header: $(HEADER)

$(HEADER):
	@mkdir -p $(dir $@)
	@touch $@
	@printf "$(PINK)\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣶⣾⣿⣿⣿⣿⣶⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⢿⣿⣿⣿⣽⣿⣿⣿⣿⣷⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣾⣿⣿⣿⣿⣿⣿⢿⡿⣿⣿⣿⣿⣿⣿⣿⣟⣿⡿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⠟⠉⠁⠀⠀⠀⠀⠀⠉⠈⠉⠛⠛⢿⣿⣿⢿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠸⢻⣿⣿⡟⢁⡴⠶⠶⣶⣶⣤⡀⠀⠀⠀⢀⣤⣤⣄⣀⣀⢸⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣷⡏⢀⣴⣶⣲⢿⣿⠆⠀⠀⢠⣿⣿⣭⣥⣄⡉⢳⡟⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⡿⠃⠈⠛⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠉⠉⠹⠗⠙⡇⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⢀⡄⢿⣿⠁⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⡺⡿⣿⣿⡄⠀⠀⠀⠀⠀⠀⢶⣾⠿⠶⠷⣶⠀⠀⠀⠀⠀⠀⢠⣿⣵⣿⡀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⣿⡀⢻⣿⣷⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⣼⣿⡋⢏⡃⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⠿⣿⣟⠀⠀⠀⠀⠀⢀⡴⠖⠚⠛⠓⠶⣤⡀⠀⠀⠀⠀⢸⣿⣦⠟⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠛⣿⠀⠀⠀⠀⠀⠀⠀⠐⢦⣤⣤⡦⠈⠀⠀⠀⠀⠀⣸⠷⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣦⣀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣨⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣷⣼⣦⡀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣶⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣷⣶⣦⣶⣶⣶⣾⣿⣿⣿⣿⢿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠟⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠈⢿⡿⠛⠛⠛⠛⠛⠛⠛⠉⠉⠀⠀⠀⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠈⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⡇⠀⠀⠀⠀⠈⠻⢷⣤⣀⡴⠚⠀⠀⠀⠀⠀⠀⣾⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⢴⣾⣿⠁⠀⠀⠀⠀⠀⠀⠀⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⣿⣿⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⠀⠀⢀⣠⢞⡅⠈⢿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣰⡿⠃⠀⣌⠲⢄⡀⠀⠀⠀⠀⠀\n"
	@printf "⠀⠀⠀⠀⣀⢴⣫⠾⠋⠀⠀⠀⠈⠛⢿⣷⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⠾⠟⠉⠀⠀⠀⠈⠳⢤⡉⠒⢤⣀⠀⠀\n"
	@printf "⣀⠤⢖⣮⠷⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠛⠓⠒⠒⠒⠒⠒⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠳⢤⣈⠑⠲\n"
	@printf "⣷⠶⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠳⡾       by joao-alm & viceda-s\n"
	@printf "$(YELLOW)\n"
	@printf "⣿⣿⣿⣿⣿⣿⣿⣿\ ⣿⣿\           ⣿⣿⣿⣿⣿⣿\            ⣿⣿⣿⣿⣿⣿\  ⣿⣿⣿⣿⣿⣿⣿\  ⣿⣿⣿⣿⣿⣿⣿⣿\ \n"
	@printf "⣿⣿  _____|⣿⣿ |          \_⣿⣿  _|          ⣿⣿  __⣿⣿\ ⣿⣿  __⣿⣿\ \____⣿⣿  |\n"
	@printf "⣿⣿ |    ⣿⣿⣿⣿⣿⣿\           ⣿⣿ |   ⣿⣿⣿⣿⣿⣿\  ⣿⣿ /  \__|⣿⣿ |  ⣿⣿ |    ⣿⣿  / \n"
	@printf "⣿⣿⣿⣿⣿\  \_⣿⣿  _|          ⣿⣿ |  ⣿⣿  __⣿⣿\ ⣿⣿ |      ⣿⣿⣿⣿⣿⣿⣿  |   ⣿⣿  /  \n"
	@printf "⣿⣿  __|   ⣿⣿ |            ⣿⣿ |  ⣿⣿ |  \__|⣿⣿ |      ⣿⣿  __⣿⣿<   ⣿⣿  /   \n"
	@printf "⣿⣿ |      ⣿⣿ |⣿⣿\         ⣿⣿ |  ⣿⣿ |      ⣿⣿ |  ⣿⣿\ ⣿⣿ |  ⣿⣿ | ⣿⣿  /    \n"
	@printf "⣿⣿ |      \⣿⣿⣿⣿  |      ⣿⣿⣿⣿⣿⣿\ ⣿⣿ |      \⣿⣿⣿⣿⣿⣿  |⣿⣿ |  ⣿⣿ |⣿⣿  /     \n"
	@printf "\__|       \____/       \______|\__|       \______/ \__|  \__|\__/      $(RESET)\n\n"

.success:
	@printf "%-12.12s %-10.10s $(GREEN)" $(ACTION) $(OBJECT); \
	bar_size=$(BAR_SIZE); \
	for j in $$(seq 1 $$bar_size); do printf "⣿"; done; \
	printf " 100%%$(RESET)\n"

#────────────────────────────────Phony Targets───────────────────────────────#

.PHONY: all clean fclean re bonus