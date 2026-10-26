## FlushJoy
Forgets joystick button presses that nobody has looked at yet, on every connected joystick. Use it before a screen that waits for a button, not in the main loop.
@gap Buttons that are currently held are not released. Only the counted and queued presses are cleared.

## GetJoy
Takes the next joystick button press out of a queue and returns the number of the button, or 0 if no button was pressed since the last call. It is the joystick counterpart of [GetMouse](BlitzBasic-Mouse#getmouse). GetJoy is undocumented in the original help but exists in all three dialects.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local prev = 0
While Not KeyHit(1)
	Local b = GetJoy()
	If b Then prev = b
	Cls
	Text 10, 10, "Press a joystick button, Escape ends"
	Text 10, 30, "Last button: " + prev
	Flip
Wend
```
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns The number of the button that was pressed (counted from 1), or 0.
@gap Up to 32 buttons per joystick are supported, and a joystick with more reports only the first 32.

## JoyDown
Tells whether a joystick button is held down right now. Buttons are counted from 1.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
While Not KeyHit(1)
	Cls
	If JoyType() = 0 Then
		Text 10, 10, "No joystick connected"
	Else
		For b = 1 To 8
			If JoyDown(b) Then Color 255, 80, 80 Else Color 70, 70, 70
			Rect 10 + (b - 1) * 38, 100, 30, 30, 1
		Next
	EndIf
	Color 255, 255, 255
	Flip
Wend
```
@param button  The button number, 1 to 32.
@param port    The joystick to ask, counted from 0. Defaults to 0.
@returns 1 while the button is held down, otherwise 0.

## JoyHat
The direction of the first hat switch (the point-of-view control) as an angle in degrees: 0 for up, 90 for right, 180 for down and 270 for left, with 45 degree steps in between. The result is -1 while the hat is in the middle.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
While Not KeyHit(1)
	Cls
	Text 10, 10, "JoyHat = " + JoyHat()
	Flip
Wend
```
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns The angle of the hat, or -1 if it is centered or the joystick has no hat.
@gap Without any joystick the original returns -1 as well, but this runtime returns 0, which looks like "up". Use [JoyType](BlitzBasic-Joystick#joytype) first to find out if there is a joystick.

## JoyHit
Counts presses of a joystick button since the last time JoyHit asked about that button.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local presses = 0
While Not KeyHit(1)
	presses = presses + JoyHit(1)
	Cls
	Text 10, 10, "Button 1 was pressed " + presses + " times"
	Flip
Wend
```
@param button  The button number, 1 to 32.
@param port    The joystick to ask, counted from 0. Defaults to 0.
@returns How many times the button was pressed since the last call.

## JoyPitch
The rotation of the joystick around its X axis, from -180 to 180. Most gamepads have no such axis and give 0. See the note on the extra axes at [JoyZ](BlitzBasic-Joystick#joyz).
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns The pitch in degrees, or 0 if the joystick has no such axis.
@gap The original gives -180 for a missing axis. Here it is 0, which is the middle position.

## JoyRoll
The rotation around the long axis of the stick, from -180 to 180. On many joysticks this is the twist of the handle or a rudder pedal.
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns The roll in degrees, or 0 if the joystick has no such axis.
@gap The original gives -180 for a missing axis. Here it is 0.

## JoyType
Tells whether a joystick is connected to the port and what kind it is.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Cls
For p = 0 To 3
	Select JoyType(p)
		Case 0 : t$ = "not connected"
		Case 1 : t$ = "gamepad"
		Default : t$ = "other joystick"
	End Select
	Text 10, 10 + p * 16, "Port " + p + ": " + t$
Next
Flip
WaitKey
```
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns 0 if there is no joystick, 1 for a gamepad and 2 for any other joystick.
@gap The original uses 1 for a digital and 2 for an analog joystick. Here a device that SDL recognizes as a gamepad is 1 and everything else is 2.
@gap Up to 4 joysticks are found, and only those that are connected when the first joystick command runs. Plugging one in later is not noticed.

## JoyU
The first extra axis of the joystick, from -1 to 1. On a gamepad this is usually a second stick or a trigger. The axes are numbered in the order of DirectInput: [JoyX](BlitzBasic-Joystick#joyx), [JoyY](BlitzBasic-Joystick#joyy), [JoyZ](BlitzBasic-Joystick#joyz), JoyU, [JoyV](BlitzBasic-Joystick#joyv), then pitch, yaw and roll. Which physical control is which axis depends on the device.
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns The axis position from -1 to 1, or 0 if the joystick has no such axis.

## JoyUDir
Like [JoyU](BlitzBasic-Joystick#joyu), but as a direction only: -1 when the axis is pushed more than a third of the way to its low end, 1 when it is pushed more than a third of the way to its high end, otherwise 0.
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns -1, 0 or 1.

## JoyV
The second extra axis of the joystick, from -1 to 1. See [JoyU](BlitzBasic-Joystick#joyu).
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns The axis position from -1 to 1, or 0 if the joystick has no such axis.

## JoyVDir
Like [JoyV](BlitzBasic-Joystick#joyv), but as a direction only: -1, 0 or 1.
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns -1, 0 or 1.

## JoyWait
Stops the program until a joystick button is pressed and returns its number. A program that has to keep drawing should poll [GetJoy](BlitzBasic-Joystick#getjoy) or [JoyHit](BlitzBasic-Joystick#joyhit) instead.
@param port  The joystick to wait for, counted from 0. Defaults to 0.
@returns The number of the button that was pressed.
@gap If no joystick is connected the function returns 0 right away instead of waiting forever.

## JoyX
The horizontal position of the main stick, from -1 (left) to 1 (right). A small value close to 0 is normal even when the stick is released, so ignore values below a dead zone of about 0.1.

```blitzbasic
;media still joystick/joyx.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Cls
Color 90, 90, 90
Oval 80, 40, 160, 160, 0
Color 255, 200, 0
Oval 160 + JoyX() * 70 - 10, 120 + JoyY() * 70 - 10, 20, 20, 1
Color 255, 255, 255
Text 160, 215, "JoyX " + JoyX() + "  JoyY " + JoyY(), 1, 1
Flip
WaitKey
```

![JoyX](media/joystick/joyx.png)
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns The position from -1 to 1, or 0 if there is no joystick.

## JoyXDir
Like [JoyX](BlitzBasic-Joystick#joyx), but as a direction only: -1 when pushed left past a third of the range, 1 when pushed right past a third, otherwise 0. Handy for menus.
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns -1, 0 or 1.

## JoyY
The vertical position of the main stick, from -1 (up) to 1 (down).
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns The position from -1 to 1, or 0 if there is no joystick.

## JoyYaw
The rotation around the vertical axis, from -180 to 180. Most joysticks do not have this axis.
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns The yaw in degrees, or 0 if the joystick has no such axis.
@gap The original gives -180 for a missing axis. Here it is 0.

## JoyYDir
Like [JoyY](BlitzBasic-Joystick#joyy), but as a direction only: -1 for up, 1 for down, 0 in the middle.
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns -1, 0 or 1.

## JoyZ
The third axis of the joystick, from -1 to 1. On a joystick it is usually the throttle slider, on a gamepad often a trigger. The yaw, pitch and roll commands read the axes after the five position axes, and scale them to degrees.
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns The axis position from -1 to 1, or 0 if the joystick has no such axis.

## JoyZDir
Like [JoyZ](BlitzBasic-Joystick#joyz), but as a direction only: -1, 0 or 1.
@param port  The joystick to ask, counted from 0. Defaults to 0.
@returns -1, 0 or 1.

## WaitJoy
The other name of [JoyWait](BlitzBasic-Joystick#joywait): stops the program until a joystick button is pressed and returns its number.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Text 10, 10, "Press a joystick button"
Flip
If JoyType() <> 0 Then b = WaitJoy()
Cls
Text 10, 10, "Button " + b
Flip
Delay 1000
```
@param port  The joystick to wait for, counted from 0. Defaults to 0.
@returns The number of the button that was pressed.
@gap If no joystick is connected the function returns 0 right away instead of waiting forever.
