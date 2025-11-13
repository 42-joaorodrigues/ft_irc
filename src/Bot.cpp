#include "Bot.hpp"

Bot::Bot(const std::string& server, int port,
				const std::string& nick, const std::string& password)
	:  _sockfd(-1), _server(server), _port(port),
		_nick(nick), _password(password) {}

Bot::~Bot() {
	if (_sockfd != -1)
		close(_sockfd);
}

bool Bot::_connectSocket() {
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
	// First, check if there's already a complete message in the buffer
	size_t pos = _buffer.find("\n");
	if (pos != std::string::npos) {
		std::string message = _buffer.substr(0, pos);
		_buffer = _buffer.substr(pos + 1);
		// Remove trailing \r if present
		if (!message.empty() && message[message.length() - 1] == '\r') {
			message = message.substr(0, message.length() - 1);
		}
		return message;
	}

	// No complete message in buffer, read more data from socket
	char buffer[512];
	int n = recv(_sockfd, buffer, sizeof(buffer) - 1, 0);

	if (n <= 0)
		return "";

	buffer[n] = '\0';
	_buffer += std::string(buffer, n);

	// Try to extract a complete message again
	pos = _buffer.find("\n");
	if (pos != std::string::npos) {
		std::string message = _buffer.substr(0, pos);
		_buffer = _buffer.substr(pos + 1);
		// Remove trailing \r if present
		if (!message.empty() && message[message.length() - 1] == '\r') {
			message = message.substr(0, message.length() - 1);
		}
		return message;
	}

	return ""; //No complete message yet
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
		std::string response = "PONG " + message.substr(pos + 4);
		_sendMessage(response);
		std::cout << "Respond to PING" << std::endl;
	}
}

void Bot::_handlePrivmsg(const std::string& message) {
	//Example: :sender!user@host PRIVMSG channel :message text
	std::cout << 1;
	size_t senderEnd = message.find('!');
	if (senderEnd == std::string::npos || senderEnd == 0)
		return;
	std::cout << 2;

	std::string sender = message.substr(1, senderEnd - 1);

	size_t privmsgPos = message.find("PRIVMSG");
	if (privmsgPos == std::string::npos)
		return;
	std::cout << 3;

	size_t channelStart = privmsgPos + 8;
	if (channelStart >= message.length())
		return;
	std::cout << 4;


	size_t channelEnd = message.find(' ', channelStart);
	if (channelEnd == std::string::npos)
		return;

	std::cout << 5;
	std::string channel = message.substr(channelStart, channelEnd - channelStart);

	size_t textStart = message.find(':', channelEnd);
	if (textStart == std::string::npos)
		return;

	std::cout << 6;
	std::string text = message.substr(textStart + 1);

	std::cout << "textStart: " << text << std::endl;

	// Remove trailing whitespace characters (\r, \n, spaces, etc.)
	while (!text.empty() && (text[text.length() - 1] == '\r' || 
							  text[text.length() - 1] == '\n' ||
							  text[text.length() - 1] == ' ' ||
							  text[text.length() - 1] == '\t')) {
		text = text.substr(0, text.length() - 1);
	}
	
	_parseAndRespond(channel, sender, text);
}

void Bot::_parseAndRespond(const std::string& channel,
							const std::string& sender,
							const std::string& text) {
	// Check if message is a command (starting with '!')
	if (text.empty() || text[0] != '!') return;

	std::string cmd = text.substr(1);

	// Determine where to send the response
	// If it's a direct message (channel is bot's nick), respond to the sender
	// Otherwise, respond to the channel
	std::string target = (channel == _nick) ? sender : channel;

	std::cout << "CMD being received: " << cmd << std::endl;
	//Handle different commands
	if (cmd == "hello") {
		std::string response = "PRIVMSG " + target + " :Hello " + sender + "!\r\n";
		_sendMessage(response);
	} else if (cmd == "help") {
		std::string response = "PRIVMSG " + target + " :Available commands: !hello, !help, !uptime\r\n";
		_sendMessage(response);
	} else if (cmd == "uptime") {
		std::string response = "PRIVMSG " + target + " :Bot is running!\r\n";
		_sendMessage(response);
	}
}

bool Bot::connect() { return _connectSocket(); }

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

		if (message.empty()) {
			//Check if connection is still alive
			char buffer[1];
			int n = recv(_sockfd, buffer, 1, MSG_PEEK | MSG_DONTWAIT);
			if (n == 0) {
				std::cerr << "Connection closed by server" << std::endl;
				break;
			}
			continue;
		}

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