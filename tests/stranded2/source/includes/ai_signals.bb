;### AI Signal
Function ai_signal(class,id,mode,range=300)
	;Caching
	Local oldunit.Tunit=TCunit
	;Get Target Handle
	Local target=parent_h(class,id)
	If target<>0 Then
		;Check Units
		For Tunit.Tunit=Each Tunit
			;Living?
			If Tunit\health>0 Then
				;In Range?
				If EntityDistance(Tunit\h,target)<range Then
					;Handle Stuff
					TCunit.Tunit=Tunit
					
					;Set Target
					TCunit\ai_target_class=class
					TCunit\ai_target_id=id
					
					;Set Mode
					Select mode
						;Food
						Case ai_food
							If TCunit\ai_mode<>ai_getfood Then
								ai_mode(ai_getfood,20000)
							EndIf
						;Attract
						Case ai_attract
							If TCunit\ai_mode<>ai_movetarget Then
								ai_mode(ai_movetarget,20000)
							EndIf
						;Distract
						Case ai_distract
							If TCunit\ai_mode<>ai_flee Then
								ai_mode(ai_flee,20000)
							EndIf
					End Select
				
				EndIf
			EndIf
		Next
	EndIf
	;Uncache
	TCunit.Tunit=oldunit
End Function


;### AI Type Signal
Function ai_typesignal(class,id,mode,typ,range=300)
	;Caching
	Local oldunit.Tunit=TCunit
	;Get Target Handle
	Local target=parent_h(class,id)
	If target<>0 Then
		;Check Units
		For Tunit.Tunit=Each Tunit
			;Living?
			If Tunit\health>0 Then
				;Correct Type?
				If Tunit\typ=typ Then
					;In Range?
					If EntityDistance(Tunit\h,target)<range Then
						;Handle Stuff
						TCunit.Tunit=Tunit
						
						;Set Target
						TCunit\ai_target_class=class
						TCunit\ai_target_id=id
						
						;Set Mode
						Select mode
							;Food
							Case ai_food
								If TCunit\ai_mode<>ai_getfood Then
									ai_mode(ai_getfood,10000)
								EndIf
							;Attract
							Case ai_attract
								If TCunit\ai_mode<>ai_movetarget Then
									ai_mode(ai_movetarget,10000)
								EndIf
							;Distract
							Case ai_distract
								If TCunit\ai_mode<>ai_flee Then
									ai_mode(ai_flee,10000)
								EndIf
						End Select
					
					EndIf
				EndIf
			EndIf
		Next
	EndIf
	;Uncache
	TCunit.Tunit=oldunit
End Function


;### AI Behaviour Signal
Function ai_behavioursignal(class,id,mode,typ,range=300)
	;Caching
	Local oldunit.Tunit=TCunit
	;Get Target Handle
	Local target=parent_h(class,id)
	If target<>0 Then
		;Check Units
		For Tunit.Tunit=Each Tunit
			;Living?
			If Tunit\health>0 Then
				;Correct Behaviour?
				If Dunit_behaviour(Tunit\typ)=typ Then
					;In Range?
					If EntityDistance(Tunit\h,target)<range Then
						;Handle Stuff
						TCunit.Tunit=Tunit
						
						;Set Target
						TCunit\ai_target_class=class
						TCunit\ai_target_id=id
						
						;Set Mode
						Select mode
							;Food
							Case ai_food
								If TCunit\ai_mode<>ai_getfood Then
									ai_mode(ai_getfood,10000)
								EndIf
							;Attract
							Case ai_attract
								If TCunit\ai_mode<>ai_movetarget Then
									ai_mode(ai_movetarget,10000)
								EndIf
							;Distract
							Case ai_distract
								If TCunit\ai_mode<>ai_flee Then
									ai_mode(ai_flee,10000)
								EndIf
						End Select
						
						;Time
						TCunit\ai_duration=10000
						TCunit\ai_timer=gt
						
					EndIf
				EndIf
			EndIf
		Next
	EndIf
	;Uncache
	TCunit.Tunit=oldunit
End Function

;### AI Behaviour Signal
Function ai_unitmode(unitid,mode,targetclass=0,targetid=0)
	If con_unit(unitid) Then
		ai_mode(mode)
		TCunit\ai_target_class=targetclass
		TCunit\ai_target_id=targetid
	EndIf
End Function