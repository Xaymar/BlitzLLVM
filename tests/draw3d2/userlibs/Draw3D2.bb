;Draw3D2 V.1.1
;28.09.2010
;Autor: hectic
;www.hectic.de


Const DRAWOFFSET%=0 ;UV/OFFSET<SIMPLE=1/EXPERT=0>
Const DRAWDOWNIMAGE%=0 ;DRAW/BUTTON/DOWN/IMAGE<1/0>
Const BUMPLIGHTDIRECTION%=315 ;BUMP/LIGHT/DIRECTION
Const BUMPLIGHTINTENSION%=48 ;BUMP/LIGHT/INTENSION
Const AUTOFLUSHFACE%=0 ;AUTO/FLUSHFACE3D<1/0>
Const XOVERDRIVE%=1 ;TEXT3D/BUTTON(X)OVERDRIVE
Const DRAWDISTANCE%=800 ;DRAWING/DISTANCE


;[Block] DRAW3D2/VARIABLENDEKLARATIONEN




;BENUTZERVARIABLEN
Global MouseX3D%=0
Global MouseY3D%=0
Global MouseXOld3D%=0
Global MouseYOld3D%=0
Global MouseXSpeed3D%=0
Global MouseYSpeed3D%=0
Global MouseHit3D%=0
Global MousePit3D%=0
Global MouseDown3D%=0
Global MouseOver3D%=0
Global MouseTest3D%=0
Global ProjectedX3D%=0
Global ProjectedY3D%=0
Global GetMOW3D%=0

;GLOBALVARIABLENDEKLARATIONEN
Global GDrawCamera%=0 ;Das-Kamera-Handle
Global GDrawPivot%=0 ;Das-Pivot-Handle
Global GDrawFaceBank%=0 ;Face-Bank-Handle
Global GDrawFontBank%=0 ;Font-Bank-Handle
Global GDrawFaceUsed%=0 ;Face-Bank-Dimension
Global GDrawFontUsed%=0 ;Font-Bank-Dimension
Global GDrawTFR%=255 ;Text3D-Farbe-Rot
Global GDrawTFG%=255 ;Text3D-Farbe-Grün
Global GDrawTFB%=255 ;Text3D-Farbe-Blau
Global GDrawTFA#=1 ;Text3D-Alpha-Angabe
Global GDrawGFR%=255 ;Grafik-Farbe-Rot
Global GDrawGFG%=255 ;Grafik-Farbe-Grün
Global GDrawGFB%=255 ;Grafik-Farbe-Blau
Global GDrawGFA#=1 ;Grafik-Alpha-Angabe
Global GDrawXSize%=0 ;MouseX3D-Offset-Faktor
Global GDrawYSize%=0 ;MouseY3D-Offset-Faktor
Global GDrawXScale#=1 ;Origin3D-X-Skallierungsfaktor
Global GDrawYScale#=1 ;Origin3D-Y-Skallierungsfaktor
Global GDrawMouseHit%=0 ;Für-Eigene-MouseHit3D-Berechnung
Global GDrawMousePit%=0 ;Für-Eigene-MousePit3D-Berechnung
Global GDrawMouseCode%=0 ;Für-MouseTest3D-Berechnung
Global GDrawX1#,GDrawY1# ;1.Bézier-Ecke
Global GDrawX2#,GDrawY2# ;2.Bézier-Ecke
Global GDrawX3#,GDrawY3# ;3.Bézier-Ecke
Global GDrawX4#,GDrawY4# ;4.Bézier-Ecke
Global GDrawX5#,GDrawY5# ;1.Bézier-Kurve
Global GDrawX6#,GDrawY6# ;2.Bézier-Kurve
Global GDrawX7#,GDrawY7# ;3.Bézier-Kurve
Global GDrawX8#,GDrawY8# ;4.Bézier-Kurve
Global GDrawAPPHWND%=SystemProperty("APPHWND") ;Fenster-Handle
Global GDrawMOWMain%=0 ;Bankeintrag-Für-MouseOverWindow
Global GDrawMOWRect%=0 ;Bankeintrag-Für-MouseOverWindow
Global GDrawMOWMX%=0 ;Desktop(Altenspeicher)-X-Mausposition
Global GDrawMOWMY%=0 ;Desktop(Altenspeicher)-Y-Mausposition
Global GDrawMOWX1%=0, GDrawMOWY1%=0 ;Linke/Obere-Fensterecke
Global GDrawMOWX2%=0, GDrawMOWY2%=0 ;Recht/Unter-Fensterecke

;OFFSET/KONSTANTEN
Const DRAWBANKKING=00
Const DRAWBANKMESH=04
Const DRAWBANKFACE=08
Const DRAWBANKTURE=12
Const DRAWBANKMEAS=16
Const DRAWBANKXRAN=20
Const DRAWBANKYRAN=24
Const DRAWBANKU1MP=28
Const DRAWBANKV1MP=32
Const DRAWBANKU2MP=36
Const DRAWBANKV2MP=40
Const DRAWBANKBUMP=44
Const DRAWBANKSTEP=48

;OFFSET/KONSTANTEN
Const DRAWFONTLINK=00
Const DRAWFONTFACE=04
Const DRAWFONTMEAS=08
Const DRAWFONTSVAL=12
Const DRAWFONTHVAL=16
Const DRAWFONTPVAL=20
Const DRAWFONTIVAL=24
Const DRAWFONTUSET=28
Const DRAWFONTVSET=32
Const DRAWFONTWSET=36
Const DRAWFONTHSET=40
Const DRAWFONTCHAR=44
Const DRAWFONTSTEP=300




;[End Block]
Function BumpImage3D(FDrawMain%,FDrawBump%)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawGrab%=PeekInt(GDrawFaceBank,FDrawMain+DRAWBANKKING)
	Local LDrawBump%=PeekInt(GDrawFaceBank,FDrawBump+DRAWBANKMESH)
	Local LDrawMain%=PeekInt(GDrawFaceBank,Abs(LDrawGrab)+DRAWBANKTURE)
	
	;BUMP/EIGENSCHAFTEN
	PokeInt GDrawFaceBank,FDrawMain+DRAWBANKBUMP,FDrawBump
	
	;BUMP/IMAGEZUWEISUNG
	EntityTexture LDrawBump,LDrawMain,0,2
	
	
	
	
End Function
Function IlluImage3D(FDrawMain%,FDrawIllu%)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawMesh%=PeekInt(GDrawFaceBank,FDrawMain+DRAWBANKMESH)
	Local LDrawIllu%=PeekInt(GDrawFaceBank,FDrawIllu+DRAWBANKTURE)
	
	;ILLU/IMAGEZUWEISUNG
	EntityTexture LDrawMesh,LDrawIllu,0,1
	
	
	
	
End Function
Function CameraProjectEntity3D(FDrawHandle%,FDrawAdding%=0)
	
	
	
	
	;ERWEITERUNG/DER/IDEE/VON: 'Chrise'
	CameraProject GDrawCamera,EntityX(FDrawHandle,1),EntityY(FDrawHandle,1),EntityZ(FDrawHandle,1)
	ProjectedX3D=(ProjectedX()-GDrawXSize)/GDrawXScale
	ProjectedY3D=(GDrawYSize-ProjectedY())/GDrawYScale
	
	;PRÜFUNG/AUF/SICHTBARKEIT
	If ProjectedZ()<>0 Then
		If Abs(ProjectedX3D)-FDrawAdding<GDrawXSize/GDrawXScale Then
			If Abs(ProjectedY3D)-FDrawAdding<GDrawYSize/GDrawYScale Then
				Return 1
			End If
		End If
	End If
	
	
	
	
End Function
Function CameraProjectCoords3D(FDrawXP#,FDrawYP#,FDrawZP#,FDrawAdding%=0)
	
	
	
	
	;ERWEITERUNG/DER/IDEE/VON: 'Chrise'
	CameraProject GDrawCamera,FDrawXP,FDrawYP,FDrawZP
	ProjectedX3D=(ProjectedX()-GDrawXSize)/GDrawXScale
	ProjectedY3D=(GDrawYSize-ProjectedY())/GDrawYScale
	
	;PRÜFUNG/AUF/SICHTBARKEIT
	If ProjectedZ()<>0 Then
		If Abs(ProjectedX3D)-FDrawAdding<GDrawXSize/GDrawXScale Then
			If Abs(ProjectedY3D)-FDrawAdding<GDrawYSize/GDrawYScale Then
				Return 1
			End If
		End If
	End If
	
	
	
	
End Function
Function ChangeCamera3D(FDrawCamera%)
	
	
	
	
	;ERWEITERUNG/VON: 'Silver_Knee'
	EntityParent GDrawPivot,FDrawCamera
	PositionEntity GDrawPivot,0,0,GraphicsWidth()/2.0
	
	;STANDARD/1:1/STELLUNG
	Origin3D()
	
	
	
	
End Function
Function CheckQuad3D(FDrawX1#,FDrawY1#,FDrawX2#,FDrawY2#,FDrawX3#,FDrawY3#,FDrawX4#,FDrawY4#,FDrawButton%=1,FDrawHandle%=0)
	
	
	
	
	;VARIABLEN/VORREINIGUNG
	GDrawMouseCode=GDrawMouseCode+1
	MouseOver3D=0
	MouseDown3D=0
	MouseHit3D=0
	MousePit3D=0
	
	;MOW/GÜLTIGKEIT
	If GetMOW3D=1 Then
		
		;VARIABLEN/VORBERECHNUNGEN
		Local IDrawXMouse%=MouseXOld3D*GDrawXScale
		Local IDrawYMouse%=MouseYOld3D*GDrawYScale
		
		;VARIABLENDEKLARATIONEN
		Local IDrawX1#,IDrawY1#
		Local IDrawX2#,IDrawY2#
		Local IDrawX3#,IDrawY3#
		Local IDrawX4#,IDrawY4#
		Local LDrawMesh%
		
		;QUELLANGABE/PRÜFUNG
		If FDrawHandle=0 Then
			
			;KEIN/TRANSFORM
			IDrawX1=FDrawX1
			IDrawY1=FDrawY1
			IDrawX2=FDrawX2
			IDrawY2=FDrawY2
			IDrawX3=FDrawX3
			IDrawY3=FDrawY3
			IDrawX4=FDrawX4
			IDrawY4=FDrawY4
		Else
			
			;VARIABLENDEKLARATIONEN
			LDrawMesh=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKMESH)
			
			;VEKTORTRANSFORMATION/VON: 'Xeres'
			TFormPoint(FDrawX1,FDrawY1,0,LDrawMesh,0): CameraProject(GDrawCamera,TFormedX(),TFormedY(),TFormedZ()): IDrawX1=ProjectedX()-GDrawXSize: IDrawY1=GDrawYSize-ProjectedY()
			TFormPoint(FDrawX2,FDrawY2,0,LDrawMesh,0): CameraProject(GDrawCamera,TFormedX(),TFormedY(),TFormedZ()): IDrawX2=ProjectedX()-GDrawXSize: IDrawY2=GDrawYSize-ProjectedY()
			TFormPoint(FDrawX3,FDrawY3,0,LDrawMesh,0): CameraProject(GDrawCamera,TFormedX(),TFormedY(),TFormedZ()): IDrawX3=ProjectedX()-GDrawXSize: IDrawY3=GDrawYSize-ProjectedY()
			TFormPoint(FDrawX4,FDrawY4,0,LDrawMesh,0): CameraProject(GDrawCamera,TFormedX(),TFormedY(),TFormedZ()): IDrawX4=ProjectedX()-GDrawXSize: IDrawY4=GDrawYSize-ProjectedY()
		End If
		
		;QUADKOLLISION/BERECHNEN+ANWENDEN
		If (IDrawY2-IDrawY1)*(IDrawXMouse-IDrawX2)-(IDrawX2-IDrawX1)*(IDrawYMouse-IDrawY2)=>0 Then
			If (IDrawY3-IDrawY2)*(IDrawXMouse-IDrawX3)-(IDrawX3-IDrawX2)*(IDrawYMouse-IDrawY3)>0 Then
				If (IDrawY4-IDrawY3)*(IDrawXMouse-IDrawX4)-(IDrawX4-IDrawX3)*(IDrawYMouse-IDrawY4)>0 Then
					If (IDrawY1-IDrawY4)*(IDrawXMouse-IDrawX1)-(IDrawX1-IDrawX4)*(IDrawYMouse-IDrawY1)=>0 Then
						
						;ALLGEMEINE/MAUSVARIABLEN/SETZEN
						MouseDown3D=MouseDown(1)+(MouseDown(2)*2)+(MouseDown(3)*4)
						If GDrawMousePit<>GDrawMouseCode Then MousePit3D=1
						If GDrawMouseHit=0 Then MouseHit3D=MouseDown3D
						GDrawMousePit=GDrawMouseCode
						MouseTest3D=GDrawMouseCode
						GDrawMouseHit=MouseDown3D
						MouseOver3D=1
						
						;GLOWIMAGE/ANWENDEN
						If (FDrawButton Mod DRAWBANKSTEP)=0 Then DrawQuad3D(FDrawButton,FDrawX1,FDrawY1,FDrawX2,FDrawY2,FDrawX3,FDrawY3,FDrawX4,FDrawY4,0,(MouseDown3D>0)*DRAWDOWNIMAGE)
						
						;FUNKTION/RÜCKGABEWERT
						Return True
					End If
				End If
			End If
		End If
	End If
	
	
	
	
End Function
Function Clear3D(FDrawFace%=0)
	
	
	
	
	;VARIABLENDEKLARATIONEN
	Local IDrawCount%
	
	;ALLES/LÖSCHEN/MODUS
	If FDrawFace=0
		
		;MOW/WINAPI/AUFRUFE
		Draw3D2_GCP(GDrawMOWMain)
		Draw3D2_GWR(GDrawAPPHWND,GDrawMOWRect)
		
		;MOW/API/AUFTEILUNG
		GDrawMOWMX=PeekInt(GDrawMOWMain,00)
		GDrawMOWMY=PeekInt(GDrawMOWMain,04)
		GDrawMOWX1=PeekInt(GDrawMOWRect,00)
		GDrawMOWY1=PeekInt(GDrawMOWRect,04)
		GDrawMOWX2=PeekInt(GDrawMOWRect,08)-GDrawMOWX1
		GDrawMOWY2=PeekInt(GDrawMOWRect,12)-GDrawMOWY1
		
		;MOW/RECHTECKPRÜFUNG
		GetMOW3D=RectsOverlap(GDrawMOWMX,GDrawMOWMY,1,1,GDrawMOWX1,GDrawMOWY1,GDrawMOWX2,GDrawMOWY2)
		
		;VARIABLEN/RÜCKSETZEN
		If MouseTest3D=0 Then GDrawMousePit=0
		MouseXSpeed3D=MouseX3D-MouseXOld3D
		MouseYSpeed3D=MouseY3D-MouseYOld3D
		MouseXOld3D=MouseX3D
		MouseYOld3D=MouseY3D
		MouseX3D=(MouseX()-GDrawXSize)/GDrawXScale
		MouseY3D=(GDrawYSize-MouseY())/GDrawYScale
		GDrawMouseCode=0
		MouseTest3D=0
		
		;SURFACE/GGF/LÖSCHEN
		For IDrawCount=DRAWBANKSTEP To GDrawFaceUsed-DRAWBANKSTEP Step DRAWBANKSTEP
			If PeekInt(GDrawFaceBank,IDrawCount+DRAWBANKKING)>0
				ClearSurface PeekInt(GDrawFaceBank,IDrawCount+DRAWBANKFACE)
			End If
		Next
		
	;EINZEL/LÖSCHEN/MODUS
	Else
		ClearSurface PeekInt(GDrawFaceBank,FDrawFace+DRAWBANKFACE)
	End If
	
	
	
	
End Function
Function ClearOff3D(FDrawHandle%)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawKing%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKKING)
	
	;FACEBANK(EIN)WEISUNGEN
	If LDrawKing>0 Then PokeInt(GDrawFaceBank,LDrawKing,-1)
	
	
	
	
End Function
Function ClearOn3D(FDrawHandle%)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawKing%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKKING)
	
	;FACEBANK(EIN)WEISUNGEN
	If LDrawKing=-1 Then PokeInt(GDrawFaceBank,FDrawHandle,FDrawHandle)
	
	
	
	
