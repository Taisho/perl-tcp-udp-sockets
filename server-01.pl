#!/usr/bin/perl
#tcpserver.pl

use IO::Socket::INET;

# flush after every write
$| = 1;

my ($socket,$client_socket);
my ($peeraddress,$peerport);
$dirname = glob("~/Deutsch/");

# creating object interface of IO::Socket::INET modules which internally does 
# socket creation, binding and listening at the specified port address.
$socket = new IO::Socket::INET (
LocalHost => '127.0.0.1',
LocalPort => '5000',
Proto => 'tcp',
Listen => 5,
Reuse => 1
) or die "ERROR in Socket Creation : $!\n";

print "SERVER Waiting for client connection on port 5000";

while(1)
{
# waiting for new client connection.
$client_socket = $socket->accept();

# get the host and port number of newly connected client.
$peer_address = $client_socket->peerhost();
$peer_port = $client_socket->peerport();

print "Accepted New Client Connection From : $peeraddress, $peerport\n ";

# write operation on the newly accepted client.

# we can also send the data through IO::Socket::INET module,
# $client_socket->send($data);

# read operation on the newly accepted client
#$data = <$client_socket>;
# we can also read from socket through recv()  in IO::Socket::INET
# $client_socket->recv($data,1024);
$client_socket->recv($data,1024);

@lines = split(/\r/, $data, 2);
$lines[0] =~ /\/[^ ]+/;
$requested_url = $&; #TODO decode HTTP decoded URLs
#print $requested_url ;

$output_buffer = "";

if($requested_url == "/"){
	
	opendir(DIR, $dirname) or die "can't opendir $dirname: $!";
	while (defined($file = readdir(DIR))) {

		$output_buffer.= "$file\n" if($file =~ /\.html$/);
	}
	closedir(DIR);	

}

$length = length $output_buffer;
$data = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: $length\r\n\r\n$output_buffer";
print $client_socket "$data\n";

#print "Received from Client : $data\n”"
}

$socket->close();