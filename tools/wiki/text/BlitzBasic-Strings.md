## Asc
Returns the character code of the first character of a string. It is the opposite of [Chr](BlitzBasic-Strings#chr).

```blitzbasic
;run
Print Asc("A")
Print Asc("BCD")
```

```text
65
66
```
@param string  The text. Only its first character counts.
@returns A code from 0 to 255.

## Bin
Turns a number into its binary digits. The result always has 32 digits, so negative numbers show their two's complement form.

```blitzbasic
;run
Print Bin$(5)
```

```text
00000000000000000000000000000101
```
@param value  The number to convert.
@returns A string of 32 digits, 0 and 1.

## Chr
Returns the one-character string for a character code. [Asc](BlitzBasic-Strings#asc) does the opposite.

```blitzbasic
;run
Print Chr$(72) + Chr$(105)
```

```text
Hi
```
@param ascii  The character code, 0 to 255.
@returns A string with a single character.
@gap Strings end at the first zero byte, so `Chr$(0)` is the same as an empty string.

## CurrentDate
Returns today's date from the system clock as day, abbreviated month and year, for example `26 Oct 2026`.

```blitzbasic
Print "Today is " + CurrentDate$()
```
@returns The date as text.

## CurrentTime
Returns the time of day from the system clock as `HH:MM:SS` on a 24 hour clock.

```blitzbasic
Print "It is " + CurrentTime$()
```
@returns The time as text.

## Hex
Turns a number into hexadecimal digits. The result always has 8 digits, so negative numbers show their two's complement form.

```blitzbasic
;run
Print Hex$(255)
Print Hex$(-1)
```

```text
000000FF
FFFFFFFF
```
@param value  The number to convert.
@returns A string of 8 digits, 0 to 9 and A to F.

## Instr
Finds the first position of a piece of text inside another string. Positions start at 1, and 0 means it was not found. The search tells upper and lower case apart.

```blitzbasic
;run
Print Instr("hello world", "o")
Print Instr("hello world", "o", 6)
Print Instr("hello", "z")
```

```text
5
8
0
```
@param string  The text to search in.
@param find    The text to look for.
@param from    Position to start searching at. Defaults to 1.
@returns The position of the first match, or 0.

## Left
Returns the first characters of a string. Asking for more characters than there are returns the whole string.

```blitzbasic
;run
Print Left$("hello", 2)
Print Left$("hello", 10)
```

```text
he
hello
```
@param string  The text.
@param count   How many characters to take.
@returns The first `count` characters.

## Len
@returns How many characters a string has. An empty string has 0.

```blitzbasic
;run
Print Len("hello")
```

```text
5
```
@param string  The text to measure.

## Lower
Returns a copy of the string with every letter in lower case.

```blitzbasic
;run
Print Lower$("Hello World 1!")
```

```text
hello world 1!
```
@param string  The text.
@returns The lower case text.

## LSet
Makes a string exactly `size` characters long by cutting it off or padding it with spaces on the right, so the text stays on the left. Useful for columns.

```blitzbasic
;run
Print "[" + LSet$("ab", 5) + "]"
Print "[" + LSet$("abcdef", 3) + "]"
```

```text
[ab   ]
[abc]
```
@param string  The text.
@param size    The length of the result.
@returns A string of exactly `size` characters.

## Mid
Returns a piece from the middle of a string. The first character is number 1. Without a count it takes everything to the end, and a count that is too long is cut off at the end.

```blitzbasic
;run
Print Mid$("hello", 2, 3)
Print Mid$("hello", 3)
```

```text
ell
llo
```
@param string  The text.
@param start   Position of the first character to take.
@param count   How many characters to take. Defaults to all that are left.
@returns The piece of the string.

## Replace
Replaces every occurrence of a piece of text with another. What was put in is not searched again, so replacing `a` with `aa` does not loop.

```blitzbasic
;run
Print Replace$("a-b-c", "-", "+")
Print Replace$("a-b-c", "-", "")
```

```text
a+b+c
abc
```
@param string  The text to change.
@param from    What to look for.
@param to      What to put in its place. May be empty to remove it.
@returns The changed text.

## Right
Returns the last characters of a string. Asking for more characters than there are returns the whole string.

```blitzbasic
;run
Print Right$("hello", 2)
```

```text
lo
```
@param string  The text.
@param count   How many characters to take.
@returns The last `count` characters.

## RSet
Makes a string exactly `size` characters long by padding it with spaces on the left, or cutting off its start, so the text stays on the right. Useful for numbers in columns.

```blitzbasic
;run
Print "[" + RSet$("42", 5) + "]"
Print "[" + RSet$("abcdef", 3) + "]"
```

```text
[   42]
[def]
```
@param string  The text.
@param size    The length of the result.
@returns A string of exactly `size` characters.

## String
Repeats a string several times.

```blitzbasic
;run
Print String$("ab", 3)
```

```text
ababab
```
@param string  The text to repeat.
@param repeat  How many copies to join. 0 gives an empty string.
@returns The repeated text.

## Trim
Removes spaces, tabs and other invisible characters from both ends of a string.

```blitzbasic
;run
Print "[" + Trim$("   hi there  ") + "]"
```

```text
[hi there]
```
@param string  The text.
@returns The text without the blanks at its ends.

## Upper
Returns a copy of the string with every letter in upper case.

```blitzbasic
;run
Print Upper$("Hello World 1!")
```

```text
HELLO WORLD 1!
```
@param string  The text.
@returns The upper case text.