End Function
Function ColorG3D(FDrawFR%=255,FDrawFG%=255,FDrawFB%=255,FDrawFA#=1)
	
	
	
	
	;GLOBALENZUWEISUNGEN
	GDrawGFR=FDrawFR
	GDrawGFG=FDrawFG
	GDrawGFB=FDrawFB
	GDrawGFA=FDrawFA
	
	
	
	
End Function
Function ColorT3D(FDrawFR%=255,FDrawFG%=255,FDrawFB%=255,FDrawFA#=1)
	;GLOBALENZUWEISUNGEN
	GDrawTFR=FDrawFR
	GDrawTFG=FDrawFG
	GDrawTFB=FDrawFB
	GDrawTFA=FDrawFA
End Function
Function CopyImage3D(FDrawHandle%,FDrawMode%=1,FDrawBlend%=2,FDrawPivot%=0,FDrawOrder%=0)
	
	
	
	
	RuntimeError "DO NOT USE THIS COMMAND"
	
	
	
	
;	;SICHERHEITSPRÜFUNG
;	If FDrawMode=2 Then RuntimeError "CopyImage3D"+Chr$(10)+Chr$(10)+"Avoid mode=''2'' when copied images!"
;	
;	;VARIABLENDEKLARATIONEN
;	Local IDrawXCount%=0
;	Local IDrawYCount%=0
;	Local IDrawSquare%=0
;	Local IDrawCode%=0
;	
;	;VARIABLEN/VORBERECHNUNGEN
;	Local IDrawMeas%=ImageSize3D(FDrawHandle)
;	
;	;GRÖßENBESTIMMUNG
;	Select IDrawMeas
;		Case 2 IDrawSquare=1
;		Case 4 IDrawSquare=2
;		Case 8 IDrawSquare=3
;		Case 16 IDrawSquare=4
;		Case 32 IDrawSquare=5
;		Case 64 IDrawSquare=6
;		Case 128 IDrawSquare=7
;		Case 256 IDrawSquare=8
;		Case 512 IDrawSquare=9
;		Case 1024 IDrawSquare=10
;		Case 2048 IDrawSquare=11
;		Case 4096 IDrawSquare=12
;	End Select
;	
;	;VARIABLEN/VORBERECHNUNGEN
;	Local IDrawHandle%=CreateImage3D(IDrawSquare,FDrawMode,FDrawBlend,FDrawPivot,FDrawOrder)
;	
;	;PIXELINHALT/ÜBERTRAGEN
;	For IDrawYCount=0 To IDrawMeas-1
;		For IDrawXCount=0 To IDrawMeas-1
;			IDrawCode=GetPixel3D(FDrawHandle,IDrawXCount,IDrawYCount)
;			SetPixel3D(IDrawHandle,IDrawXCount,IDrawYCount,IDrawCode)
;		Next
;	Next
;	
;	;AUTOFLUSHED/FACE
;	If AUTOFLUSHFACE=1 Then FlushFace3D(IDrawHandle)
;	
;	;FUNKTION/RÜCKGABEWERT
;	Return IDrawHandle
	
	
	
	
End Function
Function CreateImage3D(FDrawSize%,FDrawMode%=1,FDrawBlend%=2,FDrawPivot%=0,FDrawOrder%=0)
	
	
	
	
	RuntimeError "DO NOT USE THIS COMMAND"
	
	
	
	
;	;SICHERHEITSPRÜFUNG
;	If FDrawSize>12 Then RuntimeError "CreateImage3D"+Chr$(10)+Chr$(10)+"Size 2^"+FDrawSize+" = "+Int(2^FDrawSize)+" to big!"
;	If FDrawSize<1 Then RuntimeError "CreateImage3D"+Chr$(10)+Chr$(10)+"Size values smaller than ''1'' are invalid!"
;	If FDrawMode=2 Then RuntimeError "CreateImage3D"+Chr$(10)+Chr$(10)+"Avoid mode=''2'' when creating images!"
;	
;	;VARIABLENDEKLARATIONEN
;	Local IDrawXCount%=0
;	Local IDrawYCount%=0
;	Local IDrawCount%=0
;	Local IFaceBank%=0
;	Local IDrawCode%=0
;	Local IDrawMeas%=2^FDrawSize
;	
;	;FREIEN/BANKPLATZ/SUCHEN
;	For IDrawCount=DRAWBANKSTEP To GDrawFaceUsed-DRAWBANKSTEP Step DRAWBANKSTEP
;		If PeekInt(GDrawFaceBank,IDrawCount+DRAWBANKKING)=0 Then Exit
;	Next
;	
;	;BANKPOSITION/FESTLEGEN
;	IFaceBank=IDrawCount
;	If IDrawCount=GDrawFaceUsed Then
;		GDrawFaceUsed=GDrawFaceUsed+DRAWBANKSTEP
;		ResizeBank GDrawFaceBank,GDrawFaceUsed
;		IFaceBank=GDrawFaceUsed-DRAWBANKSTEP
;	End If
;	
;	;ZIELPIVOT/HERAUSFINDEN
;	Local IDrawPivot%=GDrawPivot
;	If FDrawPivot<>0 Then IDrawPivot=FDrawPivot
;	
;	;VARIABLEN/VORBERECHNUNGEN
;	Local IDrawKing%=IFaceBank
;	Local IDrawMesh%=CreateMesh(IDrawPivot)
;	Local IDrawFace%=CreateSurface(IDrawMesh)
;	Local IDrawTure%=CreateTexture(IDrawMeas,IDrawMeas,FDrawMode)
;	Local IDrawBuffer%=TextureBuffer(IDrawTure)
;	Local IDrawXRan#=IDrawMeas/2
;	Local IDrawYRan#=IDrawMeas/2
;	Local IDrawU1MP#=DRAWOFFSET
;	Local IDrawV1MP#=DRAWOFFSET
;	Local IDrawU2MP#=IDrawMeas-DRAWOFFSET
;	Local IDrawV2MP#=IDrawMeas-DRAWOFFSET
;	
;	;GANZE/SCHNELLER/MACHEN
;	LockBuffer IDrawBuffer
;	
;	;SPEZIALITÄTEN/MAV/UMGEHEN
;	For IDrawYCount=0 To IDrawMeas-1
;		For IDrawXCount=0 To IDrawMeas-1
;			IDrawCode=ReadPixelFast(IDrawXCount,IDrawYCount,IDrawBuffer)
;			WritePixelFast IDrawXCount,IDrawYCount,IDrawCode,IDrawBuffer
;		Next
;	Next
;	
;	;GANZE/SCHNELLER/MACHEN
;	UnlockBuffer IDrawBuffer
;	
;	;FACEBANK(EIN)WEISUNGEN
;	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKKING,IDrawKing
;	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKMESH,IDrawMesh
;	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKFACE,IDrawFace
;	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKTURE,IDrawTure
;	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKMEAS,IDrawMeas
;	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKXRAN,IDrawXRan
;	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKYRAN,IDrawYRan
;	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKU1MP,IDrawU1MP
;	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKV1MP,IDrawV1MP
;	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKU2MP,IDrawU2MP
;	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKV2MP,IDrawV2MP
;	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKBUMP,0
;	
;	;EIGENSCHAFTENZUWEISUNGEN
;	ScaleTexture IDrawTure,IDrawMeas,IDrawMeas
;	EntityTexture IDrawMesh,IDrawTure
;	TextureBlend IDrawTure,FDrawBlend
;	EntityAlpha IDrawMesh,254.0/255.0
;	EntityOrder IDrawMesh,FDrawOrder
;	EntityFX IDrawMesh,1+2+8+16
;	
;	;AUTOFLUSHED/FACE
;	If AUTOFLUSHFACE=1 Then FlushFace3D(IDrawKing)
;	
;	;FUNKTION/RÜCKGABEWERT
;	Return IDrawKing
	
	
	
	
End Function
Function CreatePivot3D(FDrawParent%,FDrawXP#,FDrawYP#,FDrawZP#,FDrawXR#=0,FDrawYR#=0,FDrawZR#=0,FDrawScale#=1)
	
	
	
	
	;VARIABLENDEKLARATIONEN
	Local IDrawHandle%=CreatePivot(FDrawParent)
	
	;EIGENSCHAFTENZUWEISUNGEN
	PositionEntity IDrawHandle,FDrawXP,FDrawYP,FDrawZP
	RotateEntity IDrawHandle,FDrawXR,FDrawYR,FDrawZR
	ScaleEntity IDrawHandle,FDrawScale,FDrawScale,1
	
	;GENAUE(U/V)ÜBERLAGERUNG/ERMÖGLICHEN
	MoveEntity IDrawHandle,-0.5*FDrawScale,+0.5*FDrawScale,0
	
	;FUNKTION/RÜCKGABEWERT
	Return IDrawHandle
	
	
	
	
End Function
Function DeffBzBend3D(FDrawX5#,FDrawY5#,FDrawX6#,FDrawY6#,FDrawX7#,FDrawY7#,FDrawX8#,FDrawY8#)
	
	
	
	
	;GLOBALENZUWEISUNGEN
	GDrawX5=FDrawX5: GDrawY5=FDrawY5
	GDrawX6=FDrawX6: GDrawY6=FDrawY6
	GDrawX7=FDrawX7: GDrawY7=FDrawY7
	GDrawX8=FDrawX8: GDrawY8=FDrawY8
	
	
	
	
End Function
Function DeffBzQuad3D(FDrawX1#,FDrawY1#,FDrawX2#,FDrawY2#,FDrawX3#,FDrawY3#,FDrawX4#,FDrawY4#)
	
	
	
	
	;GLOBALENZUWEISUNGEN
	GDrawX1=FDrawX1: GDrawY1=FDrawY1
	GDrawX2=FDrawX2: GDrawY2=FDrawY2
	GDrawX3=FDrawX3: GDrawY3=FDrawY3
	GDrawX4=FDrawX4: GDrawY4=FDrawY4
	
	
	
	
End Function
Function DrawBzQuad3D(FDrawHandle%,FDrawFrame%,FDrawDepth%,FDrawColor%=$FFFFFFFF,FDrawZPos%=0)
	
	
	
	
	;PARAMETER/VORREINIGUNG
	FDrawFrame=FDrawFrame*DRAWBANKSTEP
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE+FDrawFrame)
	Local LDrawU1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU1MP+FDrawFrame)
	Local LDrawV1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV1MP+FDrawFrame)
	Local LDrawU2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU2MP+FDrawFrame)
	Local LDrawV2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV2MP+FDrawFrame)
	Local LDrawBump%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKBUMP+FDrawFrame)
	Local LBumpFace%=PeekInt(GDrawFaceBank,LDrawBump+DRAWBANKFACE+FDrawFrame)
	
	;VARIABLENDEKLARATIONEN
	Local IDrawAX1#,IDrawAY1#
	Local IDrawBX1#,IDrawBY1#
	Local IDrawCX1#,IDrawCY1#
	Local IDrawAX2#,IDrawAY2#
	Local IDrawBX2#,IDrawBY2#
	Local IDrawCX2#,IDrawCY2#
	Local IDrawXP1#,IDrawYP1#
	Local IDrawXP2#,IDrawYP2#
	Local IDrawXP3#,IDrawYP3#
	Local IDrawXP4#,IDrawYP4#
	Local IDrawFA1#,IDrawFR1#,IDrawFG1#,IDrawFB1#
	Local IDrawFA2#,IDrawFR2#,IDrawFG2#,IDrawFB2#
	Local IDrawFA3#,IDrawFR3#,IDrawFG3#,IDrawFB3#
	Local IDrawFA4#,IDrawFR4#,IDrawFG4#,IDrawFB4#
	Local IDrawSP1#,IDrawSP2#,IDrawSP3#
	Local IDrawU1MP#
	Local IDrawU2MP#
	Local IDrawUDiff#
	Local IDrawCount#
	Local IDrawV0%
	Local IDrawV1%
	Local IDrawV2%
	Local IDrawV3%
	Local IBumpV0%
	Local IBumpV1%
	Local IBumpV2%
	Local IBumpV3%
	Local IDrawAngle1#
	Local IDrawAngle2#
	Local IRColor1#
	Local IRColor2#
	Local IGColor1#
	Local IGColor2#
	
	;FARBVERLAUF/EXTRAHIEREN
	Local IDrawFA1Abs#=((FDrawColor And %11000000000000000000000000000000) Shr 30)/3.0
	Local IDrawFR1Abs#=((FDrawColor And %00110000000000000000000000000000) Shr 28)*85
	Local IDrawFG1Abs#=((FDrawColor And %00001100000000000000000000000000) Shr 26)*85
	Local IDrawFB1Abs#=((FDrawColor And %00000011000000000000000000000000) Shr 24)*85
	Local IDrawFA2Abs#=((FDrawColor And %00000000110000000000000000000000) Shr 22)/3.0
	Local IDrawFR2Abs#=((FDrawColor And %00000000001100000000000000000000) Shr 20)*85
	Local IDrawFG2Abs#=((FDrawColor And %00000000000011000000000000000000) Shr 18)*85
	Local IDrawFB2Abs#=((FDrawColor And %00000000000000110000000000000000) Shr 16)*85
	Local IDrawFA3Abs#=((FDrawColor And %00000000000000001100000000000000) Shr 14)/3.0
	Local IDrawFR3Abs#=((FDrawColor And %00000000000000000011000000000000) Shr 12)*85
	Local IDrawFG3Abs#=((FDrawColor And %00000000000000000000110000000000) Shr 10)*85
	Local IDrawFB3Abs#=((FDrawColor And %00000000000000000000001100000000) Shr 08)*85
	Local IDrawFA4Abs#=((FDrawColor And %00000000000000000000000011000000) Shr 06)/3.0
	Local IDrawFR4Abs#=((FDrawColor And %00000000000000000000000000110000) Shr 04)*85
	Local IDrawFG4Abs#=((FDrawColor And %00000000000000000000000000001100) Shr 02)*85
	Local IDrawFB4Abs#=((FDrawColor And %00000000000000000000000000000011) Shr 00)*85
	
	;BÉZIER(1)VORBEREITUNG
	IDrawCX1=3*(GDrawX5)
	IDrawCY1=3*(GDrawY5)
	IDrawBX1=3*(GDrawX6+GDrawX2-GDrawX1-GDrawX5)-IDrawCX1
	IDrawBY1=3*(GDrawY6+GDrawY2-GDrawY1-GDrawY5)-IDrawCY1
	IDrawAX1=GDrawX2-GDrawX1-IDrawCX1-IDrawBX1
	IDrawAY1=GDrawY2-GDrawY1-IDrawCY1-IDrawBY1
	
	;BÉZIER(2)VORBEREITUNG
	IDrawCX2=3*(GDrawX8)
	IDrawCY2=3*(GDrawY8)
	IDrawBX2=3*(GDrawX7+GDrawX3-GDrawX4-GDrawX8)-IDrawCX2
	IDrawBY2=3*(GDrawY7+GDrawY3-GDrawY4-GDrawY8)-IDrawCY2
	IDrawAX2=GDrawX3-GDrawX4-IDrawCX2-IDrawBX2
	IDrawAY2=GDrawY3-GDrawY4-IDrawCY2-IDrawBY2
	
	;BUMP/VERFÜGBARKEIT
	If LDrawBump<>0 Then
		
		;WELCHER/DEPTH/MODE
		If FDrawDepth>0 Then
			
			;QUADS/DURCHGEHEN
			For IDrawCount=0 To FDrawDepth
				IDrawSP1=(IDrawCount-1)/FDrawDepth
				IDrawSP2=(IDrawCount-0)/FDrawDepth
				IDrawSP3=1.0-IDrawSP2
				IDrawXP1=((IDrawAX1*IDrawSP1+IDrawBX1)*IDrawSP1+IDrawCX1)*IDrawSP1+GDrawX1
				IDrawYP1=((IDrawAY1*IDrawSP1+IDrawBY1)*IDrawSP1+IDrawCY1)*IDrawSP1+GDrawY1
				IDrawXP2=((IDrawAX1*IDrawSP2+IDrawBX1)*IDrawSP2+IDrawCX1)*IDrawSP2+GDrawX1
				IDrawYP2=((IDrawAY1*IDrawSP2+IDrawBY1)*IDrawSP2+IDrawCY1)*IDrawSP2+GDrawY1
				IDrawXP3=((IDrawAX2*IDrawSP2+IDrawBX2)*IDrawSP2+IDrawCX2)*IDrawSP2+GDrawX4
				IDrawYP3=((IDrawAY2*IDrawSP2+IDrawBY2)*IDrawSP2+IDrawCY2)*IDrawSP2+GDrawY4
				IDrawXP4=((IDrawAX2*IDrawSP1+IDrawBX2)*IDrawSP1+IDrawCX2)*IDrawSP1+GDrawX4
				IDrawYP4=((IDrawAY2*IDrawSP1+IDrawBY2)*IDrawSP1+IDrawCY2)*IDrawSP1+GDrawY4
				
				;FARBVERLAUF/BERECHNEN
				IDrawFR2=(IDrawFR1Abs*IDrawSP3)+(IDrawFR2Abs*IDrawSP2)
				IDrawFR3=(IDrawFR4Abs*IDrawSP3)+(IDrawFR3Abs*IDrawSP2)
				IDrawFG2=(IDrawFG1Abs*IDrawSP3)+(IDrawFG2Abs*IDrawSP2)
				IDrawFG3=(IDrawFG4Abs*IDrawSP3)+(IDrawFG3Abs*IDrawSP2)
				IDrawFB2=(IDrawFB1Abs*IDrawSP3)+(IDrawFB2Abs*IDrawSP2)
				IDrawFB3=(IDrawFB4Abs*IDrawSP3)+(IDrawFB3Abs*IDrawSP2)
				IDrawFA2=(IDrawFA1Abs*IDrawSP3)+(IDrawFA2Abs*IDrawSP2)
				IDrawFA3=(IDrawFA4Abs*IDrawSP3)+(IDrawFA3Abs*IDrawSP2)
				
				;ERSTEN/ÜBERLAUFEN
				If IDrawCount>0 Then
					
					;SCHRITT(1/4)BERECHNUNG
					IDrawUDiff=(LDrawU2MP-LDrawU1MP)/4.0
					IDrawU1MP=LDrawU1MP+((IDrawCount-1) Mod 4)*IDrawUDiff
					IDrawU2MP=IDrawU1MP+IDrawUDiff
					
					;BUMP/WINKEL(1)FARBBERECHNUNG
					IDrawAngle1=ATan2(IDrawYP1-IDrawYP2,IDrawXP2-IDrawXP1)
					IRColor1=127.5+Sin(IDrawAngle1-BUMPLIGHTDIRECTION)*127
					IGColor1=127.5+Cos(IDrawAngle1-BUMPLIGHTDIRECTION)*127
					
					;BUMP/WINKEL(2)FARBBERECHNUNG
					IDrawAngle2=ATan2(IDrawYP4-IDrawYP3,IDrawXP3-IDrawXP4)
					IRColor2=127.5+Sin(IDrawAngle2-BUMPLIGHTDIRECTION)*127
					IGColor2=127.5+Cos(IDrawAngle2-BUMPLIGHTDIRECTION)*127
					
					;VERTEX/POLYGON/ZUWEISUNGEN
					IDrawV0=AddVertex(LDrawFace,IDrawXP1,IDrawYP1,FDrawZPos ,IDrawU1MP,LDrawV1MP)
					IDrawV1=AddVertex(LDrawFace,IDrawXP2,IDrawYP2,FDrawZPos ,IDrawU2MP,LDrawV1MP)
					IDrawV2=AddVertex(LDrawFace,IDrawXP3,IDrawYP3,FDrawZPos ,IDrawU2MP,LDrawV2MP)
					IDrawV3=AddVertex(LDrawFace,IDrawXP4,IDrawYP4,FDrawZPos ,IDrawU1MP,LDrawV2MP)
					IBumpV0=AddVertex(LBumpFace,IDrawXP1,IDrawYP1,FDrawZPos ,IDrawU1MP,LDrawV1MP)
					IBumpV1=AddVertex(LBumpFace,IDrawXP2,IDrawYP2,FDrawZPos ,IDrawU2MP,LDrawV1MP)
					IBumpV2=AddVertex(LBumpFace,IDrawXP3,IDrawYP3,FDrawZPos ,IDrawU2MP,LDrawV2MP)
					IBumpV3=AddVertex(LBumpFace,IDrawXP4,IDrawYP4,FDrawZPos ,IDrawU1MP,LDrawV2MP)
					VertexColor LDrawFace,IDrawV0,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
					VertexColor LDrawFace,IDrawV1,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
					VertexColor LDrawFace,IDrawV2,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
					VertexColor LDrawFace,IDrawV3,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
					VertexColor LBumpFace,IBumpV0,IRColor1,IGColor1,192,1
					VertexColor LBumpFace,IBumpV1,IRColor1,IGColor1,192,1
					VertexColor LBumpFace,IBumpV2,IRColor2,IGColor2,192,1
					VertexColor LBumpFace,IBumpV3,IRColor2,IGColor2,192,1
					AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
					AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
					AddTriangle LBumpFace,IBumpV0,IBumpV1,IBumpV2
					AddTriangle LBumpFace,IBumpV2,IBumpV3,IBumpV0
				End If
				
				;FARBVERLAUF
				IDrawFR1=IDrawFR2
				IDrawFR4=IDrawFR3
				IDrawFG1=IDrawFG2
				IDrawFG4=IDrawFG3
				IDrawFB1=IDrawFB2
				IDrawFB4=IDrawFB3
				IDrawFA1=IDrawFA2
				IDrawFA4=IDrawFA3
			Next
		Else
			
			;BUMP/WINKEL(1)FARBBERECHNUNG
			IDrawAngle1=ATan2(GDrawY1-GDrawY2,GDrawX2-GDrawX1)
			IRColor1=127.5+Sin(IDrawAngle1-BUMPLIGHTDIRECTION)*127
			IGColor1=127.5+Cos(IDrawAngle1-BUMPLIGHTDIRECTION)*127
			
			;BUMP/WINKEL(2)FARBBERECHNUNG
			IDrawAngle2=ATan2(GDrawY4-GDrawY3,GDrawX3-GDrawX4)
			IRColor2=127.5+Sin(IDrawAngle2-BUMPLIGHTDIRECTION)*127
			IGColor2=127.5+Cos(IDrawAngle2-BUMPLIGHTDIRECTION)*127
			
			;VERTEX/POLYGON/ZUWEISUNGEN
			IDrawV0=AddVertex(LDrawFace,GDrawX1,GDrawY1,FDrawZPos ,LDrawU1MP,LDrawV1MP)
			IDrawV1=AddVertex(LDrawFace,GDrawX2,GDrawY2,FDrawZPos ,LDrawU2MP,LDrawV1MP)
			IDrawV2=AddVertex(LDrawFace,GDrawX3,GDrawY3,FDrawZPos ,LDrawU2MP,LDrawV2MP)
			IDrawV3=AddVertex(LDrawFace,GDrawX4,GDrawY4,FDrawZPos ,LDrawU1MP,LDrawV2MP)
			IBumpV0=AddVertex(LBumpFace,GDrawX1,GDrawY1,FDrawZPos ,LDrawU1MP,LDrawV1MP)
			IBumpV1=AddVertex(LBumpFace,GDrawX2,GDrawY2,FDrawZPos ,LDrawU2MP,LDrawV1MP)
			IBumpV2=AddVertex(LBumpFace,GDrawX3,GDrawY3,FDrawZPos ,LDrawU2MP,LDrawV2MP)
			IBumpV3=AddVertex(LBumpFace,GDrawX4,GDrawY4,FDrawZPos ,LDrawU1MP,LDrawV2MP)
			VertexColor LDrawFace,IDrawV0,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
			VertexColor LDrawFace,IDrawV1,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
			VertexColor LDrawFace,IDrawV2,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
			VertexColor LDrawFace,IDrawV3,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
			VertexColor LBumpFace,IBumpV0,IRColor1,IGColor1,192,1
			VertexColor LBumpFace,IBumpV1,IRColor1,IGColor1,192,1
			VertexColor LBumpFace,IBumpV2,IRColor2,IGColor2,192,1
			VertexColor LBumpFace,IBumpV3,IRColor2,IGColor2,192,1
			AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
			AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
			AddTriangle LBumpFace,IBumpV0,IBumpV1,IBumpV2
			AddTriangle LBumpFace,IBumpV2,IBumpV3,IBumpV0
		End If
	Else
		
		;WELCHER/DEPTH/MODE
		If FDrawDepth>0 Then
			
			;QUADS/DURCHGEHEN
			For IDrawCount=0 To FDrawDepth
				IDrawSP1=(IDrawCount-1)/FDrawDepth
				IDrawSP2=(IDrawCount-0)/FDrawDepth
				IDrawSP3=1.0-IDrawSP2
				IDrawXP1=((IDrawAX1*IDrawSP1+IDrawBX1)*IDrawSP1+IDrawCX1)*IDrawSP1+GDrawX1
				IDrawYP1=((IDrawAY1*IDrawSP1+IDrawBY1)*IDrawSP1+IDrawCY1)*IDrawSP1+GDrawY1
				IDrawXP2=((IDrawAX1*IDrawSP2+IDrawBX1)*IDrawSP2+IDrawCX1)*IDrawSP2+GDrawX1
				IDrawYP2=((IDrawAY1*IDrawSP2+IDrawBY1)*IDrawSP2+IDrawCY1)*IDrawSP2+GDrawY1
				IDrawXP3=((IDrawAX2*IDrawSP2+IDrawBX2)*IDrawSP2+IDrawCX2)*IDrawSP2+GDrawX4
				IDrawYP3=((IDrawAY2*IDrawSP2+IDrawBY2)*IDrawSP2+IDrawCY2)*IDrawSP2+GDrawY4
				IDrawXP4=((IDrawAX2*IDrawSP1+IDrawBX2)*IDrawSP1+IDrawCX2)*IDrawSP1+GDrawX4
				IDrawYP4=((IDrawAY2*IDrawSP1+IDrawBY2)*IDrawSP1+IDrawCY2)*IDrawSP1+GDrawY4
				
				;FARBVERLAUF/BERECHNEN
				IDrawFR2=(IDrawFR1Abs*IDrawSP3)+(IDrawFR2Abs*IDrawSP2)
				IDrawFR3=(IDrawFR4Abs*IDrawSP3)+(IDrawFR3Abs*IDrawSP2)
				IDrawFG2=(IDrawFG1Abs*IDrawSP3)+(IDrawFG2Abs*IDrawSP2)
				IDrawFG3=(IDrawFG4Abs*IDrawSP3)+(IDrawFG3Abs*IDrawSP2)
				IDrawFB2=(IDrawFB1Abs*IDrawSP3)+(IDrawFB2Abs*IDrawSP2)
				IDrawFB3=(IDrawFB4Abs*IDrawSP3)+(IDrawFB3Abs*IDrawSP2)
				IDrawFA2=(IDrawFA1Abs*IDrawSP3)+(IDrawFA2Abs*IDrawSP2)
				IDrawFA3=(IDrawFA4Abs*IDrawSP3)+(IDrawFA3Abs*IDrawSP2)
				
				;ERSTEN/ÜBERLAUFEN
				If IDrawCount>0 Then
					
					;SCHRITT(1/4)BERECHNUNG
					IDrawUDiff=(LDrawU2MP-LDrawU1MP)/4.0
					IDrawU1MP=LDrawU1MP+((IDrawCount-1) Mod 4)*IDrawUDiff
					IDrawU2MP=IDrawU1MP+IDrawUDiff
					
					;VERTEX/POLYGON/ZUWEISUNGEN
					IDrawV0=AddVertex(LDrawFace,IDrawXP1,IDrawYP1,FDrawZPos ,IDrawU1MP,LDrawV1MP)
					IDrawV1=AddVertex(LDrawFace,IDrawXP2,IDrawYP2,FDrawZPos ,IDrawU2MP,LDrawV1MP)
					IDrawV2=AddVertex(LDrawFace,IDrawXP3,IDrawYP3,FDrawZPos ,IDrawU2MP,LDrawV2MP)
					IDrawV3=AddVertex(LDrawFace,IDrawXP4,IDrawYP4,FDrawZPos ,IDrawU1MP,LDrawV2MP)
					VertexColor LDrawFace,IDrawV0,IDrawFR1,IDrawFG1,IDrawFB1,IDrawFA1
					VertexColor LDrawFace,IDrawV1,IDrawFR2,IDrawFG2,IDrawFB2,IDrawFA2
					VertexColor LDrawFace,IDrawV2,IDrawFR3,IDrawFG3,IDrawFB3,IDrawFA3
					VertexColor LDrawFace,IDrawV3,IDrawFR4,IDrawFG4,IDrawFB4,IDrawFA4
					AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
					AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
				End If
				
				;FARBVERLAUF
				IDrawFR1=IDrawFR2
				IDrawFR4=IDrawFR3
				IDrawFG1=IDrawFG2
				IDrawFG4=IDrawFG3
				IDrawFB1=IDrawFB2
				IDrawFB4=IDrawFB3
				IDrawFA1=IDrawFA2
				IDrawFA4=IDrawFA3
			Next
		Else
			
			;VERTEX/POLYGON/ZUWEISUNGEN
			IDrawV0=AddVertex(LDrawFace,GDrawX1,GDrawY1,FDrawZPos ,LDrawU1MP,LDrawV1MP)
			IDrawV1=AddVertex(LDrawFace,GDrawX2,GDrawY2,FDrawZPos ,LDrawU2MP,LDrawV1MP)
			IDrawV2=AddVertex(LDrawFace,GDrawX3,GDrawY3,FDrawZPos ,LDrawU2MP,LDrawV2MP)
			IDrawV3=AddVertex(LDrawFace,GDrawX4,GDrawY4,FDrawZPos ,LDrawU1MP,LDrawV2MP)
			VertexColor LDrawFace,IDrawV0,IDrawFR1Abs,IDrawFG1Abs,IDrawFB1Abs,IDrawFA1Abs
			VertexColor LDrawFace,IDrawV1,IDrawFR2Abs,IDrawFG2Abs,IDrawFB2Abs,IDrawFA2Abs
			VertexColor LDrawFace,IDrawV2,IDrawFR3Abs,IDrawFG3Abs,IDrawFB3Abs,IDrawFA3Abs
			VertexColor LDrawFace,IDrawV3,IDrawFR4Abs,IDrawFG4Abs,IDrawFB4Abs,IDrawFA4Abs
			AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
			AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
		End If
	End If
	
	
	
	
End Function
Function DrawFree3D()
	
	
	
	
	;VARIABLENDEKLARATIONEN
	Local IDrawCount%
	
	;ALLES/WAS/GEHT/LÖSCHEN
	For IDrawCount=DRAWBANKSTEP To GDrawFaceUsed-DRAWBANKSTEP Step DRAWBANKSTEP
		
		;FACEBANK(AUS)WEISUNGEN
		If PeekInt(GDrawFaceBank,IDrawCount+DRAWBANKKING)>0 Then
			FreeTexture PeekInt(GDrawFaceBank,IDrawCount+DRAWBANKTURE)
			ClearSurface PeekInt(GDrawFaceBank,IDrawCount+DRAWBANKFACE)
			FreeEntity PeekInt(GDrawFaceBank,IDrawCount+DRAWBANKMESH)
		End If
	Next
	
	;BANKEN/FREIGEBEN
	FreeBank GDrawMOWRect
	FreeBank GDrawMOWMain
	FreeBank GDrawFontBank
	FreeBank GDrawFaceBank
	
	;GLOBALEN/STANDARDWERTE
	GDrawNFR=255:GDrawNFG=255:GDrawNFB=255:GDrawNFA=1
	GDrawTFR=255:GDrawTFG=255:GDrawTFB=255:GDrawTFA=1
	GDrawGFR=255:GDrawGFG=255:GDrawGFB=255:GDrawGFA=1
	
	;NULLSTELLUNG/SETZEN
	GDrawFaceUsed=0
	GDrawFontUsed=0
	GDrawXSize=0
	GDrawYSize=0
	
	
	
	
