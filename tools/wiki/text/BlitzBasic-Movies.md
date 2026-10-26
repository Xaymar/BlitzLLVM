## CloseMovie
Closes a movie that [OpenMovie](BlitzBasic-Movies#openmovie) opened and frees what it used. A movie that should play again has to be closed and opened anew.
@param movie  A movie handle from OpenMovie.
@gap Does nothing, because no movie can be opened.

## DrawMovie
Draws the current picture of a movie into the current buffer. For a video the movie plays by itself at its normal speed and DrawMovie shows the newest picture, so call it once per frame. The position and size are in screen pixels, the origin and viewport are ignored, and the movie has to lie completely inside the screen.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local m = OpenMovie("movie.avi")
If m = 0 Then
	Print "No movie.avi to play"
	WaitKey
	End
EndIf
While MoviePlaying(m) And Not KeyHit(1)
	Cls
	DrawMovie m, 0, 0, 320, 240
	Flip
Wend
CloseMovie m
```
@param movie  A movie handle from [OpenMovie](BlitzBasic-Movies#openmovie).
@param x      Horizontal position of the top left corner. Defaults to 0.
@param y      Vertical position of the top left corner. Defaults to 0.
@param w      Width to draw at. Defaults to the width of the movie.
@param h      Height to draw at. Defaults to the height of the movie.
@gap Draws nothing. There is no video playback.

## MovieHeight
The height of the pictures of a movie in pixels.
@param movie  A movie handle from [OpenMovie](BlitzBasic-Movies#openmovie).
@returns The height in pixels.
@gap Returns 0, because no movie can be opened.

## MoviePlaying
Tells whether a movie is still playing. It becomes 0 when the movie reaches its end, so a loop can run until the movie is over.
@param movie  A movie handle from [OpenMovie](BlitzBasic-Movies#openmovie).
@returns 1 while the movie plays, otherwise 0.
@gap Always returns 0.

## MovieWidth
The width of the pictures of a movie in pixels.
@param movie  A movie handle from [OpenMovie](BlitzBasic-Movies#openmovie).
@returns The width in pixels.
@gap Returns 0, because no movie can be opened.

## OpenMovie
Opens a movie file for playback and returns a handle for [DrawMovie](BlitzBasic-Movies#drawmovie), [MoviePlaying](BlitzBasic-Movies#movieplaying) and the other movie commands. The original played AVI, MPEG and animated GIF files through DirectShow, and a movie starts playing as soon as it is opened. A program should always test for the result 0, which means the movie could not be opened, and carry on without it.

```blitzbasic
Graphics 320, 240, 0, 2
SetBuffer BackBuffer()
Local m = OpenMovie("intro.avi")
Cls
If m = 0 Then
	Text 160, 120, "The movie could not be opened", 1, 1
Else
	Text 160, 120, "Movie size " + MovieWidth(m) + " x " + MovieHeight(m), 1, 1
	CloseMovie m
EndIf
Flip
WaitKey
```
@param file  The path of the movie file.
@returns A movie handle, or 0 if the movie could not be opened.
@gap There is no video playback yet, so the result is always 0, the same that the original gives for a file it cannot play. Programs that check the result run on, only without their movies.
