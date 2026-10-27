; draw3d2.decls
; In den Ordner  Blitz3D\userlibs\  kopieren, danach die Blitz3D-IDE neu starten.
; Draw3D2 (hectic) fragt damit die Mausposition und das Fensterrechteck ab.
; Die Pointer-Parameter werden als Bank uebergeben (Typ *).

.lib "user32.dll"

Draw3D2_GCP%(pPoint*):"GetCursorPos"
Draw3D2_GWR%(hWnd%, pRect*):"GetWindowRect"
