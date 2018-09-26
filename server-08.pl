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


print "++Accepted New Client Connection From : $peer_address, $peer_port\n";

$data_length=0;
$client_data = "";

while (<$client_socket>) {

    if(/Content-Length: (\d+)/){
        $data_length = $1;
    }

    $client_data .= $_; 
    last if($_ =~ /^\s*$/);
    print;
}
#print $client_data;

$bytes_read = 0;

if ($data_length > 0){

    $output_buffer = $requested_url;
    $length = length $output_buffer;
    $data = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n";
    $data .= "Last-Modified: " . scalar(localtime) . "\r\n";
    $data .= "Content-Length: $length\r\n\r\n$output_buffer";
    print $client_socket "$data";
    shutdown($client_socket, 1);

    $client_data_body = "";
    $bytes_to_read = $data_length;

    my $bufsize = 8192; # typical size for i/o buffers
    my ( $databuf, $readbuf, $nread );
    while (( $nread = sysread($client_socket , $readbuf, $bufsize )) > 0 ) {
        $client_data .= $readbuf;
    }
    
    $client_socket->close();
    exit;
}

#print $client_data;
#print $bytes_total . "\n";
#exit;

@lines = split(/\r/, $client_data, 2);
$lines[0] =~ /([A-Z]+)\s*(\/[^ ]*)\s*HTTP/;
#print "requested_url: $2\n";
$requested_method = $1;
$requested_url = $2 ? $2 : "/"; #TODO decode HTTP encoded URLs

#print $lines[0] . "\n";
#print $requested_url . "\n\n";
print $requested_method . "\n";

if($requested_method eq "POST"){
    print $client_data;
    #exit;
}
 
if ($requested_url eq "/favicon.ico"){
	
	print "FAVICON\n";
	$output_buffer = "No favicon availible";
	$length = length $output_buffer;
	$data = "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain; charset=utf-8\r\n";
	$data .= "Last-Modified: " . scalar(localtime) . "\r\n";
	$data .= "Content-Length: $length\r\n\r\n$output_buffer";
	print $client_socket "$data";
	$client_socket->close();
 	next;
}
#print $requested_url ;

$output_buffer = "";



if($requested_url eq "/"){
	#print "requested_url: $requested_url\n";
	
	opendir(DIR, $dirname) or die "can't opendir $dirname: $!";
	while (defined($file = readdir(DIR))) {

		$output_buffer.= "<a href=\"/$file\">$file</a> <br />\n" if($file =~ /\.html$/);
	}
	closedir(DIR);
	
	$length = length $output_buffer;
	$data = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n";
	$data .= "Last-Modified: " . scalar(localtime) . "\r\n";
	$data .= "Content-Length: $length\r\n\r\n$output_buffer";
	print $client_socket "$data";
	$client_socket->close();
	#print "$data\n";
	
	next;
}


$requested_url = substr $requested_url, 1 if (length $requested_url > 1);
$requested_url_full_path = "$dirname/$requested_url";

$output_buffer = "";
if (! -f $requested_url_full_path) {
    $output_buffer = "File not found: $requested_url";
    $length = length $output_buffer;
    $data = "HTTP/1.1 404 Not Found\r\nContent-Type: text/html; charset=utf-8\r\n";
    $data .= "Date: " . scalar(localtime) . "\r\n";
    $data .= "Content-Length: $length\r\n\r\n$output_buffer";
    print $client_socket "$data";
    $client_socket->close();

    #print $data;
    next;
}

#print "requested file: $requested_url\n";
open( FILE, "< $dirname/$requested_url") or die ("Cannot open file");

while (defined($line = <FILE>) ) {
	$output_buffer .= $line;
}

#$output_buffer = $requested_url;
$length = length $output_buffer;
$data = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n";
$data .= "Last-Modified: " . scalar(localtime) . "\r\n";
$data .= "Content-Length: $length\r\n\r\n$output_buffer";
print $client_socket "$data";
$client_socket->close();
#print "$data\n";



}

$socket->close();
