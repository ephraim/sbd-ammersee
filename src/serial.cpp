#include <iomanip>
#include <iostream>
#include <QDebug>

#ifndef _WIN32
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#else
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#include <share.h>
#endif

#include "serial.h"
#include "misc.h"
#include <QSerialPortInfo>

using namespace std;

#ifndef _WIN32
bool operator ==(const struct termios &a, const struct termios &b)
{
	if(a.c_iflag != b.c_iflag)
		return false;

	if(a.c_oflag != b.c_oflag)
		return false;

	if(a.c_cflag != b.c_cflag)
		return false;

	if(a.c_lflag != b.c_lflag)
		return false;

	for(int i = 0; i < NCCS; i++)
		if(a.c_cc[i] != b.c_cc[i])
			return false;

	return true;
}
#endif

Serial::Serial(string port, int baudrate/* = 115200*/, int stop/* = 1*/, int parity/* = 0*/, int timeout/* = 10*/)
#ifndef _WIN32
: fd(-1)
#endif
{
	if(port.empty())
		return;

#ifndef _WIN32
    fd = open(port.c_str(), O_RDWR);
#else
    serialport.setPort(QSerialPortInfo(QString(port.c_str())));
    if(!setParameters(baudrate, stop, parity, timeout)) {
        cerr << "ERROR: failed to set the parameters." << endl;
        return;
    }

    serialport.open(QIODevice::ReadWrite);
#endif
    if(!isOpen()) {
        cerr << "ERROR: could not open " << port << ". Error: " << hex << setw(8) << setfill('0') << errno << endl;
        return;
    }

}

bool Serial::isOpen()
{
#ifndef _WIN32
    return fd >= 0;
#else
    return serialport.isOpen();
#endif
}

Serial::~Serial()
{
#ifndef _WIN32
    if(fd >= 0)
        close(fd);
#else
    serialport.close();
#endif
}

bool Serial::setParameters(int baudrate/* = 115200*/, int stop/* = 1*/, int parity/* = 0*/, int timeout/* = 10*/)
{
#ifndef _WIN32
	struct termios ts;
	struct termios tmp;
	speed_t speed = B115200;

	if(fd < 0) {
		cerr << "ERROR: filedescriptor invalid. Could not set parameters" << endl;
		return false;
	}

	switch(baudrate) {
		case 9600: speed = B9600; break;
		case 115200: speed = B115200; break;
		default:
			cerr << "WARNING: unknown baudrate specified: " << dec << baudrate << ". Using default: 115200" << endl;
			break;
	}

	cfmakeraw(&ts);
	cfsetspeed(&ts, speed);

	if(stop == 2) // two stopbits
		ts.c_cflag |= CSTOPB;
	else  // one stopbits
		ts.c_cflag &= ~CSTOPB;

	if(parity == 1) { // with Even Parity
		ts.c_cflag |= PARENB;
		ts.c_cflag &= ~PARODD;
	}
	else if(parity == 2) { // with Odd Parity
		ts.c_cflag |= PARENB;
		ts.c_cflag |= PARODD;
	}
	else { // without any Parity
		ts.c_cflag &= ~PARENB;
		ts.c_cflag &= ~PARODD;
	}

	ts.c_cc[VMIN] = 1;
	ts.c_cc[VTIME] = timeout * 10; // entity: 1/10 seconds

	if(tcsetattr(fd, TCSAFLUSH, &ts) == 0) {
		tcgetattr(fd, &tmp);
		return ts == tmp;
	}
#else
    if(!serialport.setDataBits(QSerialPort::Data8))
        return false;
    if(!serialport.setBaudRate((qint32)baudrate))
        return false;
    if(!serialport.setStopBits((QSerialPort::StopBits)stop))
        return false;
    if(!serialport.setParity((QSerialPort::Parity)parity))
        return false;
    this->timeout = timeout * 100;
#endif
    return true;
}

vector<uint8_t> Serial::write_read(vector<uint8_t> v)
{
    int i;
	vector<uint8_t> ret;

	write_read_mutex.lock();
	i = write(v);
    if(i != static_cast<int>(v.size()))
		return vector<uint8_t>();
	ret = read();
    if(ret.size() == 0)
        qDebug() << "ERROR: Nothing read!!";
	write_read_mutex.unlock();
	return ret;
}

int Serial::write(const vector<uint8_t> &v)
{
    uint16_t crc;
	vector<uint8_t> data;
    int size = 2; // + crc(2)

    crc = genCrc(v);
    size += static_cast<int>(v.size());

    data.push_back(size & 0xff);
    data.push_back(static_cast<unsigned char>(size >> 8));
	data.insert(data.end(), v.begin(), v.end());

    data.push_back(crc & 0xff);
    data.push_back(crc >> 8);

    qDebug() << "WRITE(" << (int)data.size() << "): " << b2h(data).c_str() << endl;
#ifndef _WIN32
	size = ::write(fd, (const void*)data.data(), (size_t)data.size());
#else
    size = serialport.write((const char*)data.data(), data.size());
    if(!serialport.waitForBytesWritten(timeout))
        return -1;
#endif

    if(size >= 4)
        size -= 4; // - crc(2) - size(2)

	return size;
}

vector<uint8_t> Serial::read()
{
	vector<uint8_t> v;
	uint16_t size = 0;
	uint16_t crc;
    vector<uint8_t> tmp;


#ifndef _WIN32
    uint16_t count = 0;
    tmp.resize(2);
    size = ::read(fd, tmp.data(), (size_t)tmp.size());
    if(size < 2)
        return v;
    size = static_cast<uint16_t>(tmp[0] | tmp[1]<<8);

    tmp.clear();
    tmp.resize(size);
    while(size != v.size()) {
        count = ::read(fd, tmp.data(), (size_t)tmp.size());
        v.insert(v.end(), tmp.begin(), tmp.begin() + count);
    }
#else
    serialport.setReadBufferSize(1);
    while(tmp.size() < 2) {
        char d;
        if(serialport.read(&d, 1) == 1)
            tmp.push_back(d);
        else {
            if(!serialport.bytesAvailable() && !serialport.waitForReadyRead())
                return v;
        }
    }

    size = static_cast<uint16_t>(tmp[0] | tmp[1]<<8);

    while(size != v.size()) {
        char d;
        if(serialport.read(&d, 1) == 1)
            v.push_back(d);
        else {
            if(!serialport.bytesAvailable() && !serialport.waitForReadyRead())
                return v;
        }
    }
#endif

    qDebug() << "READ(" << (int)size << "): " << b2h(v).c_str() << endl;
    crc = static_cast<uint16_t>(v[v.size() - 2] | v[v.size() - 1]<<8);
	v.erase(v.end() - 2, v.end());

	if(crc != genCrc(v))
		return vector<uint8_t>();

	return v;
}

uint16_t Serial::genCrc(vector<uint8_t> v)
{
	uint16_t ret = 0xFFFF;
	uint16_t b;

	for(unsigned int i = 0; i < v.size(); i++) {
		b = v[i];
        b ^= static_cast<uint8_t>(ret);
        b ^= static_cast<uint8_t>(b << 4);
        ret = static_cast<uint16_t>(((b << 8) | (ret >> 8)) ^ (b >> 4) ^ (b << 3));
	}

	return ret;
}
