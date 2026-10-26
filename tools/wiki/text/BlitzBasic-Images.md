## AutoMidHandle
Turns on or off the automatic centering of the handle of every image that is loaded, created or copied from now on. The handle is the point of an image that sits at the position given to [DrawImage](BlitzBasic-Images#drawimage). It starts in the top left corner. With AutoMidHandle on, it is in the middle of the image, which is what rotating and scaling sprites usually need. Images that already exist keep their handle.

```blitzbasic
;media still images/automidhandle.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
AutoMidHandle True
Local a = CreateImage(64, 64)
SetBuffer ImageBuffer(a)
Color 255, 160, 0
Oval 0, 0, 64, 64, 1
SetBuffer BackBuffer()
AutoMidHandle False
Local b = CreateImage(64, 64)
SetBuffer ImageBuffer(b)
Color 0, 160, 255
Oval 0, 0, 64, 64, 1
SetBuffer BackBuffer()
Cls
Color 255, 255, 255
Line 160, 0, 160, 239
Line 0, 120, 319, 120
DrawImage a, 80, 120
DrawImage b, 240, 120
Text 80, 200, "centered", 1, 1
Text 240, 200, "corner", 1, 1
Flip
WaitKey
```

![AutoMidHandle](media/images/automidhandle.png)
@param enable  True to center the handle of new images, False to put it in the top left corner (the default).

## CopyImage
Makes a new image that has the same pictures, handle and mask color as an existing one. Changes to the copy, such as [ScaleImage](BlitzBasic-Images#scaleimage), do not change the original, so copy an image before you transform it for several uses.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local original = CreateImage(32, 32)
Local copy = CopyImage(original)
ScaleImage copy, 2, 2
Print ImageWidth(original) + " and " + ImageWidth(copy)
WaitKey
```
@param image  The image to copy.
@returns A handle for the new image.

## CreateImage
Creates an empty image that is filled with black, which is the default mask color and so draws as transparent. Draw into it by making it the current buffer with [ImageBuffer](BlitzBasic-Images#imagebuffer). An image can hold several frames of the same size next to each other, such as the steps of an animation, which are chosen with the frame number of [DrawImage](BlitzBasic-Images#drawimage).

```blitzbasic
;media gif images/createimage.gif 40 20
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local img = CreateImage(64, 64, 8)
For f = 0 To 7
	SetBuffer ImageBuffer(img, f)
	Color 255, 200, 40
	Oval 0, 0, 64, 64, 1
	Color 0, 0, 0
	Oval 16 + f * 4, 8 + f, 24, 40, 1
Next
SetBuffer BackBuffer()
Local n = 0
While n < 40
	Cls
	Color 255, 255, 255
	DrawImage img, 128, 88, (n / 2) Mod 8
	Text 160, 190, "frame " + ((n / 2) Mod 8), 1, 1
	Flip
	n = n + 1
Wend
```

![CreateImage](media/images/createimage.gif)
@param width   Width of one frame in pixels.
@param height  Height of one frame in pixels.
@param frames  Number of frames. Defaults to 1.
@returns A handle for the image.
@gap A graphics window must be open, because images live in video memory. A size that is zero or negative stops the program with an error.

## DrawBlock
Draws a frame of an image without any transparency, so the mask color is drawn like any other. It is faster than [DrawImage](BlitzBasic-Images#drawimage) for pictures that fill a rectangle completely, such as backgrounds.

```blitzbasic
;media still images/drawblock.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local img = CreateImage(100, 100)
SetBuffer ImageBuffer(img)
Color 255, 160, 0
Oval 5, 5, 90, 90, 1
SetBuffer BackBuffer()
Cls
Color 40, 90, 160
Rect 0, 0, 320, 240, 1
DrawImage img, 30, 70
DrawBlock img, 190, 70
Color 255, 255, 255
Text 80, 200, "DrawImage", 1, 1
Text 240, 200, "DrawBlock", 1, 1
Flip
WaitKey
```

![DrawBlock](media/images/drawblock.png)
@param image  The image to draw.
@param x      Horizontal position of the handle of the image.
@param y      Vertical position of the handle of the image.
@param frame  Which frame to draw. Defaults to 0.

## DrawBlockRect
Draws only a rectangle of a frame, without any transparency. See [DrawBlock](BlitzBasic-Images#drawblock) and [DrawImageRect](BlitzBasic-Images#drawimagerect). The handle of the image is not used: the top left corner of the rectangle goes to the given position.
@param image        The image to draw.
@param x            Horizontal position on the screen of the top left corner of the part.
@param y            Vertical position on the screen of the top left corner of the part.
@param rect_x       Left edge of the part inside the frame.
@param rect_y       Top edge of the part inside the frame.
@param rect_width   Width of the part.
@param rect_height  Height of the part.
@param frame        Which frame to draw. Defaults to 0.
@gap Only the part that lies inside the frame is drawn. A rectangle that reaches over the edge is cut off.

## DrawImage
Draws a frame of an image at a position. The handle of the image, which is its top left corner unless [HandleImage](BlitzBasic-Images#handleimage), [MidHandle](BlitzBasic-Images#midhandle) or [AutoMidHandle](BlitzBasic-Images#automidhandle) says otherwise, ends up at the position. Pixels with the mask color of the image (black unless [MaskImage](BlitzBasic-Images#maskimage) changed it) are left out, so the picture can have any shape. Drawing is clipped by the viewport, and the [Origin](BlitzBasic-Drawing#origin) moves it.

```blitzbasic
;media still images/drawimage.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local ball = CreateImage(40, 40)
SetBuffer ImageBuffer(ball)
Color 255, 120, 0
Oval 0, 0, 40, 40, 1
Color 255, 230, 160
Oval 8, 6, 12, 12, 1
SetBuffer BackBuffer()
Cls
For i = 0 To 7
	DrawImage ball, 20 + i * 36, 100 + Sin(i * 45) * 50
Next
Flip
WaitKey
```

![DrawImage](media/images/drawimage.png)
@param image  The image to draw.
@param x      Horizontal position of the handle of the image.
@param y      Vertical position of the handle of the image.
@param frame  Which frame to draw. Defaults to 0.
@gap A frame number that does not exist stops the program with an error message.

## DrawImageRect
Draws only a rectangle of a frame, with the mask color left out. It can show a part of a big picture or cut a sheet into tiles. The handle of the image is not used: the top left corner of the rectangle goes to the given position.

```blitzbasic
;media still images/drawimagerect.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local img = CreateImage(120, 120)
SetBuffer ImageBuffer(img)
For i = 0 To 5
	Color 255 - i * 40, 100 + i * 25, 60 + i * 30
	Rect i * 10, i * 10, 120 - i * 20, 120 - i * 20, 1
Next
SetBuffer BackBuffer()
Cls
DrawImage img, 20, 60
DrawImageRect img, 180, 80, 40, 40, 80, 80
Color 255, 255, 255
Rect 180 - 1, 80 - 1, 82, 82, 0
Flip
WaitKey
```

![DrawImageRect](media/images/drawimagerect.png)
@param image        The image to draw.
@param x            Horizontal position on the screen of the top left corner of the part.
@param y            Vertical position on the screen of the top left corner of the part.
@param rect_x       Left edge of the part inside the frame.
@param rect_y       Top edge of the part inside the frame.
@param rect_width   Width of the part.
@param rect_height  Height of the part.
@param frame        Which frame to draw. Defaults to 0.
@gap Only the part that lies inside the frame is drawn. A rectangle that reaches over the edge is cut off.

## FreeImage
Releases an image and its video memory. The handle must not be used afterwards.
@param image  The image to free.
@gap Freeing a handle that is 0 or was already freed does nothing, while other commands stop with an error when they get such a handle.

## GrabImage
Copies a part of the current buffer into a frame of an image. The part has the size of the image and starts at the given position, so this is the way to take a screenshot into an image or to build a sprite from something that was drawn.

```blitzbasic
;media still images/grabimage.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local shot = CreateImage(80, 80)
Cls
Color 255, 80, 80
Oval 20, 20, 80, 80, 1
Color 80, 200, 255
Rect 60, 60, 60, 60, 1
GrabImage shot, 40, 40
Cls
For i = 0 To 2
	DrawBlock shot, 20 + i * 100, 80
Next
Flip
WaitKey
```

![GrabImage](media/images/grabimage.png)
@param image  The image to copy into.
@param x      Left edge of the part of the buffer to copy.
@param y      Top edge of the part of the buffer to copy.
@param frame  The frame to copy into. Defaults to 0.
@gap Parts that lie outside of the buffer are not copied and keep what the frame had before.

## HandleImage
Sets the handle of an image: the point of the image that is placed at the position given to [DrawImage](BlitzBasic-Images#drawimage). The handle is measured from the top left corner of the image, and it is also the point around which [RotateImage](BlitzBasic-Images#rotateimage) and [ScaleImage](BlitzBasic-Images#scaleimage) work. It may lie outside of the image.

```blitzbasic
;media still images/handleimage.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local img = CreateImage(60, 40)
SetBuffer ImageBuffer(img)
Color 255, 160, 0
Rect 0, 0, 60, 40, 1
Color 0, 0, 0
Rect 20, 12, 20, 16, 1
SetBuffer BackBuffer()
Cls
HandleImage img, 0, 0
DrawImage img, 100, 60
HandleImage img, 30, 20
DrawImage img, 100, 160
Color 255, 255, 255
Line 80, 60, 120, 60 : Line 100, 40, 100, 80
Line 80, 160, 120, 160 : Line 100, 140, 100, 180
Text 180, 60, "handle 0, 0", 0, 1
Text 180, 160, "handle 30, 20", 0, 1
Flip
WaitKey
```

![HandleImage](media/images/handleimage.png)
@param image  The image.
@param x      Horizontal position of the handle, counted from the left edge.
@param y      Vertical position of the handle, counted from the top edge.

## ImageBuffer
Returns the buffer of one frame of an image, which [SetBuffer](BlitzBasic-Buffers-and-Pixels#setbuffer) can make the target of all drawing commands. The buffer is also the one that [LockBuffer](BlitzBasic-Buffers-and-Pixels#lockbuffer) and [ReadPixel](BlitzBasic-Buffers-and-Pixels#readpixel) work on.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local img = CreateImage(32, 32, 2)
SetBuffer ImageBuffer(img, 0)
Color 255, 0, 0
Rect 0, 0, 32, 32, 1
SetBuffer ImageBuffer(img, 1)
Color 0, 0, 255
Rect 0, 0, 32, 32, 1
SetBuffer BackBuffer()
Cls
DrawImage img, 60, 100, 0
DrawImage img, 140, 100, 1
Flip
WaitKey
```
@param image  The image.
@param frame  The frame whose buffer to return. Defaults to 0.
@returns A buffer handle for [SetBuffer](BlitzBasic-Buffers-and-Pixels#setbuffer) and the pixel commands.
@gap A frame number that does not exist stops the program with an error message.

## ImageHeight
The height of one frame of an image in pixels.
@param image  The image.
@returns The height of a frame.

## ImageRectCollide
Tells whether a rectangle touches any visible (not masked) pixel of a frame of an image placed at a position. It is exact, unlike [ImageRectOverlap](BlitzBasic-Images#imagerectoverlap), which only compares the box of the image.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local ring = CreateImage(100, 100)
SetBuffer ImageBuffer(ring)
Color 255, 255, 0
Oval 0, 0, 100, 100, 0
SetBuffer BackBuffer()
; The middle of the ring is empty, so the box of the image is touched but not the ring.
Print ImageRectOverlap(ring, 50, 50, 90, 90, 10, 10)
Print ImageRectCollide(ring, 50, 50, 0, 90, 90, 10, 10)
Print ImageRectCollide(ring, 50, 50, 0, 50, 95, 10, 10)
WaitKey
```
@param image        The image.
@param x            Horizontal position where the image is drawn.
@param y            Vertical position where the image is drawn.
@param frame        The frame to test.
@param rect_x       Left edge of the rectangle.
@param rect_y       Top edge of the rectangle.
@param rect_width   Width of the rectangle.
@param rect_height  Height of the rectangle.
@returns 1 if the rectangle touches a pixel of the image, otherwise 0.

## ImageRectOverlap
Tells whether a rectangle touches the box of an image at a position. Transparent pixels count, so this is the quick first check before the exact [ImageRectCollide](BlitzBasic-Images#imagerectcollide).
@param image        The image.
@param x            Horizontal position where the image is drawn.
@param y            Vertical position where the image is drawn.
@param rect_x       Left edge of the rectangle.
@param rect_y       Top edge of the rectangle.
@param rect_width   Width of the rectangle.
@param rect_height  Height of the rectangle.
@returns 1 if the rectangle touches the box of the image, otherwise 0.

## ImagesCollide
Tells whether two images touch, looking at the pixels that are visible. Both images are taken at their handle, and the frame to test is given for each.

```blitzbasic
;media still images/imagescollide.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local a = CreateImage(80, 80)
SetBuffer ImageBuffer(a)
Color 255, 160, 0
Oval 0, 0, 80, 80, 1
SetBuffer BackBuffer()
Local b = CopyImage(a)
Cls
DrawImage a, 60, 40
DrawImage b, 125, 105
Color 255, 255, 255
Text 10, 190, "ImagesOverlap: " + ImagesOverlap(a, 60, 40, b, 125, 105)
Text 10, 206, "ImagesCollide: " + ImagesCollide(a, 60, 40, 0, b, 125, 105, 0)
Flip
WaitKey
```

![ImagesCollide](media/images/imagescollide.png)
@param image1  The first image.
@param x1      Horizontal position where the first image is drawn.
@param y1      Vertical position where the first image is drawn.
@param frame1  The frame of the first image.
@param image2  The second image.
@param x2      Horizontal position where the second image is drawn.
@param y2      Vertical position where the second image is drawn.
@param frame2  The frame of the second image.
@returns 1 if visible pixels of the two images are on top of each other, otherwise 0.
@gap A frame number that does not exist stops the program with an error message.

## ImagesOverlap
Tells whether the boxes of two images touch, which is quick but counts transparent pixels as well. Use it to decide whether the exact [ImagesCollide](BlitzBasic-Images#imagescollide) is needed.
@param image1  The first image.
@param x1      Horizontal position where the first image is drawn.
@param y1      Vertical position where the first image is drawn.
@param image2  The second image.
@param x2      Horizontal position where the second image is drawn.
@param y2      Vertical position where the second image is drawn.
@returns 1 if the boxes overlap, otherwise 0.

## ImageWidth
The width of one frame of an image in pixels.
@param image  The image.
@returns The width of a frame.

## ImageXHandle
The horizontal position of the handle of an image, counted from its left edge.
@param image  The image.
@returns The x position of the handle.

## ImageYHandle
The vertical position of the handle of an image, counted from its top edge.
@param image  The image.
@returns The y position of the handle.

## LoadAnimImage
Loads a picture file that contains several frames next to each other and cuts it into the frames of one image. Frames are counted from left to right, then from top to bottom, and each is `cellwidth` by `cellheight` pixels. Choose one with the frame number of [DrawImage](BlitzBasic-Images#drawimage).

The example makes its own sheet first with [CreateImage](BlitzBasic-Images#createimage) and [SaveImage](BlitzBasic-Images#saveimage), so that it needs no other file.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
; Four frames of 32x32 next to each other, saved as a 128x32 picture.
Local sheet = CreateImage(128, 32)
SetBuffer ImageBuffer(sheet)
For f = 0 To 3
	Color 60 + f * 60, 200 - f * 40, 80
	Oval f * 32 + 16 - f * 3, 16 - f * 3, f * 6 + 2, f * 6 + 2, 1
Next
SetBuffer BackBuffer()
SaveImage sheet, "sheet.bmp"
Local anim = LoadAnimImage("sheet.bmp", 32, 32, 0, 4)
Cls
For f = 0 To 3
	DrawImage anim, 40 + f * 60, 100, f
Next
Flip
WaitKey
```
@param file        The path of the picture file. BMP, PNG, JPEG and other common formats can be loaded.
@param cellwidth   Width of one frame.
@param cellheight  Height of one frame.
@param first       Number of the first frame in the sheet, usually 0.
@param count       How many frames to cut out.
@returns A handle for the image, or 0 if the file could not be loaded or the frame size does not fit.

## LoadImage
Loads a picture file into an image with one frame. Pixels that are black are drawn as transparent by [DrawImage](BlitzBasic-Images#drawimage) until [MaskImage](BlitzBasic-Images#maskimage) picks another color. Load images once at the start of a program and draw them often. If the file is missing, the result is 0, so check it before drawing.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
; Make a picture file first so that the example runs without any other file.
Local made = CreateImage(64, 64)
SetBuffer ImageBuffer(made)
Color 80, 200, 120
Oval 0, 0, 64, 64, 1
SetBuffer BackBuffer()
SaveImage made, "dot.bmp"

Local img = LoadImage("dot.bmp")
If img = 0 Then RuntimeError "dot.bmp could not be loaded"
Cls
DrawImage img, 128, 88
Flip
WaitKey
```
@param file  The path of the picture file. BMP, PNG, JPEG and other common formats can be loaded.
@returns A handle for the image, or 0 if the file could not be loaded.
@gap More file formats load than in the original, which read BMP, PNG, JPEG and TGA. Files are decoded by SDL_image.
@gap Backslashes in paths are changed into slashes on Linux and macOS.

## MaskImage
Chooses the color that [DrawImage](BlitzBasic-Images#drawimage) leaves out when it draws the image. The default is black. Setting a color that the picture does not contain makes every pixel visible, which is how to show black pixels. [DrawBlock](BlitzBasic-Images#drawblock) ignores the mask.

```blitzbasic
;media still images/maskimage.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local img = CreateImage(80, 80)
SetBuffer ImageBuffer(img)
Color 255, 0, 255
Rect 0, 0, 80, 80, 1
Color 255, 220, 0
Oval 10, 10, 60, 60, 1
SetBuffer BackBuffer()
Cls
Color 30, 60, 120
Rect 0, 0, 320, 240, 1
DrawImage img, 30, 80
MaskImage img, 255, 0, 255
DrawImage img, 190, 80
Color 255, 255, 255
Text 70, 190, "mask black", 1, 1
Text 230, 190, "mask magenta", 1, 1
Flip
WaitKey
```

![MaskImage](media/images/maskimage.png)
@param image  The image.
@param red    Red part of the mask color, 0 to 255.
@param green  Green part of the mask color, 0 to 255.
@param blue   Blue part of the mask color, 0 to 255.

## MidHandle
Puts the handle of an image in its middle. Images drawn at a position then appear centered on it, and rotate and scale around their middle.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local img = CreateImage(40, 40)
SetBuffer ImageBuffer(img)
Color 255, 160, 0
Rect 0, 0, 40, 40, 1
SetBuffer BackBuffer()
MidHandle img
Cls
DrawImage img, MouseX(), MouseY()
Print ImageXHandle(img) + ", " + ImageYHandle(img)
Flip
WaitKey
```
@param image  The image.

## RectsOverlap
Tells whether two rectangles touch. It works on plain numbers and needs no image, so it is a good quick test for boxes of any kind.

```blitzbasic
Print RectsOverlap(0, 0, 50, 50, 40, 40, 50, 50)
Print RectsOverlap(0, 0, 50, 50, 60, 60, 50, 50)
WaitKey
```
@param x1       Left edge of the first rectangle.
@param y1       Top edge of the first rectangle.
@param width1   Width of the first rectangle.
@param height1  Height of the first rectangle.
@param x2       Left edge of the second rectangle.
@param y2       Top edge of the second rectangle.
@param width2   Width of the second rectangle.
@param height2  Height of the second rectangle.
@returns 1 if the rectangles overlap, otherwise 0.

## ResizeImage
Changes the size of every frame of an image to a new width and height in pixels, stretching the picture. The handle moves with the picture. Resizing again and again loses quality, so keep the original or use [CopyImage](BlitzBasic-Images#copyimage) first.

```blitzbasic
;media still images/resizeimage.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local img = CreateImage(40, 40)
SetBuffer ImageBuffer(img)
Color 255, 160, 0
Oval 0, 0, 40, 40, 1
Color 0, 0, 0
Oval 12, 12, 16, 16, 1
SetBuffer BackBuffer()
Local wide = CopyImage(img)
ResizeImage wide, 120, 40
Local tall = CopyImage(img)
ResizeImage tall, 40, 120
Cls
DrawImage img, 20, 100
DrawImage wide, 90, 100
DrawImage tall, 240, 60
Flip
WaitKey
```

![ResizeImage](media/images/resizeimage.png)
@param image   The image.
@param width   New width of a frame in pixels.
@param height  New height of a frame in pixels.
@gap The picture is stretched with smooth filtering, where the original used simple pixel picking. Edges of resized images are softer.

## RotateImage
Turns every frame of an image around its handle by an angle in degrees, clockwise when positive. The image gets larger so that the whole picture fits, and the corners that are added are masked. The change is permanent and cumulative, and every rotation blurs the picture a little, so rotate a copy of the original image.

```blitzbasic
;media still images/rotateimage.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local arrow = CreateImage(60, 30)
SetBuffer ImageBuffer(arrow)
Color 255, 160, 0
Rect 0, 8, 40, 14, 1
Rect 36, 0, 8, 30, 1
Rect 44, 4, 8, 22, 1
Rect 52, 10, 8, 10, 1
SetBuffer BackBuffer()
Cls
For i = 0 To 3
	Local r = CopyImage(arrow)
	MidHandle r
	RotateImage r, i * 30
	DrawImage r, 50 + i * 75, 120
Next
Flip
WaitKey
```

![RotateImage](media/images/rotateimage.png)
@param image  The image.
@param angle  The angle in degrees.

## SaveImage
Writes one frame of an image into a picture file. The file is a PNG when its name ends with `.png`, otherwise a BMP.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local img = CreateImage(64, 64)
SetBuffer ImageBuffer(img)
Color 255, 255, 0
Oval 0, 0, 64, 64, 1
SetBuffer BackBuffer()
If SaveImage(img, "saved.png") Then Print "saved.png written" Else Print "could not save"
WaitKey
```
@param image  The image.
@param file   The path of the file to write.
@param frame  The frame to save. Defaults to 0.
@returns 1 if the file was written, otherwise 0.
@gap The original only writes BMP files. A name ending in `.png` gives a PNG here.

## ScaleImage
Scales every frame of an image by a factor: 2 doubles its size, 0.5 halves it, and a negative factor flips the picture, which then extends to the left or up from the handle. The change is permanent, so scale a copy when the original is still needed.

```blitzbasic
;media still images/scaleimage.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local img = CreateImage(32, 32)
SetBuffer ImageBuffer(img)
Color 255, 160, 0
Rect 0, 0, 32, 32, 1
Color 0, 0, 0
Rect 0, 16, 16, 16, 1
SetBuffer BackBuffer()
Local big = CopyImage(img)
ScaleImage big, 3, 3
Local flip_x = CopyImage(img)
ScaleImage flip_x, -2, 2
Cls
DrawImage img, 20, 100
DrawImage big, 80, 70
DrawImage flip_x, 270, 100
Flip
WaitKey
```

![ScaleImage](media/images/scaleimage.png)
@param image   The image.
@param xscale  Horizontal factor.
@param yscale  Vertical factor.
@gap Scaling uses the same smooth filter as [TFormImage](BlitzBasic-Images#tformimage), which [TFormFilter](BlitzBasic-Images#tformfilter) can turn off.

## TFormFilter
Chooses how [TFormImage](BlitzBasic-Images#tformimage), [ScaleImage](BlitzBasic-Images#scaleimage) and [RotateImage](BlitzBasic-Images#rotateimage) look pixels up. With the filter on, the colors of neighboring pixels are blended for a smooth result. With it off, the nearest pixel is taken, which keeps hard edges and is the right choice for pixel art.

```blitzbasic
;media still images/tformfilter.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local img = CreateImage(8, 8)
SetBuffer ImageBuffer(img)
Color 255, 255, 255
Rect 0, 0, 8, 8, 0
Rect 2, 2, 4, 4, 1
SetBuffer BackBuffer()
TFormFilter True
Local smooth = CopyImage(img)
ScaleImage smooth, 12.5, 12.5
TFormFilter False
Local sharp = CopyImage(img)
ScaleImage sharp, 12.5, 12.5
Cls
DrawBlock smooth, 10, 40
DrawBlock sharp, 160, 40
Color 255, 255, 255
Text 60, 160, "filter on", 1, 1
Text 210, 160, "filter off", 1, 1
Flip
WaitKey
```

![TFormFilter](media/images/tformfilter.png)
@param enable  True for smooth results (the default), False for the nearest pixel.

## TFormImage
Transforms every frame of an image with a 2x2 matrix. With the values `a, b, c, d` a point `(x, y)` of the picture, measured from the handle, goes to `(a*x + c*y, b*x + d*y)`. The matrix `a=1, b=0, c=0.6, d=1` tilts the picture to the right, and [ScaleImage](BlitzBasic-Images#scaleimage) and [RotateImage](BlitzBasic-Images#rotateimage) are special cases. The image becomes as large as the result needs.

```blitzbasic
;media still images/tformimage.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local img = CreateImage(60, 60)
SetBuffer ImageBuffer(img)
Color 255, 160, 0
Rect 0, 0, 60, 60, 1
Color 0, 0, 0
Oval 15, 15, 30, 30, 1
SetBuffer BackBuffer()
Local tilted = CopyImage(img)
MidHandle tilted
TFormImage tilted, 1, 0, 0.6, 1
Cls
DrawImage img, 40, 90
DrawImage tilted, 200, 120
Flip
WaitKey
```

![TFormImage](media/images/tformimage.png)
@param image  The image.
@param a      Horizontal part of the first column of the matrix.
@param b      Vertical part of the first column of the matrix.
@param c      Horizontal part of the second column of the matrix.
@param d      Vertical part of the second column of the matrix.
@gap A matrix that cannot be inverted (for example `a=0, b=0`) stops the program with an error message.

## TileBlock
Fills the whole current buffer with copies of a frame of an image, drawn without transparency. The pattern starts at the given offset, which makes scrolling backgrounds easy: change the offset a little every frame.

```blitzbasic
;media gif images/tileblock.gif 40 20
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local tile = CreateImage(32, 32)
SetBuffer ImageBuffer(tile)
Color 40, 70, 130
Rect 0, 0, 32, 32, 1
Color 70, 110, 190
Rect 0, 0, 16, 16, 1
Rect 16, 16, 16, 16, 1
SetBuffer BackBuffer()
Local n = 0
While n < 40
	TileBlock tile, n, n / 2
	Flip
	n = n + 1
Wend
```

![TileBlock](media/images/tileblock.gif)
@param image  The image to repeat.
@param x      Horizontal offset of the pattern. Defaults to 0.
@param y      Vertical offset of the pattern. Defaults to 0.
@param frame  Which frame to use. Defaults to 0.

## TileImage
Like [TileBlock](BlitzBasic-Images#tileblock), but the mask color is left out, so what is behind the tiles shows through.

```blitzbasic
;media still images/tileimage.png
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local star = CreateImage(24, 24)
SetBuffer ImageBuffer(star)
Color 255, 220, 0
Oval 6, 6, 12, 12, 1
Rect 11, 0, 2, 24, 1
Rect 0, 11, 24, 2, 1
SetBuffer BackBuffer()
Cls
Color 20, 40, 90
Rect 0, 0, 320, 240, 1
TileImage star, 4, 4
Flip
WaitKey
```

![TileImage](media/images/tileimage.png)
@param image  The image to repeat.
@param x      Horizontal offset of the pattern. Defaults to 0.
@param y      Vertical offset of the pattern. Defaults to 0.
@param frame  Which frame to use. Defaults to 0.
