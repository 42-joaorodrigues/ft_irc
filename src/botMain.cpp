#include "Bot.hpp"
#include <cstdlib>

int main(int argc, char **argv) {
	if (argc != 4) {
		std::cerr << "Usage: ./ircbot <server> <port> <password>" << std::endl;
		return 1;
	}

	std::string server = argv[1];
	int port = std::atoi(argv[2]);
	std::string password = argv[3];

	Bot bot(server, port, "MyBot", password);

	if (!bot.connect()) {
		std::cerr << "Failed to connect" << std::endl;
		return 1;
	}

	bot.authenticate();
	sleep(2); //Waiting for authentication
	bot.joinChannel("#test");
	bot.messageLoop();
	bot.disconnect();

	return 0;
}