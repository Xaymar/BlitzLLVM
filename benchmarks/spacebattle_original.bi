; Original Blitz3D side of the space battle benchmark, next to bench_original.bi: there is no physics, so the debris of a ship that
; dies fly in straight lines and turn, through everything.

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
