Class {
	#name : #TPRBParenthesisErrorNode,
	#superclass : #TPRBEnglobingErrorNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'as yet unclassified' }
TPRBParenthesisErrorNode class >> error: aToken withNodes: aCollection [
	| message |
	message := ('(' = aToken value asString) ifTrue: [ ''')'' expected' ] 
										  				 ifFalse: [ '''('' expected' ].
	aCollection isEmpty
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aToken stop; errorMessage: message ].
	(message = ''')'' expected')
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aCollection last stop; errorMessage: message ]
		ifFalse: [ ^self new content: aCollection; start: aCollection first start; stop: aToken stop; errorMessage: message ]
]

{ #category : #testing }
TPRBParenthesisErrorNode >> isParenthesisError [
	^true
]

{ #category : #accessing }
TPRBParenthesisErrorNode >> value [
	^  self errorMessage = '''('' expected' ifTrue: [ super value, ')' ] 
														ifFalse: [ '( ', super value ] 
]
