## CreateToolBar
Makes a row of icon buttons from a picture file. The picture holds square icons side by side, and the number of icons is its width divided by its height. The pixel in the top left corner is the transparent color, and an icon that is only that color becomes a gap between buttons. Clicking a button sends $401 and [EventData](BlitzPlus-Events#eventdata) is the number of the icon, counted from 0.

```blitzbasic
;media interact toolbars/createtoolbar.gif 1
;media click 24 52
;media click 64 52
Graphics 320, 240, 32, 2
; Make a strip of four 16x16 icons: a square, a gap, a circle and a bar.
strip = CreateImage(64, 16)
SetBuffer ImageBuffer(strip)
Color 255, 0, 255 : Rect 0, 0, 64, 16, 1
Color 200, 40, 40 : Rect 2, 2, 12, 12, 1
Color 40, 140, 40 : Oval 34, 2, 12, 12, 1
Color 40, 40, 200 : Rect 50, 6, 12, 4, 1
SaveImage strip, "icons.bmp"
SetBuffer BackBuffer()

win = CreateWindow("Tools", 10, 10, 300, 150, Desktop(), 3)
bar = CreateToolBar("icons.bmp", 0, 0, 280, 28, win)
Repeat
	e = WaitEvent()
	If e = $401 And EventSource() = bar Then SetGadgetText win, "Icon " + EventData()
Until e = $803
```

![CreateToolBar](media/toolbars/createtoolbar.gif)
@param file    Picture file with the icons.
@param x       Horizontal position inside the group.
@param y       Vertical position inside the group.
@param width   Width of the toolbar.
@param height  Height of the toolbar.
@param group   Window, panel, tabber or canvas that holds it.
@param style   Reserved. Defaults to 0.
@returns A handle for the toolbar.
@gap The tool tips given with [SetToolBarTips](BlitzPlus-Toolbars#settoolbartips) are not shown.

## DisableToolBarItem
Greys out one icon of a toolbar. It no longer reacts and sends no events. [EnableToolBarItem](BlitzPlus-Toolbars#enabletoolbaritem) turns it back on.

```blitzbasic
Graphics 320, 240, 32, 2
strip = CreateImage(32, 16)
SetBuffer ImageBuffer(strip)
Color 255, 0, 255 : Rect 0, 0, 32, 16, 1
Color 200, 40, 40 : Rect 2, 2, 12, 12, 1
Color 40, 140, 40 : Oval 18, 2, 12, 12, 1
SaveImage strip, "icons.bmp"
SetBuffer BackBuffer()
win = CreateWindow("Off", 10, 10, 300, 100, Desktop(), 3)
bar = CreateToolBar("icons.bmp", 0, 0, 280, 28, win)
DisableToolBarItem bar, 1
Repeat
Until WaitEvent() = $803
```
@param toolbar  Handle of a toolbar.
@param index    Number of the icon, counted from 0 and not counting gaps.

## EnableToolBarItem
Turns an icon that was disabled with [DisableToolBarItem](BlitzPlus-Toolbars#disabletoolbaritem) back on.
@param toolbar  Handle of a toolbar.
@param index    Number of the icon, counted from 0 and not counting gaps.

## FreeIconStrip
Frees an icon strip that was loaded with [LoadIconStrip](BlitzPlus-Toolbars#loadiconstrip). Only needed when you load many during the run of a program, otherwise they are freed when it ends.
@param strip  Handle of an icon strip.

## LoadIconStrip
Loads a picture of icons placed side by side to use for the entries of list boxes, combo boxes and tabbers. Hand the result to [SetGadgetIconStrip](BlitzPlus-Toolbars#setgadgeticonstrip). The icons are squares with the height of the picture.

```blitzbasic
Graphics 320, 240, 32, 2
strip = CreateImage(32, 16)
SetBuffer ImageBuffer(strip)
Color 255, 0, 255 : Rect 0, 0, 32, 16, 1
Color 200, 40, 40 : Rect 2, 2, 12, 12, 1
Color 40, 140, 40 : Oval 18, 2, 12, 12, 1
SaveImage strip, "icons.bmp"
SetBuffer BackBuffer()
icons = LoadIconStrip("icons.bmp")
Notify "Strip " + icons
FreeIconStrip icons
```
@param file  Picture file with the icons.
@returns A handle for the icon strip.

## SetGadgetIconStrip
Gives a list box, combo box or tabber the icons to use for its entries. Afterwards the icon number given to [AddGadgetItem](BlitzPlus-Gadgets#addgadgetitem), [InsertGadgetItem](BlitzPlus-Gadgets#insertgadgetitem) or [ModifyGadgetItem](BlitzPlus-Gadgets#modifygadgetitem) picks one.

```blitzbasic
;media interact toolbars/setgadgeticonstrip.png 1
Graphics 320, 240, 32, 2
strip = CreateImage(32, 16)
SetBuffer ImageBuffer(strip)
Color 255, 0, 255 : Rect 0, 0, 32, 16, 1
Color 200, 40, 40 : Rect 2, 2, 12, 12, 1
Color 40, 140, 40 : Oval 18, 2, 12, 12, 1
SaveImage strip, "icons.bmp"
SetBuffer BackBuffer()
win  = CreateWindow("Icons", 10, 10, 300, 150, Desktop(), 3)
list = CreateListBox(10, 10, 200, 90, win)
SetGadgetIconStrip list, LoadIconStrip("icons.bmp")
AddGadgetItem list, "Red square", False, 0
AddGadgetItem list, "Green circle", False, 1
Repeat
Until WaitEvent() = $803
```

![SetGadgetIconStrip](media/toolbars/setgadgeticonstrip.png)
@param gadget  Handle of a list box, combo box or tabber.
@param strip   Handle from [LoadIconStrip](BlitzPlus-Toolbars#loadiconstrip).

## SetToolBarTips
Sets the hints for the icons of a toolbar, as a list separated by commas with one for each icon. They are supposed to pop up when the mouse rests over an icon.

```blitzbasic
Graphics 320, 240, 32, 2
strip = CreateImage(32, 16)
SetBuffer ImageBuffer(strip)
Color 255, 0, 255 : Rect 0, 0, 32, 16, 1
Color 200, 40, 40 : Rect 2, 2, 12, 12, 1
Color 40, 140, 40 : Oval 18, 2, 12, 12, 1
SaveImage strip, "icons.bmp"
SetBuffer BackBuffer()
win = CreateWindow("Tips", 10, 10, 300, 100, Desktop(), 3)
bar = CreateToolBar("icons.bmp", 0, 0, 280, 28, win)
SetToolBarTips bar, "Red thing,Green thing"
Repeat
Until WaitEvent() = $803
```
@param toolbar  Handle of a toolbar.
@param tips     Hints separated by commas.
@gap The hints are stored but never shown, there are no tool tips.
