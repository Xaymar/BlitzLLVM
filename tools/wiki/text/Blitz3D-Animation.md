## Animate
Starts, changes or stops the skeletal or keyframe animation of an entity, such as a character loaded with [LoadAnimMesh](Blitz3D-Meshes#loadanimmesh). The animation then advances every time [UpdateWorld](Blitz3D-World#updateworld) runs. Entities that have no animation ignore the call.

| Mode | Behavior |
|---|---|
| 0 | Stop. |
| 1 | Loop, jumping back to the start when the end is reached. This is the default. |
| 2 | Ping-pong: play to the end, then backwards to the start, and so on. |
| 3 | One-shot: play once and then stop at the last frame. |

A negative speed plays the sequence backwards. A model has sequence 0 after loading; more sequences come from [LoadAnimSeq](Blitz3D-Animation#loadanimseq), [AddAnimSeq](Blitz3D-Animation#addanimseq) and [ExtractAnimSeq](Blitz3D-Animation#extractanimseq). Calling Animate again with the same mode and sequence only changes the speed and does not restart the animation.

```blitzbasic
Graphics3D 320, 240, 0, 2
SetBuffer BackBuffer()
camera = CreateCamera()
light = CreateLight()
RotateEntity light, 40, 30, 0

; A box that slides to the right and back, described with two keys.
box = CreateCube()
PositionEntity box, -2, 0, 6 : SetAnimKey box, 0
PositionEntity box, 2, 0, 6 : SetAnimKey box, 30
AddAnimSeq box, 30

Animate box, 2, 1
While Not KeyHit(1)
	UpdateWorld
	RenderWorld
	Text 8, 8, "Time " + AnimTime(box)
	Flip
Wend
```

@param entity      The entity to animate.
@param mode        0 stop, 1 loop, 2 ping-pong, 3 one-shot. Defaults to 1.
@param speed       Playback speed, negative for backwards. Defaults to 1.
@param sequence    Number of the sequence to play. Defaults to 0.
@param transition  Frames to blend from the current pose to the first frame. Defaults to 0.
@gap The transition argument is accepted but ignored: the entity jumps to the first frame of the new animation.
@gap The original moves an animation by one frame per UpdateWorld call at speed 1. Here the animation follows the clock: at speed 1 it plays 60 frames per second (or the frame rate stored in the model file), however often UpdateWorld runs. A single slow update never advances more than a tenth of a second.

## Animating
@returns True while the entity is playing an animation, and False when it is stopped, has finished a one-shot animation or has no animation at all.
@param entity  The entity.

## AnimSeq
@returns The number of the sequence that the entity is playing or was last set to, starting at 0.
@param entity  The entity.

## AnimLength
@returns The length of the entity's current sequence, in frames. It is 0 for an entity that has no animation.
@param entity  The entity.

## AnimTime
@returns How far into the current sequence the animation is, in frames. The value starts at 0 at the beginning of the sequence and can have a fractional part between two frames.
@param entity  The entity.

## SetAnimTime
Poses the entity at a point in time of a sequence without playing it. This is for animating by hand, for example to scrub through an animation with a slider or to show frame 10 of a pose. It also makes the given sequence the current one.

```blitzbasic
;media gif animation/setanimtime.gif 40 20
Graphics3D 320, 240, 0, 2
SetBuffer BackBuffer()
camera = CreateCamera()
CameraClsColor camera, 70, 100, 160
light = CreateLight()
RotateEntity light, 40, 30, 0

; Keys at frames 0, 10 and 20 move and turn a cube.
cube = CreateCube()
EntityColor cube, 240, 170, 60
PositionEntity cube, -2, 0, 6
RotateEntity cube, 20, 0, 0
SetAnimKey cube, 0
PositionEntity cube, 2, 1, 6
RotateEntity cube, 20, 180, 0
SetAnimKey cube, 10
PositionEntity cube, -2, 0, 6
RotateEntity cube, 20, 360, 0
SetAnimKey cube, 20
AddAnimSeq cube, 20

For frame = 0 To 39
	SetAnimTime cube, frame / 2.0
	RenderWorld
	Flip
Next
```

![SetAnimTime](media/animation/setanimtime.gif)
@param entity    The entity.
@param time      Time in frames from the start of the sequence.
@param anim_seq  Sequence to pose, defaults to 0.

## SetAnimKey
Records the entity's current position, rotation and scale as a keyframe at the given frame. After the keys are made, [AddAnimSeq](Blitz3D-Animation#addanimseq) turns them into a sequence that [Animate](Blitz3D-Animation#animate) and [SetAnimTime](Blitz3D-Animation#setanimtime) can play, with the frames between the keys interpolated. Use it on the bones of a hand-built model or on any entity that you want to animate by keys.

Each of the three flags decides which part of the pose is stored. Setting a key again at the same frame replaces the old one.
@param entity     The entity whose pose is recorded.
@param frame      Frame number of the key, starting at 0.
@param pos_key    True to store the position. Defaults to True.
@param rot_key    True to store the rotation. Defaults to True.
@param scale_key  True to store the scale. Defaults to True.

## AddAnimSeq
Turns the keys made with [SetAnimKey](Blitz3D-Animation#setanimkey) into a new animation sequence of the given length, for the entity and everything below it. If the entity had no animation before, it gets sequence 0; otherwise the new sequence is appended behind the existing ones and gets the next number.
@param entity  The entity.
@param length  Length of the sequence in frames.
@returns The number of the new sequence.

## ExtractAnimSeq
Cuts a range of frames out of an existing sequence and makes it a sequence of its own, which is how you split one long animation, as MD2 files and many exporters produce, into walk, run and idle clips that can each be played with [Animate](Blitz3D-Animation#animate).

```blitzbasic
; Split a long animation into clips; the frame numbers come from your model.
Graphics3D 320, 240, 0, 2
SetBuffer BackBuffer()
camera = CreateCamera()
light = CreateLight()

hero = LoadAnimMesh("hero.b3d")
PositionEntity hero, 0, -1, 5

walk = ExtractAnimSeq(hero, 1, 30)
run = ExtractAnimSeq(hero, 31, 50)
Animate hero, 1, 1, walk

While Not KeyHit(1)
	If KeyHit(57) Then Animate hero, 1, 1, run
	UpdateWorld
	RenderWorld
	Flip
Wend
```

@param entity      The animated entity.
@param first_frame  First frame of the clip.
@param last_frame   Last frame of the clip.
@param anim_seq     Sequence to take the frames from. Defaults to 0.
@returns The number of the new sequence, or -1 if the entity has no animation.
@gap An entity without animation gives 0 here, not -1.

## LoadAnimSeq
Loads the animation of a second file, such as a separate walk cycle, and appends it to an entity as a new sequence. The file must have the same bones as the model it is added to.

```blitzbasic
Graphics3D 320, 240, 0, 2
SetBuffer BackBuffer()
camera = CreateCamera()
light = CreateLight()

hero = LoadAnimMesh("hero.b3d")
PositionEntity hero, 0, -1, 5
jump = LoadAnimSeq(hero, "hero_jump.b3d")
Animate hero, 3, 1, jump

While Not KeyHit(1)
	UpdateWorld
	RenderWorld
	Flip
Wend
```

@param entity    The entity that receives the sequence.
@param file      File with the animation, for example a .b3d.
@returns The number of the new sequence, which is also the highest sequence number the entity has. If the file cannot be read nothing is added and the number of the last existing sequence comes back; -1 means the entity has no animation.

## LoadMD2
Loads a Quake 2 model (.md2). The model is made of a single mesh that moves from frame to frame, so it has its own commands, [AnimateMD2](Blitz3D-Animation#animatemd2) and the MD2Anim commands, and does not work with the other animation commands. The picture of the model is a separate file: load it with [LoadTexture](Blitz3D-Textures#loadtexture) and give it to the model with [EntityTexture](Blitz3D-Entities#entitytexture), otherwise the model is not textured.

A parent makes the model follow another entity. The model is still created at 0, 0, 0 and not at the parent's position, and moving the model does not move the parent.

Case matters for file names on Linux, so use the exact spelling of the files.

```blitzbasic
;media gif animation/loadmd2.gif 40 20
; Uses the Gargoyle model of the Blitz3D samples, which are run from the folder that contains "media".
Graphics3D 320, 240, 0, 2
SetBuffer BackBuffer()
camera = CreateCamera()
CameraClsColor camera, 70, 100, 160
light = CreateLight()
RotateEntity light, 40, 30, 0

gargoyle = LoadMD2("media/Gargoyle/Gargoyle.md2")
skin = LoadTexture("media/Gargoyle/Gargoyle.bmp")
EntityTexture gargoyle, skin
PositionEntity gargoyle, 0, -30, 100
RotateEntity gargoyle, 0, 160, 0

AnimateMD2 gargoyle, 1, 1, 1, 40
For i = 0 To 39
	UpdateWorld
	RenderWorld
	Delay 50
	Flip
Next
```

![LoadMD2](media/animation/loadmd2.gif)
@param file      The .md2 file.
@param parent    Optional parent entity.
@returns An entity handle, or 0 if the file could not be loaded.

## AnimateMD2
Plays frames of an MD2 model. The model moves on while [UpdateWorld](Blitz3D-World#updateworld) runs, and the frames between the first and the last are blended smoothly. The mode values are the same as for [Animate](Blitz3D-Animation#animate): 0 stop, 1 loop, 2 ping-pong, 3 one-shot.

A transition above 0 blends from the pose the model is in now to the first frame over that many frames instead of snapping to it, so switching from idle to walk looks smooth.
@param md2          The MD2 entity.
@param mode         0 to 3. Defaults to 1.
@param speed        Playback speed, negative for backwards. Defaults to 1.
@param first_frame  First frame of the clip. Defaults to 0.
@param last_frame   Last frame of the clip. Defaults to the last frame of the model.
@param transition   Frames of blending into the first frame. Defaults to 0.
@gap The official help gives 1 as the default first frame; frames are counted from 0 and the default is 0, in the engine as well as here.
@gap Like Animate, the model advances with the clock (60 frames per second at speed 1) and not once per UpdateWorld.

## MD2Animating
@returns True while the MD2 model is playing an animation, otherwise False.
@param md2  The MD2 entity.

## MD2AnimLength
@returns The number of frames that the MD2 file contains in total.
@param md2  The MD2 entity.

## MD2AnimTime
@returns The exact frame that the MD2 model is at. Between frames 3 and 4 the value lies between 3 and 4.
@param md2  The MD2 entity.