End Function
Function DrawImage3D(FDrawHandle%,FDrawX#,FDrawY#,FDrawButton%=0,FDrawAngle#=0,FDrawScale#=1,FDrawFrame%=0)
	
	
	
	
	;PARAMETER/VORREINIGUNG
	FDrawFrame=FDrawFrame*DRAWBANKSTEP
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE+FDrawFrame)
	Local LDrawXRan#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKXRAN+FDrawFrame)*FDrawScale
	Local LDrawYRan#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKYRAN+FDrawFrame)*FDrawScale
	Local LDrawU1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU1MP+FDrawFrame)
	Local LDrawV1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV1MP+FDrawFrame)
	Local LDrawU2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU2MP+FDrawFrame)
	Local LDrawV2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV2MP+FDrawFrame)
	Local LDrawBump%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKBUMP+FDrawFrame)
	
	;EXTRA/WINKELBERECHNUNG
	If FDrawAngle<>0 Then
		
		;SCHNELLE/UMRECHNUNG/VON: 'aMul'
		Local IDrawTCos#=Cos(FDrawAngle)
		Local IDrawTSin#=Sin(FDrawAngle)
		Local IDrawXPos1#=LDrawXRan*IDrawTCos-LDrawYRan*IDrawTSin
		Local IDrawYPos1#=LDrawYRan*IDrawTCos+LDrawXRan*IDrawTSin
		Local IDrawXPos2#=LDrawXRan*IDrawTCos+LDrawYRan*IDrawTSin
		Local IDrawYPos2#=LDrawYRan*IDrawTCos-LDrawXRan*IDrawTSin
	Else
		
		;DIREKTE/DARSTELLUNG
		IDrawXPos1=LDrawXRan
		IDrawYPos1=LDrawYRan
		IDrawXPos2=LDrawXRan
		IDrawYPos2=LDrawYRan
	End If
	
	;VERTEX/POLYGON/ZUWEISUNGEN
	Local IDrawV0%=AddVertex(LDrawFace,FDrawX-IDrawXPos1,FDrawY+IDrawYPos1,0 ,LDrawU1MP,LDrawV1MP)
	Local IDrawV1%=AddVertex(LDrawFace,FDrawX+IDrawXPos2,FDrawY+IDrawYPos2,0 ,LDrawU2MP,LDrawV1MP)
	Local IDrawV2%=AddVertex(LDrawFace,FDrawX+IDrawXPos1,FDrawY-IDrawYPos1,0 ,LDrawU2MP,LDrawV2MP)
	Local IDrawV3%=AddVertex(LDrawFace,FDrawX-IDrawXPos2,FDrawY-IDrawYPos2,0 ,LDrawU1MP,LDrawV2MP)
	
;	X=1: Y=4 ;ILLUIMAGE3D
;	VertexNormal LDrawFace,IDrawV0,-((LDrawXRan*X)*IDrawTCos-(LDrawYRan*Y)*IDrawTSin),+((LDrawYRan*Y)*IDrawTCos+(LDrawXRan*X)*IDrawTSin),-1
;	VertexNormal LDrawFace,IDrawV1,+((LDrawXRan*X)*IDrawTCos+(LDrawYRan*Y)*IDrawTSin),+((LDrawYRan*Y)*IDrawTCos-(LDrawXRan*X)*IDrawTSin),-1
;	VertexNormal LDrawFace,IDrawV2,+((LDrawXRan*X)*IDrawTCos-(LDrawYRan*Y)*IDrawTSin),-((LDrawYRan*Y)*IDrawTCos+(LDrawXRan*X)*IDrawTSin),-1
;	VertexNormal LDrawFace,IDrawV3,-((LDrawXRan*X)*IDrawTCos+(LDrawYRan*Y)*IDrawTSin),-((LDrawYRan*Y)*IDrawTCos-(LDrawXRan*X)*IDrawTSin),-1
	
	;BUMP/VERFÜGBARKEIT
	If LDrawBump<>0 Then
		
		;FACEBANK(AUS)WEISUNGEN
		Local LBumpFace%=PeekInt(GDrawFaceBank,LDrawBump+DRAWBANKFACE)
		
		;BUMP/WINKEL/FARBBERECHNUNG
		Local IRColor#=127.5+Sin(FDrawAngle-BUMPLIGHTDIRECTION)*127
		Local IGColor#=127.5+Cos(FDrawAngle-BUMPLIGHTDIRECTION)*127
		
		;VERTEX/POLYGON/ZUWEISUNGEN
		Local IBumpV0%=AddVertex(LBumpFace,FDrawX-IDrawXPos1,FDrawY+IDrawYPos1,0 ,LDrawU1MP,LDrawV1MP)
		Local IBumpV1%=AddVertex(LBumpFace,FDrawX+IDrawXPos2,FDrawY+IDrawYPos2,0 ,LDrawU2MP,LDrawV1MP)
		Local IBumpV2%=AddVertex(LBumpFace,FDrawX+IDrawXPos1,FDrawY-IDrawYPos1,0 ,LDrawU2MP,LDrawV2MP)
		Local IBumpV3%=AddVertex(LBumpFace,FDrawX-IDrawXPos2,FDrawY-IDrawYPos2,0 ,LDrawU1MP,LDrawV2MP)
		VertexColor LDrawFace,IDrawV0,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LDrawFace,IDrawV1,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LDrawFace,IDrawV2,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LDrawFace,IDrawV3,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LBumpFace,IBumpV0,IRColor,IGColor,192,1
		VertexColor LBumpFace,IBumpV1,IRColor,IGColor,192,1
		VertexColor LBumpFace,IBumpV2,IRColor,IGColor,192,1
		VertexColor LBumpFace,IBumpV3,IRColor,IGColor,192,1
		AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
		AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
		AddTriangle LBumpFace,IBumpV0,IBumpV1,IBumpV2
		AddTriangle LBumpFace,IBumpV2,IBumpV3,IBumpV0
	Else
		
		;VERTEX/POLYGON/ZUWEISUNGEN
		If GDrawGFR<>255 Or GDrawGFG<>255 Or GDrawGFB<>255 Or GDrawGFA<>1 Then
		VertexColor LDrawFace,IDrawV0,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV1,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV2,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV3,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		End If
		AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
		AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
	End If
	
	;SCHALTFLÄCHE/PRÜFUNG
	If FDrawButton<>0 Then CheckQuad3D(FDrawX-IDrawXPos1,FDrawY+IDrawYPos1,FDrawX+IDrawXPos2,FDrawY+IDrawYPos2,FDrawX+IDrawXPos1,FDrawY-IDrawYPos1,FDrawX-IDrawXPos2,FDrawY-IDrawYPos2,FDrawButton,FDrawHandle)
	
	
	
	
End Function
Function DrawImage4D(FDrawHandle%,FDrawX#,FDrawY#,FDrawZ#,FDrawButton%=0,FDrawAngle#=0,FDrawScale#=1,FDrawFrame%=0)
	
	
	
	
	;PARAMETER/VORREINIGUNG
	FDrawFrame=FDrawFrame*DRAWBANKSTEP
	
	;RAUMPROJEKTION/VON: 'aMul'
	TFormPoint(FDrawX,FDrawY,FDrawZ,0,GDrawCamera)
	
	;KAMERA/Z-POSITION
	FDrawZ=TFormedZ()
	
	;SICHTBARKEIT/PRÜFEN
	If FDrawZ>0 Then
		
		;TRANSFORMATION
		FDrawX=TFormedX()
		FDrawY=TFormedY()
		
		;FACEBANK(AUS)WEISUNGEN
		Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE+FDrawFrame)
		Local LDrawXRan#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKXRAN+FDrawFrame)*FDrawScale
		Local LDrawYRan#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKYRAN+FDrawFrame)*FDrawScale
		Local LDrawU1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU1MP+FDrawFrame)
		Local LDrawV1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV1MP+FDrawFrame)
		Local LDrawU2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU2MP+FDrawFrame)
		Local LDrawV2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV2MP+FDrawFrame)
		
		;EXTRA/WINKELBERECHNUNG
		If FDrawAngle<>0 Then
			
			;SCHNELLE/UMRECHNUNG/VON: 'aMul'
			Local IDrawTCos#=Cos(FDrawAngle)
			Local IDrawTSin#=Sin(FDrawAngle)
			Local IDrawXPos1#=LDrawXRan*IDrawTCos-LDrawYRan*IDrawTSin
			Local IDrawYPos1#=LDrawYRan*IDrawTCos+LDrawXRan*IDrawTSin
			Local IDrawXPos2#=LDrawXRan*IDrawTCos+LDrawYRan*IDrawTSin
			Local IDrawYPos2#=LDrawYRan*IDrawTCos-LDrawXRan*IDrawTSin
		Else
			
			;DIREKTE/DARSTELLUNG
			IDrawXPos1=LDrawXRan
			IDrawYPos1=LDrawYRan
			IDrawXPos2=LDrawXRan
			IDrawYPos2=LDrawYRan
		End If
		
		;VERTEX/POLYGON/ZUWEISUNGEN
		Local IDrawV0%=AddVertex(LDrawFace,FDrawX-IDrawXPos1,FDrawY+IDrawYPos1,FDrawZ ,LDrawU1MP,LDrawV1MP)
		Local IDrawV1%=AddVertex(LDrawFace,FDrawX+IDrawXPos2,FDrawY+IDrawYPos2,FDrawZ ,LDrawU2MP,LDrawV1MP)
		Local IDrawV2%=AddVertex(LDrawFace,FDrawX+IDrawXPos1,FDrawY-IDrawYPos1,FDrawZ ,LDrawU2MP,LDrawV2MP)
		Local IDrawV3%=AddVertex(LDrawFace,FDrawX-IDrawXPos2,FDrawY-IDrawYPos2,FDrawZ ,LDrawU1MP,LDrawV2MP)
		VertexColor LDrawFace,IDrawV0,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV1,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV2,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV3,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
		AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
	EndIf
	
	;SCHALTFLÄCHE/PRÜFUNG
	If FDrawButton<>0 Then
		
		;VARIABLENDEKLARATIONEN
		Local IDrawX1#,IDrawY1#
		Local IDrawX2#,IDrawY2#
		Local IDrawX3#,IDrawY3#
		Local IDrawX4#,IDrawY4#
		Local LDrawMesh%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKMESH)
		
		;VEKTORTRANSFORMATION/VON: 'Xeres'
		TFormPoint(FDrawX-IDrawXPos1,FDrawY+IDrawYPos1,FDrawZ,LDrawMesh,0): CameraProject(GDrawCamera,TFormedX(),TFormedY(),TFormedZ()): IDrawX1=ProjectedX()-GDrawXSize: IDrawY1=GDrawYSize-ProjectedY()
		TFormPoint(FDrawX+IDrawXPos2,FDrawY+IDrawYPos2,FDrawZ,LDrawMesh,0): CameraProject(GDrawCamera,TFormedX(),TFormedY(),TFormedZ()): IDrawX2=ProjectedX()-GDrawXSize: IDrawY2=GDrawYSize-ProjectedY()
		TFormPoint(FDrawX+IDrawXPos1,FDrawY-IDrawYPos1,FDrawZ,LDrawMesh,0): CameraProject(GDrawCamera,TFormedX(),TFormedY(),TFormedZ()): IDrawX3=ProjectedX()-GDrawXSize: IDrawY3=GDrawYSize-ProjectedY()
		TFormPoint(FDrawX-IDrawXPos2,FDrawY-IDrawYPos2,FDrawZ,LDrawMesh,0): CameraProject(GDrawCamera,TFormedX(),TFormedY(),TFormedZ()): IDrawX4=ProjectedX()-GDrawXSize: IDrawY4=GDrawYSize-ProjectedY()
		
		;GLOWIMAGE/ANWENDEN
		CheckQuad3D(IDrawX1,IDrawY1,IDrawX2,IDrawY2,IDrawX3,IDrawY3,IDrawX4,IDrawY4,FDrawButton,0)
	End If
	
	
	
	
End Function
Function DrawInit3D(FDrawCamera%)
	
	;SICHERHEITSPRÜFUNG
	If GDrawFaceUsed<>0 Then RuntimeError "DrawInit3D"+Chr$(10)+Chr$(10)+"Draw3D is already initialized!"
	If FDrawCamera=0 Then RuntimeError "DrawInit3D"+Chr$(10)+Chr$(10)+"Parameter ''FDrawCamera'' not legal!"
	
	;FÜR/SICHERHEITSPRÜFUNG
	GDrawFaceUsed=DRAWBANKSTEP
	GDrawFontUsed=DRAWFONTSTEP
	
	;KAMERAHANDLE/ZUWEISUNG
	GDrawCamera=FDrawCamera
	
	;PIVOTHANDLE/ZUWEISUNG
	GDrawPivot=CreatePivot(FDrawCamera)
	
	;DRAWBANK/NEUERSTELLUNG
	GDrawFaceBank=CreateBank()
	GDrawFontBank=CreateBank()
	
	;MOW-BANK/NEUERSTELLUNG
	GDrawMOWMain=CreateBank(08)
	GDrawMOWRect=CreateBank(16)
	
	;SONSTIGE/WERTEZUWEISUNGEN
	GDrawXSize=GraphicsWidth()/2
	GDrawYSize=GraphicsHeight()/2
	
	;STANDARD/1:1/STELLUNG
	Origin3D()
	
	
End Function
Function DrawLine3D(FDrawHandle%,FDrawX1#,FDrawY1#,FDrawX2#,FDrawY2#,FDrawSize#,FDrawMode%=0,FDrawFrame%=0)
	
	
	
	
	;SICHERHEITSPRÜFUNG
	If FDrawX1<>FDrawX2 Or FDrawY1<>FDrawY2 Then
		
		;PARAMETER/VORREINIGUNG
		FDrawFrame=FDrawFrame*DRAWBANKSTEP
		
		;FACEBANK(AUS)WEISUNGEN
		Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE+FDrawFrame)
		Local LDrawXRan#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKXRAN+FDrawFrame)
		Local LDrawU1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU1MP+FDrawFrame)
		Local LDrawV1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV1MP+FDrawFrame)
		Local LDrawU2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU2MP+FDrawFrame)
		Local LDrawV2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV2MP+FDrawFrame)
		Local LDrawBump%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKBUMP+FDrawFrame)
		
		;VARIABLEN/VORBERECHNUNGEN
		TFormNormal FDrawX2-FDrawX1,FDrawY2-FDrawY1,0,0,0
		Local IDrawXTForm#=TFormedX()*FDrawSize
		Local IDrawYTForm#=TFormedY()*FDrawSize
		
		;MODUS/ROLLEN
		If FDrawMode=1 Then LDrawU2MP=LDrawU1MP+Sqr((FDrawX1-FDrawX2)*(FDrawX1-FDrawX2)+(FDrawY1-FDrawY2)*(FDrawY1-FDrawY2))
		
		;MODUS/ABSOLUT
		If FDrawMode=2 Then FDrawX2=FDrawX1+TFormedX()*LDrawXRan*2: FDrawY2=FDrawY1+TFormedY()*LDrawXRan*2
		
		;VERTEX/POLYGON/ZUWEISUNGEN
		Local IDrawV0%=AddVertex(LDrawFace,FDrawX1-IDrawYTForm,FDrawY1+IDrawXTForm,0 ,LDrawU1MP,LDrawV1MP)
		Local IDrawV1%=AddVertex(LDrawFace,FDrawX2-IDrawYTForm,FDrawY2+IDrawXTForm,0 ,LDrawU2MP,LDrawV1MP)
		Local IDrawV2%=AddVertex(LDrawFace,FDrawX2+IDrawYTForm,FDrawY2-IDrawXTForm,0 ,LDrawU2MP,LDrawV2MP)
		Local IDrawV3%=AddVertex(LDrawFace,FDrawX1+IDrawYTForm,FDrawY1-IDrawXTForm,0 ,LDrawU1MP,LDrawV2MP)
		
		;BUMP/VERFÜGBARKEIT
		If LDrawBump<>0 Then
			
			;FACEBANK(AUS)WEISUNGEN
			Local LBumpFace%=PeekInt(GDrawFaceBank,LDrawBump+DRAWBANKFACE)
			
			;BUMP/WINKEL/FARBBERECHNUNG
			Local IDrawAngle#=ATan2(FDrawY1-FDrawY2,FDrawX2-FDrawX1)
			Local IRColor#=127.5+Sin(IDrawAngle-BUMPLIGHTDIRECTION)*127
			Local IGColor#=127.5+Cos(IDrawAngle-BUMPLIGHTDIRECTION)*127
			
			;VERTEX/POLYGON/ZUWEISUNGEN
			Local IBumpV0%=AddVertex(LBumpFace,FDrawX1-IDrawYTForm,FDrawY1+IDrawXTForm,0 ,LDrawU1MP,LDrawV1MP)
			Local IBumpV1%=AddVertex(LBumpFace,FDrawX2-IDrawYTForm,FDrawY2+IDrawXTForm,0 ,LDrawU2MP,LDrawV1MP)
			Local IBumpV2%=AddVertex(LBumpFace,FDrawX2+IDrawYTForm,FDrawY2-IDrawXTForm,0 ,LDrawU2MP,LDrawV2MP)
			Local IBumpV3%=AddVertex(LBumpFace,FDrawX1+IDrawYTForm,FDrawY1-IDrawXTForm,0 ,LDrawU1MP,LDrawV2MP)
			VertexColor LDrawFace,IDrawV0,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
			VertexColor LDrawFace,IDrawV1,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
			VertexColor LDrawFace,IDrawV2,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
			VertexColor LDrawFace,IDrawV3,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
			VertexColor LBumpFace,IBumpV0,IRColor,IGColor,192,1
			VertexColor LBumpFace,IBumpV1,IRColor,IGColor,192,1
			VertexColor LBumpFace,IBumpV2,IRColor,IGColor,192,1
			VertexColor LBumpFace,IBumpV3,IRColor,IGColor,192,1
			AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
			AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
			AddTriangle LBumpFace,IBumpV0,IBumpV1,IBumpV2
			AddTriangle LBumpFace,IBumpV2,IBumpV3,IBumpV0
		Else
			
			;VERTEX/POLYGON/ZUWEISUNGEN
			VertexColor LDrawFace,IDrawV0,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
			VertexColor LDrawFace,IDrawV1,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
			VertexColor LDrawFace,IDrawV2,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
			VertexColor LDrawFace,IDrawV3,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
			AddTriangle(LDrawFace,IDrawV0,IDrawV1,IDrawV2)
			AddTriangle(LDrawFace,IDrawV2,IDrawV3,IDrawV0)
		End If
	End If
	
	
	
	
End Function
Function DrawLine4D(FDrawHandle%,FDrawX1#,FDrawY1#,FDrawZ1#,FDrawX2#,FDrawY2#,FDrawZ2#,FDrawSize#=1,FDrawFrame%=0)
	
	
	
	
	;SICHERHEITSPRÜFUNG
	If FDrawX1<>FDrawX2 Or FDrawY1<>FDrawY2 Or FDrawZ1<>FDrawZ2 Then
		
		;PARAMETER/VORREINIGUNG
		FDrawFrame=FDrawFrame*DRAWBANKSTEP
		
		;FACEBANK(AUS)WEISUNGEN
		Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE+FDrawFrame)
		Local LDrawXRan#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKXRAN+FDrawFrame)*FDrawSize
		Local LDrawU1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU1MP+FDrawFrame)
		Local LDrawV1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV1MP+FDrawFrame)
		Local LDrawU2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU2MP+FDrawFrame)
		Local LDrawV2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV2MP+FDrawFrame)
		
		;RAUM/KAMERA/TRANSFORMATION
		TFormPoint(FDrawX1,FDrawY1,FDrawZ1,0,GDrawCamera)
		FDrawX1=TFormedX()
		FDrawY1=TFormedY()
		FDrawZ1=TFormedZ()
		
		;RAUM/KAMERA/TRANSFORMATION
		TFormPoint(FDrawX2,FDrawY2,FDrawZ2,0,GDrawCamera)
		FDrawX2=TFormedX()
		FDrawY2=TFormedY()
		FDrawZ2=TFormedZ()
		
		;KREUZPRODUKT/BERECHNUNGEN
		Local IDrawLX#=FDrawX1-FDrawX2
		Local IDrawLY#=FDrawY1-FDrawY2
		Local IDrawLZ#=FDrawZ1-FDrawZ2
		
		;KREUZPRODUKT/BERECHNUNGEN
		Local IDrawNX#=(IDrawLY*FDrawZ2)-(IDrawLZ*FDrawY2)
		Local IDrawNY#=(IDrawLZ*FDrawX2)-(IDrawLX*FDrawZ2)
		Local IDrawNZ#=(IDrawLX*FDrawY2)-(IDrawLY*FDrawX2)
		
		;KREUZPRODUKT/BERECHNUNGEN
		Local IDrawLN#=Sqr(IDrawNX*IDrawNX+IDrawNY*IDrawNY+IDrawNZ*IDrawNZ)
		IDrawNX=IDrawNX/IDrawLN*LDrawXRan
		IDrawNY=IDrawNY/IDrawLN*LDrawXRan
		IDrawNZ=IDrawNZ/IDrawLN*LDrawXRan
		
		;VERTEX/POLYGON/ZUWEISUNGEN
		Local IDrawV0%=AddVertex(LDrawFace,FDrawX1+IDrawNX,FDrawY1+IDrawNY,FDrawZ1+IDrawNZ ,LDrawU1MP,LDrawV1MP)
		Local IDrawV1%=AddVertex(LDrawFace,FDrawX2+IDrawNX,FDrawY2+IDrawNY,FDrawZ2+IDrawNZ ,LDrawU2MP,LDrawV1MP)
		Local IDrawV2%=AddVertex(LDrawFace,FDrawX2-IDrawNX,FDrawY2-IDrawNY,FDrawZ2-IDrawNZ ,LDrawU2MP,LDrawV2MP)
		Local IDrawV3%=AddVertex(LDrawFace,FDrawX1-IDrawNX,FDrawY1-IDrawNY,FDrawZ1-IDrawNZ ,LDrawU1MP,LDrawV2MP)
		
		;VERTEX/POLYGON/ZUWEISUNGEN
		VertexColor LDrawFace,IDrawV0,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV1,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV2,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV3,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		AddTriangle(LDrawFace,IDrawV0,IDrawV1,IDrawV2)
		AddTriangle(LDrawFace,IDrawV2,IDrawV3,IDrawV0)
	End If
	
	
	
	
