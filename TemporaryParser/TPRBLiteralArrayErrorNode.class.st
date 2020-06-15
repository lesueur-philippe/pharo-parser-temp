Class {
	#name : #TPRBLiteralArrayErrorNode,
	#superclass : #TPRBEnglobingErrorNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'as yet unclassified' }
TPRBLiteralArrayErrorNode class >> error: aToken withNodes: aCollection [
	aCollection isEmpty
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aToken stop; errorMessage: ''')'' expected' ]
		ifFalse: [ ^self new content: aCollection; start: aToken start; stop: aCollection last stop; errorMessage: ''')'' expected' ]
		
]

{ #category : #testing }
TPRBLiteralArrayErrorNode >> isLiteralArrayError [
	^true
]

{ #category : #accessing }
TPRBLiteralArrayErrorNode >> value [
	^  '#( ', super value 
]
