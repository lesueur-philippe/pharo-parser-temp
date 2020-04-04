"
This class contains tests
"
Class {
	#name : #TPRBSequenceNodeTest,
	#superclass : #TPRBParseTreeTest,
	#category : #'TemporaryParser-Tests-Nodes'
}

{ #category : #tests }
TPRBSequenceNodeTest >> testStop [
	| ast |
	ast := self parserClass parseMethod: 'method | temp |'.
	self assert: ast body stop equals: ast body temporaries last stop
]
