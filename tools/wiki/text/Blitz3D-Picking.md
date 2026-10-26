## EntityPickMode
Makes an entity pickable and chooses what shape the pick commands test against. Entities are not pickable by default (mode 0). Pick commands only ever report entities that have a mode, and they ignore hidden entities.

| Mode | Shape |
|---|---|
| 0 | Not pickable. |
| 1 | Sphere, using the [EntityRadius](Blitz3D-Collisions#entityradius). |
| 2 | The triangles of the mesh. |
| 3 | Box, using the [EntityBox](Blitz3D-Collisions#entitybox). |

The `obscurer` argument only matters for [EntityVisible](Blitz3D-Picking#entityvisible). An obscurer blocks the line of sight; an entity that is pickable but not an obscurer can be hit by the other pick commands yet is looked through by EntityVisible, which suits things like glass or trigger volumes.

Sprites can only be picked with the sphere or box mode, because they have no mesh triangles.
@param entity         The entity.
@param pick_geometry  Shape to test, 0 to 3.
@param obscurer       True if the entity blocks EntityVisible. Defaults to True.

## CameraPick
Finds the entity that appears at a pixel of a camera's view, which is how you select things with the mouse. The coordinates are in pixels of the camera's viewport, like [MouseX](BlitzBasic-Mouse#mousex) and [MouseY](BlitzBasic-Mouse#mousey) give them, with 0, 0 at the top left. The ray runs as far as the camera's far range.

Only entities with an [EntityPickMode](Blitz3D-Picking#entitypickmode) are found. Afterwards [PickedX](Blitz3D-Picking#pickedx), [PickedEntity](Blitz3D-Picking#pickedentity) and the other Picked commands describe the hit.

```blitzbasic
;media still picking/camerapick.png
Graphics3D 320, 240, 0, 2
SetBuffer BackBuffer()
camera = CreateCamera()
CameraClsColor camera, 50, 70, 110
light = CreateLight()
RotateEntity light, 40, 30, 0

; Three pickable cubes.
For i = 0 To 2
	cube = CreateCube()
	PositionEntity cube, -2.5 + i * 2.5, 0, 6
	TurnEntity cube, 20, 25 + i * 20, 0
	EntityPickMode cube, 2
	EntityColor cube, 200, 200, 200
Next

; Pick what is under a point and tint it red.
hit = CameraPick(camera, 160, 120)
If hit Then EntityColor hit, 230, 60, 60

RenderWorld
Color 255, 255, 255
Rect 154, 119, 13, 1, 1
Rect 160, 113, 1, 13, 1
If hit
	Text 8, 8, "Picked entity " + hit
	Text 8, 24, "Point " + Int(PickedX() * 100) / 100.0 + ", " + Int(PickedY() * 100) / 100.0 + ", " + Int(PickedZ() * 100) / 100.0
Else
	Text 8, 8, "Nothing picked"
EndIf
Flip
WaitKey
```

![CameraPick](media/picking/camerapick.png)
@param camera      The camera whose view is used.
@param viewport_x  Horizontal pixel position inside the camera's viewport.
@param viewport_y  Vertical pixel position inside the camera's viewport.
@returns The entity found, or 0 if there was none.

## LinePick
Looks along a line from a start point in a direction and returns the first pickable entity it meets. The direction is not normalized: the line ends where `x + dx, y + dy, z + dz` ends, so longer vectors look further. With a radius greater than 0 the line becomes a thick tube, which finds things that a hairline would slip past.

```blitzbasic
Graphics3D 320, 240, 0, 2
SetBuffer BackBuffer()
camera = CreateCamera()

wall = CreateCube()
PositionEntity wall, 0, 0, 10
EntityPickMode wall, 2

; Shoot a line from the camera straight ahead, 20 units long.
hit = LinePick(0, 0, 0, 0, 0, 20)
If hit = wall Then
	Text 8, 8, "Hit the wall at z = " + PickedZ()
	Text 8, 24, "Surface normal: " + PickedNX() + ", " + PickedNY() + ", " + PickedNZ()
Else
	Text 8, 8, "Nothing there"
EndIf
Flip
WaitKey
```

@param x       Start X in world coordinates.
@param y       Start Y.
@param z       Start Z.
@param dx      How far the line goes along X.
@param dy      How far the line goes along Y.
@param dz      How far the line goes along Z.
@param radius  Thickness of the line. Defaults to 0.
@returns The entity found, or 0.
@gap The radius widens the line only against entities that are picked as a sphere. Against polygon and box picking it behaves like a line of no thickness, whereas the original also thickens those.

## EntityPick
Looks straight ahead along the entity's own Z axis, as far as the range, and returns the first pickable entity. The entity itself is never found. Use it for shots fired from a gun entity or for "what am I facing" checks. The range is multiplied by the entity's Z scale, so a scaled entity looks proportionally further.
@param entity  The entity that looks.
@param range   Distance to look, in world units.
@returns The entity found, or 0.

## EntityVisible
Tells whether two entities have a clear line of sight between their origins. Every entity with a pick mode that is an obscurer, see [EntityPickMode](Blitz3D-Picking#entitypickmode), blocks the view; the two entities themselves and hidden entities never do.

```blitzbasic
Graphics3D 320, 240, 0, 2
SetBuffer BackBuffer()

guard = CreatePivot()
PositionEntity guard, 0, 0, -6
thief = CreatePivot()
PositionEntity thief, 0, 0, 6

crate = CreateCube()
EntityPickMode crate, 2

If EntityVisible(guard, thief)
	Text 8, 8, "The guard sees the thief"
Else
	Text 8, 8, "The crate is in the way"
EndIf
Flip
WaitKey
```

@param src_entity   The entity that looks.
@param dest_entity  The entity it looks at.
@returns True if nothing in the way blocks the line, otherwise False.

## PickedEntity
@returns The entity that the latest [CameraPick](Blitz3D-Picking#camerapick), [EntityPick](Blitz3D-Picking#entitypick) or [LinePick](Blitz3D-Picking#linepick) found, or 0 if it found nothing.

## PickedX
@returns The world X coordinate of the exact point where the latest pick touched an entity. Only meaningful after a pick that hit something; after a miss it keeps the value of the last hit.

## PickedY
@returns The world Y coordinate of the point where the latest pick touched an entity.

## PickedZ
@returns The world Z coordinate of the point where the latest pick touched an entity.

## PickedNX
@returns The X part of the surface normal at the picked point: a direction of length 1 that points out of the surface, towards the side the line came from.

## PickedNY
@returns The Y part of the surface normal at the picked point.

## PickedNZ
@returns The Z part of the surface normal at the picked point.

## PickedTime
@returns How far along the line the hit was, from 0 at its start to 1 at its end. After a pick that found nothing the value is 1.
@gap The official help describes this as the time taken to calculate the pick. As in the original engine, the value is the fraction along the line described above.

## PickedSurface
@returns The handle of the surface that the latest pick hit, usable with the surface commands. It is 0 when the entity was picked as a sphere or box.

## PickedTriangle
@returns The number of the triangle that the latest pick hit, in the surface from PickedSurface. Triangle numbers start at 0. It is 0 when the entity was picked as a sphere or box.
