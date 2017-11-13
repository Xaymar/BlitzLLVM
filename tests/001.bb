; Ein simpler Lexer Test
Local Variable = 1.0
Local Variable2$ = "Hallo Welt"

For I = 0 To 8
	Variable = Variable + I
Next

While Variable
	Variable = Variable - 1
Wend

Repeat
	Variable = Variable + 1
Until Variable

Repeat
	Exit
Forever

If Variable = 0 Then
	Variable = 1
EndIf

Function DoVar(Var)
	Return Var * Var
End Function

DoVar Variable
DoVar(Variable)

Global Variable3# = 7.2
Variable3 = Variable3 / 4 * 5 - 2 + 8 ^ 22
;~IDEal Editor Parameters:
;~C#BlitzNext