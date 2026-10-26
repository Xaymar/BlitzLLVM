; Float math with NaN and Infinity, which has to keep working with the default optimizations.
Function IsNaN(x#)
	Return (x <> x)
End Function

Function Divide#(a#, b#)
	Return a / b
End Function

Local zero# = Float(Rand(0, 0))
Local nan# = Divide(0, zero)
Local inf# = Divide(1, zero)
Local scaled# = inf * 2.5
Print "nan " + IsNaN(nan) + " inf " + (inf > 1000000000 And scaled > 1000000000)