End Function
Function DrawNerd3D(FDrawHandle%,FDrawX1#,FDrawY1#,FDrawX2#,FDrawY2#,FDrawX3#,FDrawY3#,FDrawX4#,FDrawY4#,FDrawUSet#,FDrawVSet#,FDrawWSet#,FDrawHSet#,FDrawButton%=0)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE)
	Local LDrawBump%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKBUMP)
	
	;VERTEX/POLYGON/ZUWEISUNGEN
	Local IDrawV0%=AddVertex(LDrawFace,FDrawX1,FDrawY1,0 ,FDrawUSet,FDrawVSet)
	Local IDrawV1%=AddVertex(LDrawFace,FDrawX2,FDrawY2,0 ,FDrawUSet+FDrawWSet,FDrawVSet)
	Local IDrawV2%=AddVertex(LDrawFace,FDrawX3,FDrawY3,0 ,FDrawUSet+FDrawWSet,FDrawVSet+FDrawHSet)
	Local IDrawV3%=AddVertex(LDrawFace,FDrawX4,FDrawY4,0 ,FDrawUSet,FDrawVSet+FDrawHSet)
	
	;BUMP/VERFÜGBARKEIT
	If LDrawBump<>0 Then
		
		;FACEBANK(AUS)WEISUNGEN
		Local LBumpFace%=PeekInt(GDrawFaceBank,LDrawBump+DRAWBANKFACE)
		
		;BUMP/WINKEL(1)FARBBERECHNUNG
		Local IDrawAngle1#=ATan2(FDrawY1-FDrawY2,FDrawX2-FDrawX1)
		Local IRColor1#=127.5+Sin(IDrawAngle1-BUMPLIGHTDIRECTION)*127
		Local IGColor1#=127.5+Cos(IDrawAngle1-BUMPLIGHTDIRECTION)*127
		
		;BUMP/WINKEL(2)FARBBERECHNUNG
		Local IDrawAngle2#=ATan2(FDrawY4-FDrawY3,FDrawX3-FDrawX4)
		Local IRColor2#=127.5+Sin(IDrawAngle2-BUMPLIGHTDIRECTION)*127
		Local IGColor2#=127.5+Cos(IDrawAngle2-BUMPLIGHTDIRECTION)*127
		
		;VERTEX/POLYGON/ZUWEISUNGEN
		Local IBumpV0%=AddVertex(LBumpFace,FDrawX1,FDrawY1,0 ,FDrawUSet,FDrawVSet)
		Local IBumpV1%=AddVertex(LBumpFace,FDrawX2,FDrawY2,0 ,FDrawUSet+FDrawWSet,FDrawVSet)
		Local IBumpV2%=AddVertex(LBumpFace,FDrawX3,FDrawY3,0 ,FDrawUSet+FDrawWSet,FDrawVSet+FDrawHSet)
		Local IBumpV3%=AddVertex(LBumpFace,FDrawX4,FDrawY4,0 ,FDrawUSet,FDrawVSet+FDrawHSet)
		VertexColor LDrawFace,IDrawV0,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LDrawFace,IDrawV1,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LDrawFace,IDrawV2,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LDrawFace,IDrawV3,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LBumpFace,IBumpV0,IRColor1,IGColor1,192,1
		VertexColor LBumpFace,IBumpV1,IRColor1,IGColor1,192,1
		VertexColor LBumpFace,IBumpV2,IRColor2,IGColor2,192,1
		VertexColor LBumpFace,IBumpV3,IRColor2,IGColor2,192,1
		AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
		AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
		AddTriangle LBumpFace,IBumpV0,IBumpV1,IBumpV2
		AddTriangle LBumpFace,IBumpV2,IBumpV3,IBumpV0
	Else
		
		;VERTEX/POLYGON/ZUWEISUNGEN
		If GDrawGFR<>255 Or GDrawGFG<>255 Or GDrawGFB<>255 Or GDrawGFA<>1 Then
		VertexColor LDrawFace,IDrawV0,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV1,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV2,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV3,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		End If
		AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
		AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
	End If
	
	;SCHALTFLÄCHE/PRÜFUNG
	If FDrawButton<>0 Then CheckQuad3D(FDrawX1,FDrawY1,FDrawX2,FDrawY2,FDrawX3,FDrawY3,FDrawX4,FDrawY4,FDrawButton,FDrawHandle)
	
	
	
	
End Function
Function DrawOrder3D(FDrawHandle%,FDrawOrder%=0)
	
	
	
	
	;SICHERHEITSPRÜFUNG
	If PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKKING)<0 Then RuntimeError "DrawOrder3D"+Chr$(10)+Chr$(10)+"Order only ''PullImage3D'' handles!"
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawMesh%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKMESH)
	
	;EIGENSCHAFTENZUWEISUNGEN
	EntityOrder LDrawMesh,FDrawOrder
	
	
	
	
End Function
Function DrawQuad3D(FDrawHandle%,FDrawX1#,FDrawY1#,FDrawX2#,FDrawY2#,FDrawX3#,FDrawY3#,FDrawX4#,FDrawY4#,FDrawButton%=0,FDrawFrame%=0)
	
	
	
	
	;PARAMETER/VORREINIGUNG
	FDrawFrame=FDrawFrame*DRAWBANKSTEP
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE+FDrawFrame)
	Local LDrawU1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU1MP+FDrawFrame)
	Local LDrawV1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV1MP+FDrawFrame)
	Local LDrawU2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU2MP+FDrawFrame)
	Local LDrawV2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV2MP+FDrawFrame)
	Local LDrawBump%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKBUMP+FDrawFrame)
	
	;VERTEX/POLYGON/ZUWEISUNGEN
	Local IDrawV0%=AddVertex(LDrawFace,FDrawX1,FDrawY1,0 ,LDrawU1MP,LDrawV1MP)
	Local IDrawV1%=AddVertex(LDrawFace,FDrawX2,FDrawY2,0 ,LDrawU2MP,LDrawV1MP)
	Local IDrawV2%=AddVertex(LDrawFace,FDrawX3,FDrawY3,0 ,LDrawU2MP,LDrawV2MP)
	Local IDrawV3%=AddVertex(LDrawFace,FDrawX4,FDrawY4,0 ,LDrawU1MP,LDrawV2MP)
	
	;BUMP/VERFÜGBARKEIT
	If LDrawBump<>0 Then
		
		;FACEBANK(AUS)WEISUNGEN
		Local LBumpFace%=PeekInt(GDrawFaceBank,LDrawBump+DRAWBANKFACE)
		
		;BUMP/WINKEL(1)FARBBERECHNUNG
		Local IDrawAngle1#=ATan2(FDrawY1-FDrawY2,FDrawX2-FDrawX1)
		Local IRColor1#=127.5+Sin(IDrawAngle1-BUMPLIGHTDIRECTION)*127
		Local IGColor1#=127.5+Cos(IDrawAngle1-BUMPLIGHTDIRECTION)*127
		
		;BUMP/WINKEL(2)FARBBERECHNUNG
		Local IDrawAngle2#=ATan2(FDrawY4-FDrawY3,FDrawX3-FDrawX4)
		Local IRColor2#=127.5+Sin(IDrawAngle2-BUMPLIGHTDIRECTION)*127
		Local IGColor2#=127.5+Cos(IDrawAngle2-BUMPLIGHTDIRECTION)*127
		
		;VERTEX/POLYGON/ZUWEISUNGEN
		Local IBumpV0%=AddVertex(LBumpFace,FDrawX1,FDrawY1,0 ,LDrawU1MP,LDrawV1MP)
		Local IBumpV1%=AddVertex(LBumpFace,FDrawX2,FDrawY2,0 ,LDrawU2MP,LDrawV1MP)
		Local IBumpV2%=AddVertex(LBumpFace,FDrawX3,FDrawY3,0 ,LDrawU2MP,LDrawV2MP)
		Local IBumpV3%=AddVertex(LBumpFace,FDrawX4,FDrawY4,0 ,LDrawU1MP,LDrawV2MP)
		VertexColor LDrawFace,IDrawV0,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LDrawFace,IDrawV1,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LDrawFace,IDrawV2,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LDrawFace,IDrawV3,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LBumpFace,IBumpV0,IRColor1,IGColor1,192,1
		VertexColor LBumpFace,IBumpV1,IRColor1,IGColor1,192,1
		VertexColor LBumpFace,IBumpV2,IRColor2,IGColor2,192,1
		VertexColor LBumpFace,IBumpV3,IRColor2,IGColor2,192,1
		AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
		AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
		AddTriangle LBumpFace,IBumpV0,IBumpV1,IBumpV2
		AddTriangle LBumpFace,IBumpV2,IBumpV3,IBumpV0
	Else
		
		;VERTEX/POLYGON/ZUWEISUNGEN
		If GDrawGFR<>255 Or GDrawGFG<>255 Or GDrawGFB<>255 Or GDrawGFA<>1 Then
		VertexColor LDrawFace,IDrawV0,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV1,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV2,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV3,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		End If
		AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
		AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
	End If
	
	;SCHALTFLÄCHE/PRÜFUNG
	If FDrawButton<>0 Then CheckQuad3D(FDrawX1,FDrawY1,FDrawX2,FDrawY2,FDrawX3,FDrawY3,FDrawX4,FDrawY4,FDrawButton,FDrawHandle)
	
	
	
	
End Function
Function DrawRect3D(FDrawHandle%,FDrawX#,FDrawY#,FDrawUSet#,FDrawVSet#,FDrawWSet#,FDrawHSet#,FDrawButton%=0,FDrawAngle#=0,FDrawScale#=1)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE)
	Local LDrawBump%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKBUMP)
	
	;EXTRA/WINKELBERECHNUNG
	If FDrawAngle<>0 Then
		
		;SCHNELLE/UMRECHNUNG/VON: 'aMul'
		Local IDrawTCos#=Cos(FDrawAngle)*FDrawScale*0.5
		Local IDrawTSin#=Sin(FDrawAngle)*FDrawScale*0.5
		Local IDrawXPos1#=FDrawWSet*IDrawTCos-FDrawHSet*IDrawTSin
		Local IDrawYPos1#=FDrawHSet*IDrawTCos+FDrawWSet*IDrawTSin
		Local IDrawXPos2#=FDrawWSet*IDrawTCos+FDrawHSet*IDrawTSin
		Local IDrawYPos2#=FDrawHSet*IDrawTCos-FDrawWSet*IDrawTSin
	Else
		
		;DIREKTE/DARSTELLUNG
		IDrawXPos1=FDrawWSet*FDrawScale*0.5
		IDrawYPos1=FDrawHSet*FDrawScale*0.5
		IDrawXPos2=FDrawWSet*FDrawScale*0.5
		IDrawYPos2=FDrawHSet*FDrawScale*0.5
	End If
	
	;VERTEX/POLYGON/ZUWEISUNGEN
	Local IDrawV0%=AddVertex(LDrawFace,FDrawX-IDrawXPos1,FDrawY+IDrawYPos1,0 ,FDrawUSet,FDrawVSet)
	Local IDrawV1%=AddVertex(LDrawFace,FDrawX+IDrawXPos2,FDrawY+IDrawYPos2,0 ,FDrawUSet+FDrawWSet,FDrawVSet)
	Local IDrawV2%=AddVertex(LDrawFace,FDrawX+IDrawXPos1,FDrawY-IDrawYPos1,0 ,FDrawUSet+FDrawWSet,FDrawVSet+FDrawHSet)
	Local IDrawV3%=AddVertex(LDrawFace,FDrawX-IDrawXPos2,FDrawY-IDrawYPos2,0 ,FDrawUSet,FDrawVSet+FDrawHSet)
	
	;BUMP/VERFÜGBARKEIT
	If LDrawBump<>0 Then
		
		;FACEBANK(AUS)WEISUNGEN
		Local LBumpFace%=PeekInt(GDrawFaceBank,LDrawBump+DRAWBANKFACE)
		
		;BUMP/WINKEL/FARBBERECHNUNG
		Local IRColor#=127.5+Sin(FDrawAngle-BUMPLIGHTDIRECTION)*127
		Local IGColor#=127.5+Cos(FDrawAngle-BUMPLIGHTDIRECTION)*127
		
		;VERTEX/POLYGON/ZUWEISUNGEN
		Local IBumpV0%=AddVertex(LBumpFace,FDrawX-IDrawXPos1,FDrawY+IDrawYPos1,0 ,FDrawUSet,FDrawVSet)
		Local IBumpV1%=AddVertex(LBumpFace,FDrawX+IDrawXPos2,FDrawY+IDrawYPos2,0 ,FDrawUSet+FDrawWSet,FDrawVSet)
		Local IBumpV2%=AddVertex(LBumpFace,FDrawX+IDrawXPos1,FDrawY-IDrawYPos1,0 ,FDrawUSet+FDrawWSet,FDrawVSet+FDrawHSet)
		Local IBumpV3%=AddVertex(LBumpFace,FDrawX-IDrawXPos2,FDrawY-IDrawYPos2,0 ,FDrawUSet,FDrawVSet+FDrawHSet)
		VertexColor LDrawFace,IDrawV0,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LDrawFace,IDrawV1,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LDrawFace,IDrawV2,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LDrawFace,IDrawV3,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,BUMPLIGHTINTENSION,1
		VertexColor LBumpFace,IBumpV0,IRColor,IGColor,192,1
		VertexColor LBumpFace,IBumpV1,IRColor,IGColor,192,1
		VertexColor LBumpFace,IBumpV2,IRColor,IGColor,192,1
		VertexColor LBumpFace,IBumpV3,IRColor,IGColor,192,1
		AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
		AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
		AddTriangle LBumpFace,IBumpV0,IBumpV1,IBumpV2
		AddTriangle LBumpFace,IBumpV2,IBumpV3,IBumpV0
	Else
		
		;VERTEX/POLYGON/ZUWEISUNGEN
		If GDrawGFR<>255 Or GDrawGFG<>255 Or GDrawGFB<>255 Or GDrawGFA<>1 Then
		VertexColor LDrawFace,IDrawV0,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV1,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV2,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		VertexColor LDrawFace,IDrawV3,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
		End If
		AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
		AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
	End If
	
	;SCHALTFLÄCHE/PRÜFUNG
	If FDrawButton<>0 Then CheckQuad3D(FDrawX-IDrawXPos1,FDrawY+IDrawYPos1,FDrawX+IDrawXPos2,FDrawY+IDrawYPos2,FDrawX+IDrawXPos1,FDrawY-IDrawYPos1,FDrawX-IDrawXPos2,FDrawY-IDrawYPos2,FDrawButton,FDrawHandle)
	
	
	
	
End Function
Function DrawTile3D(FDrawHandle%,FDrawX1#,FDrawY1#,FDrawX2#,FDrawY2#,FDrawX3#,FDrawY3#,FDrawX4#,FDrawY4#,FDrawScale#=1,FDrawButton%=0)
	
	
	
	
	;PARAMETER/VORREINIGUNG
	FDrawScale=1.0/FDrawScale
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE)
	
	;VERTEX/POLYGON/ZUWEISUNGEN
	Local IDrawV0%=AddVertex(LDrawFace,FDrawX1,FDrawY1,0 ,FDrawX1*FDrawScale,-FDrawY1*FDrawScale)
	Local IDrawV1%=AddVertex(LDrawFace,FDrawX2,FDrawY2,0 ,FDrawX2*FDrawScale,-FDrawY2*FDrawScale)
	Local IDrawV2%=AddVertex(LDrawFace,FDrawX3,FDrawY3,0 ,FDrawX3*FDrawScale,-FDrawY3*FDrawScale)
	Local IDrawV3%=AddVertex(LDrawFace,FDrawX4,FDrawY4,0 ,FDrawX4*FDrawScale,-FDrawY4*FDrawScale)
	
	;VERTEX/POLYGON/ZUWEISUNGEN
	VertexColor LDrawFace,IDrawV0,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
	VertexColor LDrawFace,IDrawV1,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
	VertexColor LDrawFace,IDrawV2,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
	VertexColor LDrawFace,IDrawV3,GDrawGFR,GDrawGFG,GDrawGFB,GDrawGFA
	AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
	AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
	
	;SCHALTFLÄCHE/PRÜFUNG
	If FDrawButton<>0 Then CheckQuad3D(FDrawX1,FDrawY1,FDrawX2,FDrawY2,FDrawX3,FDrawY3,FDrawX4,FDrawY4,FDrawButton,FDrawHandle)
	
	
	
	
End Function
Function FlushFace3D(FDrawHandle%)
	
	
	
	
	;VARIABLENDEKLARATIONEN
	Local IDrawCount%=0
	Local IDrawV0%=0
	Local IDrawV1%=0
	Local IDrawV2%=0
	Local IDrawV3%=0
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE)
	
	;VORREINIGUNG
	RenderWorld: ClearSurface LDrawFace
	
	;REINIGUNG/DURCHFÜHREN
	For IDrawCount=1 To 16383
		
		;VERTEX/POLYGON/ZUWEISUNGEN
		IDrawV0=AddVertex(LDrawFace,-1,+1,100)
		IDrawV1=AddVertex(LDrawFace,+1,+1,100)
		IDrawV2=AddVertex(LDrawFace,+1,-1,100)
		IDrawV3=AddVertex(LDrawFace,-1,-1,100)
		AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
		AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
	Next
	
	;NACHREINIGUNG
	RenderWorld: ClearSurface LDrawFace
	
	
	
	
End Function
Function FontRange3D(FDrawLink%,FDrawUSet%=0,FDrawVSet%=0,FDrawWSet%=0,FDrawHSet%=0,FDrawRows%=16)
	
	
	
	
	;PARAMETER/VORREINIGUNG
	If FDrawRows>16 Then FDrawRows=16
	
	;VARIABLENDEKLARATIONEN
	Local IDrawXCount%=0
	Local IDrawYCount%=0
	Local IDrawUCount%=0
	Local IDrawVCount%=0
	Local IDrawCount%=0
	Local IDrawValue%=0
	Local IDrawXTile%=0
	Local IDrawYTile%=0
	Local IDrawLSet%=0
	Local IDrawRSet%=0
	Local IFontBank%=0
	
	;FREIEN/BANKPLATZ/SUCHEN
	For IDrawCount=DRAWFONTSTEP To GDrawFontUsed-DRAWFONTSTEP Step DRAWFONTSTEP
		If PeekInt(GDrawFontBank,IDrawCount+DRAWFONTLINK)=0 Then Exit
	Next
	
	;BANKPOSITION/FESTLEGEN
	IFontBank=IDrawCount
	If IDrawCount=GDrawFontUsed Then
		GDrawFontUsed=GDrawFontUsed+DRAWFONTSTEP
		ResizeBank GDrawFontBank,GDrawFontUsed
		IFontBank=GDrawFontUsed-DRAWFONTSTEP
	End If
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawLink+DRAWBANKFACE)
	Local LDrawTure%=PeekInt(GDrawFaceBank,FDrawLink+DRAWBANKTURE)
	Local LDrawMeas%=PeekInt(GDrawFaceBank,FDrawLink+DRAWBANKMEAS)
	
	;VARIABLEN/VORBERECHNUNGEN
	Local IDrawBuffer%=TextureBuffer(LDrawTure)
	
	;SICHERHEITSPRÜFUNG
	If FDrawWSet=0 Then FDrawWSet=LDrawMeas/16
	If FDrawHSet=0 Then FDrawHSet=LDrawMeas/16
	
	;FONTBANK(EIN)WEISUNGEN
	PokeInt GDrawFontBank,IFontBank+DRAWFONTLINK,FDrawLink
	PokeInt GDrawFontBank,IFontBank+DRAWFONTFACE,LDrawFace
	PokeInt GDrawFontBank,IFontBank+DRAWFONTMEAS,LDrawMeas
	PokeFloat GDrawFontBank,IFontBank+DRAWFONTSVAL,1
	PokeFloat GDrawFontBank,IFontBank+DRAWFONTHVAL,1
	PokeFloat GDrawFontBank,IFontBank+DRAWFONTPVAL,0
	PokeFloat GDrawFontBank,IFontBank+DRAWFONTIVAL,0
	PokeInt GDrawFontBank,IFontBank+DRAWFONTUSET,FDrawUSet
	PokeInt GDrawFontBank,IFontBank+DRAWFONTVSET,FDrawVSet
	PokeInt GDrawFontBank,IFontBank+DRAWFONTWSET,FDrawWSet
	PokeInt GDrawFontBank,IFontBank+DRAWFONTHSET,FDrawHSet
	
	;GANZE/SCHNELLER/MACHEN
	LockBuffer IDrawBuffer
	
	;ZEICHENSPEZIFISCHE/FESTLEGUNG
	For IDrawYCount=0 To FDrawRows-1
		For IDrawXCount=0 To 15
			
			;VARIABLEN/VORBERECHNUNGEN
			IDrawXTile=FDrawUSet+IDrawXCount*FDrawWSet
			IDrawYTile=FDrawVSet+IDrawYCount*FDrawHSet
			IDrawLSet=0
			IDrawRSet=0
			
			;LINKE/SYMBOLGRENZE/SUCHEN
			For IDrawUCount=FDrawWSet-1 To 0 Step-1
				For IDrawVCount=0 To FDrawHSet-1 Step+1
					IDrawValue=ReadPixelFast(IDrawXTile+IDrawUCount,IDrawYTile+IDrawVCount,IDrawBuffer)
					If (IDrawValue And $FF000000)<>0 Then IDrawLSet=IDrawUCount
				Next
			Next
			
			;RECHTE/SYMBOLGRENZE/SUCHEN
			For IDrawUCount=0 To FDrawWSet-1 Step+1
				For IDrawVCount=0 To FDrawHSet-1 Step+1
					IDrawValue=ReadPixelFast(IDrawXTile+IDrawUCount,IDrawYTile+IDrawVCount,IDrawBuffer)
					If (IDrawValue And $FF000000)<>0 Then IDrawRSet=IDrawUCount
				Next
			Next
			
			;SYMBOL/LINKSVERSCHIEBUNG
			If IDrawYCount>1 And IDrawLSet>0 Then
				For IDrawUCount=0 To FDrawWSet-1-IDrawLSet Step+1
					For IDrawVCount=0 To FDrawHSet-1 Step+1
						IDrawValue=ReadPixelFast(IDrawXTile+IDrawUCount+IDrawLSet,IDrawYTile+IDrawVCount,IDrawBuffer)
						WritePixelFast IDrawXTile+IDrawUCount+IDrawLSet,IDrawYTile+IDrawVCount,$00000000,IDrawBuffer
						WritePixelFast IDrawXTile+IDrawUCount,IDrawYTile+IDrawVCount,IDrawValue,IDrawBuffer
					Next
				Next
			End If
			
			;ZEICHENBREITE/SICHERN
			If IDrawYCount=0 Or IDrawYCount=1 Then IDrawLSet=0
			
			IDrawValue=IFontBank+DRAWFONTCHAR+IDrawXCount+IDrawYCount*16
			PokeByte GDrawFontBank,IDrawValue,IDrawRSet-IDrawLSet+1
		Next
	Next
	
	;GANZE/SCHNELLER/MACHEN
	UnlockBuffer IDrawBuffer
	
	;LEERZEICHEN/SONDERBEHANDLUNG
	Local IDrawLeer=PeekByte(GDrawFontBank,IFontBank+DRAWFONTCHAR+32)
	Local IDrawRufe=PeekByte(GDrawFontBank,IFontBank+DRAWFONTCHAR+33)
	If IDrawLeer=1 Then PokeByte GDrawFontBank,IFontBank+DRAWFONTCHAR+32,IDrawRufe
	
	;FUNKTION/RÜCKGABEWERT
	Return IFontBank
	
	
	
	
