; With BlitzLLVM the limit is no longer bi-linear filtering, even Anisotropy is possible
; It defaults to tri-linear, but you can choose your own at will.

Graphics3D 640, 480, 32, 2
SetBuffer BackBuffer() ; You actually don't need to do this, but it's become a habit from old Blitz3D
Dither 0 ; We don't want dithering right now.
AntiAlias 0 ; Anti-Aliasing will also not be needed yet.

; Build a texture with alternating white and black squares, like a chess board.
Local ChessTex = CreateTexture(64, 64, 1 + 8)
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

Local Plane = CreateInfinityPlane()
EntityFX Plane, 1 ; Full Bright (1)
EntityTexture Plane, ChessTex, 0

Local Camera = CreateCamera()
PositionEntity Camera, 0, 2, 0 ; 2 units up.
CameraRange Camera, 0.1, 65535.
CameraFogMode Camera, 2
CameraFogColor Camera, 51, 155, 255
CameraFogRange Camera, 1., 128.

Local SkySphere = CreateSphere(8, Camera)
EntityColor SkySphere, 51, 155, 255
EntityFX SkySphere, 1 + 8 + 16 ; Full Bright (1), Ignore Fog (8), Draw both sides (16)
ScaleEntity SkySphere, 512, 512, 512

; The default when mip-mapping (8) is enabled is Tri-Linear, but we can do more now.
Local ChessSampler = CreateSampler()
SetSamplerFilterMin ChessSampler, 0
SetSamplerFilterMag ChessSampler, 0
SetSamplerFilterMip ChessSampler, 0
SetTextureSampler ChessTex, ChessSampler ; Override the default sampler with out own.

RawInput 1 ; Enable raw input handling
Local lastTime:UInt64 = Microseconds()
While Not KeyHit(1) ; Escape quits this.
	Local nowTime:Uint64 = Microseconds()
	Local deltaTime:Float = Float(nowTime - lastTime) / 1000.f ; Calculate delta between frames in Microseconds
	Local deltaMul:Float = Float(16.67) / deltaTime ; We aim for 60.0 fps.
	lastTime = nowTime

	; Toggle between different sampling modes with the number row.
	If (KeyHit(79) Or KeyHit(2)) ; Either 1 (Numpad or Number Row)
		SetSamplerFilterMin ChessSampler, 0
	ElseIf (KeyHit(80) Or KeyHit(3)) ; Either 2 (Numpad or Number Row)
		SetSamplerFilterMin ChessSampler, 1
	ElseIf (KeyHit(81) Or KeyHit(4)) ; Either 3 (Numpad or Number Row)
		; Decrease Anisotropy
		SetSamplerAnisotropy ChessSampler, GetSamplerAnisotropy(ChessSampler) - 1
	ElseIf (KeyHit(75) Or KeyHit(5)) ; Either 4 (Numpad or Number Row)
		SetSamplerFilterMag ChessSampler, 0
	ElseIf (KeyHit(76) Or KeyHit(6)) ; Either 5 (Numpad or Number Row)
		SetSamplerFilterMag ChessSampler, 1
	ElseIf (KeyHit(77) Or KeyHit(7)) ; Either 6 (Numpad or Number Row)
		; Reset
		SetSamplerFilterMin ChessSampler, 0
		SetSamplerFilterMag ChessSampler, 0
		SetSamplerFilterMip ChessSampler, 0
		SetSamplerAnisotropy ChessSampler, 0
	ElseIf (KeyHit(71) Or KeyHit(8)) ; Either 7 (Numpad or Number Row)
		SetSamplerFilterMip ChessSampler, 0 ; Nearest
	ElseIf (KeyHit(72) Or KeyHit(9)) ; Either 8 (Numpad or Number Row)
		SetSamplerFilterMip ChessSampler, 1 ; Linear
	ElseIf (KeyHit(73) Or KeyHit(10)) ; Either 9 (Numpad or Number Row)
		; Increase Anisotropy
		SetSamplerAnisotropy ChessSampler, GetSamplerAnisotropy(ChessSampler) + 1
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

	Text 0, 0, "Min Mode: " + Str(GetSamplerFilterMin(ChessSampler))
	Text 0, 15, "Mag Mode: " + Str(GetSamplerFilterMag(ChessSampler))
	Text 0, 30, "Mip Mode: " + Str(GetSamplerFilterMip(ChessSampler))
	Text 0, 45, "Anisotropy: " + Str(GetSamplerAnisotropy(ChessSampler))

	Flip 1 ; Flip with VSync
	; Cls - Not necessary, handled by camera.
Wend

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
