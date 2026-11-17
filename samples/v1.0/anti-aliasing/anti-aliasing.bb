; As MSAA and SSAA (the original behavior) are extremely expensive, BlitzLLVM
; opts for an alternative: SMAA, and SMAA T2x. SMAA provides spatial AA, while
; SMAA T2x provides temporal AA - but without the smearing usually seen in TAA!

; First lets create our usual graphics buffers.
Graphics3D 640, 480, 32, 2 ; 640x480, 32 bit, Windowed
SetBuffer BackBuffer() ; An old habit from BlitzBasic and Blitz3D where this was actually necessary.
Dither 0 ; We don't want dithering right now, we'll look into that later.

Local Scene = CreateScene() ; Create the necessary scene to showcase this effect.

Local Camera = CreateCamera() ; The camera we need.
PositionEntity Camera, 0, 2, 0 ; 2 units up.
CameraRange Camera, 0.1, 65535.
CameraFogMode Camera, 2
CameraFogColor Camera, 51, 155, 255
CameraFogRange Camera, 1., 128.

; Now we just need something to showcase the effect, how about a Cube?
Local Cube = CreateCube()
PositionEntity Cube, 0, 2, 5 ; 2 units up, 5 units forwards.
RotateEntity Cube, 30, 40, 20 ; 30° Pitch, 40° Yaw, 20° Roll

RawInput True ; Enable raw input handling.
Local lastTime:UInt64 = Microseconds()
Local HasSaved = False
While Not KeyHit(1) ; Escape quits this.
	Local nowTime:Uint64 = Microseconds()
	Local deltaTime:Float = Float(nowTime - lastTime) / 1000.f ; Calculate delta between frames in Microseconds
	Local deltaMul:Float = Float(16.67) / deltaTime ; We aim for 60.0 fps.
	lastTime = nowTime

	; Lets add some toggles so we can showcase each variant.
	If (KeyHit(79) Or KeyHit(2)) ; Either 1 (Numpad or Number Row)
		AntiAlias 0 ; No Anti-Aliasing
		HasSaved = False
	ElseIf (KeyHit(80) Or KeyHit(3)) ; Either 2 (Numpad or Number Row)
		AntiAlias 1 ; SMAA
		HasSaved = False
	ElseIf (KeyHit(81) Or KeyHit(4)) ; Either 3 (Numpad or Number Row)
		AntiAlias 2 ; SMAA T2x
		HasSaved = False
	EndIf

	; Camera Movement logic
	If MouseDown(2) Then ; While Right Mouse button is held
		HidePointer ; Hide The Mouse
		LockMouse ; Lock it to the current window

		; Mouse turns camera, WASDQE moves it.
		TurnEntity Camera, MouseYSpeed() * deltaTime * 0.1, -MouseXSpeed() * deltaTime * 0.1, 0
		MoveEntity Camera, (KeyDown(32) - KeyDown(30)) * deltaTime * 0.01, (KeyDown(18) - KeyDown(16)) * deltaTime * 0.01, (KeyDown(17) - KeyDown(31)) * deltaTime * 0.01
	Else ; Otherwise
		ShowPointer ; Show the Mouse
		UnlockMouse ; And let it roam free.
	EndIf

	RenderWorld ; Draw to screen.
	;If Not HasSaved Then
	;	SaveBuffer(BackBuffer(), "tmp.png", "lossless")
	;	HasSaved = True
	;EndIf

	Flip 1 ; Flip with VSync
	; Cls - Not necessary, handled by camera.
Wend

Function CreateScene:Int32()
	Local Scene = CreatePivot()

	; Build a texture with alternating white and black squares, like a chess board.
	Local ChessTex = CreateTexture(64, 64, 1 + 8) ; Only need Color for this demo.
	Local Buf = TextureBuffer(ChessTex)
	LockBuffer(Buf)
	For X = 0 To 63
		For Y = 0 To 63
			WritePixelFast X, Y, 0, Buf
			If X <= 31 And Y <= 31 Then
				WritePixelFast X, Y, 0xFFFFFFFF, Buf
			ElseIf X >= 32 And Y >= 32 Then
				WritePixelFast X, Y, 0xFFFFFFFF, Buf
			EndIf
		Next
	Next
	UnlockBuffer(Buf)

	Local Plane = CreateInfinityPlane(Scene)
	EntityFX Plane, 1 ; Full Bright (1)
	EntityTexture Plane, ChessTex, 0

	Local SkySphere = CreateSphere(8, Scene)
	EntityColor SkySphere, 51, 155, 255
	EntityFX SkySphere, 1 + 8 + 16 ; Full Bright (1), Ignore Fog (8), Draw both sides (16)
	ScaleEntity SkySphere, 512, 512, 512

	; The default when mip-mapping (8) is enabled is Tri-Linear, but we can do more now.
	Local ChessSampler = CreateSampler()
	SetSamplerFilterMin ChessSampler, 1 ; Linear Filtering everywhere.
	SetSamplerFilterMag ChessSampler, 1
	SetSamplerFilterMip ChessSampler, 1
	SetSamplerAnisotropy ChessSampler, 4
	SetTextureSampler ChessTex, ChessSampler ; Override the default sampler with out own.

	Return Scene
EndFunction

Function CreateInfinityPlane:Int32(Parent:Int32 = 0)
	Local Plane = CreateMesh(Parent)
	Local PlaneSurf = CreateSurface(Plane)

	Const SubDiv = 128
	Const Size# = 4096.

	; Create an optimal sub-divided plane that can move with us.
	Local X, Y
	Local VertXY[SubDiv * SubDiv]
	For Y = 0 To SubDiv - 1
		For X = 0 To SubDiv - 1
			Local Xn# = Float(X) / Float(SubDiv)
			Local Yn# = Float(Y) / Float(SubDiv)
			Local Rx# = (Xn - 0.5) * (Size / 2.)
			Local Ry# = (Yn - 0.5) * (Size / 2.)
			Local Ux# = Xn * Size
			Local Uy# = Yn * Size
			VertXY[Y * SubDiv + X] = AddVertex(PlaneSurf, Rx, 0., Ry, Ux, Uy, 0)
			VertexNormal PlaneSurf, VertXY[Y * SubDiv + X], 0, 1, 0
		Next
	Next
	For Y = 1 To SubDiv - 1
		For X = 1 To SubDiv - 1
			AddTriangle(PlaneSurf, VertXY[((Y - 1) * SubDiv) + (X - 1)], VertXY[((Y) * SubDiv) + (X - 1)], VertXY[((Y - 1) * SubDiv) + (X)])
			AddTriangle(PlaneSurf, VertXY[((Y - 1) * SubDiv) + (X)], VertXY[((Y) * SubDiv) + (X - 1)], VertXY[((Y) * SubDiv) + (X)])
		Next
	Next

	Return Plane
EndFunction
