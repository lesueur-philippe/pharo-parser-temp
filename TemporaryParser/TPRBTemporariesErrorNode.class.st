Class {
	#name : #TPRBTemporariesErrorNode,
	#superclass : #TPRBEnglobingErrorNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'as yet unclassified' }
TPRBTemporariesErrorNode class >> error: aToken withNodes: aCollection [
	aCollection isEmpty
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aToken stop; errorMessage: '''|'' expected' ]
		ifFalse: [ ^self new content: aCollection; start: aToken start; stop: aCollection last stop; errorMessage: '''|'' expected' ]
]

{ #category : #testing }
TPRBTemporariesErrorNode >> isTemporariesError [
	^true
]

{ #category : #accessing }
TPRBTemporariesErrorNode >> value [
	^  '| ', super value 
]
