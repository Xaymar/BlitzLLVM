; Original Blitz3D side of the space battle benchmark: the timer has milliseconds only, there are no draw counters (0) and no
; physics, so the debris of a ship that dies fly in straight lines and turn, through everything.

Function BenchMicros()
	Return MilliSecs() * 1000
End Function

Function BenchDraws()
	Return 0
End Function

Function BenchFlip()
	Flip 0
End Function

Function BenchPhysics()
	Return 0
End Function

Function BenchPhysicsInit()
End Function

Function BenchPhysicsStation(x#, y#, z#)
End Function

Function BenchPhysicsAsteroid(x#, y#, z#, radius#)
End Function

Function BenchDebrisCreate(template, x#, y#, z#, vx#, vy#, vz#)
	mesh = CopyEntity(template)
	ShowEntity mesh
	PositionEntity mesh, x, y, z
	Return mesh
End Function

Function BenchDebrisMove(entity, vx#, vy#, vz#, spin#)
	TranslateEntity entity, vx, vy, vz
	TurnEntity entity, spin, spin * 0.7, 0
End Function

Function BenchPhysicsUpdate()
End Function
