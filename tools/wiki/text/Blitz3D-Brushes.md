## CreateBrush
Makes a brush: a bundle of look settings (color, alpha, shininess, blend mode, effects and up to eight textures) that you can apply in one go with [PaintEntity](Blitz3D-Entities#paintentity), [PaintMesh](Blitz3D-Meshes#paintmesh) or [PaintSurface](Blitz3D-Surfaces#paintsurface). The new brush is opaque white with no texture unless you pass a color.

Brushes are the way to give different surfaces of one mesh a different look, because [EntityColor](Blitz3D-Entities#entitycolor) and [EntityAlpha](Blitz3D-Entities#entityalpha) affect the whole entity at once.

```blitzbasic
;media still brushes/createbrush.png
Graphics3D 320, 240, 0, 2
SetBuffer BackBuffer()
camera = CreateCamera()
CameraClsColor camera, 70, 100, 160
light = CreateLight()
RotateEntity light, 40, 30, 0

mesh = CreateMesh()
a = CreateSurface(mesh)
AddVertex a, -1, 1, 0 : AddVertex a, 1, 1, 0 : AddVertex a, 1, -1, 0 : AddVertex a, -1, -1, 0
AddTriangle a, 0, 1, 2 : AddTriangle a, 0, 2, 3
b = CreateSurface(mesh)
AddVertex b, 1, 1, 0 : AddVertex b, 3, 1, 0 : AddVertex b, 3, -1, 0 : AddVertex b, 1, -1, 0
AddTriangle b, 0, 1, 2 : AddTriangle b, 0, 2, 3
UpdateNormals mesh

red = CreateBrush(220, 60, 50)
BrushShininess red, 0.8
green = CreateBrush(60, 190, 90)
PaintSurface a, red
PaintSurface b, green
FreeBrush red
FreeBrush green

PositionEntity mesh, -1, 0, 6
TurnEntity mesh, 0, -20, 0
RenderWorld
Flip
WaitKey
```

![CreateBrush](media/brushes/createbrush.png)
@param red    Red part, 0 to 255. Defaults to 255.
@param green  Green part, 0 to 255. Defaults to 255.
@param blue   Blue part, 0 to 255. Defaults to 255.
@returns A brush handle.

## FreeBrush
Releases a brush. Things that were painted with it keep the look they got, because painting copies the settings. Textures that were assigned to the brush are not freed by this, use [FreeTexture](Blitz3D-Textures#freetexture) for them.
@param brush  The brush to free.

## LoadBrush
Makes a brush that has a texture loaded from a picture file as its first layer, and returns it. This is a shortcut for [LoadTexture](Blitz3D-Textures#loadtexture), [CreateBrush](Blitz3D-Brushes#createbrush) and [BrushTexture](Blitz3D-Brushes#brushtexture), including the optional [ScaleTexture](Blitz3D-Textures#scaletexture).
@param texture_file  Picture file to use as the texture.
@param flags         Texture flags, see CreateTexture. Defaults to 1.
@param u_scale       How often the texture repeats horizontally. Defaults to 1.
@param v_scale       How often the texture repeats vertically. Defaults to 1.
@returns A brush handle, or 0 if the file could not be loaded.

## BrushColor
Sets the color the brush multiplies onto the surface: the red, green and blue parts range from 0 to 255 and are clamped. The default is 255, 255, 255, which leaves textures unchanged.
@param brush  The brush.
@param red    Red part, 0 to 255.
@param green  Green part, 0 to 255.
@param blue   Blue part, 0 to 255.

## BrushAlpha
Sets how see-through painted surfaces are. 1 is solid, 0 is invisible and values between give glass-like surfaces. Values outside 0 to 1 are clamped.

A surface with alpha 0 is not drawn but still takes part in collisions, which is the difference to [HideEntity](Blitz3D-Entities#hideentity).
@param brush  The brush.
@param alpha  Opacity, 0 to 1. The default is 1.

## BrushShininess
Sets the strength of the specular highlight on painted surfaces. 0 gives matt surfaces and 1 a very shiny, billiard-ball look when a light shines on them.
@param brush      The brush.
@param shininess  Shininess, 0 to 1. The default is 0.

## BrushBlend
Chooses how painted surfaces are mixed with what is already on the screen: 1 alpha (the default), 2 multiply, 3 add. Any other number selects the default.
@param brush  The brush.
@param blend  1, 2 or 3.

## BrushFX
Switches extra effects on or off with a sum of flags: 1 full-bright (no lighting), 2 vertex colors replace the brush color, 4 flat shading, 8 no fog, 16 no back-face culling, so both sides of a triangle are drawn. A value of 0 removes all effects.
@param brush  The brush.
@param fx     Sum of the flags above.

## BrushTexture
Puts a texture on one of the layers of the brush. Layer 0 is the base texture, further layers are blended on top of it using [TextureBlend](Blitz3D-Textures#textureblend). For a texture from [LoadAnimTexture](Blitz3D-Textures#loadanimtexture) the frame chooses the cell to show.

```blitzbasic
;media still brushes/brushtexture.png
Graphics3D 320, 240, 0, 2
SetBuffer BackBuffer()
camera = CreateCamera()
CameraClsColor camera, 70, 100, 160
light = CreateLight()
RotateEntity light, 40, 30, 0

tex = CreateTexture(64, 64)
SetBuffer TextureBuffer(tex)
ClsColor 250, 240, 200
Cls
Color 190, 70, 40
Rect 0, 0, 32, 32, 1
Rect 32, 32, 32, 32, 1
SetBuffer BackBuffer()

brush = CreateBrush(255, 255, 255)
BrushTexture brush, tex
cube = CreateCube()
PositionEntity cube, 0, 0, 4.4
TurnEntity cube, 25, 35, 0
PaintEntity cube, brush
RenderWorld
Flip
WaitKey
```

![BrushTexture](media/brushes/brushtexture.png)
@param brush    The brush.
@param texture  The texture to put on the brush.
@param frame    Frame of an animated texture. Defaults to 0.
@param index    Layer number. Defaults to 0.
@gap Layers 0 to 7 are accepted. The original help documents only 0 to 3 for this command.

## GetBrushTexture
Returns the texture on one layer of the brush, or 0 if there is none. Combine it with [TextureName](Blitz3D-Textures#texturename) to find out which file a painted surface uses.
@param brush  The brush.
@param index  Layer number, 0 to 7. Defaults to 0.
@returns A new handle for the texture of that layer, or 0. Free it separately when you no longer need it; the brush keeps its texture.
@gap A layer without a texture gives 0. The original hands out a handle to an empty texture instead.

## GetEntityBrush
Makes a new brush that has the same look as an entity: its color, alpha, shininess, blend mode, effects and textures. Free the brush with [FreeBrush](Blitz3D-Brushes#freebrush) when you no longer need it.
@param entity  The entity.
@returns A brush handle.

## GetSurfaceBrush
Makes a new brush that has the look that was painted on a mesh surface. Free it with [FreeBrush](Blitz3D-Brushes#freebrush) afterwards.
@param surface  The surface.
@returns A brush handle.
@gap A surface that was never painted gives a plain white brush.