End Function
Function FreeImage3D(FDrawHandle%)
	
	
	
	
	;VARIABLENDEKLARATIONEN
	Local IDrawCount%=0
	Local IDrawPoint%=0
	
	;HANDLE/GÜLTIGKEITSPRÜFUNG
	If FDrawHandle<>0 And (FDrawHandle Mod DRAWBANKSTEP)=0 Then
		
		;(LOAD/GRAB)IMAGE/SELEKTIEREN
		If PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKKING)>0 Then
			
			;ANGEGEBENE/ENTITY/FREIGEBEN
			FreeTexture PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKTURE)
			ClearSurface PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE)
			FreeEntity PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKMESH)
			
			;ALLE/FACE/BANKPOS/DURCHGEHEN
			For IDrawCount=DRAWBANKSTEP To GDrawFaceUsed-DRAWBANKSTEP Step DRAWBANKSTEP
				
				;ALLE/FACE/DEPENDENCIES/FREIGEBEN
				If Abs(PeekInt(GDrawFaceBank,IDrawCount+DRAWBANKKING))=FDrawHandle Then
					
					;ANGEGEBENE/FACE/BANKPOS/FREIGEBEN
					PokeInt GDrawFaceBank,IDrawCount+DRAWBANKKING,0
					PokeInt GDrawFaceBank,IDrawCount+DRAWBANKMESH,0
					PokeInt GDrawFaceBank,IDrawCount+DRAWBANKFACE,0
					PokeInt GDrawFaceBank,IDrawCount+DRAWBANKTURE,0
					PokeInt GDrawFaceBank,IDrawCount+DRAWBANKMEAS,0
					PokeFloat GDrawFaceBank,IDrawCount+DRAWBANKXRAN,0
					PokeFloat GDrawFaceBank,IDrawCount+DRAWBANKYRAN,0
					PokeFloat GDrawFaceBank,IDrawCount+DRAWBANKU1MP,0
					PokeFloat GDrawFaceBank,IDrawCount+DRAWBANKV1MP,0
					PokeFloat GDrawFaceBank,IDrawCount+DRAWBANKU2MP,0
					PokeFloat GDrawFaceBank,IDrawCount+DRAWBANKV2MP,0
					PokeInt GDrawFaceBank,IDrawCount+DRAWBANKBUMP,0
				End If
			Next
			
			;ALLE/FONT/BANKPOS/DURCHGEHEN
			For IDrawCount=DRAWFONTSTEP To GDrawFontUsed-DRAWFONTSTEP Step DRAWFONTSTEP
				
				;ALLE/FONT/DEPENDENCIES/FREIGEBEN
				If Abs(PeekInt(GDrawFontBank,IDrawCount+DRAWFONTLINK))=FDrawHandle Then
					
					;ANGEGEBENE/FONT/BANKPOS/FREIGEBEN
					PokeInt GDrawFontBank,IDrawCount+DRAWFONTLINK,0
					PokeInt GDrawFontBank,IDrawCount+DRAWFONTFACE,0
					PokeInt GDrawFontBank,IDrawCount+DRAWFONTMEAS,0
					PokeInt GDrawFontBank,IDrawCount+DRAWFONTSVAL,0
					PokeInt GDrawFontBank,IDrawCount+DRAWFONTHVAL,0
					PokeInt GDrawFontBank,IDrawCount+DRAWFONTPVAL,0
					PokeInt GDrawFontBank,IDrawCount+DRAWFONTIVAL,0
					PokeInt GDrawFontBank,IDrawCount+DRAWFONTUSET,0
					PokeInt GDrawFontBank,IDrawCount+DRAWFONTVSET,0
					PokeInt GDrawFontBank,IDrawCount+DRAWFONTWSET,0
					PokeInt GDrawFontBank,IDrawCount+DRAWFONTHSET,0
					PokeInt GDrawFontBank,IDrawCount+DRAWFONTCHAR,0
				End If
			Next
		Else
			
			;ANGEGEBENE/FACE/BANKPOS/FREIGEBEN
			PokeInt GDrawFaceBank,FDrawHandle+DRAWBANKKING,0
			PokeInt GDrawFaceBank,FDrawHandle+DRAWBANKMESH,0
			PokeInt GDrawFaceBank,FDrawHandle+DRAWBANKFACE,0
			PokeInt GDrawFaceBank,FDrawHandle+DRAWBANKTURE,0
			PokeInt GDrawFaceBank,FDrawHandle+DRAWBANKMEAS,0
			PokeFloat GDrawFaceBank,FDrawHandle+DRAWBANKXRAN,0
			PokeFloat GDrawFaceBank,FDrawHandle+DRAWBANKYRAN,0
			PokeFloat GDrawFaceBank,FDrawHandle+DRAWBANKU1MP,0
			PokeFloat GDrawFaceBank,FDrawHandle+DRAWBANKV1MP,0
			PokeFloat GDrawFaceBank,FDrawHandle+DRAWBANKU2MP,0
			PokeFloat GDrawFaceBank,FDrawHandle+DRAWBANKV2MP,0
			PokeInt GDrawFaceBank,FDrawHandle+DRAWBANKBUMP,0
		End If
		
		;ALLE/FACE/BANKPOS/DURCHGEHEN
		For IDrawCount=DRAWBANKSTEP To GDrawFaceUsed-DRAWBANKSTEP Step DRAWBANKSTEP
			
			;LETZTES/FACE/HANDLE/SUCHEN
			If PeekInt(GDrawFaceBank,IDrawCount+DRAWBANKKING)<>0 Then IDrawPoint=IDrawCount
		Next
		
		;FACE/DRAWBANK/GRÖßENZUWEISUNG
		GDrawFaceUsed=IDrawPoint+DRAWBANKSTEP
		ResizeBank GDrawFaceBank,GDrawFaceUsed
		
		;ALLE/FONT/BANKPOS/DURCHGEHEN
		For IDrawCount=DRAWFONTSTEP To GDrawFontUsed-DRAWFONTSTEP Step DRAWFONTSTEP
			
			;LETZTES/FONT/HANDLE/SUCHEN
			If PeekInt(GDrawFontBank,IDrawCount+DRAWFONTLINK)<>0 Then IDrawPoint=IDrawCount
		Next
		
		;FONT/DRAWBANK/GRÖßENZUWEISUNG
		GDrawFontUsed=IDrawPoint+DRAWFONTSTEP
		ResizeBank GDrawFontBank,GDrawFontUsed
	End If
	
	
	
	
End Function
Function GetPixel3D(FDrawHandle%,FDrawX%,FDrawY%,FDrawMask%=$FFFFFFFF)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawTure%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKTURE)
	Local IDrawARGB%=ReadPixelFast(FDrawX,FDrawY,TextureBuffer(LDrawTure))
	
	;MASKENFILTER/PRÜFEN
	If FDrawMask<>$FFFFFFFF Then
		
		;VARIABLENDEKLARATIONEN
		Local IDrawRPMXPos%=0
		Local IDrawRPMWert%=0
		Local IDrawRPMPlus%=1
		
		;MASKE/ZUSAMMENFASSEN
		For IDrawRPMXPos=0 To 31
			If FDrawMask And 2^IDrawRPMXPos Then
				If IDrawARGB And 2^IDrawRPMXPos Then
					IDrawRPMWert=IDrawRPMWert+IDrawRPMPlus
				End If
				IDrawRPMPlus=IDrawRPMPlus*2
			End If
		Next
		
		;MASKEN/AUSGABE
		Return IDrawRPMWert
	Else
		
		;REINE/AUSGABE
		Return IDrawARGB
	End If
	
	
	
	
End Function
Function GetTexel3D(FDrawHandle%,FDrawX1#,FDrawY1#,FDrawX2#,FDrawY2#,FDrawAngle#=0,FDrawScale#=1,FDrawMask%=$FFFFFFFF)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawTure%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKTURE)
	Local LDrawXRan#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKXRAN)
	Local LDrawYRan#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKYRAN)
	Local LDrawU1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU1MP)
	Local LDrawV1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV1MP)
	
	;VARIABLEN/VORBERECHNUNGEN
	Local IDrawXRelative%=(FDrawX1-FDrawX2)/FDrawScale
	Local IDrawYRelative%=(FDrawY1-FDrawY2)/FDrawScale
	Local IDrawXRan#=LDrawXRan
	Local IDrawYRan#=LDrawYRan
	LDrawXRan=LDrawXRan*FDrawScale
	LDrawYRan=LDrawYRan*FDrawScale
	Local IDrawARGB%=0
	
	;WINKEL/HINZURECHNEN
	If FDrawAngle<>0 Then
		
		;SCHNELLE/UMRECHNUNG/VON: 'aMul'
		Local IDrawTCos#=Cos(FDrawAngle)
		Local IDrawTSin#=Sin(FDrawAngle)
		Local IDrawTempValue#=IDrawXRelative
		IDrawXRelative=IDrawXRelative*IDrawTCos-IDrawYRelative*IDrawTSin
		IDrawYRelative=IDrawYRelative*IDrawTCos+IDrawTempValue*IDrawTSin
	End If
	
	;TEXTUR/TEXEL/SETZEN
	If IDrawXRelative=>-IDrawXRan Then
		If IDrawXRelative<+IDrawXRan Then
			If IDrawYRelative>-IDrawYRan Then
				If IDrawYRelative<=+IDrawYRan Then
					IDrawARGB=ReadPixelFast(LDrawU1MP+IDrawXRan+IDrawXRelative,LDrawV1MP+IDrawYRan-IDrawYRelative,TextureBuffer(LDrawTure))
				End If
			End If
		End If
	End If
	
	;MASKENFILTER/PRÜFEN
	If FDrawMask<>$FFFFFFFF Then
		
		;VARIABLENDEKLARATIONEN
		Local IDrawRPMXPos%=0
		Local IDrawRPMWert%=0
		Local IDrawRPMPlus%=1
		
		;MASKE/ZUSAMMENFASSEN
		For IDrawRPMXPos=0 To 31
			If FDrawMask And 2^IDrawRPMXPos Then
				If IDrawARGB And 2^IDrawRPMXPos Then
					IDrawRPMWert=IDrawRPMWert+IDrawRPMPlus
				End If
				IDrawRPMPlus=IDrawRPMPlus*2
			End If
		Next
		
		;MASKEN/AUSGABE
		Return IDrawRPMWert
	Else
		
		;REINE/AUSGABE
		Return IDrawARGB
	End If
	
	
	
	
End Function
Function GrabAnimImage3D(FDrawHandle%,FDrawWSet%,FDrawHSet%,FDrawStart%,FDrawFrames%,FDrawXScale#=1,FDrawYScale#=1)
	
	
	
	
	;SICHERHEITSPRÜFUNG
	If FDrawHandle<0 Then RuntimeError "GrabAnimImage3D"+Chr$(10)+Chr$(10)+"Grabb only main images!"
	
	;VARIABLENDEKLARATIONEN
	Local IDrawHandle%
	Local IDrawFrames%
	Local IDrawXCount%
	Local IDrawYCount%
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawMeas%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKMEAS)
	
	;ALLE/TEILBILDER/DURCHGEHEN
	For IDrawFrames=0 To FDrawStart+FDrawFrames-1
		
		;EINZELNES/TEILBILD/AUSSCHNEIDEN
		If IDrawFrames=>FDrawStart Then IDrawHandle=GrabImage3D(FDrawHandle,IDrawXCount,IDrawYCount,FDrawWSet,FDrawHSet,FDrawXScale,FDrawYScale)
		
		;NÄCHSTE/UV-KOORDINATEN/SETZEN
		IDrawXCount=IDrawXCount+FDrawWSet
		If IDrawXCount+FDrawWSet>LDrawMeas Then
			IDrawYCount=IDrawYCount+FDrawHSet
			IDrawXCount=0
		End If
	Next
	
	;FUNKTION/RÜCKGABEWERT
	Return IDrawHandle-FDrawFrames*DRAWBANKSTEP+DRAWBANKSTEP
	
	
	
	
End Function
Function GrabImage3D(FDrawHandle%,FDrawUSet%,FDrawVSet%,FDrawWSet%,FDrawHSet%,FDrawXScale#=1,FDrawYScale#=1)
	
	
	
	
	;SICHERHEITSPRÜFUNG
	If FDrawHandle<0 Then RuntimeError "GrabImage3D"+Chr$(10)+Chr$(10)+"Grabb only main images!"
	
	;VARIABLENDEKLARATIONEN
	Local IFaceBank%=GDrawFaceUsed
	
	;DRAWBANK/GRÖßENZUWEISUNG
	GDrawFaceUsed=GDrawFaceUsed+DRAWBANKSTEP
	ResizeBank GDrawFaceBank,GDrawFaceUsed+DRAWBANKSTEP
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawMesh%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKMESH)
	Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE)
	Local LDrawTure%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKTURE)
	Local LDrawMeas%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKMEAS)
	
	;FACEBANK(EIN)WEISUNGEN
	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKKING,-FDrawHandle
	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKMESH,LDrawMesh
	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKFACE,LDrawFace
	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKTURE,LDrawTure
	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKMEAS,LDrawMeas
	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKXRAN,Abs(FDrawWSet)*FDrawXScale/2.0
	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKYRAN,Abs(FDrawHSet)*FDrawYScale/2.0
	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKU1MP,FDrawUSet+DRAWOFFSET*Sgn(FDrawWSet)
	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKV1MP,FDrawVSet+DRAWOFFSET*Sgn(FDrawHSet)
	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKU2MP,FDrawUSet+FDrawWSet-DRAWOFFSET*Sgn(FDrawWSet)
	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKV2MP,FDrawVSet+FDrawHSet-DRAWOFFSET*Sgn(FDrawHSet)
	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKBUMP,0
	
	;FUNKTION/RÜCKGABEWERT
	Return IFaceBank
	
	
	
	
End Function
Function ImageSize3D(FDrawHandle%,FDrawSource%=0)
	
	
	
	
	;FUNKTION/RÜCKGABEWERT
	If FDrawSource=0 Then Return PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKMEAS)
	
	;FUNKTION/RÜCKGABEWERT
	If FDrawSource=1 Then Return Abs(PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU1MP)-PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU2MP))
	
	;FUNKTION/RÜCKGABEWERT
	If FDrawSource=2 Then Return Abs(PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV1MP)-PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV2MP))
	
	
	
	
End Function
Function ImagesOverlap3D(FDrawHandleA%,FDrawXA#,FDrawYA#,FDrawAngleA#,FDrawScaleA#,FDrawHandleB%,FDrawXB#,FDrawYB#,FDrawAngleB#,FDrawScaleB#)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawXRanA#=PeekFloat(GDrawFaceBank,FDrawHandleA+DRAWBANKXRAN)*FDrawScaleA
	Local LDrawYRanA#=PeekFloat(GDrawFaceBank,FDrawHandleA+DRAWBANKYRAN)*FDrawScaleA
	Local LDrawXRanB#=PeekFloat(GDrawFaceBank,FDrawHandleB+DRAWBANKXRAN)*FDrawScaleB
	Local LDrawYRanB#=PeekFloat(GDrawFaceBank,FDrawHandleB+DRAWBANKYRAN)*FDrawScaleB
	
	;SCHNELLE/VORABPRÜFUNG
	If Abs(FDrawXA-FDrawXB)+Abs(FDrawYA-FDrawYB)>(LDrawXRanA+LDrawYRanA+LDrawXRanB+LDrawYRanB)*1.41421 Then Return False
	
	;VARIABLENDEKLARATIONEN
	Local IDrawXA#[3]
	Local IDrawYA#[3]
	
	;EXTRA/WINKELBERECHNUNG
	If FDrawAngleA<>0 Then
		
		;SCHNELLE/UMRECHNUNG/VON: 'aMul'
		Local IDrawTCosA#=Cos(FDrawAngleA)
		Local IDrawTSinA#=Sin(FDrawAngleA)
		Local IDrawXPos1A#=LDrawXRanA*IDrawTCosA-LDrawYRanA*IDrawTSinA
		Local IDrawYPos1A#=LDrawYRanA*IDrawTCosA+LDrawXRanA*IDrawTSinA
		Local IDrawXPos2A#=LDrawXRanA*IDrawTCosA+LDrawYRanA*IDrawTSinA
		Local IDrawYPos2A#=LDrawYRanA*IDrawTCosA-LDrawXRanA*IDrawTSinA
	Else
		
		;DIREKTE/DARSTELLUNG
		IDrawXPos1A=LDrawXRanA
		IDrawYPos1A=LDrawYRanA
		IDrawXPos2A=LDrawXRanA
		IDrawYPos2A=LDrawYRanA
	End If
	
	;ECKENPOS/ZWISCHENSPEICHER
	IDrawXA[0]=FDrawXA-IDrawXPos1A
	IDrawYA[0]=FDrawYA+IDrawYPos1A
	IDrawXA[1]=FDrawXA+IDrawXPos2A
	IDrawYA[1]=FDrawYA+IDrawYPos2A
	IDrawXA[2]=FDrawXA+IDrawXPos1A
	IDrawYA[2]=FDrawYA-IDrawYPos1A
	IDrawXA[3]=FDrawXA-IDrawXPos2A
	IDrawYA[3]=FDrawYA-IDrawYPos2A
	
	;VARIABLENDEKLARATIONEN
	Local IDrawXB#[3]
	Local IDrawYB#[3]
	
	;EXTRA/WINKELBERECHNUNG
	If FDrawAngleB<>0 Then
		
		;SCHNELLE/UMRECHNUNG/VON: 'aMul'
		Local IDrawTCosB#=Cos(FDrawAngleB)
		Local IDrawTSinB#=Sin(FDrawAngleB)
		Local IDrawXPos1B#=LDrawXRanB*IDrawTCosB-LDrawYRanB*IDrawTSinB
		Local IDrawYPos1B#=LDrawYRanB*IDrawTCosB+LDrawXRanB*IDrawTSinB
		Local IDrawXPos2B#=LDrawXRanB*IDrawTCosB+LDrawYRanB*IDrawTSinB
		Local IDrawYPos2B#=LDrawYRanB*IDrawTCosB-LDrawXRanB*IDrawTSinB
	Else
		
		;DIREKTE/DARSTELLUNG
		IDrawXPos1B=LDrawXRanB
		IDrawYPos1B=LDrawYRanB
		IDrawXPos2B=LDrawXRanB
		IDrawYPos2B=LDrawYRanB
	End If
	
	;ECKENPOS/ZWISCHENSPEICHER
	IDrawXB[0]=FDrawXB-IDrawXPos1B
	IDrawYB[0]=FDrawYB+IDrawYPos1B
	IDrawXB[1]=FDrawXB+IDrawXPos2B
	IDrawYB[1]=FDrawYB+IDrawYPos2B
	IDrawXB[2]=FDrawXB+IDrawXPos1B
	IDrawYB[2]=FDrawYB-IDrawYPos1B
	IDrawXB[3]=FDrawXB-IDrawXPos2B
	IDrawYB[3]=FDrawYB-IDrawYPos2B
	
	;VARIABLENDEKLARATIONEN
	Local IDrawXCenter#
	Local IDrawYCenter#
	
	;QUADKOLLISION[A>B]/VORBEREITEN
	IDrawXCenter=(IDrawXA[0]+IDrawXA[1]+IDrawXA[2]+IDrawXA[3])*0.25
	IDrawYCenter=(IDrawYA[0]+IDrawYA[1]+IDrawYA[2]+IDrawYA[3])*0.25
	
	;QUADKOLLISION/BERECHNEN+ANWENDEN
	If (IDrawYB[1]-IDrawYB[0])*(IDrawXCenter-IDrawXB[1])-(IDrawXB[1]-IDrawXB[0])*(IDrawYCenter-IDrawYB[1])>0 Then
		If (IDrawYB[2]-IDrawYB[1])*(IDrawXCenter-IDrawXB[2])-(IDrawXB[2]-IDrawXB[1])*(IDrawYCenter-IDrawYB[2])>0 Then
			If (IDrawYB[3]-IDrawYB[2])*(IDrawXCenter-IDrawXB[3])-(IDrawXB[3]-IDrawXB[2])*(IDrawYCenter-IDrawYB[3])>0 Then
				If (IDrawYB[0]-IDrawYB[3])*(IDrawXCenter-IDrawXB[0])-(IDrawXB[0]-IDrawXB[3])*(IDrawYCenter-IDrawYB[0])>0 Then
					Return True
				End If
			End If
		End If
	End If
	
	;QUADKOLLISION[B>A]/VORBEREITEN
	IDrawXCenter=(IDrawXB[0]+IDrawXB[1]+IDrawXB[2]+IDrawXB[3])*0.25
	IDrawYCenter=(IDrawYB[0]+IDrawYB[1]+IDrawYB[2]+IDrawYB[3])*0.25
	
	;QUADKOLLISION/BERECHNEN+ANWENDEN
	If (IDrawYA[1]-IDrawYA[0])*(IDrawXCenter-IDrawXA[1])-(IDrawXA[1]-IDrawXA[0])*(IDrawYCenter-IDrawYA[1])>0 Then
		If (IDrawYA[2]-IDrawYA[1])*(IDrawXCenter-IDrawXA[2])-(IDrawXA[2]-IDrawXA[1])*(IDrawYCenter-IDrawYA[2])>0 Then
			If (IDrawYA[3]-IDrawYA[2])*(IDrawXCenter-IDrawXA[3])-(IDrawXA[3]-IDrawXA[2])*(IDrawYCenter-IDrawYA[3])>0 Then
				If (IDrawYA[0]-IDrawYA[3])*(IDrawXCenter-IDrawXA[0])-(IDrawXA[0]-IDrawXA[3])*(IDrawYCenter-IDrawYA[0])>0 Then
					Return True
				End If
			End If
		End If
	End If
	
	;VARIABLENDEKLARATIONEN
	Local IDrawACount%
	Local IDrawBCount%
	Local IDrawADrive%
	Local IDrawBDrive%
	Local IDrawLIA#
	Local IDrawLI1#
	Local IDrawLI2#
	
	;ALLE[B]PRODUKTE
	For IDrawBCount=0 To 3
		IDrawBDrive=(IDrawBCount+1) Mod 4
		
		;ALLE[A]PRODUKTE
		For IDrawACount=0 To 3
			IDrawADrive=(IDrawACount+1) Mod 4
			
			;LINES/INTERSECTS/DURCHFÜHREN
			IDrawLIA=(IDrawXA[IDrawADrive]-IDrawXA[IDrawACount])*(IDrawYB[IDrawBDrive]-IDrawYB[IDrawBCount])-(IDrawXB[IDrawBDrive]-IDrawXB[IDrawBCount])*(IDrawYA[IDrawADrive]-IDrawYA[IDrawACount])
			IDrawLI1=((IDrawXB[IDrawBDrive]-IDrawXB[IDrawBCount])*(IDrawYA[IDrawACount]-IDrawYB[IDrawBCount])-(IDrawXA[IDrawACount]-IDrawXB[IDrawBCount])*(IDrawYB[IDrawBDrive]-IDrawYB[IDrawBCount]))/IDrawLIA
			IDrawLI2=((IDrawXA[IDrawADrive]-IDrawXA[IDrawACount])*(IDrawYA[IDrawACount]-IDrawYB[IDrawBCount])-(IDrawXA[IDrawACount]-IDrawXB[IDrawBCount])*(IDrawYA[IDrawADrive]-IDrawYA[IDrawACount]))/IDrawLIA
			If IDrawLI1=>0 And IDrawLI1=<1 And IDrawLI2=>0 And IDrawLI2=<1 Then Return True
		Next
	Next
	
	
	
	
End Function
Function LoadImage3D(FDrawFile$,FDrawMode%=2,FDrawBlend%=2,FDrawPivot%=0,FDrawOrder%=0)
	
	
	
	
	;PARAMETER/VORFILTERUNG
	FDrawFile=Lower$(FDrawFile)
	
	;VARIABLENDEKLARATIONEN
	Local IDrawFile%=0
	Local IDrawSize%=0
	Local IDrawFileX%=-1
	Local IDrawFileY%=-1
	Local IDrawCode%=$C0
	Local IDrawXCount%=0
	Local IDrawYCount%=0
	Local IDrawCount%=0
	Local IDrawCheck%=0
	Local IDrawMeas%=0
	Local IFaceBank%=0
	
	;BILDDATEI/BEARBEITUNG
	If FileType(FDrawFile)=1 Then
		Select Right$(FDrawFile,4)
				
			;BMP/LESEN
			Case ".bmp"
				IDrawFile=ReadFile(FDrawFile)
				SeekFile IDrawFile,18
				IDrawFileX=ReadInt(IDrawFile)
				IDrawFileY=ReadInt(IDrawFile)
				CloseFile IDrawFile
				IDrawCheck=1
				
			;PCX/LESEN
			Case ".pcx"
				IDrawFile=ReadFile(FDrawFile)
				SeekFile IDrawFile,8
				IDrawFileX=ReadShort(IDrawFile)+1
				IDrawFileY=ReadShort(IDrawFile)+1
				CloseFile IDrawFile
				IDrawCheck=1
				
			;TGA/LESEN
			Case ".tga"
				IDrawFile=ReadFile(FDrawFile)
				SeekFile IDrawFile,12
				IDrawFileX=ReadShort(IDrawFile)
				IDrawFileY=ReadShort(IDrawFile)
				CloseFile IDrawFile
				IDrawCheck=1
				
			;PNG/LESEN
			Case ".png"
				IDrawFile=ReadFile(FDrawFile)
				SeekFile IDrawFile,16
				IDrawFileX=(ReadByte(IDrawFile)*$1000000)+(ReadByte(IDrawFile)*$10000)+(ReadByte(IDrawFile)*$100)+(ReadByte(IDrawFile)*$1)
				IDrawFileY=(ReadByte(IDrawFile)*$1000000)+(ReadByte(IDrawFile)*$10000)+(ReadByte(IDrawFile)*$100)+(ReadByte(IDrawFile)*$1)
				CloseFile IDrawFile
				IDrawCheck=1
				
			;JPG/LESEN
			Case ".jpg"
				IDrawFile=ReadFile(FDrawFile)
				IDrawSize=FileSize(FDrawFile)-10
				If IDrawSize>65532 Then IDrawSize=65532
				SeekFile IDrawFile,0
				For IDrawCount=0 To IDrawSize
					If ReadByte(IDrawFile)=$FF Then
						If ReadByte(IDrawFile)=$C2 Then IDrawCode=$C2
					End If
				Next
				SeekFile IDrawFile,0
				For IDrawCount=0 To IDrawSize
					If ReadByte(IDrawFile)=$FF Then
						If ReadByte(IDrawFile)=IDrawCode Then
							ReadByte(IDrawFile)
							ReadByte(IDrawFile)
							ReadByte(IDrawFile)
							IDrawFileY=(ReadByte(IDrawFile)*$100)+(ReadByte(IDrawFile)*$1)
							IDrawFileX=(ReadByte(IDrawFile)*$100)+(ReadByte(IDrawFile)*$1)
						End If
					End If
				Next
				CloseFile IDrawFile
				IDrawCheck=1
				
			; Direct Draw Surface
			Case ".dds"
                IDrawFile=ReadFile(FDrawFile)
                IDrawSize=FileSize(FDrawFile)
				
                ; Verify Magic Number
                If (ReadByte(IDrawFile) = $44) And (ReadByte(IDrawFile) = $44) And (ReadByte(IDrawFile) = $53) And (ReadByte(IDrawFile) = $20) Then
                    SeekFile(IDrawFile, $C)
                    IDrawFileY=ReadInt(IDrawFile)
                    IDrawFileX=ReadInt(IDrawFile)                    
                End If
				
                CloseFile(FDrawFile)
                IDrawCheck=1
				
		;ENDE/SELECT
		End Select
	End If
	
	;KANTENLÄNGE/VERGLEICH
	If IDrawFileX>0 Then
		If IDrawFileY>0 Then
			If Floor(Log(IDrawFileX)/Log(2))=Log(IDrawFileX)/Log(2) Then
				If Floor(Log(IDrawFileY)/Log(2))=Log(IDrawFileY)/Log(2) Then
					If IDrawFileX=IDrawFileY Then IDrawCheck=-1: IDrawMeas=IDrawFileX
				End If
			End If
		End If
	End If
	
	;ALLGEMEINE/FEHLERBEHANDLUNG
	If FileType(FDrawFile)<>1 Then RuntimeError "LoadImage3D"+Chr$(10)+Chr$(10)+"Requested file ''"+FDrawFile+"'' not found!"
	If IDrawCheck=1 Then RuntimeError "LoadImage3D"+Chr$(10)+Chr$(10)+"Requested file ''"+FDrawFile+"''"+Chr$(10)+Chr$(10)+"Load only square textures with a power-of-two size!"
	If IDrawCheck=0 Then RuntimeError "LoadImage3D"+Chr$(10)+Chr$(10)+"Requested file ''"+FDrawFile+"''"+Chr$(10)+Chr$(10)+"Load only images with the Function!"
	
	;FREIEN/BANKPLATZ/SUCHEN
	For IDrawCount=DRAWBANKSTEP To GDrawFaceUsed-DRAWBANKSTEP Step DRAWBANKSTEP
		If PeekInt(GDrawFaceBank,IDrawCount+DRAWBANKKING)=0 Then Exit
	Next
	
	;BANKPOSITION/FESTLEGEN
	IFaceBank=IDrawCount
	If IDrawCount=GDrawFaceUsed Then
		GDrawFaceUsed=GDrawFaceUsed+DRAWBANKSTEP
		ResizeBank GDrawFaceBank,GDrawFaceUsed
		IFaceBank=GDrawFaceUsed-DRAWBANKSTEP
	End If
	
	;ZIELPIVOT/HERAUSFINDEN
	Local IDrawPivot%=GDrawPivot
	If FDrawPivot<>0 Then IDrawPivot=FDrawPivot
	
	;VARIABLEN/VORBERECHNUNGEN
	Local IDrawKing%=IFaceBank
	Local IDrawMesh%=CreateMesh(IDrawPivot)
	Local IDrawFace%=CreateSurface(IDrawMesh)
	Local IDrawTure%=LoadTexture( FDrawFile, FDrawMode)
	If IDrawTure = 0 Then ;!ToDo: AssetManager should have all textures ready.
		IDrawTure = LoadTexture(FDrawFile,FDrawMode)
	EndIf
	Local IDrawBuffer%=TextureBuffer(IDrawTure)
	Local IDrawXRan#=IDrawMeas/2
	Local IDrawYRan#=IDrawMeas/2
	Local IDrawU1MP#=DRAWOFFSET
	Local IDrawV1MP#=DRAWOFFSET
	Local IDrawU2MP#=IDrawMeas-DRAWOFFSET
	Local IDrawV2MP#=IDrawMeas-DRAWOFFSET
	
	; This part is completely unnecessary under BlitzLLVM and has been commented out.
	;GANZE/SCHNELLER/MACHEN
	;LockBuffer IDrawBuffer
	
	; This part is completely unnecessary under BlitzLLVM and has been commented out.
	;SPEZIALITÄTEN/MAV/UMGEHEN
	;For IDrawYCount=0 To IDrawMeas-1
	;	For IDrawXCount=0 To IDrawMeas-1
	;		IDrawCode=ReadPixelFast(IDrawXCount,IDrawYCount,IDrawBuffer)
	;		WritePixelFast IDrawXCount,IDrawYCount,IDrawCode,IDrawBuffer
	;	Next
	;Next
	
	; This part is completely unnecessary under BlitzLLVM and has been commented out.
	;GANZE/SCHNELLER/MACHEN
	;UnlockBuffer IDrawBuffer
	
	;FACEBANK(EIN)WEISUNGEN
	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKKING,IDrawKing
	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKMESH,IDrawMesh
	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKFACE,IDrawFace
	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKTURE,IDrawTure
	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKMEAS,IDrawMeas
	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKXRAN,IDrawXRan
	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKYRAN,IDrawYRan
	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKU1MP,IDrawU1MP
	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKV1MP,IDrawV1MP
	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKU2MP,IDrawU2MP
	PokeFloat GDrawFaceBank,IFaceBank+DRAWBANKV2MP,IDrawV2MP
	PokeInt GDrawFaceBank,IFaceBank+DRAWBANKBUMP,0
	
	;EIGENSCHAFTENZUWEISUNGEN
	If FDrawPivot<>GDrawCamera Then EntityAlpha IDrawMesh,254.0/255.0
	ScaleTexture IDrawTure,IDrawFileX,IDrawFileY
	EntityTexture IDrawMesh,IDrawTure
	TextureBlend IDrawTure,FDrawBlend
	EntityOrder IDrawMesh,FDrawOrder
	EntityFX IDrawMesh,1+2+8+16
	
	;AUTOFLUSHED/FACE
	If AUTOFLUSHFACE=1 Then FlushFace3D(IDrawKing)
	
	;FUNKTION/RÜCKGABEWERT
	Return IDrawKing
	
	
	
	
End Function
Function MaskImage3D(FDrawHandle%,FDrawRGB%=$00FFFFFF)
	
	
	
	
	;PARAMETER/VORFILTERUNG
	FDrawRGB=$00FFFFFF And FDrawRGB
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawTure%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKTURE)
	Local LDrawU1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU1MP)
	Local LDrawV1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV1MP)
	Local LDrawU2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU2MP)
	Local LDrawV2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV2MP)
	
	;VARIABLENDEKLARATIONEN
	Local IDrawBuffer%=TextureBuffer(LDrawTure)
	Local IDrawXCount%=0
	Local IDrawYCount%=0
	Local IDrawRGB%=0
	
	;GANZE/SCHNELLER/MACHEN
	LockBuffer IDrawBuffer
	
	;MASKENFILTER/ANWENDEN
	For IDrawYCount=LDrawV1MP To LDrawV2MP-1
		For IDrawXCount=LDrawU1MP To LDrawU2MP-1
			IDrawRGB=$00FFFFFF And ReadPixelFast(IDrawXCount,IDrawYCount,IDrawBuffer)
			If IDrawRGB=FDrawRGB Then WritePixelFast IDrawXCount,IDrawYCount,IDrawRGB,IDrawBuffer
		Next
	Next
	
	;GANZE/SCHNELLER/MACHEN
	UnlockBuffer IDrawBuffer
	
	
	
	
