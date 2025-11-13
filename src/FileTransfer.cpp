#include "FileTransfer.hpp"

FileTransfer::FileTransfer(const std::string& filename,
							const std::string& sender,
							const std::string& receiver)
	: _listen_fd(-1), _transfer_fd(-1), _filename(filename),
		_filesize(0), _bytes_sent(0), _sender_nick(sender),
		_receiver_nick(receiver), _active(false) {

	//Open file and get size
	_file.open(filename.c_str(), std::ios::binary | std::ios::ate);
	if (_file.is_open()) {
		_filesize = static_cast<unsigned long>(_file.tellg());
		_file.seekg(0, std::ios::beg);
	}
}

FileTransfer::~FileTransfer() {
	abort();
}

unsigned long FileTransfer::_ipToLong(const std::string& ip) {
	struct in_addr addr;
	inet_pton(AF_INET, ip.c_str(), &addr);
	return ntohl(addr.s_addr);
}

std::string FileTransfer::_getLocalIP() {
	//Simplified - returns localhost; in production, get actual network interface IP
	return "127.0.0.1";
}

bool FileTransfer::setupListenSocket(int& port) {
	_listen_fd = socket(AF_INET, SOCK_STREAM, 0);
	if (_listen_fd < 0) {
		return false;
	}

	struct sockaddr_in addr;
	std::memset(&addr, 0, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = INADDR_ANY;
	addr.sin_port = 0; //Let system assign port

	if (bind(_listen_fd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
		close(_listen_fd);
		_listen_fd = -1;
		return false;
	}

	if (listen(_listen_fd, 1) < 0) {
		close(_listen_fd);
		_listen_fd = -1;
		return false;
	}

	//Get assigned port
	socklen_t len = sizeof(addr);
	if (getsockname(_listen_fd, (struct sockaddr*)&addr, &len) < 0) {
		close(_listen_fd);
		_listen_fd = -1;
		return false;
	}
	port = ntohs(addr.sin_port);

	//Set non-blocking
	int flags = fcntl(_listen_fd, F_GETFL, 0);
	if (flags < 0) {
		close(_listen_fd);
		_listen_fd = -1;
		return false;
	}
	if (fcntl(_listen_fd, F_SETFL, flags | O_NONBLOCK) < 0) {
		close(_listen_fd);
		_listen_fd = -1;
		return false;
	}

	return true;
}

std::string FileTransfer::generateDccSendMessage(int port) {
	if (!_file.is_open())
		return "";

	std::string ip = _getLocalIP();
	unsigned long ip_long = _ipToLong(ip);

	std::ostringstream oss;
	oss << "PRIVMSG " << _receiver_nick
		<< " :\001DCC SEND " << _filename << ""
		<< ip_long << " " << port << " "
		<< _filesize << "\001\r\n";

	_active = true;
	return oss.str();
}

bool FileTransfer::acceptConnection() {
	if (_listen_fd < 0) {
		return false;
	}

	struct sockaddr_in client_addr;
	socklen_t len = sizeof(client_addr);

	_transfer_fd = accept(_listen_fd, (struct sockaddr*)&client_addr, &len);
	if (_transfer_fd < 0) {
		return false;
	}

	//Close listening socket
	close(_listen_fd);
	_listen_fd = -1;

	std::cout << "DCC connection accepted for " << _filename << std::endl;
	return true;
}

bool FileTransfer::sendFileData() {
	if (_transfer_fd < 0 || !_file.is_open()) {
		return false;
	}

	char buffer[4096];
	_file.read(buffer, sizeof(buffer));

	//Using gcount() with explicit cast to get bytes read (C++98 compliant)
	std::streamsize bytes_read_stream = _file.gcount();
	size_t bytes_read = static_cast<size_t>(bytes_read_stream);

	if (bytes_read > 0) {
		ssize_t sent = send(_transfer_fd, buffer, bytes_read, 0);
		if (sent > 0) {
			_bytes_sent += static_cast<unsigned long>(sent);

			//Wait for acknoledgment (required by DCC protocol)
			unsigned long ack = 0;
			ssize_t recv_result = recv(_transfer_fd, &ack, sizeof(ack), 0);
			if (recv_result <= 0) {
				return false;
			}
			return true;
		}
		return false;
	}
	//No more data read
	return false;
}

bool FileTransfer::isComplete() const {
	return _bytes_sent >= _filesize;
	}

bool FileTransfer::isActive() const {
	return _active;
	}

unsigned long FileTransfer::getProgress() const {
	if (_filesize == 0) {
		return 0;
	}
	return (_bytes_sent * 100) / _filesize;
}

void FileTransfer::abort() {
	if (_listen_fd >= 0) {
		close(_listen_fd);
		_listen_fd = -1;
	}
	if (_transfer_fd >= 0) {
		close(_transfer_fd);
		_transfer_fd = -1;
	}
	if (_file.is_open()) { _file.close(); }
	_active = false;
}