Class {
	#name : #TPRBEnglobingErrorNode,
	#superclass : #TPRBParseErrorNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #initialization }
TPRBEnglobingErrorNode >> initialize [ 
	super initialize.
	value := OrderedCollection new.
]

{ #category : #testing }
TPRBEnglobingErrorNode >> isEnglobingError [
	^true
]
