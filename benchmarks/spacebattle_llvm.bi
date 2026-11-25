; BlitzLLVM side of the space battle benchmark, next to bench_llvm.bi: physics. The debris of a ship that dies are dynamic bodies
; without gravity; the asteroids and the hubs of the stations are static bodies they bump into.

Function BenchPhysics()
	Return 1
End Function

Function BenchPhysicsInit()
	PhysicsGravity 0, 0, 0
	PhysicsDeterministic True
End Function

Function BenchPhysicsStation(x#, y#, z#)
	body = CreatePhysicsBody(2, 1, 32, 0, 0)
	PositionEntity body, x, y, z
End Function

Function BenchPhysicsAsteroid(x#, y#, z#, radius#)
	body = CreatePhysicsBody(2, 1, radius, 0, 0)
	PositionEntity body, x, y, z
End Function

; A piece of debris, moving at vx, vy, vz units per frame (60 frames a second for the simulation).
Function BenchDebrisCreate(template, x#, y#, z#, vx#, vy#, vz#)
	body = CreatePhysicsBody(1, 3, 0.8, 0.5, 1.2)
	PositionEntity body, x, y, z
	mesh = CopyEntity(template, body)
	ShowEntity mesh
	PhysicsLinearVelocity body, vx * 60, vy * 60, vz * 60, True
	PhysicsAngularVelocity body, vy * 200, vz * 200, vx * 200, True
	Return body
End Function

; The simulation moves the debris.
Function BenchDebrisMove(entity, vx#, vy#, vz#, spin#)
End Function

Function BenchPhysicsUpdate()
	PhysicsUpdate 1.0 / 60
End Function
