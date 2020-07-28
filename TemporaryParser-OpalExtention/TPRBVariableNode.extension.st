Extension { #name : #TPRBVariableNode }

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBVariableNode >> binding [
	
	^ variable
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBVariableNode >> binding: aSemVar [
	
	variable := aSemVar
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBVariableNode >> hasBreakpoint [
	^ (self afterLinks anySatisfy: [ :link | link metaObject = Break ])
		or: [ super hasBreakpoint ]
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBVariableNode >> isArg [

	^self binding isArg
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBVariableNode >> isArgOrTemp [
	^self binding isTemp
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBVariableNode >> isClean [
	^ (self isInstance | self isSpecialVariable) not
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBVariableNode >> isGlobal [
	^self binding isGlobal
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBVariableNode >> isInstance [
	^self binding isInstance
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBVariableNode >> isSpecialVariable [
	^ self binding isSpecialVariable
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBVariableNode >> isUndeclared [

	^self binding isUndeclared
]
