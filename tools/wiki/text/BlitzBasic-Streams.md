Streams are what the file handles from [[BlitzBasic-Files]] give you, and what [[BlitzBasic-Network]] gives for TCP and UDP. These commands read and write on any of them, so the same code that saves a file can send over a network.

Numbers are stored little-endian in the sizes the commands say. A string written with [WriteString](BlitzBasic-Streams#writestring) has its length in front, a line written with [WriteLine](BlitzBasic-Streams#writeline) ends with a carriage return and a line feed. Everything written can be read back in the same order.

## CopyStream
Copies everything that is left in one stream into another, in pieces of `buffer_size` bytes.
@param src_stream   The stream to read from.
@param dest_stream  The stream to write to.
@param buffer_size  How many bytes to move at a time. Defaults to 16384.

## Eof
@returns 1 when a file has been read to its end, otherwise 0.

```blitzbasic
;run
file = WriteFile("streams_eof_example.tmp")
WriteLine file, "a"
WriteLine file, "b"
CloseFile file
file = ReadFile("streams_eof_example.tmp")
While Not Eof(file)
	Print ReadLine$(file)
Wend
CloseFile file
DeleteFile "streams_eof_example.tmp"
```

```text
a
b
```
@param stream  The stream to check.

## ReadAvail
@returns How many bytes can be read right now without waiting. It is meant for network streams, where data arrives over time. On a file it gives 0 or what is left.
@param stream  The stream to check.

## ReadByte
@returns The next byte of the stream, from 0 to 255.
@param stream  The stream to read from.

## ReadFloat
@returns The next 4 bytes of the stream as a float.
@param stream  The stream to read from.

## ReadInt
@returns The next 4 bytes of the stream as an integer.
@param stream  The stream to read from.

## ReadLine
Reads text up to the end of the line. Lines may end with a line feed or with a carriage return and a line feed, and a last line without an ending is read as well. The line ending is not part of the result.

```blitzbasic
;run
file = WriteFile("streams_line_example.tmp")
WriteByte file, Asc("a")
WriteByte file, 10
WriteByte file, Asc("b")
WriteByte file, 13
WriteByte file, 10
WriteByte file, Asc("c")
CloseFile file
file = ReadFile("streams_line_example.tmp")
Print ReadLine$(file)
Print ReadLine$(file)
Print ReadLine$(file)
CloseFile file
DeleteFile "streams_line_example.tmp"
```

```text
a
b
c
```
@param stream  The stream to read from.
@returns The text of the line.

## ReadShort
@returns The next 2 bytes of the stream as a number from 0 to 65535.
@param stream  The stream to read from.

## ReadString
Reads a string that [WriteString](BlitzBasic-Streams#writestring) wrote: first its length, then its text.
@param stream  The stream to read from.
@returns The string.

## WriteByte
Writes one byte. Values outside 0 to 255 wrap around.
@param stream  The stream to write to.
@param byte    The value to write.

## WriteFloat
Writes a float in 4 bytes.

```blitzbasic
;run
file = WriteFile("streams_float_example.tmp")
WriteFloat file, 3.25
CloseFile file
file = ReadFile("streams_float_example.tmp")
Print ReadFloat(file)
CloseFile file
DeleteFile "streams_float_example.tmp"
```

```text
3.25
```
@param stream  The stream to write to.
@param float   The value to write.

## WriteInt
Writes an integer in 4 bytes, low byte first.

```blitzbasic
;run
file = WriteFile("streams_int_example.tmp")
WriteInt file, 123456789
WriteInt file, -42
CloseFile file
file = ReadFile("streams_int_example.tmp")
Print ReadInt(file)
Print ReadInt(file)
CloseFile file
DeleteFile "streams_int_example.tmp"
```

```text
123456789
-42
```
@param stream  The stream to write to.
@param int     The value to write.

## WriteLine
Writes text followed by a carriage return and a line feed. Read it back with [ReadLine](BlitzBasic-Streams#readline).
@param stream  The stream to write to.
@param string  The text to write.

## WriteShort
Writes a number in 2 bytes, low byte first. Values outside 0 to 65535 wrap around.
@param stream  The stream to write to.
@param short   The value to write.

## WriteString
Writes a string as its length in 4 bytes followed by its text, without a line ending. Read it back with [ReadString](BlitzBasic-Streams#readstring).

```blitzbasic
;run
file = WriteFile("streams_string_example.tmp")
WriteString file, "Hello"
CloseFile file
Print FileSize("streams_string_example.tmp")
file = ReadFile("streams_string_example.tmp")
Print ReadString$(file)
CloseFile file
DeleteFile "streams_string_example.tmp"
```

```text
9
Hello
```
@param stream  The stream to write to.
@param string  The text to write.
