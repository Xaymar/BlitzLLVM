A TCP or UDP connection is a stream, so everything on [[BlitzBasic-Streams]] works on it: `WriteInt`, `ReadLine` and so on. IP addresses are whole numbers with the first part in the highest byte, which [DottedIP](BlitzBasic-Network#dottedip) turns into text like `127.0.0.1`.

**TCP** is a connection: one side calls [CreateTCPServer](BlitzBasic-Network#createtcpserver) and [AcceptTCPStream](BlitzBasic-Network#accepttcpstream), the other [OpenTCPStream](BlitzBasic-Network#opentcpstream), and both can then read and write. Data arrives in order, and reading waits for data until the timeout of [TCPTimeouts](BlitzBasic-Network#tcptimeouts) is over.

**UDP** is a series of messages: you write into the stream to build a message, send it with [SendUDPMsg](BlitzBasic-Network#sendudpmsg), and the other side takes the next one with [RecvUDPMsg](BlitzBasic-Network#recvudpmsg) and reads it from its stream. Messages may be lost or arrive out of order. Only IPv4 addresses are supported.

## AcceptTCPStream
Takes the next connection that a client made to a TCP server and returns a stream for it. If nobody connected within the accept timeout of [TCPTimeouts](BlitzBasic-Network#tcptimeouts), which is 0 until you set it, it returns 0, so call it in a loop.

```blitzbasic
;run
TCPTimeouts 1000, 1000
server = CreateTCPServer(40751)
client = OpenTCPStream("127.0.0.1", 40751)
connection = 0
For i = 1 To 50
	connection = AcceptTCPStream(server)
	If connection <> 0 Then Exit
	Delay 20
Next
WriteLine client, "hello server"
Print ReadLine$(connection)
CloseTCPStream client
CloseTCPStream connection
CloseTCPServer server
```

```text
hello server
```
@param tcp_server  The server from [CreateTCPServer](BlitzBasic-Network#createtcpserver).
@returns A TCP stream, or 0 when nobody connected.

## CloseTCPServer
Stops a TCP server. Streams that it accepted stay open.
@param tcp_server  The server to close.

## CloseTCPStream
Closes a TCP stream. The other side sees the stream end once it has read everything that was sent.
@param tcp_stream  The stream to close.

## CloseUDPStream
Closes a UDP stream and gives its port back.
@param udp_stream  The stream to close.

## CountHostIPs
Looks up a host name and returns how many addresses it has. Use [HostIP](BlitzBasic-Network#hostip) to get them. A name that cannot be found returns 0.

```blitzbasic
;run
Print CountHostIPs("localhost") >= 1
```

```text
1
```
@param host_name  A host name such as `localhost`, or an address as text.
@returns The number of addresses.
@gap Returns 1 when the name resolves and 0 otherwise, never more, even for hosts with several addresses.

## CreateTCPServer
Starts listening for TCP connections on a port. Clients connect with [OpenTCPStream](BlitzBasic-Network#opentcpstream) and you take them with [AcceptTCPStream](BlitzBasic-Network#accepttcpstream).
@param port  The port to listen on.
@returns A server handle, or 0 when the port cannot be used, for example because another program already listens on it.

## CreateUDPStream
Creates a UDP stream that can send and receive messages. Use a fixed port when other programs have to find you, and no port to let the system pick one.

```blitzbasic
;run
a = CreateUDPStream(40752)
b = CreateUDPStream(40753)
UDPTimeouts 1000
WriteInt a, 12345
SendUDPMsg a, $7F000001, 40753
size = RecvUDPMsg(b)
Print size
Print ReadInt(b)
Print UDPMsgPort(b)
CloseUDPStream a
CloseUDPStream b
```

```text
4
12345
40752
```
@param port  The port to receive on. Defaults to 0, which lets the system pick one.
@returns A UDP stream, or 0 when the port cannot be used.

## DottedIP
@returns An address as text, with its four parts separated by dots.

```blitzbasic
;run
Print DottedIP$($7F000001)
Print DottedIP$($C0A80164)
```

```text
127.0.0.1
192.168.1.100
```
@param IP  The address as a whole number, with the first part in the highest byte.

## HostIP
@returns One of the addresses found by the last [CountHostIPs](BlitzBasic-Network#counthostips), as a number for [DottedIP](BlitzBasic-Network#dottedip).
@param host_index  The address to take, counting from 1.
@gap Only index 1 gives an address, and it is always the one of `localhost` (127.0.0.1) whatever name was asked for in [CountHostIPs](BlitzBasic-Network#counthostips). Every other index returns 0.

## OpenTCPStream
Connects to a TCP server. It returns once the connection is made or has failed.

```blitzbasic
;run
; nothing listens on this port
Print OpenTCPStream("127.0.0.1", 40754)
```

```text
0
```
@param server       The address of the server, as a name or as dotted numbers.
@param server_port  The port the server listens on.
@param local_port   The port to connect from. Defaults to 0, which lets the system pick one.
@returns A TCP stream, or 0 when the connection could not be made.

## RecvUDPMsg
Receives the next UDP message, if one has arrived, and makes it readable from the stream. It waits for up to the time set by [UDPTimeouts](BlitzBasic-Network#udptimeouts), which is 0 until you set it, so it does not wait by default. [UDPMsgIP](BlitzBasic-Network#udpmsgip) and [UDPMsgPort](BlitzBasic-Network#udpmsgport) then say who sent it.
@param udp_stream  The stream to receive on.
@returns The size of the message in bytes, or 0 when there was none.

## SendUDPMsg
Sends what you wrote to the stream as one message and empties the stream for the next one.
@param udp_stream  The stream to send from.
@param dest_ip     The receiver's address as a number.
@param dest_port   The receiver's port. Defaults to 0, which means the port of this stream.

## TCPStreamIP
@returns The address on the other end of a TCP stream, as a number for [DottedIP](BlitzBasic-Network#dottedip).
@param tcp_stream  The stream.

## TCPStreamPort
@returns The port on the other end of a TCP stream.
@param tcp_stream  The stream.

## TCPTimeouts
Sets how long to wait. Reading from a TCP stream waits for data until the read timeout is over, and [AcceptTCPStream](BlitzBasic-Network#accepttcpstream) waits for a client until the accept timeout is over. The defaults are 10000 milliseconds for reading and 0 for accepting.
@param read_millis    Read timeout in milliseconds.
@param accept_millis  Accept timeout in milliseconds.

## UDPMsgIP
@returns The address of the sender of the last message that [RecvUDPMsg](BlitzBasic-Network#recvudpmsg) received.
@param udp_stream  The stream.

## UDPMsgPort
@returns The port of the sender of the last message that [RecvUDPMsg](BlitzBasic-Network#recvudpmsg) received.
@param udp_stream  The stream.

## UDPStreamIP
@returns The address of this computer that the stream receives on.
@gap Always the `localhost` address (127.0.0.1) and not the address of a network adapter, so it cannot be given to other computers.
@param udp_stream  The stream.

## UDPStreamPort
@returns The port the stream receives on.
@param udp_stream  The stream.

## UDPTimeouts
Sets how long [RecvUDPMsg](BlitzBasic-Network#recvudpmsg) waits for a message. The default is 0, which returns right away. Negative values count as 0.
@param recv_timeout  Time to wait in milliseconds.
