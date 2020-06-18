Class {
	#name : #TPRBLiteralByteArrayErrorNode,
	#superclass : #TPRBEnglobingErrorNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'as yet unclassified' }
TPRBLiteralByteArrayErrorNode class >> error: aToken withNodes: aCollection [
	aCollection isEmpty
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aToken stop; errorMessage: ''']'' expected' ]
		ifFalse: [ ^self new content: aCollection; start: aToken start; stop: aCollection last stop; errorMessage: ''']'' expected' ]
]

{ #category : #testing }
TPRBLiteralByteArrayErrorNode >> isLiteralByteArrayError [
	^true
]

{ #category : #accessing }
TPRBLiteralByteArrayErrorNode >> value [
	^  '#[ ', super value 
]