End Function
Function OnLockBuffer3D(FDrawHandle%)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawTure%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKTURE)
	
	;EIGENSCHAFTENZUWEISUNGEN
	LockBuffer TextureBuffer(LDrawTure)
	
	
	
	
End Function
Function Origin3D(FDrawX#=0,FDrawY#=0,FDrawPivot%=0)
	
	
	
	
	;PARAMETER/VORFILTERUNG
	If FDrawPivot=0 Then FDrawPivot=GDrawPivot
	
	;AUTOMATISCHE/1:1/STELLUNG
	If FDrawX=0 And FDrawY=0 Then
		FDrawX=GraphicsWidth()
		FDrawY=GraphicsHeight()
	End If
	
	;VARIABLEN/VORBERECHNUNGEN
	GDrawXScale=GraphicsWidth()/FDrawX
	GDrawYScale=GraphicsHeight()/FDrawY
	Local IDrawXScale#=GDrawXScale*(DRAWDISTANCE*2)/GraphicsWidth()
	Local IDrawYScale#=GDrawYScale*(DRAWDISTANCE*2)/GraphicsWidth()
	
	;EIGENSCHAFTENZUWEISUNGEN
	ScaleEntity FDrawPivot,IDrawXScale,IDrawYScale,1
	PositionEntity FDrawPivot,0,0,DRAWDISTANCE
	
	;GENAUE(U/V)ÜBERLAGERUNG/ERMÖGLICHEN
	MoveEntity FDrawPivot,-IDrawXScale*0.5,+IDrawYScale*0.5,0
	
	
	
	
End Function
Function SetFont3D(FDrawHandle%,FDrawSFont#=1,FDrawHFont#=1,FDrawPFont#=0,FDrawIFont#=0)
	
	
	
	
	;SICHERHEITSPRÜFUNG
	If (FDrawHandle Mod DRAWFONTSTEP)<>0 Then RuntimeError "SetFont3D"+Chr$(10)+Chr$(10)+"Handle not legal!"
	
	;FONTBANK(EIN)WEISUNGEN
	PokeFloat GDrawFontBank,FDrawHandle+DRAWFONTSVAL,FDrawSFont
	PokeFloat GDrawFontBank,FDrawHandle+DRAWFONTHVAL,FDrawHFont
	PokeFloat GDrawFontBank,FDrawHandle+DRAWFONTPVAL,FDrawPFont
	PokeFloat GDrawFontBank,FDrawHandle+DRAWFONTIVAL,FDrawIFont
	
	
	
	
End Function
Function SetPivot3D(FDrawHandle%,FDrawXP#,FDrawYP#,FDrawZP#,FDrawXR#=0,FDrawYR#=0,FDrawZR#=0,FDrawScale#=1)
	
	
	
	
	;EIGENSCHAFTENZUWEISUNGEN
	PositionEntity FDrawHandle,FDrawXP,FDrawYP,FDrawZP
	RotateEntity FDrawHandle,FDrawXR,FDrawYR,FDrawZR
	ScaleEntity FDrawHandle,FDrawScale,FDrawScale,1
	
	;GENAUE(U/V)ÜBERLAGERUNG/ERMÖGLICHEN
	MoveEntity FDrawHandle,-0.5*FDrawScale,+0.5*FDrawScale,0
	
	
	
	
End Function
Function SetPixel3D(FDrawHandle%,FDrawX%,FDrawY%,FDrawARGB%=0)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawTure%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKTURE)
	
	;PIXELFARBE(EIN)ZEICHNEN
	WritePixelFast FDrawX,FDrawY,FDrawARGB,TextureBuffer(LDrawTure)
	
	
	
	
End Function
Function SetTexel3D(FDrawHandle%,FDrawX1#,FDrawY1#,FDrawX2#,FDrawY2#,FDrawAngle#=0,FDrawScale#=1,FDrawARGB%=0)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawTure%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKTURE)
	Local LDrawXRan#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKXRAN)
	Local LDrawYRan#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKYRAN)
	Local LDrawU1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU1MP)
	Local LDrawV1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV1MP)
	
	;VARIABLEN/VORBERECHNUNGEN
	Local IDrawXRelative%=(FDrawX1-FDrawX2)/FDrawScale
	Local IDrawYRelative%=(FDrawY1-FDrawY2)/FDrawScale
	Local IDrawXRan#=LDrawXRan
	Local IDrawYRan#=LDrawYRan
	LDrawXRan=LDrawXRan*FDrawScale
	LDrawYRan=LDrawYRan*FDrawScale
	
	;WINKEL/HINZURECHNEN
	If FDrawAngle<>0 Then
		
		;SCHNELLE/UMRECHNUNG/VON: 'aMul'
		Local IDrawTCos#=Cos(FDrawAngle)
		Local IDrawTSin#=Sin(FDrawAngle)
		Local IDrawTempValue#=IDrawXRelative
		IDrawXRelative=(IDrawXRelative*IDrawTCos-IDrawYRelative*IDrawTSin)
		IDrawYRelative=(IDrawYRelative*IDrawTCos+IDrawTempValue*IDrawTSin)
	End If
	
	;TEXTUR/TEXEL/SETZEN
	If IDrawXRelative=>-IDrawXRan Then
		If IDrawXRelative<+IDrawXRan Then
			If IDrawYRelative>-IDrawYRan Then
				If IDrawYRelative<=+IDrawYRan Then
					WritePixelFast LDrawU1MP+IDrawXRan+IDrawXRelative,LDrawV1MP+IDrawYRan-IDrawYRelative,FDrawARGB,TextureBuffer(LDrawTure)
				End If
			End If
		End If
	End If
	
	
	
	
End Function
Function StringHeight3D(FDrawHandle%)
	
	
	
	
	;SICHERHEITSPRÜFUNG
	If FDrawHandle=0 Then RuntimeError "StringHeight3D"+Chr$(10)+Chr$(10)+"Handle not legal!"
	
	;FUNKTION/RÜCKGABEWERT
	Return PeekInt(GDrawFontBank,FDrawHandle+DRAWFONTHSET)
	
	
	
	
End Function
Function StringWidth3D(FDrawHandle%,FDrawString$)
	
	
	
	
	;SICHERHEITSPRÜFUNG
	If FDrawHandle=0 Then RuntimeError "StringWidth3D"+Chr$(10)+Chr$(10)+"Handle not legal!"
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawSVal#=PeekFloat(GDrawFontBank,FDrawHandle+DRAWFONTSVAL)
	Local LDrawPVal#=PeekFloat(GDrawFontBank,FDrawHandle+DRAWFONTPVAL)
	
	;VARIABLEN/VORBERECHNUNGEN
	Local IDrawLen%=Len(FDrawString)
	Local IDrawWidth#
	Local LDrawWidth%
	Local IDrawCount%
	Local IDrawMode%
	Local IDrawTags%=(Instr(FDrawString,"<")>0)
	Local IDrawAsc%
	
	;STRINGLÄNGE/BERECHNEN
	For IDrawCount=1 To IDrawLen
		IDrawAsc=Asc(Mid(FDrawString,IDrawCount,1))
		
		;RÜCKSTELLUNG
		IDrawMode=0
		
		;<TAG>ÜBERSPRINGEN
		If IDrawAsc=60 And IDrawTags Then
			
			;<ENDE-TAG>ÜBERSPRINGEN
			If Mid(FDrawString,IDrawCount+1,3)="/#>" Then
				IDrawCount=IDrawCount+3
				IDrawMode=1
			End If
			
			;<FARB-TAG>ÜBERSPRINGEN
			If Mid(FDrawString,IDrawCount+1,1)="#" Then
				If Mid(FDrawString,IDrawCount+5,1)=">" Then IDrawCount=IDrawCount+5: IDrawMode=1
				If Mid(FDrawString,IDrawCount+6,1)=">" Then IDrawCount=IDrawCount+6: IDrawMode=1
			End If
			
			;<SPACE-TAG>ÜBERSPRINGEN
			If Mid(FDrawString,IDrawCount+1,1)="%" Then
				If Mid(FDrawString,IDrawCount+5,1)=">" Then
					IDrawWidth=Int(Mid(FDrawString,IDrawCount+2,3))
					IDrawCount=IDrawCount+5
					IDrawMode=1
				End If
			End If
		End If
		
		;ZUSAMMEN/SCHUSTERN
		If IDrawMode=0 Then
			LDrawWidth=PeekByte(GDrawFontBank,FDrawHandle+DRAWFONTCHAR+IDrawAsc)
			IDrawWidth=IDrawWidth+LDrawWidth+LDrawPVal
		End If
	Next
	
	;FUNKTION/RÜCKGABEWERT
	Return IDrawWidth*LDrawSVal-LDrawPVal
	
	
	
	
End Function
Function Text3D(FDrawHandle%,FDrawX#,FDrawY#,FDrawString$,FDrawAlign#=0,FDrawButton%=0,FDrawAngle#=0)
	
	
	
	
	;SICHERHEITSPRÜFUNG
	If FDrawHandle=0 Then RuntimeError "Text3D"+Chr$(10)+Chr$(10)+"Handle not legal!"
	
	;FARBEN/ÜBERNEHMEN
	Local IDrawTFR%=GDrawTFR
	Local IDrawTFG%=GDrawTFG
	Local IDrawTFB%=GDrawTFB
	Local IDrawTFA#=GDrawTFA
	
	;FONTBANK(AUS)WEISUNGEN
	Local LDrawFace%=PeekInt(GDrawFontBank,FDrawHandle+DRAWFONTFACE)
	Local LDrawSVal#=PeekFloat(GDrawFontBank,FDrawHandle+DRAWFONTSVAL)
	Local LDrawHVal#=PeekFloat(GDrawFontBank,FDrawHandle+DRAWFONTHVAL)
	Local LDrawPVal#=PeekFloat(GDrawFontBank,FDrawHandle+DRAWFONTPVAL)
	Local LDrawIVal#=PeekFloat(GDrawFontBank,FDrawHandle+DRAWFONTIVAL)
	Local LDrawUSet%=PeekInt(GDrawFontBank,FDrawHandle+DRAWFONTUSET)
	Local LDrawVSet%=PeekInt(GDrawFontBank,FDrawHandle+DRAWFONTVSET)
	Local LDrawWSet%=PeekInt(GDrawFontBank,FDrawHandle+DRAWFONTWSET)
	Local LDrawHSet%=PeekInt(GDrawFontBank,FDrawHandle+DRAWFONTHSET)
	
	;VARIABLEN/VORBERECHNUNGEN
	Local IDrawLen%=Len(FDrawString)
	Local IDrawXVector#=Cos(-FDrawAngle)*LDrawSVal
	Local IDrawYVector#=Sin(-FDrawAngle)*LDrawSVal
	Local IDrawXI#=IDrawXVector*LDrawIVal*LDrawHVal
	Local IDrawYI#=IDrawYVector*LDrawIVal*LDrawHVal
	Local IDrawX1Pos#=0
	Local IDrawY1Pos#=0
	Local IDrawX2Pos#=0
	Local IDrawY2Pos#=0
	Local IDrawX3Pos#=0
	Local IDrawY3Pos#=0
	Local IDrawX4Pos#=0
	Local IDrawY4Pos#=0
	Local IDrawX1Sav#=0
	Local IDrawY1Sav#=0
	Local IDrawX4Sav#=0
	Local IDrawY4Sav#=0
	Local LDrawWidth%=0
	Local IDrawCount%=0
	Local IDrawMode%=0
	Local IDrawAsc%=0
	
	;SONSTIGE/VARIABLEN
	Local IDrawU1Map%=0
	Local IDrawV1Map%=0
	Local IDrawU2Map%=0
	Local IDrawV2Map%=0
	Local IDrawV0%=0
	Local IDrawV1%=0
	Local IDrawV2%=0
	Local IDrawV3%=0
	Local IDrawSpace%=0
	Local IDrawWidth#=0
	Local IDrawWhite%=0
	
	;OPT: leere Texte und Texte weit ausserhalb des Bildes ueberspringen (nur ohne Schaltflaeche)
	If IDrawLen=0 Then Return
	If FDrawButton=0 And FDrawAngle=0 Then
		If FDrawY<-GDrawYSize/GDrawYScale-LDrawHVal*LDrawHSet*LDrawSVal Then Return
		If FDrawY>GDrawYSize/GDrawYScale+LDrawHVal*LDrawHSet*LDrawSVal Then Return
	End If
	
	;OPT: Strings ohne Tags brauchen keine Tag-Pruefungen
	Local IDrawTags%=(Instr(FDrawString,"<")>0)
	
	
	
	
	;STRING/GGF/AUSRICHTEN
	If FDrawAlign<>0 Then
		For IDrawCount=1 To IDrawLen
			IDrawAsc=Asc(Mid(FDrawString,IDrawCount,1))
			
			;RÜCKSTELLUNG
			IDrawMode=0
			
			;<TAG>ÜBERSPRINGEN
			If IDrawAsc=60 And IDrawTags Then
				
				;<ENDE-TAG>ÜBERSPRINGEN
				If Mid(FDrawString,IDrawCount+1,3)="/#>" Then
					IDrawCount=IDrawCount+3
					IDrawMode=1
				End If
				
				;<FARB-TAG>ÜBERSPRINGEN
				If Mid(FDrawString,IDrawCount+1,1)="#" Then
					If Mid(FDrawString,IDrawCount+5,1)=">" Then IDrawCount=IDrawCount+5: IDrawMode=1
					If Mid(FDrawString,IDrawCount+6,1)=">" Then IDrawCount=IDrawCount+6: IDrawMode=1
				End If
				
				;<SPACE-TAG>ÜBERSPRINGEN
				If Mid(FDrawString,IDrawCount+1,1)="%" Then
					If Mid(FDrawString,IDrawCount+5,1)=">" Then
						IDrawWidth=Int(Mid(FDrawString,IDrawCount+2,3))
						IDrawCount=IDrawCount+5
						IDrawMode=1
					End If
				End If
			End If
			
			;ZUSAMMEN/SCHUSTERN
			If IDrawMode=0 Then
				IDrawWidth=IDrawWidth+PeekByte(GDrawFontBank,FDrawHandle+DRAWFONTCHAR+IDrawAsc)+LDrawPVal
			End If
		Next
	End If
	
	;STARTKANTEN/FESTLEGEN
	IDrawX1Pos=FDrawX+IDrawXI-IDrawYVector*LDrawHVal*LDrawHSet*0.5-IDrawWidth*IDrawXVector*FDrawAlign*0.5
	IDrawY1Pos=FDrawY+IDrawYI+IDrawXVector*LDrawHVal*LDrawHSet*0.5-IDrawWidth*IDrawYVector*FDrawAlign*0.5
	IDrawX4Pos=FDrawX-IDrawXI+IDrawYVector*LDrawHVal*LDrawHSet*0.5-IDrawWidth*IDrawXVector*FDrawAlign*0.5
	IDrawY4Pos=FDrawY-IDrawYI-IDrawXVector*LDrawHVal*LDrawHSet*0.5-IDrawWidth*IDrawYVector*FDrawAlign*0.5
	
	;PIXELGENAUIGKEIT
	If (FDrawAngle Mod 90)=0 Then
		IDrawX1Pos=Floor(IDrawX1Pos)
		IDrawY1Pos=Floor(IDrawY1Pos)
		IDrawX4Pos=Floor(IDrawX4Pos)
		IDrawY4Pos=Floor(IDrawY4Pos)
	End If
	
	;STARTKANTEN/SICHERN
	IDrawX1Sav=IDrawX1Pos
	IDrawY1Sav=IDrawY1Pos
	IDrawX4Sav=IDrawX4Pos
	IDrawY4Sav=IDrawY4Pos
	
	
	
	
	;TEXTAUSGABE/DURCHFÜHREN
	For IDrawCount=1 To IDrawLen
		IDrawAsc=Asc(Mid(FDrawString,IDrawCount,1))
		
		;RÜCKSTELLUNG
		IDrawMode=0
		
		;EVENTUELL/EIN<TAG>
		If IDrawAsc=60 And IDrawTags Then
			
			;PRÜFEN/OB/EIN/ENDE<ENDE-TAG>
			If Mid(FDrawString,IDrawCount+1,3)="/#>" Then
				IDrawTFR=GDrawTFR
				IDrawTFG=GDrawTFG
				IDrawTFB=GDrawTFB
				IDrawTFA=GDrawTFA
				IDrawCount=IDrawCount+3
				IDrawMode=1
			End If
			
			;PRÜFEN/OB/EIN/ECHTER<FARB-TAG>
			If Mid(FDrawString,IDrawCount+1,1)="#" Then
				
				;TAGBEARBEITUNG<#RGB>NUR/FARBEN
				If Mid(FDrawString,IDrawCount+5,1)=">" Then
					IDrawTFR=((Asc(Lower(Mid(FDrawString,IDrawCount+2,1)))-48) Mod 39)*17
					IDrawTFG=((Asc(Lower(Mid(FDrawString,IDrawCount+3,1)))-48) Mod 39)*17
					IDrawTFB=((Asc(Lower(Mid(FDrawString,IDrawCount+4,1)))-48) Mod 39)*17
					IDrawCount=IDrawCount+5
					IDrawMode=1
					
				;TAGBEARBEITUNG<#ARGB>MIT/ALPHA
				Else If Mid(FDrawString,IDrawCount+6,1)=">" Then
					IDrawTFA=((Asc(Lower(Mid(FDrawString,IDrawCount+2,1)))-48) Mod 39)/15.0
					IDrawTFR=((Asc(Lower(Mid(FDrawString,IDrawCount+3,1)))-48) Mod 39)*17
					IDrawTFG=((Asc(Lower(Mid(FDrawString,IDrawCount+4,1)))-48) Mod 39)*17
					IDrawTFB=((Asc(Lower(Mid(FDrawString,IDrawCount+5,1)))-48) Mod 39)*17
					IDrawCount=IDrawCount+6
					IDrawMode=1
				End If
			End If
			
			;PRÜFEN/OB/EIN/ECHTER<SPACE-TAG>
			If Mid(FDrawString,IDrawCount+1,1)="%" Then
				If Mid(FDrawString,IDrawCount+5,1)=">" Then
					IDrawSpace=Int(Mid(FDrawString,IDrawCount+2,3))
					IDrawX1Pos=IDrawX1Sav+IDrawXVector*IDrawSpace
					IDrawY1Pos=IDrawY1Sav+IDrawYVector*IDrawSpace
					IDrawX4Pos=IDrawX4Sav+IDrawXVector*IDrawSpace
					IDrawY4Pos=IDrawY4Sav+IDrawYVector*IDrawSpace
					IDrawCount=IDrawCount+5
					IDrawMode=1
				End If
			End If
		End If
		
		
		
		
		;TEXTAUSGABE
		If IDrawMode=0 Then
			LDrawWidth=PeekByte(GDrawFontBank,FDrawHandle+DRAWFONTCHAR+IDrawAsc)
			IDrawWhite=(IDrawTFR=255 And IDrawTFG=255 And IDrawTFB=255 And IDrawTFA=1)
			IDrawX2Pos=IDrawX1Pos+IDrawXVector*LDrawWidth
			IDrawY2Pos=IDrawY1Pos+IDrawYVector*LDrawWidth
			IDrawX3Pos=IDrawX4Pos+IDrawXVector*LDrawWidth
			IDrawY3Pos=IDrawY4Pos+IDrawYVector*LDrawWidth
			IDrawU1Map=LDrawUSet+LDrawWSet*(IDrawAsc Mod 16)
			IDrawV1Map=LDrawVSet+LDrawHSet*Floor(IDrawAsc/16)
			IDrawU2Map=IDrawU1Map+LDrawWidth
			IDrawV2Map=IDrawV1Map+LDrawHSet
			
			;VERTEX/POLYGON/ZUWEISUNGEN
			IDrawV0=AddVertex(LDrawFace,IDrawX1Pos,IDrawY1Pos,0 ,IDrawU1Map,IDrawV1Map)
			IDrawV1=AddVertex(LDrawFace,IDrawX2Pos,IDrawY2Pos,0 ,IDrawU2Map,IDrawV1Map)
			IDrawV2=AddVertex(LDrawFace,IDrawX3Pos,IDrawY3Pos,0 ,IDrawU2Map,IDrawV2Map)
			IDrawV3=AddVertex(LDrawFace,IDrawX4Pos,IDrawY4Pos,0 ,IDrawU1Map,IDrawV2Map)
			If IDrawWhite=0 Then
				VertexColor LDrawFace,IDrawV0,IDrawTFR,IDrawTFG,IDrawTFB,IDrawTFA
				VertexColor LDrawFace,IDrawV1,IDrawTFR,IDrawTFG,IDrawTFB,IDrawTFA
				VertexColor LDrawFace,IDrawV2,IDrawTFR,IDrawTFG,IDrawTFB,IDrawTFA
				VertexColor LDrawFace,IDrawV3,IDrawTFR,IDrawTFG,IDrawTFB,IDrawTFA
			End If
			AddTriangle LDrawFace,IDrawV0,IDrawV1,IDrawV2
			AddTriangle LDrawFace,IDrawV2,IDrawV3,IDrawV0
			
			;ENDEKANTEN/FORTBEWEGEN
			IDrawX1Pos=IDrawX2Pos+LDrawPVal*IDrawXVector
			IDrawY1Pos=IDrawY2Pos+LDrawPVal*IDrawYVector
			IDrawX4Pos=IDrawX3Pos+LDrawPVal*IDrawXVector
			IDrawY4Pos=IDrawY3Pos+LDrawPVal*IDrawYVector
		End If
	Next
	
	
	
	
	;SCHALTFLÄCHE/PRÜFUNG
	If FDrawButton<>0 Then
		
		;TEXT3D/BUTTON/OVERDRIVE
		If XOVERDRIVE<>0 Then
			IDrawXVector=IDrawXVector*XOVERDRIVE*LDrawSVal*LDrawWSet*0.125
			IDrawYVector=IDrawYVector*XOVERDRIVE*LDrawSVal*LDrawWSet*0.125
			IDrawX1Sav=IDrawX1Sav-IDrawXVector
			IDrawY1Sav=IDrawY1Sav-IDrawYVector
			IDrawX2Pos=IDrawX2Pos+IDrawXVector
			IDrawY2Pos=IDrawY2Pos+IDrawYVector
			IDrawX3Pos=IDrawX3Pos+IDrawXVector
			IDrawY3Pos=IDrawY3Pos+IDrawYVector
			IDrawX4Sav=IDrawX4Sav-IDrawXVector
			IDrawY4Sav=IDrawY4Sav-IDrawYVector
		End If
		
		;SCHALTFLÄCHE/PRÜFUNG
		CheckQuad3D(IDrawX1Sav,IDrawY1Sav,IDrawX2Pos,IDrawY2Pos,IDrawX3Pos,IDrawY3Pos,IDrawX4Sav,IDrawY4Sav,FDrawButton,PeekInt(GDrawFontBank,FDrawHandle+DRAWFONTLINK))
	End If
	
	
	
	
End Function
Function Text3DTT(FDrawHandle%,FDrawDestin%,FDrawX%,FDrawY%,FDrawString$)
	
	
	
	
	;SICHERHEITSPRÜFUNG
	If FDrawHandle=0 Then RuntimeError "Text3DTT"+Chr$(10)+Chr$(10)+"Handle not legal!"
	If FDrawDestin=0 Then RuntimeError "Text3DTT"+Chr$(10)+Chr$(10)+"Handle not legal!"
	
	;FONTBANK(AUS)WEISUNGEN
	Local LDrawPVal#=PeekFloat(GDrawFontBank,FDrawHandle+DRAWFONTPVAL)
	Local LDrawUSet%=PeekInt(GDrawFontBank,FDrawHandle+DRAWFONTUSET)
	Local LDrawVSet%=PeekInt(GDrawFontBank,FDrawHandle+DRAWFONTVSET)
	Local LDrawWSet%=PeekInt(GDrawFontBank,FDrawHandle+DRAWFONTWSET)
	Local LDrawHSet%=PeekInt(GDrawFontBank,FDrawHandle+DRAWFONTHSET)
	
	;FONTBANK(AUS)WEISUNGEN
	Local LDrawLinked%=PeekInt(GDrawFontBank,FDrawHandle)
	Local IDrawFontBuffer%=TextureBuffer(PeekInt(GDrawFaceBank,LDrawLinked+DRAWBANKTURE))
	Local IDrawDestBuffer%=TextureBuffer(PeekInt(GDrawFaceBank,FDrawDestin+DRAWBANKTURE))
	
	;POSITIONS/KORREKTUREN
	FDrawX=ImageSize3D(FDrawDestin,1)/2+FDrawX
	FDrawY=ImageSize3D(FDrawDestin,2)/2-FDrawY
	FDrawY=FDrawY-StringHeight3D(FDrawHandle)/2
	
	;VARIABLENDEKLARATIONEN
	Local IDrawHFC%=0,IDrawDFC%=0
	Local IDrawHFA#=0,IDrawDFA#=0
	Local IDrawHFR#=0,IDrawDFR#=0
	Local IDrawHFG#=0,IDrawDFG#=0
	Local IDrawHFB#=0,IDrawDFB#=0
	Local IDrawHFM#=0,IDrawDFM#=0
	
	;VARIABLEN/VORBERECHNUNGEN
	Local IDrawLen%=Len(FDrawString)
	Local IDrawXPos%=FDrawX
	Local IDrawYPos%=FDrawY
	Local IDrawU1Map%
	Local IDrawV1Map%
	Local IDrawXCount%
	Local IDrawYCount%
	Local IDrawCount%
	Local LDrawWidth%
	Local IDrawMode%
	Local IDrawAsc%
	
	;GANZE/SCHNELLER/MACHEN
	LockBuffer IDrawFontBuffer
	LockBuffer IDrawDestBuffer
	
	;TEXTAUSGABE/DURCHFÜHREN
	For IDrawCount=1 To IDrawLen
		IDrawAsc=Asc(Mid(FDrawString,IDrawCount,1))
		
		;TEXTAUSGABE
		If IDrawMode=0 Then
			LDrawWidth=PeekByte(GDrawFontBank,FDrawHandle+DRAWFONTCHAR+IDrawAsc)
			IDrawU1Map=LDrawUSet+LDrawWSet*(IDrawAsc Mod 16)
			IDrawV1Map=LDrawVSet+LDrawHSet*Floor(IDrawAsc/16)
			
			;CHAR/ZEICHEN
			For IDrawYCount=0 To LDrawHSet
				For IDrawXCount=0 To LDrawWidth
					
					;FARBEN/HANDLE/AUSLESEN
					IDrawHFC=ReadPixel(IDrawXCount+IDrawU1Map,IDrawYCount+IDrawV1Map,IDrawFontBuffer)
					IDrawHFA=(IDrawHFC And $FF000000) Shr $18
					IDrawHFR=(IDrawHFC And $00FF0000) Shr $10
					IDrawHFG=(IDrawHFC And $0000FF00) Shr $08
					IDrawHFB=(IDrawHFC And $000000FF) Shr $00
					
					;FARBEN/DESTIN/AUSLESEN
					IDrawDFC=ReadPixel(IDrawXCount+IDrawXPos,IDrawYCount+IDrawYPos,IDrawDestBuffer)
					IDrawDFA=(IDrawDFC And $FF000000) Shr $18
					IDrawDFR=(IDrawDFC And $00FF0000) Shr $10
					IDrawDFG=(IDrawDFC And $0000FF00) Shr $08
					IDrawDFB=(IDrawDFC And $000000FF) Shr $00
					
					;FARBVERHÄLTNISSE
					IDrawHFM=IDrawHFA/255.0
					IDrawDFM=1.0-IDrawHFM
					
					;FARBVERHÄLTNISSE/MISCHEN
					IDrawDFA=IDrawHFA+IDrawDFA
					If IDrawDFA>255 Then IDrawDFA=255
					IDrawDFR=IDrawHFR*IDrawHFM+IDrawDFR*IDrawDFM
					IDrawDFG=IDrawHFG*IDrawHFM+IDrawDFG*IDrawDFM
					IDrawDFB=IDrawHFB*IDrawHFM+IDrawDFB*IDrawDFM
					
					;FARBCODE/NEUKODIERUNG
					IDrawDFC=(IDrawDFA Shl $18)+(IDrawDFR Shl $10)+(IDrawDFG Shl $08)+(IDrawDFB Shl $00)
					
					;FARBCODE/PIXEL/SETZEN
					WritePixel IDrawXPos+IDrawXCount,IDrawYPos+IDrawYCount,IDrawDFC,IDrawDestBuffer
				Next
			Next
			
			;ENDEKANTEN/FORTBEWEGEN
			IDrawXPos=IDrawXPos+LDrawWidth+LDrawPVal
		End If
	Next
	
	;GANZE/SCHNELLER/MACHEN
	UnlockBuffer IDrawFontBuffer
	UnlockBuffer IDrawDestBuffer
	
	
	
	
End Function
Function UnLockBuffer3D(FDrawHandle%)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawTure%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKTURE)
	
	;EIGENSCHAFTENZUWEISUNGEN
	UnlockBuffer TextureBuffer(LDrawTure)
	
	
	
	
End Function
Function USwap3D(FDrawHandle%,FDrawFrame%=0,FDrawMode%=0)
	
	
	
	
	;PARAMETER/VORREINIGUNG
	FDrawFrame=FDrawFrame*DRAWBANKSTEP
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawU1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU1MP+FDrawFrame)
	Local LDrawU2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKU2MP+FDrawFrame)
	Local IDrawSwap%=0
	
	;RICHTUNGEN/PRÜFEN
	If FDrawMode=-1 Then If LDrawU2MP>LDrawU1MP Then IDrawSwap=1
	If FDrawMode=+1 Then If LDrawU1MP>LDrawU2MP Then IDrawSwap=1
	If FDrawMode=0 Then IDrawSwap=1
	
	;MAPPING/TAUSCHEN
	If IDrawSwap=1 Then
		PokeFloat GDrawFaceBank,FDrawHandle+DRAWBANKU1MP+FDrawFrame,LDrawU2MP
		PokeFloat GDrawFaceBank,FDrawHandle+DRAWBANKU2MP+FDrawFrame,LDrawU1MP
	End If
	
	
	
	
