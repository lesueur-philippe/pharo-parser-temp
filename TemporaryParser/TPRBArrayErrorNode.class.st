Class {
	#name : #TPRBArrayErrorNode,
	#superclass : #TPRBEnglobingErrorNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'as yet unclassified' }
TPRBArrayErrorNode class >> error: aToken withNodes: aCollection [
	| message |
	message := ('{' = aToken value asString) ifTrue: [ '''}'' expected' ] 
										  				 ifFalse: [ '''{'' expected' ].
	aCollection isEmpty
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aToken stop; errorMessage: message ].
	(message = '''}'' expected')
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aCollection last stop; errorMessage: message ]
		ifFalse: [ ^self new content: aCollection; start: aCollection first start; stop: aToken stop; errorMessage: message ]
]

{ #category : #testing }
TPRBArrayErrorNode >> isArrayError [
	^true
]

{ #category : #accessing }
TPRBArrayErrorNode >> value [
	^  self errorMessage = '''{'' expected' ifTrue: [ super value, '}' ] 
														ifFalse: [ '{ ', super value ] 
]
