## ACos
Returns the angle whose cosine is the given number. The result is in degrees, from 0 to 180. A number outside -1 to 1 has no such angle.

```blitzbasic
;run
Print ACos(0.5)
```

```text
60.0
```
@param float  The cosine, from -1 to 1.
@returns The angle in degrees.

## ASin
Returns the angle whose sine is the given number. The result is in degrees, from -90 to 90.

```blitzbasic
;run
Print ASin(0.5)
```

```text
30.0
```
@param float  The sine, from -1 to 1.
@returns The angle in degrees.

## ATan
Returns the angle whose tangent is the given number, in degrees from -90 to 90. When you have both sides of the triangle, [ATan2](BlitzBasic-Math#atan2) is usually the better choice because it knows which quadrant the angle is in.

```blitzbasic
;run
Print ATan(1)
```

```text
45.0
```
@param float  The tangent.
@returns The angle in degrees.

## ATan2
Returns the angle of the point (`b`, `a`) seen from the origin, in degrees from -180 to 180. Note the order: the vertical distance `a` comes first. 0 points along positive x, 90 along positive y.

```blitzbasic
;run
Print ATan2(1, 1)
Print ATan2(0, -1)
```

```text
45.0
180.0
```
@param floata  The vertical distance (y).
@param floatb  The horizontal distance (x).
@returns The angle in degrees.

## Ceil
Rounds up to the next whole number and returns it as a float.

```blitzbasic
;run
Print Ceil(2.1)
Print Ceil(-2.1)
```

```text
3.0
-2.0
```
@param float  The number to round up.
@returns The smallest whole number that is not below `float`.

## Cos
Returns the cosine of an angle given in degrees, not radians.

```blitzbasic
;run
Print Cos(60)
```

```text
0.5
```
@param degrees  The angle in degrees.
@returns A value from -1 to 1.

## Exp
Returns e (2.71828...) raised to the given power. It is the opposite of [Log](BlitzBasic-Math#log).

```blitzbasic
;run
Print Exp(1)
```

```text
2.71828
```
@param float  The exponent.
@returns e to the power of `float`.

## Floor
Rounds down to the previous whole number and returns it as a float.

```blitzbasic
;run
Print Floor(2.9)
Print Floor(-2.1)
```

```text
2.0
-3.0
```
@param float  The number to round down.
@returns The largest whole number that is not above `float`.

## Log
Returns the natural logarithm (base e) of a number. For base 10 use [Log10](BlitzBasic-Math#log10).

```blitzbasic
;run
Print Log(10)
```

```text
2.30259
```
@param float  A number above 0.
@returns The natural logarithm.

## Log10
Returns the logarithm to base 10, which is how many times 10 goes into the number.

```blitzbasic
;run
Print Log10(1000)
```

```text
3.0
```
@param float  A number above 0.
@returns The logarithm to base 10.

## Rand
Returns a random whole number from `from` to `to`, both included. With one argument the range is 1 up to that number. The same seed (see [SeedRnd](BlitzBasic-Math#seedrnd)) always gives the same sequence.

```blitzbasic
;run
SeedRnd 1234
dice = Rand(1, 6)
Print dice >= 1 And dice <= 6
Print Rand(5, 5)
```

```text
1
5
```
@param from  Lowest result, or the highest when `to` is left out.
@param to    Highest result. Defaults to 1.
@returns A random integer in the range.

## Rnd
Returns a random float from `from` up to, but not including, `to`. With one argument the range is 0 up to that number.

```blitzbasic
;run
SeedRnd 7
r# = Rnd(5, 6)
Print r >= 5 And r < 6
```

```text
1
```
@param from  Lowest result, or the limit when `to` is left out.
@param to    The limit, never reached. Defaults to 0.
@returns A random float in the range.

## RndSeed
@returns The current seed of the random number generator. Store it and give it to [SeedRnd](BlitzBasic-Math#seedrnd) later to replay a sequence of random numbers.

## SeedRnd
Restarts the random number generator from a seed. The same seed always gives the same numbers from [Rand](BlitzBasic-Math#rand) and [Rnd](BlitzBasic-Math#rnd), which is useful for replays and procedurally generated levels. Every program starts with the same seed (4660), so it gets the same random numbers on every run until you use `SeedRnd MilliSecs()` for different ones.

```blitzbasic
;run
SeedRnd 42
a = Rand(1, 1000)
SeedRnd 42
b = Rand(1, 1000)
Print a = b
```

```text
1
```
@param seed  The starting value.

## Sin
Returns the sine of an angle given in degrees, not radians.

```blitzbasic
;run
Print Sin(30)
```

```text
0.5
```
@param degrees  The angle in degrees.
@returns A value from -1 to 1.

## Sqr
Returns the square root of a number.

```blitzbasic
;run
Print Sqr(2)
Print Sqr(16)
```

```text
1.41421
4.0
```
@param float  A number of 0 or more.
@returns The square root.

## Tan
Returns the tangent of an angle given in degrees, not radians.

```blitzbasic
;run
Print Tan(45)
```

```text
1.0
```
@param degrees  The angle in degrees.
@returns The tangent.