End Function
Function VSwap3D(FDrawHandle%,FDrawFrame%=0,FDrawMode%=0)
	
	
	
	
	;PARAMETER/VORREINIGUNG
	FDrawFrame=FDrawFrame*DRAWBANKSTEP
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawV1MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV1MP+FDrawFrame)
	Local LDrawV2MP#=PeekFloat(GDrawFaceBank,FDrawHandle+DRAWBANKV2MP+FDrawFrame)
	Local IDrawSwap%=0
	
	;RICHTUNGEN/PRÜFEN
	If FDrawMode=-1 Then If LDrawV2MP>LDrawV1MP Then IDrawSwap=1
	If FDrawMode=+1 Then If LDrawV1MP>LDrawV2MP Then IDrawSwap=1
	If FDrawMode=0 Then IDrawSwap=1
	
	;MAPPING/TAUSCHEN
	If IDrawSwap=1 Then
		PokeFloat GDrawFaceBank,FDrawHandle+DRAWBANKV1MP+FDrawFrame,LDrawV2MP
		PokeFloat GDrawFaceBank,FDrawHandle+DRAWBANKV2MP+FDrawFrame,LDrawV1MP
	End If
	
	
	
	
End Function


;[Block] NATIVE/VARIABLENDEKLARATIONEN




;GLOBALVARIABLENDEKLARATIONEN
Global GDrawNFR%=255 ;Native-Farbe-Rot
Global GDrawNFG%=255 ;Native-Farbe-Grün
Global GDrawNFB%=255 ;Native-Farbe-Blau
Global GDrawNFA#=1 ;Native-Alpha-Angabe




