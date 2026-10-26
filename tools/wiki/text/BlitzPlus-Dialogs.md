## RequestColor
Opens a color picker with three sliders and waits until the user presses OK or Cancel. Read the picked color with [RequestedRed](BlitzPlus-Dialogs#requestedred), [RequestedGreen](BlitzPlus-Dialogs#requestedgreen) and [RequestedBlue](BlitzPlus-Dialogs#requestedblue). While the picker is open nothing else in the program window reacts.

```blitzbasic
;media interact dialogs/requestcolor.gif 1
;media wait 300
;media click 340 107
;media click 200 137
;media click 278 223
Graphics 480, 300, 32, 2
win   = CreateWindow("Pick", 20, 20, 240, 140, Desktop(), 3)
swatch = CreatePanel(20, 20, 100, 60, win)
If RequestColor(40, 120, 200) Then
	SetPanelColor swatch, RequestedRed(), RequestedGreen(), RequestedBlue()
EndIf
Repeat
Until WaitEvent() = $803
```

![RequestColor](media/dialogs/requestcolor.gif)
@param red    Red the sliders start at, 0 to 255. Defaults to 255.
@param green  Green the sliders start at, 0 to 255. Defaults to 255.
@param blue   Blue the sliders start at, 0 to 255. Defaults to 255.
@returns 1 if the user pressed OK, 0 if the dialog was cancelled.
@gap The picker is drawn by the program inside its own window and is simpler than the Windows color dialog: three sliders and a preview, no palette and no custom colors. Return confirms and Escape cancels.

## RequestDir
Opens the folder picker of the system and gives the folder that was chosen, or an empty string if the user cancelled.

```blitzbasic
Graphics 320, 240, 32, 2
win = CreateWindow("Folders", 20, 20, 260, 100, Desktop(), 3)
dir$ = RequestDir("Pick a folder", CurrentDir$())
If dir$ <> "" Then SetGadgetText win, dir$
Repeat
Until WaitEvent() = $803
```
@param prompt  Text for the title of the dialog. Defaults to an empty string.
@param path    Folder to start in. Defaults to an empty string, which lets the system choose.
@returns The full path of the folder, or an empty string if nothing was picked.
@gap It is the folder dialog of the operating system, which differs between Windows, macOS and Linux. The prompt is the title, not text inside the dialog. Without a desktop session that can show one it returns an empty string.

## RequestedBlue
@returns The blue part, 0 to 255, of the color the last [RequestColor](BlitzPlus-Dialogs#requestcolor) picked. 0 before any color was picked.

## RequestedGreen
@returns The green part, 0 to 255, of the color the last [RequestColor](BlitzPlus-Dialogs#requestcolor) picked. 0 before any color was picked.

## RequestedRed
@returns The red part, 0 to 255, of the color the last [RequestColor](BlitzPlus-Dialogs#requestcolor) picked. 0 before any color was picked.

## RequestFile
Opens the file picker of the system and gives the file that was chosen, or an empty string if the user cancelled. Pass a list of extensions to show only those files. With the save flag the dialog is for naming a file that may not exist yet.

The extension list is separated by commas, and a `;` splits it into groups: `"bb,bmx;*.txt"` offers the types bb and bmx together, and txt next to them.

```blitzbasic
Graphics 320, 240, 32, 2
win = CreateWindow("Files", 20, 20, 260, 100, Desktop(), 3)
file$ = RequestFile("Open a picture", "png,jpg,bmp")
If file$ <> "" Then SetGadgetText win, file$
Repeat
Until WaitEvent() = $803
```
@param title      Title of the dialog. Defaults to an empty string.
@param extensions Comma separated file types to show, without dots. Defaults to an empty string, which shows all files.
@param save       1 asks for a name to save to, 0 asks for an existing file. Defaults to 0.
@param name       File name or folder to start with. Defaults to an empty string.
@returns The full path of the file, or an empty string if nothing was picked.
@gap It is the file dialog of the operating system, so it looks different on each system. The list of extensions is shown as one filter named "Files", groups with `;` are merged into it.

## RequestFont
Opens a font picker and gives a font that was chosen, or 0 if the user cancelled. The font works with `SetFont`, [SetGadgetFont](BlitzPlus-Gadgets#setgadgetfont) and [FontName](BlitzPlus-System#fontname).

```blitzbasic
;media interact dialogs/requestfont.gif 1
;media wait 300
;media click 200 174
;media click 238 308
Graphics 480, 360, 32, 2
win   = CreateWindow("Fonts", 20, 20, 300, 120, Desktop(), 3)
label = CreateLabel("The quick brown fox", 10, 10, 270, 50, win)
font = RequestFont()
If font Then SetGadgetFont label, font
Repeat
Until WaitEvent() = $803
```

![RequestFont](media/dialogs/requestfont.gif)
@returns A font handle, or 0 if cancelled.
@gap Only the size can be picked, from 8 to 32 points in a list, and the result is always the built-in font. There is no font name, bold, italic or underline choice, and no preview.
