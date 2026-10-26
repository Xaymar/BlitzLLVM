## DirectInputEnabled
Tells whether the program asked for DirectInput style input with [EnableDirectInput](BlitzBasic-Mouse#enabledirectinput). It is an undocumented command of the original and only exists so that old programs still compile.
@returns 1 if the setting is on, otherwise 0.
@gap There is no DirectInput on this platform. The command only reports the value last given to EnableDirectInput (initially 1); input always comes from SDL.

## EnableDirectInput
Switches the DirectInput setting on or off. In the original it chose between two ways of reading the keyboard and mouse. It is an undocumented command that old programs sometimes call at their start.
@param enable  1 to switch it on, 0 to switch it off.
@gap Only the value is remembered so that [DirectInputEnabled](BlitzBasic-Mouse#directinputenabled) can report it. Input is read the same way whatever it is set to.

## FlushMouse
Forgets mouse button presses that nobody has looked at yet: the queue behind [GetMouse](BlitzBasic-Mouse#getmouse) and [WaitMouse](BlitzBasic-Mouse#waitmouse), the presses counted for [MouseHit](BlitzBasic-Mouse#mousehit), and the movement counted by the speed functions. Use it before a screen that waits for a click so that earlier clicks do not skip it, but not in the main loop.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Text 10, 10, "Click as often as you like..."
Flip
Delay 2000
FlushMouse
Cls
Text 10, 10, "Old clicks are gone. Click once more."
Flip
WaitMouse
```

## GetMouse
Takes the next mouse button press out of a queue and returns its number: 1 for the left button, 2 for the right and 3 for the middle button. It returns 0 if nothing was pressed since the last call. Unlike [MouseHit](BlitzBasic-Mouse#mousehit) it does not need to be told which button to look at.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local prev = 0
While Not KeyHit(1)
	Local b = GetMouse()
	If b Then prev = b
	Cls
	Text 10, 10, "Click with any mouse button"
	Text 10, 30, "Last button: " + prev
	Flip
Wend
```
@returns The number of the button that was pressed, or 0 if there is none.
@gap The queue holds 15 presses and forgets the oldest ones when it is full.

## MouseDown
Tells whether a mouse button is held down at this moment.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
While Not KeyHit(1)
	Cls
	If MouseDown(1) Then Color 255, 80, 80 Else Color 80, 80, 80
	Rect 20, 60, 80, 80, 1
	If MouseDown(3) Then Color 255, 80, 80 Else Color 80, 80, 80
	Rect 120, 60, 80, 80, 1
	If MouseDown(2) Then Color 255, 80, 80 Else Color 80, 80, 80
	Rect 220, 60, 80, 80, 1
	Color 255, 255, 255
	Text 160, 200, "Hold a mouse button", 1, 1
	Flip
Wend
```
@param button  1 for the left, 2 for the right, 3 for the middle button.
@returns 1 while the button is held down, otherwise 0.
@gap A button number outside 1 to 3 always gives 0. Extra buttons of the mouse are not supported.

## MouseHit
Counts presses of a mouse button since the last time MouseHit asked about that button. Use it for clicks that should do one thing and not repeat while the button is held, and [MouseDown](BlitzBasic-Mouse#mousedown) for dragging.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local clicks = 0
While Not KeyHit(1)
	If MouseHit(1) Then clicks = clicks + 1
	Cls
	Text 10, 10, "Left clicks: " + clicks
	Flip
Wend
```
@param button  1 for the left, 2 for the right, 3 for the middle button.
@returns How many times the button was pressed since the last call.
@gap The result is never more than 1: two clicks between two calls count as one.

## MouseWait
The older name of [WaitMouse](BlitzBasic-Mouse#waitmouse). It stops the program until a mouse button is pressed and returns the button.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Text 10, 10, "Click a mouse button"
Flip
Local b = MouseWait()
Cls
Text 10, 10, "That was button " + b
Flip
Delay 1000
```
@returns The number of the button that was pressed.

## MouseX
The horizontal position of the pointer in the graphics buffer, from 0 on the left to `GraphicsWidth() - 1`. When the window is scaled, the position is converted back to buffer pixels. [MoveMouse](BlitzBasic-Mouse#movemouse) sets it. BlitzPlus programs can also pass a canvas handle to get the position relative to that canvas.

```blitzbasic
;media still mouse/mousex.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
MoveMouse 200, 90
Cls
Color 255, 255, 255
Line MouseX(), 0, MouseX(), 239
Line 0, MouseY(), 319, MouseY()
Text 10, 10, "MouseX = " + MouseX()
Text 10, 24, "MouseY = " + MouseY()
Flip
WaitKey
```

![MouseX](media/mouse/mousex.png)
@returns The horizontal position of the pointer.

## MouseXSpeed
How far the pointer moved sideways since the last time this function was called. It gives the same result whether the pointer reached the edge of the window or not, which makes it useful for looking around in a 3D scene: call [MoveMouse](BlitzBasic-Mouse#movemouse) every frame to put the pointer back in the middle and use the speed as the turning amount.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local x = 160
While Not KeyHit(1)
	x = x + MouseXSpeed()
	MoveMouse 160, 120
	Cls
	Text 10, 10, "Move the mouse sideways"
	Oval x - 8, 110, 16, 16, 1
	Flip
Wend
```
@returns The change of the horizontal position since the previous call.
@gap Putting the pointer somewhere with MoveMouse does not count as movement, the same as in the original. To make that work on every platform the window captures the pointer for as long as the program keeps calling MoveMouse; it lets go about 300 milliseconds after the last call.

## MouseY
The vertical position of the pointer in the graphics buffer, from 0 at the top to `GraphicsHeight() - 1`. See [MouseX](BlitzBasic-Mouse#mousex).
@returns The vertical position of the pointer.

## MouseYSpeed
How far the pointer moved up or down since the last call. See [MouseXSpeed](BlitzBasic-Mouse#mousexspeed).
@returns The change of the vertical position since the previous call.

## MouseZ
The position of the mouse wheel. It starts at 0 and counts up when the wheel is rolled away from you and down when it is rolled towards you.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
While Not KeyHit(1)
	Cls
	Text 10, 10, "Roll the mouse wheel"
	Text 10, 30, "MouseZ = " + MouseZ()
	Flip
Wend
```
@returns The wheel position added up since the program started.
@gap Fine scrolling wheels and touchpads that report fractions of a notch are rounded to whole steps.

## MouseZSpeed
How far the wheel moved since the last call, in notches. Rolling away from you is positive and towards you negative.
@returns The wheel movement since the previous call.
@gap The original only ever gives -1, 0 or 1. A wheel that is turned several notches between two calls can give a larger number here.

## MoveMouse
Puts the pointer at a position of the graphics buffer, in buffer pixels. After the call [MouseX](BlitzBasic-Mouse#mousex) and [MouseY](BlitzBasic-Mouse#mousey) return the new position straight away.
@param x  Horizontal position in the graphics buffer.
@param y  Vertical position in the graphics buffer.
@gap The pointer is not warped on the desktop. The window takes the pointer over while MoveMouse is being called each frame and the position the program sees is calculated from the mouse movement, which keeps MouseXSpeed and MouseYSpeed correct. When MoveMouse is not called for about 300 milliseconds the pointer is given back and placed where the program thought it was.

## WaitMouse
Stops the program until a mouse button is pressed and returns its number. Presses made before the call count too, so call [FlushMouse](BlitzBasic-Mouse#flushmouse) first if only a new click should end the wait. In a game loop prefer [MouseHit](BlitzBasic-Mouse#mousehit) or [GetMouse](BlitzBasic-Mouse#getmouse), which let the screen keep updating.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
FlushMouse
Text 10, 10, "Click a mouse button"
Flip
Local b = WaitMouse()
Cls
Text 10, 10, "Button " + b + " was pressed"
Flip
Delay 1000
```
@returns The number of the button that was pressed.