;[End Block]
Function ColorN3D(FDrawFR%=255,FDrawFG%=255,FDrawFB%=255,FDrawFA#=1)
	
	
	
	
	;GLOBALENZUWEISUNGEN
	GDrawNFR=FDrawFR
	GDrawNFG=FDrawFG
	GDrawNFB=FDrawFB
	GDrawNFA=FDrawFA
	
	
	
	
End Function
Function Line3D(FDrawHandle%,FDrawX1#,FDrawY1#,FDrawX2#,FDrawY2#,FDrawSize#=2)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE)
	Local LDrawMeas%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKMEAS)
	
	;AUSBLENDUNG/FEHLERKORREKTUR
	If FDrawX1<>FDrawX2 Or FDrawY1<>FDrawY2 Then
		
		;PARAMETER/VORREINIGUNG
		If FDrawSize=0 Then FDrawSize=2
		
		;VARIABLEN/VORBERECHNUNGEN
		TFormNormal FDrawX2-FDrawX1,FDrawY2-FDrawY1,0,0,0
		Local IDrawUTForm#=TFormedX()*0.5
		Local IDrawVTForm#=TFormedY()*0.5
		Local IDrawXTForm#=IDrawUTForm*2*FDrawSize
		Local IDrawYTForm#=IDrawVTForm*2*FDrawSize
		Local IDrawCenter%=LDrawMeas/2
		
		;VERTEX/POLYGON/ZUWEISUNGEN
		Local IDrawV0%=AddVertex(LDrawFace,FDrawX1+IDrawYTForm,FDrawY1-IDrawXTForm,0 ,IDrawCenter+IDrawVTForm*LDrawMeas,IDrawCenter+IDrawUTForm*LDrawMeas)
		Local IDrawV1%=AddVertex(LDrawFace,FDrawX1-IDrawYTForm,FDrawY1+IDrawXTForm,0 ,IDrawCenter-IDrawVTForm*LDrawMeas,IDrawCenter-IDrawUTForm*LDrawMeas)
		Local IDrawV2%=AddVertex(LDrawFace,FDrawX2-IDrawYTForm,FDrawY2+IDrawXTForm,0 ,IDrawCenter-IDrawVTForm*LDrawMeas,IDrawCenter-IDrawUTForm*LDrawMeas)
		Local IDrawV3%=AddVertex(LDrawFace,FDrawX2+IDrawYTForm,FDrawY2-IDrawXTForm,0 ,IDrawCenter+IDrawVTForm*LDrawMeas,IDrawCenter+IDrawUTForm*LDrawMeas)
		VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawV2,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawV3,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		AddTriangle(LDrawFace,IDrawV0,IDrawV1,IDrawV2)
		AddTriangle(LDrawFace,IDrawV2,IDrawV3,IDrawV0)
	End If
	
	
	
	
End Function
Function Oval3D(FDrawHandle%,FDrawX#,FDrawY#,FDrawXS#,FDrawYS#,FDrawFill%=1,FDrawSize#=0)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE)
	Local LDrawMeas%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKMEAS)
	
	;VARIABLEN/VORBERECHNUNGEN
	FDrawXS=Abs(FDrawXS)
	FDrawYS=Abs(FDrawYS)
	Local IDrawSequences#=8+Int((FDrawXS+FDrawYS)/20)
	If IDrawSequences>32 Then IDrawSequences=32
	Local IDrawAngle#=90.0/IDrawSequences
	Local IDrawCenter%=LDrawMeas/2
	Local IDrawCount%
	
	;RAHMEN/ALLEIN/MODUS
	If FDrawFill=0 Then
		If FDrawSize=0 Then FDrawSize=2
		Local IDrawXOutside#=FDrawXS+FDrawSize
		Local IDrawYOutside#=FDrawYS+FDrawSize
		Local IDrawXInside#=FDrawXS-FDrawSize
		Local IDrawYInside#=FDrawYS-FDrawSize
		For IDrawCount=1 To IDrawSequences
			
			;VERTEX/POLYGON/VEKTOREN
			Local IDrawXPos1#=Cos(IDrawCount*IDrawAngle)
			Local IDrawYPos1#=Sin(IDrawCount*IDrawAngle)
			Local IDrawXPos2#=Cos(IDrawCount*IDrawAngle-IDrawAngle)
			Local IDrawYPos2#=Sin(IDrawCount*IDrawAngle-IDrawAngle)
			Local IDrawUPos1#=IDrawXPos1*IDrawCenter
			Local IDrawVPos1#=IDrawYPos1*IDrawCenter
			Local IDrawUPos2#=IDrawXPos2*IDrawCenter
			Local IDrawVPos2#=IDrawYPos2*IDrawCenter
			
			;OVAL3D/QUARTAL(1/4)MIRROR
			Local IDrawV0%=AddVertex(LDrawFace,FDrawX+IDrawXPos1*IDrawXOutside,FDrawY+IDrawYPos1*IDrawYOutside,0 ,IDrawCenter+IDrawUPos1,IDrawCenter-IDrawVPos1)
			Local IDrawV1%=AddVertex(LDrawFace,FDrawX+IDrawXPos2*IDrawXOutside,FDrawY+IDrawYPos2*IDrawYOutside,0 ,IDrawCenter+IDrawUPos2,IDrawCenter-IDrawVPos2)
			Local IDrawV2%=AddVertex(LDrawFace,FDrawX+IDrawXPos2*IDrawXInside,FDrawY+IDrawYPos2*IDrawYInside,0 ,IDrawCenter-IDrawUPos2,IDrawCenter+IDrawVPos2)
			Local IDrawV3%=AddVertex(LDrawFace,FDrawX+IDrawXPos1*IDrawXInside,FDrawY+IDrawYPos1*IDrawYInside,0 ,IDrawCenter-IDrawUPos1,IDrawCenter+IDrawVPos1)
			VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV2,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV3,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			AddTriangle(LDrawFace,IDrawV0,IDrawV1,IDrawV2)
			AddTriangle(LDrawFace,IDrawV2,IDrawV3,IDrawV0)
			
			;OVAL3D/QUARTAL(2/4)MIRROR
			IDrawV0=AddVertex(LDrawFace,FDrawX+IDrawXPos1*IDrawXOutside,FDrawY-IDrawYPos1*IDrawYOutside,0 ,IDrawCenter+IDrawUPos1,IDrawCenter+IDrawVPos1)
			IDrawV1=AddVertex(LDrawFace,FDrawX+IDrawXPos2*IDrawXOutside,FDrawY-IDrawYPos2*IDrawYOutside,0 ,IDrawCenter+IDrawUPos2,IDrawCenter+IDrawVPos2)
			IDrawV2=AddVertex(LDrawFace,FDrawX+IDrawXPos2*IDrawXInside,FDrawY-IDrawYPos2*IDrawYInside,0 ,IDrawCenter-IDrawUPos2,IDrawCenter-IDrawVPos2)
			IDrawV3=AddVertex(LDrawFace,FDrawX+IDrawXPos1*IDrawXInside,FDrawY-IDrawYPos1*IDrawYInside,0 ,IDrawCenter-IDrawUPos1,IDrawCenter-IDrawVPos1)
			VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV2,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV3,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			AddTriangle(LDrawFace,IDrawV0,IDrawV1,IDrawV2)
			AddTriangle(LDrawFace,IDrawV2,IDrawV3,IDrawV0)
			
			;OVAL3D/QUARTAL(3/4)MIRROR
			IDrawV0=AddVertex(LDrawFace,FDrawX-IDrawXPos1*IDrawXOutside,FDrawY-IDrawYPos1*IDrawYOutside,0 ,IDrawCenter-IDrawUPos1,IDrawCenter+IDrawVPos1)
			IDrawV1=AddVertex(LDrawFace,FDrawX-IDrawXPos2*IDrawXOutside,FDrawY-IDrawYPos2*IDrawYOutside,0 ,IDrawCenter-IDrawUPos2,IDrawCenter+IDrawVPos2)
			IDrawV2=AddVertex(LDrawFace,FDrawX-IDrawXPos2*IDrawXInside,FDrawY-IDrawYPos2*IDrawYInside,0 ,IDrawCenter+IDrawUPos2,IDrawCenter-IDrawVPos2)
			IDrawV3=AddVertex(LDrawFace,FDrawX-IDrawXPos1*IDrawXInside,FDrawY-IDrawYPos1*IDrawYInside,0 ,IDrawCenter+IDrawUPos1,IDrawCenter-IDrawVPos1)
			VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV2,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV3,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			AddTriangle(LDrawFace,IDrawV0,IDrawV1,IDrawV2)
			AddTriangle(LDrawFace,IDrawV2,IDrawV3,IDrawV0)
			
			;OVAL3D/QUARTAL(4/4)MIRROR
			IDrawV0=AddVertex(LDrawFace,FDrawX-IDrawXPos1*IDrawXOutside,FDrawY+IDrawYPos1*IDrawYOutside,0 ,IDrawCenter-IDrawUPos1,IDrawCenter-IDrawVPos1)
			IDrawV1=AddVertex(LDrawFace,FDrawX-IDrawXPos2*IDrawXOutside,FDrawY+IDrawYPos2*IDrawYOutside,0 ,IDrawCenter-IDrawUPos2,IDrawCenter-IDrawVPos2)
			IDrawV2=AddVertex(LDrawFace,FDrawX-IDrawXPos2*IDrawXInside,FDrawY+IDrawYPos2*IDrawYInside,0 ,IDrawCenter+IDrawUPos2,IDrawCenter+IDrawVPos2)
			IDrawV3=AddVertex(LDrawFace,FDrawX-IDrawXPos1*IDrawXInside,FDrawY+IDrawYPos1*IDrawYInside,0 ,IDrawCenter+IDrawUPos1,IDrawCenter+IDrawVPos1)
			VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV2,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV3,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			AddTriangle(LDrawFace,IDrawV0,IDrawV1,IDrawV2)
			AddTriangle(LDrawFace,IDrawV2,IDrawV3,IDrawV0)
		Next
	Else
		
		;MITTELPUNKT/VERTEX/ZUWEISUNG
		Local IDrawVC%=AddVertex(LDrawFace,FDrawX,FDrawY,0 ,IDrawCenter,IDrawCenter)
		VertexColor LDrawFace,IDrawVC,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		
		;GEFÜLLT+HALBRAHMEN/MODUS
		If FDrawSize>0 Then
			IDrawXOutside=FDrawXS+FDrawSize
			IDrawYOutside=FDrawYS+FDrawSize
			For IDrawCount=1 To IDrawSequences
				
				;VERTEX/POLYGON/VEKTOREN
				IDrawXPos1=Cos(IDrawCount*IDrawAngle)
				IDrawYPos1=Sin(IDrawCount*IDrawAngle)
				IDrawXPos2=Cos(IDrawCount*IDrawAngle-IDrawAngle)
				IDrawYPos2=Sin(IDrawCount*IDrawAngle-IDrawAngle)
				IDrawUPos1=IDrawXPos1*IDrawCenter
				IDrawVPos1=IDrawYPos1*IDrawCenter
				IDrawUPos2=IDrawXPos2*IDrawCenter
				IDrawVPos2=IDrawYPos2*IDrawCenter
				
				;OVAL3D/QUARTAL(1/4)MIRROR
				IDrawV0=AddVertex(LDrawFace,FDrawX+IDrawXPos1*IDrawXOutside,FDrawY+IDrawYPos1*IDrawYOutside,0 ,IDrawCenter+IDrawUPos1,IDrawCenter-IDrawVPos1)
				IDrawV1=AddVertex(LDrawFace,FDrawX+IDrawXPos2*IDrawXOutside,FDrawY+IDrawYPos2*IDrawYOutside,0 ,IDrawCenter+IDrawUPos2,IDrawCenter-IDrawVPos2)
				IDrawV2=AddVertex(LDrawFace,FDrawX+IDrawXPos2*FDrawXS,FDrawY+IDrawYPos2*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				IDrawV3=AddVertex(LDrawFace,FDrawX+IDrawXPos1*FDrawXS,FDrawY+IDrawYPos1*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV2,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV3,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				AddTriangle(LDrawFace,IDrawV0,IDrawV1,IDrawV2)
				AddTriangle(LDrawFace,IDrawV2,IDrawV3,IDrawV0)
				AddTriangle(LDrawFace,IDrawVC,IDrawV3,IDrawV2)
				
				;OVAL3D/QUARTAL(2/4)MIRROR
				IDrawV0=AddVertex(LDrawFace,FDrawX+IDrawXPos1*IDrawXOutside,FDrawY-IDrawYPos1*IDrawYOutside,0 ,IDrawCenter+IDrawUPos1,IDrawCenter+IDrawVPos1)
				IDrawV1=AddVertex(LDrawFace,FDrawX+IDrawXPos2*IDrawXOutside,FDrawY-IDrawYPos2*IDrawYOutside,0 ,IDrawCenter+IDrawUPos2,IDrawCenter+IDrawVPos2)
				IDrawV2=AddVertex(LDrawFace,FDrawX+IDrawXPos2*FDrawXS,FDrawY-IDrawYPos2*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				IDrawV3=AddVertex(LDrawFace,FDrawX+IDrawXPos1*FDrawXS,FDrawY-IDrawYPos1*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV2,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV3,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				AddTriangle(LDrawFace,IDrawV0,IDrawV1,IDrawV2)
				AddTriangle(LDrawFace,IDrawV2,IDrawV3,IDrawV0)
				AddTriangle(LDrawFace,IDrawVC,IDrawV3,IDrawV2)
				
				;OVAL3D/QUARTAL(3/4)MIRROR
				IDrawV0=AddVertex(LDrawFace,FDrawX-IDrawXPos1*IDrawXOutside,FDrawY-IDrawYPos1*IDrawYOutside,0 ,IDrawCenter-IDrawUPos1,IDrawCenter+IDrawVPos1)
				IDrawV1=AddVertex(LDrawFace,FDrawX-IDrawXPos2*IDrawXOutside,FDrawY-IDrawYPos2*IDrawYOutside,0 ,IDrawCenter-IDrawUPos2,IDrawCenter+IDrawVPos2)
				IDrawV2=AddVertex(LDrawFace,FDrawX-IDrawXPos2*FDrawXS,FDrawY-IDrawYPos2*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				IDrawV3=AddVertex(LDrawFace,FDrawX-IDrawXPos1*FDrawXS,FDrawY-IDrawYPos1*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV2,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV3,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				AddTriangle(LDrawFace,IDrawV0,IDrawV1,IDrawV2)
				AddTriangle(LDrawFace,IDrawV2,IDrawV3,IDrawV0)
				AddTriangle(LDrawFace,IDrawVC,IDrawV3,IDrawV2)
				
				;OVAL3D/QUARTAL(4/4)MIRROR
				IDrawV0=AddVertex(LDrawFace,FDrawX-IDrawXPos1*IDrawXOutside,FDrawY+IDrawYPos1*IDrawYOutside,0 ,IDrawCenter-IDrawUPos1,IDrawCenter-IDrawVPos1)
				IDrawV1=AddVertex(LDrawFace,FDrawX-IDrawXPos2*IDrawXOutside,FDrawY+IDrawYPos2*IDrawYOutside,0 ,IDrawCenter-IDrawUPos2,IDrawCenter-IDrawVPos2)
				IDrawV2=AddVertex(LDrawFace,FDrawX-IDrawXPos2*FDrawXS,FDrawY+IDrawYPos2*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				IDrawV3=AddVertex(LDrawFace,FDrawX-IDrawXPos1*FDrawXS,FDrawY+IDrawYPos1*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV2,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV3,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				AddTriangle(LDrawFace,IDrawV0,IDrawV1,IDrawV2)
				AddTriangle(LDrawFace,IDrawV2,IDrawV3,IDrawV0)
				AddTriangle(LDrawFace,IDrawVC,IDrawV3,IDrawV2)
			Next
		Else
			
			;GEFÜLLT/ALLEIN/MODUS
			For IDrawCount=1 To IDrawSequences
				
				;VERTEX/POLYGON/VEKTOREN
				IDrawXPos1=Cos(IDrawCount*IDrawAngle)
				IDrawYPos1=Sin(IDrawCount*IDrawAngle)
				IDrawXPos2=Cos(IDrawCount*IDrawAngle-IDrawAngle)
				IDrawYPos2=Sin(IDrawCount*IDrawAngle-IDrawAngle)
				
				;OVAL3D/QUARTAL(1/4)MIRROR
				IDrawV0=AddVertex(LDrawFace,FDrawX+IDrawXPos1*FDrawXS,FDrawY+IDrawYPos1*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				IDrawV1=AddVertex(LDrawFace,FDrawX+IDrawXPos2*FDrawXS,FDrawY+IDrawYPos2*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				AddTriangle(LDrawFace,IDrawVC,IDrawV1,IDrawV0)
				
				;OVAL3D/QUARTAL(2/4)MIRROR
				IDrawV0=AddVertex(LDrawFace,FDrawX+IDrawXPos1*FDrawXS,FDrawY-IDrawYPos1*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				IDrawV1=AddVertex(LDrawFace,FDrawX+IDrawXPos2*FDrawXS,FDrawY-IDrawYPos2*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				AddTriangle(LDrawFace,IDrawVC,IDrawV1,IDrawV0)
				
				;OVAL3D/QUARTAL(3/4)MIRROR
				IDrawV0=AddVertex(LDrawFace,FDrawX-IDrawXPos1*FDrawXS,FDrawY-IDrawYPos1*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				IDrawV1=AddVertex(LDrawFace,FDrawX-IDrawXPos2*FDrawXS,FDrawY-IDrawYPos2*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				AddTriangle(LDrawFace,IDrawVC,IDrawV1,IDrawV0)
				
				;OVAL3D/QUARTAL(4/4)MIRROR
				IDrawV0=AddVertex(LDrawFace,FDrawX-IDrawXPos1*FDrawXS,FDrawY+IDrawYPos1*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				IDrawV1=AddVertex(LDrawFace,FDrawX-IDrawXPos2*FDrawXS,FDrawY+IDrawYPos2*FDrawYS,0 ,IDrawCenter,IDrawCenter)
				VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
				AddTriangle(LDrawFace,IDrawVC,IDrawV1,IDrawV0)
			Next
		End If
	End If
	
	
	
	
End Function
Function Plot3D(FDrawHandle%,FDrawX#,FDrawY#,FDrawSize#=2)
	
	
	
	
	;PARAMETER/VORREINIGUNG
	If FDrawSize=0 Then FDrawSize=2
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE)
	Local LDrawMeas%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKMEAS)
	
	;VERTEX/POLYGON/ZUWEISUNGEN
	Local IDrawV0%=AddVertex(LDrawFace,FDrawX-FDrawSize,FDrawY+FDrawSize,0 ,0,0)
	Local IDrawV1%=AddVertex(LDrawFace,FDrawX+FDrawSize,FDrawY+FDrawSize,0 ,LDrawMeas,0)
	Local IDrawV2%=AddVertex(LDrawFace,FDrawX+FDrawSize,FDrawY-FDrawSize,0 ,LDrawMeas,LDrawMeas)
	Local IDrawV3%=AddVertex(LDrawFace,FDrawX-FDrawSize,FDrawY-FDrawSize,0 ,0,LDrawMeas)
	VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
	VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
	VertexColor LDrawFace,IDrawV2,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
	VertexColor LDrawFace,IDrawV3,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
	AddTriangle(LDrawFace,IDrawV0,IDrawV1,IDrawV2)
	AddTriangle(LDrawFace,IDrawV2,IDrawV3,IDrawV0)
	
	
	
	
End Function
Function Poly3D(FDrawHandle%,FDrawX1#,FDrawY1#,FDrawX2#,FDrawY2#,FDrawX3#,FDrawY3#)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE)
	Local LDrawMeas%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKMEAS)
	
	;VARIABLEN/VORBERECHNUNGEN
	Local IDrawCenter%=LDrawMeas/2
	
	;VERTEX/POLYGON/ZUWEISUNGEN
	Local IDrawV0%=AddVertex(LDrawFace,FDrawX1,FDrawY1,0 ,IDrawCenter,IDrawCenter)
	Local IDrawV1%=AddVertex(LDrawFace,FDrawX2,FDrawY2,0 ,IDrawCenter,IDrawCenter)
	Local IDrawV2%=AddVertex(LDrawFace,FDrawX3,FDrawY3,0 ,IDrawCenter,IDrawCenter)
	VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
	VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
	VertexColor LDrawFace,IDrawV2,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
	AddTriangle(LDrawFace,IDrawV0,IDrawV1,IDrawV2)
	
	
	
	
End Function
Function Rect3D(FDrawHandle%,FDrawX#,FDrawY#,FDrawXS#,FDrawYS#,FDrawFill%=1,FDrawSize#=0)
	
	
	
	
	;FACEBANK(AUS)WEISUNGEN
	Local LDrawFace%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKFACE)
	Local LDrawMeas%=PeekInt(GDrawFaceBank,FDrawHandle+DRAWBANKMEAS)
	
	;PARAMETER/VORREINIGUNG
	FDrawXS=Abs(FDrawXS)
	FDrawYS=Abs(FDrawYS)
	
	;VARIABLEN/VORBERECHNUNGEN
	Local IDrawCenter%=LDrawMeas/2
	
	;RAHMEN/ALLEIN/MODUS
	If FDrawFill=0 Then
		
		;PARAMETER/VORREINIGUNG
		If FDrawSize=0 Then FDrawSize=2
		
		;VERTEX/POLYGON/ZUWEISUNGEN
		Local IDrawV0%=AddVertex(LDrawFace,FDrawX-FDrawXS-FDrawSize,FDrawY+FDrawYS+FDrawSize,0 ,IDrawCenter,0)
		Local IDrawV1%=AddVertex(LDrawFace,FDrawX+FDrawXS+FDrawSize,FDrawY+FDrawYS+FDrawSize,0 ,IDrawCenter,0)
		Local IDrawV2%=AddVertex(LDrawFace,FDrawX+FDrawXS-FDrawSize,FDrawY+FDrawYS-FDrawSize,0 ,IDrawCenter,LDrawMeas)
		Local IDrawV3%=AddVertex(LDrawFace,FDrawX-FDrawXS+FDrawSize,FDrawY+FDrawYS-FDrawSize,0 ,IDrawCenter,LDrawMeas)
		Local IDrawV4%=AddVertex(LDrawFace,FDrawX+FDrawXS+FDrawSize,FDrawY+FDrawYS+FDrawSize,0 ,LDrawMeas,IDrawCenter)
		Local IDrawV5%=AddVertex(LDrawFace,FDrawX+FDrawXS+FDrawSize,FDrawY-FDrawYS-FDrawSize,0 ,LDrawMeas,IDrawCenter)
		Local IDrawV6%=AddVertex(LDrawFace,FDrawX+FDrawXS-FDrawSize,FDrawY-FDrawYS+FDrawSize,0 ,0,IDrawCenter)
		Local IDrawV7%=AddVertex(LDrawFace,FDrawX+FDrawXS-FDrawSize,FDrawY+FDrawYS-FDrawSize,0 ,0,IDrawCenter)
		Local IDrawV8%=AddVertex(LDrawFace,FDrawX+FDrawXS+FDrawSize,FDrawY-FDrawYS-FDrawSize,0 ,IDrawCenter,LDrawMeas)
		Local IDrawV9%=AddVertex(LDrawFace,FDrawX-FDrawXS-FDrawSize,FDrawY-FDrawYS-FDrawSize,0 ,IDrawCenter,LDrawMeas)
		Local IDrawVA%=AddVertex(LDrawFace,FDrawX-FDrawXS+FDrawSize,FDrawY-FDrawYS+FDrawSize,0 ,IDrawCenter,0)
		Local IDrawVB%=AddVertex(LDrawFace,FDrawX+FDrawXS-FDrawSize,FDrawY-FDrawYS+FDrawSize,0 ,IDrawCenter,0)
		Local IDrawVC%=AddVertex(LDrawFace,FDrawX-FDrawXS-FDrawSize,FDrawY-FDrawYS-FDrawSize,0 ,0,IDrawCenter)
		Local IDrawVD%=AddVertex(LDrawFace,FDrawX-FDrawXS-FDrawSize,FDrawY+FDrawYS+FDrawSize,0 ,0,IDrawCenter)
		Local IDrawVE%=AddVertex(LDrawFace,FDrawX-FDrawXS+FDrawSize,FDrawY+FDrawYS-FDrawSize,0 ,LDrawMeas,IDrawCenter)
		Local IDrawVF%=AddVertex(LDrawFace,FDrawX-FDrawXS+FDrawSize,FDrawY-FDrawYS+FDrawSize,0 ,LDrawMeas,IDrawCenter)
		VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawV2,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawV3,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawV4,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawV5,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawV6,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawV7,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawV8,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawV9,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawVA,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawVB,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawVC,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawVD,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawVE,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawVF,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		AddTriangle(LDrawFace,IDrawV0,IDrawV1,IDrawV2)
		AddTriangle(LDrawFace,IDrawV2,IDrawV3,IDrawV0)
		AddTriangle(LDrawFace,IDrawV4,IDrawV5,IDrawV6)
		AddTriangle(LDrawFace,IDrawV6,IDrawV7,IDrawV4)
		AddTriangle(LDrawFace,IDrawV8,IDrawV9,IDrawVA)
		AddTriangle(LDrawFace,IDrawVA,IDrawVB,IDrawV8)
		AddTriangle(LDrawFace,IDrawVC,IDrawVD,IDrawVE)
		AddTriangle(LDrawFace,IDrawVE,IDrawVF,IDrawVC)
	Else
		
		;VERTEX/POLYGON/GEFÜLLT/ALLEIN
		IDrawV0=AddVertex(LDrawFace,FDrawX-FDrawXS,FDrawY+FDrawYS,0 ,IDrawCenter,IDrawCenter)
		IDrawV1=AddVertex(LDrawFace,FDrawX+FDrawXS,FDrawY+FDrawYS,0 ,IDrawCenter,IDrawCenter)
		IDrawV2=AddVertex(LDrawFace,FDrawX+FDrawXS,FDrawY-FDrawYS,0 ,IDrawCenter,IDrawCenter)
		IDrawV3=AddVertex(LDrawFace,FDrawX-FDrawXS,FDrawY-FDrawYS,0 ,IDrawCenter,IDrawCenter)
		VertexColor LDrawFace,IDrawV0,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawV1,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawV2,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		VertexColor LDrawFace,IDrawV3,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
		AddTriangle(LDrawFace,IDrawV0,IDrawV1,IDrawV2)
		AddTriangle(LDrawFace,IDrawV2,IDrawV3,IDrawV0)
		
		;HALBRAHMEN/HINZUFÜGEN
		If FDrawSize>0 Then
			
			;VERTEX/POLYGON/ZUWEISUNGEN
			IDrawV4=AddVertex(LDrawFace,FDrawX-FDrawXS-FDrawSize,FDrawY+FDrawYS+FDrawSize,0 ,IDrawCenter,0)
			IDrawV5=AddVertex(LDrawFace,FDrawX+FDrawXS+FDrawSize,FDrawY+FDrawYS+FDrawSize,0 ,IDrawCenter,0)
			IDrawV6=AddVertex(LDrawFace,FDrawX+FDrawXS+FDrawSize,FDrawY+FDrawYS+FDrawSize,0 ,LDrawMeas,IDrawCenter)
			IDrawV7=AddVertex(LDrawFace,FDrawX+FDrawXS+FDrawSize,FDrawY-FDrawYS-FDrawSize,0 ,LDrawMeas,IDrawCenter)
			IDrawV8=AddVertex(LDrawFace,FDrawX+FDrawXS+FDrawSize,FDrawY-FDrawYS-FDrawSize,0 ,IDrawCenter,LDrawMeas)
			IDrawV9=AddVertex(LDrawFace,FDrawX-FDrawXS-FDrawSize,FDrawY-FDrawYS-FDrawSize,0 ,IDrawCenter,LDrawMeas)
			IDrawVA=AddVertex(LDrawFace,FDrawX-FDrawXS-FDrawSize,FDrawY-FDrawYS-FDrawSize,0 ,0,IDrawCenter)
			IDrawVB=AddVertex(LDrawFace,FDrawX-FDrawXS-FDrawSize,FDrawY+FDrawYS+FDrawSize,0 ,0,IDrawCenter)
			VertexColor LDrawFace,IDrawV4,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV5,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV6,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV7,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV8,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawV9,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawVA,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			VertexColor LDrawFace,IDrawVB,GDrawNFR,GDrawNFG,GDrawNFB,GDrawNFA
			AddTriangle(LDrawFace,IDrawV4,IDrawV5,IDrawV1)
			AddTriangle(LDrawFace,IDrawV1,IDrawV0,IDrawV4)
			AddTriangle(LDrawFace,IDrawV6,IDrawV7,IDrawV2)
			AddTriangle(LDrawFace,IDrawV2,IDrawV1,IDrawV6)
			AddTriangle(LDrawFace,IDrawV8,IDrawV9,IDrawV3)
			AddTriangle(LDrawFace,IDrawV3,IDrawV2,IDrawV8)
			AddTriangle(LDrawFace,IDrawVA,IDrawVB,IDrawV0)
			AddTriangle(LDrawFace,IDrawV0,IDrawV3,IDrawVA)
		End If
	End If
	
	
	
	
End Function

;~IDEal Editor Parameters:
;~F#F#6C#80#90#A7#BE#CE#11E#153#162#171#187#1C2#225#23C#24B#25A#373#39B#3F9
;~F#470#4C1#503#545#557#5A0#5EF#60F#634#719#740#789#7AF#7D9#7EB#87A#943#96A#979#998
;~F#9AA#9BB#9CA#9F8#A07#A49#B3E#BAD#BBC#BD8#BF6#C05#C14#C3C#D09#D25#D3E
;~C#Blitz3D