## AddTextAreaText
Appends text at the end of a text area, with the formatting of the text before it. Line breaks are made with `Chr$(13)` or `Chr$(13) + Chr$(10)`.

```blitzbasic
;media interact textareas/addtextareatext.png 1
Graphics 320, 240, 32, 2
win = CreateWindow("Log", 10, 10, 300, 180, Desktop(), 3)
log = CreateTextArea(10, 10, 270, 120, win)
For i = 1 To 4
	AddTextAreaText log, "Line " + i + Chr$(13)
Next
Repeat
Until WaitEvent() = $803
```

![AddTextAreaText](media/textareas/addtextareatext.png)
@param textarea  Handle of a text area.
@param text      Text to append.

## CreateTextArea
Makes a box for editing several lines of text, with scroll bars. The user can type, select with the mouse or with Shift and the arrow keys, and use Ctrl+A, C, X and V. Every change sends a $401 event; [TextAreaText](BlitzPlus-Text-Areas#textareatext) reads the result. Style 1 turns line wrapping on so text is only scrolled vertically, and 65536 can be added to not follow the group when it is resized.

```blitzbasic
;media interact textareas/createtextarea.gif 2
;media click 100 80
;media type Hello
;media key Return
;media type world
Graphics 320, 240, 32, 2
win  = CreateWindow("Notes", 10, 10, 300, 180, Desktop(), 3)
area = CreateTextArea(10, 10, 270, 120, win, 1)
ActivateGadget area
Repeat
	e = WaitEvent()
	If e = $401 Then SetGadgetText win, "Notes - " + TextAreaLen(area) + " chars"
Until e = $803
```

![CreateTextArea](media/textareas/createtextarea.gif)
@param x       Horizontal position inside the group.
@param y       Vertical position inside the group.
@param width   Width of the text area.
@param height  Height of the text area.
@param group   Window, panel, tabber or canvas that holds it.
@param style   1 for wrapping, plus 65536 for not following the group. Defaults to 0.
@returns A handle for the text area.
@gap Without wrapping, long lines can only be scrolled sideways with the keyboard and the mouse wheel. There is no horizontal scroll bar yet.
@gap It is not a rich text control: it holds colors and bold or italic for ranges of text, but no pictures, links or paragraph styles.

## CreateTextField
Makes a box for a single line of text. A $401 event is sent for each change and its [EventData](BlitzPlus-Events#eventdata) is the character typed, and Enter sends one with 13. Style 1 shows stars instead of what is typed, for passwords. Read the text with [TextFieldText](BlitzPlus-Text-Areas#textfieldtext) and set it with [SetGadgetText](BlitzPlus-Gadgets#setgadgettext).

Text fields use Enter and Escape themselves, so use a button of style 4 or 5 to react to these keys, see [CreateButton](BlitzPlus-Gadgets#createbutton).

```blitzbasic
;media interact textareas/createtextfield.gif 2
;media click 100 90
;media type secret
Graphics 320, 240, 32, 2
win  = CreateWindow("Login", 10, 10, 300, 140, Desktop(), 3)
CreateLabel "Password:", 10, 10, 150, 24, win
pass = CreateTextField(10, 40, 200, 24, win, 1)
Repeat
	e = WaitEvent()
	If e = $401 Then SetGadgetText win, "Length " + Len(TextFieldText(pass))
Until e = $803
```

![CreateTextField](media/textareas/createtextfield.gif)
@param x       Horizontal position inside the group.
@param y       Vertical position inside the group.
@param width   Width of the field.
@param height  Height of the field.
@param group   Window, panel, tabber or canvas that holds it.
@param style   1 for a password field, plus 65536 for not following the group. Defaults to 0.
@returns A handle for the text field.

## FormatTextAreaText
Changes the color and style of a part of the text. The style is 1 for bold, 2 for italic and 3 for both, and 0 for plain. The part starts at a character or line and goes on for a number of them.

```blitzbasic
;media interact textareas/formattextareatext.png 1
Graphics 320, 240, 32, 2
win  = CreateWindow("Format", 10, 10, 300, 150, Desktop(), 3)
area = CreateTextArea(10, 10, 270, 90, win)
SetGadgetText area, "Red green bold italic"
FormatTextAreaText area, 255, 0, 0, 0, 0, 3
FormatTextAreaText area, 0, 140, 0, 0, 4, 5
FormatTextAreaText area, 0, 0, 0, 1, 10, 4
FormatTextAreaText area, 0, 0, 160, 2, 15, 6
Repeat
Until WaitEvent() = $803
```

![FormatTextAreaText](media/textareas/formattextareatext.png)
@param textarea  Handle of a text area.
@param red       Red part of the text color, 0 to 255.
@param green     Green part of the text color, 0 to 255.
@param blue      Blue part of the text color, 0 to 255.
@param style     1 bold, 2 italic, 3 both, 0 plain.
@param position  Where to start. Defaults to 0.
@param length    How much to change. Defaults to -1, which means to the end.
@param units     1 counts characters, 2 counts lines. Defaults to 1.
@gap Underline and strike-through are not supported, as in the original.

## LockTextArea
Holds back redrawing of a text area while you change a lot of it, which is faster and does not flicker. Call [UnlockTextArea](BlitzPlus-Text-Areas#unlocktextarea) afterwards.

```blitzbasic
Graphics 320, 240, 32, 2
win  = CreateWindow("Lock", 10, 10, 300, 150, Desktop(), 3)
area = CreateTextArea(10, 10, 270, 90, win)
LockTextArea area
For i = 1 To 200
	AddTextAreaText area, "Line " + i + Chr$(13)
Next
UnlockTextArea area
Repeat
Until WaitEvent() = $803
```
@param textarea  Handle of a text area.
@gap While a text area is locked it sends no events for the changes you make.

## SetTextAreaColor
Sets the color of the text, or with the last parameter the color of the background, of the whole text area.

```blitzbasic
;media interact textareas/settextareacolor.png 1
Graphics 320, 240, 32, 2
win  = CreateWindow("Colors", 10, 10, 300, 150, Desktop(), 3)
area = CreateTextArea(10, 10, 270, 90, win)
SetGadgetText area, "Green on black"
SetTextAreaColor area, 0, 0, 0, 1
SetTextAreaColor area, 0, 255, 0
Repeat
Until WaitEvent() = $803
```

![SetTextAreaColor](media/textareas/settextareacolor.png)
@param textarea    Handle of a text area.
@param red         Red part, 0 to 255.
@param green       Green part, 0 to 255.
@param blue        Blue part, 0 to 255.
@param background  0 sets the text color, 1 sets the background color. Defaults to 0.

## SetTextAreaFont
Changes the font of the whole text area.

```blitzbasic
Graphics 320, 240, 32, 2
win  = CreateWindow("Font", 10, 10, 300, 150, Desktop(), 3)
area = CreateTextArea(10, 10, 270, 90, win)
SetTextAreaFont area, LoadFont("Courier New", 16)
SetGadgetText area, "Courier"
Repeat
Until WaitEvent() = $803
```
@param textarea  Handle of a text area.
@param font      Font handle from `LoadFont` or [RequestFont](BlitzPlus-Dialogs#requestfont).
@gap Only the size of the font is used, every font is drawn with the built-in typeface.

## SetTextAreaTabs
Sets how wide a tab character is, independent of the font.

```blitzbasic
Graphics 320, 240, 32, 2
win  = CreateWindow("Tabs", 10, 10, 300, 150, Desktop(), 3)
area = CreateTextArea(10, 10, 270, 90, win)
SetTextAreaTabs area, 40
SetGadgetText area, "a" + Chr$(9) + "b" + Chr$(9) + "c"
Repeat
Until WaitEvent() = $803
```
@param textarea  Handle of a text area.
@param tabs      Width of a tab.

## SetTextAreaText
Writes text into a text area at a place. It replaces the given number of characters or lines there, so a length of 0 only inserts.

```blitzbasic
Graphics 320, 240, 32, 2
win  = CreateWindow("Insert", 10, 10, 300, 150, Desktop(), 3)
area = CreateTextArea(10, 10, 270, 90, win)
SetGadgetText area, "Hello world"
SetTextAreaText area, "big ", 6, 0
SetTextAreaText area, "HELLO", 0, 5
Repeat
Until WaitEvent() = $803
```
@param textarea  Handle of a text area.
@param text      The text to write.
@param position  Where to write it. Defaults to 0.
@param length    How much to replace there. Defaults to -1, which means to the end.
@param units     1 counts characters, 2 counts lines. Defaults to 1.

## TextAreaChar
@param textarea  Handle of a text area.
@param line      Number of the line, starting at 0.
@returns The position of the first character of that line, which can be used as the start of [TextAreaText](BlitzPlus-Text-Areas#textareatext).

## TextAreaCursor
Gives where the text cursor is.

```blitzbasic
;media interact textareas/textareacursor.gif 2
;media click 100 70
;media type abc
;media key Return
;media type de
Graphics 320, 240, 32, 2
win  = CreateWindow("Cursor", 10, 10, 300, 150, Desktop(), 3)
area = CreateTextArea(10, 10, 270, 90, win)
ActivateGadget area
Repeat
	e = WaitEvent()
	If e = $401 Then SetGadgetText win, "Cursor " + TextAreaCursor(area) + " line " + TextAreaCursor(area, 2)
Until e = $803
```

![TextAreaCursor](media/textareas/textareacursor.gif)
@param textarea  Handle of a text area.
@param units     1 gives the character position, 2 gives the line. Defaults to 1.
@returns The position, counting from 0.

## TextAreaLen
@param textarea  Handle of a text area.
@param units     1 counts characters, 2 counts lines. Defaults to 1.
@returns How many characters or lines the text has.

## TextAreaLine
@param textarea  Handle of a text area.
@param position  Position of a character.
@returns The number of the line that character is on, starting at 0.

## TextAreaLineLen
@param textarea  Handle of a text area.
@param line      Number of the line, starting at 0.
@returns How many characters are in that line.

## TextAreaSelLen
Gives how much is selected.

```blitzbasic
;media interact textareas/textareasellen.png 1
;media click 100 70
;media type Select me
;media key shift+Left
;media key shift+Left
;media key shift+Left
Graphics 320, 240, 32, 2
win  = CreateWindow("Selection", 10, 10, 300, 150, Desktop(), 3)
area = CreateTextArea(10, 10, 270, 90, win)
ActivateGadget area
Repeat
	e = WaitEvent()
	If e = $401 Then SetGadgetText win, "Selected " + TextAreaSelLen(area)
Until e = $803
```

![TextAreaSelLen](media/textareas/textareasellen.png)
@param textarea  Handle of a text area.
@param units     1 counts characters, 2 counts lines. Defaults to 1.
@returns The size of the selection.

## TextAreaText
Reads the text, all of it or a part. Line breaks are given as `Chr$(13)`.

```blitzbasic
Graphics 320, 240, 32, 2
win  = CreateWindow("Read", 10, 10, 300, 150, Desktop(), 3)
area = CreateTextArea(10, 10, 270, 90, win)
SetGadgetText area, "one" + Chr$(13) + "two" + Chr$(13) + "three"
SetGadgetText win, TextAreaText(area, 1, 1, 2) ; the second line
Repeat
Until WaitEvent() = $803
```
@param textarea  Handle of a text area.
@param position  Where to start. Defaults to 0.
@param length    How much to read. Defaults to -1, which means to the end.
@param units     1 counts characters, 2 counts lines. Defaults to 1.
@returns The text.

## TextFieldText
@param textfield  Handle of a text field.
@returns The text in the field, even for a password field.

## UnlockTextArea
Allows the text area to be redrawn again after [LockTextArea](BlitzPlus-Text-Areas#locktextarea) and shows what changed.
@param textarea  Handle of a text area.
