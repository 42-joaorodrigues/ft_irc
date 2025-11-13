#include "Bot.hpp"

Bot::Bot(const std::string& server, int port,
				const std::string& nick, const std::string& password)
	:  _sockfd(-1), _server(server), _port(port),
		_nick(nick), _password(password) {}

Bot::~Bot() {
	if (_sockfd != -1)
		close(_sockfd);
}

bool Bot::_connectSocket()
{
	struct sockaddr_in serv_addr;

	_sockfd = socket(AF_INET, SOCK_STREAM, 0);
	if (_sockfd < 0)
	{
		std::cerr << "Error: cannot create socket" << std::endl;
		return false;
	}

	memset(&serv_addr, 0, sizeof(serv_addr));
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_port = htons(_port);

	if (inet_pton(AF_INET, _server.c_str(), &serv_addr.sin_addr) <= 0)
	{
		std::cerr << "Error: invalid server address" << std::endl;
		return false;
	}

	if (::connect(_sockfd, (struct sockaddr*)&serv_addr,
				sizeof(serv_addr)) < 0)
	{
		std::cerr << "Error: connection failed" << std::endl;
		return false;
	}

	std::cout << "Connected to " << _server << ":" << _port << std::endl;
	return true;
}

void Bot::_sendMessage(const std::string& message) {
	if (send(_sockfd, message.c_str(), message.length(), 0) < 0) {
		std::cerr << "Error: failed to send message" << std::endl;
	}
}

std::string Bot::_readMessage() {
	char buffer[512];
	int n = recv(_sockfd, buffer, sizeof(buffer) - 1, 0);

	if (n <= 0)
		return "";

	buffer[n] = '\0';
	return std::string(buffer);
}

std::vector<std::string> Bot::_split(const std::string& str, char delimiter) {
	std::vector<std::string> tokens;
	std::stringstream ss(str);
	std::string token;

	while (std::getline(ss, token, delimiter)) {
		tokens.push_back(token);
	}
	return tokens;
}

void Bot::_handlePing(const std::string& message) {
	size_t pos = message.find("PING");
	if (pos != std::string::npos) {
		std::string response = "PONG" + message.substr(pos + 4);
		_sendMessage(response);
		std::cout << "Respond to PING" << std::endl;
	}
}

void Bot::_handlePrivmsg(const std::string& message) {
	//Example PRIVMSG format:
	//:sender!user@host PRIVMSG channel :message text
	size_t senderEnd = message.find('!');
	if (senderEnd == std::string::npos) return;

	std::string sender = message.substr(1, senderEnd - 1);

	size_t privmsgPos = message.find("PRIVMSG");
	if (privmsgPos == std::string::npos) return;

	size_t channelStart = privmsgPos + 8;
	size_t channelEnd = message.find(' ', channelStart);
	std::string channel = message.substr(channelStart, channelEnd - channelStart);

	size_t textStart = message.find(':', channelEnd);
	if (textStart == std::string::npos) return;

	std::string text = message.substr(textStart + 1);
	// Remove trailing newline
	if (!text.empty() && text[text.length() - 1] == '\n') 
		text = text.substr(0, text.length() - 1);

		_parseAndRespond(channel, sender, text);
}

void Bot::_parseAndRespond(const std::string& channel,
							const std::string& sender,
							const std::string& text) {
	// Check if message is a command (starting with '!')
	if (text.empty() || text[0] != '!') return;

	std::string cmd = text.substr(1);

	//Handle different commands
	if (cmd == "hello") {
		std::string response = "PRIVMSG" + channel + " :Hello " + sender + "!\r\n";
		_sendMessage(response);
	} else if (cmd == "help") {
		std::string response = "PRIVMSG" + channel + " :Available commands: !hello, !help, !uptime\r\n";
		_sendMessage(response);
	} else if (cmd == "uptime") {
		std::string response = "PRIVMSG" + channel + " :Bot is running!\r\n";
		_sendMessage(response);
	}
}

bool Bot::connect() { return _connectSocket; }

void Bot::authenticate() {
	//Send password if required
	if (!_password.empty()) {
		std::string passMsg = "PASS " + _password + "\r\n";
		_sendMessage(passMsg);
	}

	//Send NICK and USER commands
	std::string nickMsg = "NICK " + _nick + "\r\n";
	_sendMessage(nickMsg);

	std::string userMsg = "USER " + _nick + " 0 * : " + _nick + "\r\n";
	_sendMessage(userMsg);

	std::cout << "Sent authentication commands" << std::endl;
}

void Bot::joinChannel(const std::string& channel) {
	std::string joinMsg = "JOIN " + channel + "\r\n";
	_sendMessage(joinMsg);
	std::cout << "Joining channel " << channel << std::endl;
}

void Bot::messageLoop() {
	std::cout << "Bot message loop started" << std::endl;
	while (true) {
		std::string message = _readMessage();

		if (message.empty()) continue;

		std::cout << "Received: " << message;

		if (message.find("PING") != std::string::npos) {
			_handlePing(message);
		} else if (message.find("PRIVMSG") != std::string::npos) {
			_handlePrivmsg(message);
		}
	}
}

void Bot::disconnect() {
	if (_sockfd != -1) {
		close(_sockfd);
		_sockfd = -1;
	}
}