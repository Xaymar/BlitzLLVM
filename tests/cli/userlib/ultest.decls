; The functions of ultest.c, as a userlib declares them.
.lib "ultest.dll"

UlAdd%(a%, b%):"_UlAdd@8"
UlScale#(value#, factor#)
UlGreet$(name$)
UlStore(memory*, value)
UlLoad%(memory*)

; The types in the short form (%, %%, #, ##, $, *) and the long form (:Type), which can be mixed, and each type of number.
UlShortInt%(a%, b%):"UlAdd"
UlLongInt:Int(a:Int, b:Int):"UlAdd"
UlShortFloat#(value#, factor#):"UlScale"
UlLongFloat:Float(value:Float, factor:Float):"UlScale"
UlShortString$(name$):"UlGreet"
UlLongString:String(name:String):"UlGreet"
UlLongPointer(memory:Pointer, value:Int):"UlStore"
UlLongVoid:Void(memory*, value%):"UlStore"
UlByte:Byte(value:Byte)
UlUByte:UByte(value:UByte)
UlShort:Short(value:Short)
UlUShort:UShort(value:UShort)
UlUInt:UInt(value:UInt)
UlLong:Long(value:Long)
UlShortLong%%(value%%):"UlLong"
UlULong:ULong(value:ULong)
UlDouble:Double(value:Double)
UlShortDouble##(value##):"UlDouble"
; A Pointer can be returned too, and goes into a parameter of the same type as it is.
UlSelf*(memory*)
UlOffset:Pointer(memory:Pointer, bytes:Int)
