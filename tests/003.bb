Local iValue = 1, iValue2 = 1.2, iValue3 = "Hello World"
; iValue should be 1
; iValue2 should be 1, and print a warning
; iValue3 should be 0 (converted from string), and print a warning
Local fValue# = 1, fValue2# = 1.2, fValue3# = "Hello World"
; fValue should be 1.0
; fValue2 should be 1.2
; fValue3 should be 0.0 (converted from string), and print a warning
Local sValue$ = 1, sValue2$ = 1.2, sValue3$ = "Hello World"
; sValue = "1", print warning
; sValue2 = "1.2", print warning
; sValue3 = "Hello World"

Function iFunction()
	Return 1
End Function
Function iFunction2()
	Return 1.2
End Function
Function iFunction3()
	Return "Hello World"
End Function
; iFunction returns 1
; iFunction2 returns 1, prints warning
; iFunction3 returns 0, prints warning

Function fFunction#()
	Return 1
End Function
Function fFunction2#()
	Return 1.2
End Function
Function fFunction3#()
	Return "Hello World"
End Function
; fFunction returns 1.0
; fFunction2 returns 1.2
; fFunction3 returns 0, prints warning

Function sFunction$()
	Return 1
End Function
Function sFunction2$()
	Return 1.2
End Function
Function sFunction3$()
	Return "Hello World"
End Function
; sFunction returns "1", prints warning
; sFunction2 returns "1.2", prints warning
; sFunction3 returns "Hello World"

;-- AST Representation
;LocalVariables{
;  Variable{Int32, iValue, toInt32(Int32(1))},
;  Variable{Int32, iValue2, toInt32(Real32(1.2))},
;  Variable{Int32, iValue3, toInt32(String(Hello World))},
;}
;LocalVariables{
;  Variable{Real32, fValue, toReal32(Int32(1))},
;  Variable{Real32, fValue2, toReal32(Real32(1.2))},
;  Variable{Real32, fValue3, toReal32(String(Hello World))},
;}
;LocalVariables{
;  Variable{String, sValue, toString(Int32(1))},
;  Variable{String, sValue2, toString(Real32(1.2))},
;  Variable{String, sValue3, toString("Hello World")},
;}
; 
;Function{
;  Text(iFunction),
;  Int32,
;  Parameters{
;  },
;  Content{
;    Return(Int32(1))
;  }
;}
;Function{
;  Text(iFunction2),
;  Int32,
;  Parameters{
;  },
;  Content{
;    Return(Real32(1.2))
;  }
;}
;Function{
;  Text(iFunction3),
;  Int32,
;  Parameters{
;  },
;  Content{
;    Return(String("Hello World"))
;  }
;}
; 
;Function{
;  Text(fFunction),
;  Real32,
;  Parameters{
;  },
;  Content{
;    Return(Int32(1))
;  }
;}
;Function{
;  Text(fFunction2),
;  Real32,
;  Parameters{
;  },
;  Content{
;    Return(Real32(1.2))
;  }
;}
;Function{
;  Text(fFunction3),
;  Real32,
;  Parameters{
;  },
;  Content{
;    Return(String("Hello World"))
;  }
;}
; 
;Function{
;  Text(sFunction),
;  String,
;  Parameters{
;  },
;  Content{
;    Return(Int32(1))
;  }
;}
;Function{
;  Text(sFunction2),
;  String,
;  Parameters{
;  },
;  Content{
;    Return(Real32(1.2))
;  }
;}
;Function{
;  Text(sFunction3),
;  String,
;  Parameters{
;  },
;  Content{
;    Return(String("Hello World"))
;  }
;}