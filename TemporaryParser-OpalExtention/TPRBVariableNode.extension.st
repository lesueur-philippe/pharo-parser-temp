Extension { #name : #TPRBVariableNode }

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBVariableNode >> binding [
	^self propertyAt: #binding ifAbsent: [nil].
]
