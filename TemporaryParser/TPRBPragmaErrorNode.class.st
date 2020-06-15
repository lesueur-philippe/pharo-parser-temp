Class {
	#name : #TPRBPragmaErrorNode,
	#superclass : #TPRBEnglobingErrorNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'as yet unclassified' }
TPRBPragmaErrorNode class >> error: aToken withNodes: aCollection [
	aCollection isEmpty
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aToken stop; errorMessage: '''>'' expected' ]
		ifFalse: [ ^self new content: aCollection; start: aToken start; stop: aCollection last stop; errorMessage: '''>'' expected' ]
]

{ #category : #testing }
TPRBPragmaErrorNode >> isPragmaError [
	^true
]

{ #category : #accessing }
TPRBPragmaErrorNode >> value [
	^   '< ', super value 
]
