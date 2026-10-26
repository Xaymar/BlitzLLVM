## ActiveObjects
Counts what your program has made and not freed yet: banks, streams, sounds, images, textures, fonts, timers and objects of your own types. It is meant to help you find leaks while developing.

```blitzbasic
Graphics 320, 240, 32, 2
win = CreateWindow("Objects", 20, 20, 240, 100, Desktop(), 3)
start = ActiveObjects()
bank = CreateBank(16)
SetGadgetText win, "One more: " + (ActiveObjects() - start)
FreeBank bank
Repeat
Until WaitEvent() = $803
```
@returns How many objects are alive. The official help lists the command as undocumented.
@gap Windows and gadgets are not counted here.

## AutoSuspend
Switches whether the program stops when its window is not the active one and carries on when it is back. It is off by default, and a program can also react to the events $2001 and $2002 itself.

```blitzbasic
Graphics 320, 240, 32, 2
AutoSuspend 1
win = CreateWindow("Suspends", 20, 20, 240, 100, Desktop(), 3)
Repeat
Until WaitEvent() = $803
```
@param enable  1 turns it on, 0 turns it off.
@gap Accepted but does nothing: the program keeps running when it is not in front.

## Confirm
Shows a question with an OK and a Cancel button and waits for the answer. Lines can be split with `Chr$(13)`. The second parameter chooses a warning symbol instead of the information symbol.

```blitzbasic
Graphics 320, 240, 32, 2
If Confirm("Delete all saves?", 1) Then
	Notify "They are gone."
EndIf
```
@param text     The question.
@param serious  1 for the warning symbol, 0 for information. Defaults to 0.
@returns 1 for OK, 0 for Cancel.
@gap The box is a message box of the operating system and not part of the program window. When the program runs without a screen it writes the text to the error output and answers 0.

## CreateProcess
Starts another program and gives you a stream to read what it writes.

```blitzbasic
Graphics 320, 240, 32, 2
If CreateProcess("notepad.exe") = 0 Then Notify "Could not start it."
```
@param file  The program to run, with arguments if needed.
@returns The official version gives a stream with the output of the program. 
@gap Here the result is only 1 when the program was started and 0 when it was not, and its output is not available. The program is started on its own and not waited for.

