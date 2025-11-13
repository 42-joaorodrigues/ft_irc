#ifndef FILETRANSFER_HPP
#define FILETRANSFER_HPP

#include <string>
#include <map>
#include <fstream>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <fcntl.h>
#include <sstream>
#include <iostream>
#include <cstring>

class FileTransfer {
private:
	int _listen_fd;
	int _transfer_fd;
	std::string _filename;
	unsigned long _filesize;
	unsigned long _bytes_sent;
	std::string _sender_nick;
	std::string _receiver_nick;
	std::ifstream _file;
	bool _active;

	std::string _getLocalIP();
	unsigned long _ipToLong(const std::string& ip);

public:
	FileTransfer(const std::string& filename,
				const std::string& sender,
				const std::string& received);
	~FileTransfer();

	//Public methods
	bool setupListenSocket(int& port);
	std::string generateDccSendMessage(int port);
	bool acceptConnection();
	bool sendFileData();

	//Status
	bool isComplete() const;
	bool isActive() const;
	unsigned long getProgress() const;

	//Cleanup
	void abort();
};

#endif //FILETRANSFER_HPP