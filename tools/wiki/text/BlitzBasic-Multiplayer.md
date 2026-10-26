In a multiplayer game one program hosts the game and the others join it. Every program creates one or more players with [CreateNetPlayer](BlitzBasic-Multiplayer#createnetplayer), and players send messages to one player or to everyone. A program takes what arrived with [RecvNetMsg](BlitzBasic-Multiplayer#recvnetmsg), one message per call, and then looks at it with [NetMsgType](BlitzBasic-Multiplayer#netmsgtype), [NetMsgFrom](BlitzBasic-Multiplayer#netmsgfrom), [NetMsgTo](BlitzBasic-Multiplayer#netmsgto) and [NetMsgData](BlitzBasic-Multiplayer#netmsgdata).

Message types from 1 to 99 are yours to use. The system sends these itself:

| Type | Meaning | What to read |
|---|---|---|
| 100 | A new player joined the game. | `NetMsgFrom()` is the new player. |
| 101 | A player left the game. | `NetMsgFrom()` is the player who left. |
| 200 | The connection to the game was lost. | |

**Differences from the original.** The original used Microsoft DirectPlay, which no longer exists. Here the programs that join connect to the program that hosts with TCP on port 40500, or the port in the environment variable `BLITZ_NETGAME_PORT`, and the host passes the messages on. Games made with BlitzLLVM can play with each other, but not with programs made with the original Blitz3D. `StartNetGame` asks on the console and not in a dialog box, and there is no game browser, so a joining program has to know the address of the host.

## CreateNetPlayer
Creates a player that belongs to this program and tells the other programs about it, who see it as a message of type 100. Players are what messages are sent from and to.

```blitzbasic
If HostNetGame("my game") = 2
	me = CreateNetPlayer("Alice")
	Print NetPlayerName$(me)
EndIf
```
@param name  The name of the player.
@returns A player number, or 0 when there is no game.

## DeleteNetPlayer
Removes a player of this program from the game. The others see a message of type 101.
@param player  A player made with [CreateNetPlayer](BlitzBasic-Multiplayer#createnetplayer).

## HostNetGame
Starts a game on this computer as its host and waits for other programs to join it.
@param game_name  The name of the game. Joining programs have to use the same name.
@returns 2 when the game was started, 0 when it could not be, for example because the port is taken.

## JoinNetGame
Joins a game that another program hosts, which is found by its address.
@param game_name   The name of the game, which has to match the one given to [HostNetGame](BlitzBasic-Multiplayer#hostnetgame).
@param ip_address  The address of the host as dotted numbers, such as `192.168.1.20`.
@returns 1 when the game was joined, 0 when it was not found or has another name.

## NetMsgData
@returns The text of the message that [RecvNetMsg](BlitzBasic-Multiplayer#recvnetmsg) took last. It is empty for the system messages.

## NetMsgFrom
@returns The player the last message came from. For type 100 and 101 messages it is the player who joined or left.

## NetMsgTo
@returns The player the last message was for, or 0 when it was sent to everyone.

## NetMsgType
@returns The type of the last message: the number that was given to [SendNetMsg](BlitzBasic-Multiplayer#sendnetmsg), or 100, 101 or 200 for the messages of the system.

## NetPlayerLocal
@returns 1 when a player belongs to this program and 0 when it belongs to another one or does not exist.
@param player  The player number.

## NetPlayerName
@returns The name of a player. The player number 0 gives `<all>` and one that does not exist gives `<unknown>`.
@param player  The player number.

## RecvNetMsg
Takes the next message that arrived and makes it available to [NetMsgType](BlitzBasic-Multiplayer#netmsgtype) and the other message commands. Call it in a loop until it returns 0, once per frame, to handle everything that arrived.

```blitzbasic
While RecvNetMsg()
	Select NetMsgType()
		Case 100 : Print NetPlayerName$(NetMsgFrom()) + " joined"
		Case 101 : Print NetPlayerName$(NetMsgFrom()) + " left"
		Case 200 : Print "lost the game"
		Default : Print NetMsgData$()
	End Select
Wend
```
@returns 1 when a message was taken, 0 when nothing arrived.

## SendNetMsg
Sends a message from a player of this program to one other player or to everyone.
@param type         A message type from 1 to 99 that your program defines.
@param msg          The text to send. Long texts arrive in one piece.
@param from_player  A player of this program.
@param to_player    The player to send to. Defaults to 0, which means everyone.
@param reliable     Defaults to 1. The original allowed unreliable delivery with 0, but here every message arrives.
@returns 1 when the message was sent, 0 when `from_player` is not a player of this program.

## StartNetGame
Asks on the console whether to host or to join a game and does what was chosen, using the game name `BlitzLLVM game`. Joining asks for the address of the host.
@returns 2 when a game was hosted, 1 when one was joined and 0 when nothing was started or it failed.
@gap The original showed a dialog box with the games found in the network. Use [HostNetGame](BlitzBasic-Multiplayer#hostnetgame) and [JoinNetGame](BlitzBasic-Multiplayer#joinnetgame) when you need to choose in your own interface.

## StopNetGame
Leaves or ends the game. Players of this program are removed.