## DebugObjects
Writes how many objects of each kind are alive into the debug log, one line per kind. Together with [ActiveObjects](BlitzPlus-System#activeobjects) it helps to find things that were forgotten to be freed.

```blitzbasic
Graphics 320, 240, 32, 2
DebugObjects
```
@gap The list covers banks, streams, sounds, images, textures, fonts, timers and your own types, but no windows or gadgets.

## FlushEvents
Throws away events that are waiting, so they are never delivered by [WaitEvent](BlitzPlus-Events#waitevent). Without parameters everything goes. A kind removes only that one, a kind with the low byte zero such as $100 removes the whole group of keys, and a source removes only what came from there.

```blitzbasic
Graphics 320, 240, 32, 2
win = CreateWindow("Flush", 20, 20, 240, 100, Desktop(), 3)
Delay 500
FlushEvents $100 ; drop the keys that were typed meanwhile
Repeat
Until WaitEvent() = $803
```
@param kind    Event kind or group to remove. Defaults to -1, which means all.
@param source  Only remove events from this object. Defaults to 0, which means any.

## FontAscent
@param font  A font handle from `LoadFont` or [RequestFont](BlitzPlus-Dialogs#requestfont).
@returns How many pixels the font rises above the baseline. Add [FontDescent](BlitzPlus-System#fontdescent) to get the height of a line.

## FontDescent
@param font  A font handle from `LoadFont` or [RequestFont](BlitzPlus-Dialogs#requestfont).
@returns How many pixels the font reaches below the baseline.

## FontName
@param font  A font handle from `LoadFont` or [RequestFont](BlitzPlus-Dialogs#requestfont).
@returns The name the font was loaded with.

## FontSize
@param font  A font handle from `LoadFont` or [RequestFont](BlitzPlus-Dialogs#requestfont).
@returns The size in points.

## FontStyle
@param font  A font handle from `LoadFont` or [RequestFont](BlitzPlus-Dialogs#requestfont).
@returns The sum of 1 for bold, 2 for italic and 4 for underlined.

## HotKeyEvent
Makes a key combination produce an event of your choice, even when no gadget wants the key. Handy for shortcuts. The scan code is what `KeyDown` uses, and the modifiers are added: 1 shift, 2 control, 4 alt.

```blitzbasic
Graphics 320, 240, 32, 2
win = CreateWindow("Hot key", 20, 20, 240, 100, Desktop(), 3)
HotKeyEvent 31, 2, $4242, 7 ; Ctrl+S
Repeat
	e = WaitEvent()
	If e = $4242 Then SetGadgetText win, "Saved " + EventData()
Until e = $803
```
@param scancode  Scan code of the key.
@param modifier  Sum of 1 (shift), 2 (control) and 4 (alt).
@param id        Kind of event to post.
@param data      Value for [EventData](BlitzPlus-Events#eventdata). Defaults to 0.
@param x         Value for [EventX](BlitzPlus-Events#eventx). Defaults to 0.
@param y         Value for [EventY](BlitzPlus-Events#eventy). Defaults to 0.
@param z         Value for [EventZ](BlitzPlus-Events#eventz). Defaults to 0.
@param source    Value for [EventSource](BlitzPlus-Events#eventsource). Defaults to 0.

## Notify
Shows a message with one OK button and waits until it is closed. Lines can be split with `Chr$(13)`.

```blitzbasic
Graphics 320, 240, 32, 2
Notify "Everything is fine.", 0
```
@param text     The message.
@param serious  1 for the warning symbol, 0 for information. Defaults to 0.
@gap The box is a message box of the operating system and not part of the program window. Without a screen it writes the text to the error output.

## PauseTimer
Stops a timer from ticking and posting events until [ResumeTimer](BlitzPlus-System#resumetimer) is called. Its tick count stays where it is.

```blitzbasic
Graphics 320, 240, 32, 2
win = CreateWindow("Timer", 20, 20, 240, 100, Desktop(), 3)
tm = CreateTimer(2)
PauseTimer tm
Repeat
	e = WaitEvent(1000)
	If e = $4001 Then SetGadgetText win, "Never gets here"
Until e = $803
```
@param timer  A timer from `CreateTimer`.

## Proceed
Shows a question with Yes, No and Cancel and waits for the answer. Lines can be split with `Chr$(13)`.

```blitzbasic
Graphics 320, 240, 32, 2
Select Proceed("Save before quitting?")
	Case 1  Notify "Saved"
	Case 0  Notify "Dropped"
	Case -1 Notify "Staying"
End Select
```
@param text     The question.
@param serious  1 for the warning symbol, 0 for information. Defaults to 0.
@returns 1 for Yes, 0 for No and -1 for Cancel.
@gap The box is a message box of the operating system. Without a screen it writes the text to the error output and answers -1.

## QueryObject
In the original it gives the Windows handle behind a gadget (query 1 is the HWND, 2 the HWND of the client area, 3 the HFONT), so it can be used with the Windows API.

```blitzbasic
Graphics 320, 240, 32, 2
win = CreateWindow("Query", 20, 20, 240, 100, Desktop(), 3)
SetGadgetText win, "Handle " + QueryObject(win, 1)
Repeat
Until WaitEvent() = $803
```
@param object  A window, gadget or font.
@param query   1 for the window handle, 2 for the client handle, 3 for the font handle.
@gap Always returns 0, because gadgets are drawn by the program and are no objects of the operating system.

## ResetTimer
Sets the tick count of a timer back to 0 and starts counting again from now.

```blitzbasic
Graphics 320, 240, 32, 2
win = CreateWindow("Timer", 20, 20, 240, 100, Desktop(), 3)
tm = CreateTimer(4)
Repeat
	e = WaitEvent()
	If e = $4001 And TimerTicks(tm) >= 8 Then ResetTimer tm
	If e = $4001 Then SetGadgetText win, "Ticks " + TimerTicks(tm)
Until e = $803
```
@param timer  A timer from `CreateTimer`.

## ResumeTimer
Lets a timer paused with [PauseTimer](BlitzPlus-System#pausetimer) tick again.

```blitzbasic
Graphics 320, 240, 32, 2
win = CreateWindow("Timer", 20, 20, 240, 100, Desktop(), 3)
tm = CreateTimer(2)
PauseTimer tm
ResumeTimer tm
Repeat
	e = WaitEvent()
	If e = $4001 Then SetGadgetText win, "Tick " + EventData()
Until e = $803
```
@param timer  A timer from `CreateTimer`.

## TimerTicks
Counts how many ticks a timer made since it was created or last reset. Each tick also arrives as a $4001 event, but when the program is busy several ticks are put into one event, so the count is the reliable number.

```blitzbasic
Graphics 320, 240, 32, 2
win = CreateWindow("Timer", 20, 20, 240, 100, Desktop(), 3)
tm = CreateTimer(10)
Repeat
	e = WaitEvent()
	If e = $4001 Then SetGadgetText win, "Ticks " + TimerTicks(tm)
Until e = $803
```
@param timer  A timer from `CreateTimer`.
@returns The number of ticks.
