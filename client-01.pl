#!/usr/bin/perl
#tcpclient.pl

use IO::Socket::INET;

# flush after every write
$| = 1;

my ($socket,$client_socket);

# creating object interface of IO::Socket::INET modules which internally creates 
# socket, binds and connects to the TCP server running on the specific port.
$socket = new IO::Socket::INET (
PeerHost => '127.0.0.1',
PeerPort => '80',
Proto => 'tcp',
) or die "ERROR in Socket Creation : $!\n";

print "TCP Connection Success.\n";

# write on the socket to server.
$data = "GET /favicon.ico HTTP/1.1\r\nHost: localhost\r\n\r\n";
print $socket "$data\n";
# we can also send the data through IO::Socket::INET module,
# $socket->send($data);

# read the socket data sent by server.
#$data = <$socket>;
# we can also read from socket through recv()  in IO::Socket::INET
# $socket->recv($data,1024);
$socket->recv($data,65536);
print "Received from Server : $data\n";

sleep (10);
$socket->close();