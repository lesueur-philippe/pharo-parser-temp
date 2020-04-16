"
Abstract visitor providing generic block visiting capabilities.
Subclasses provide specific node type capabilties

"
Class {
	#name : #TPRBAbstractBlockVisitor,
	#superclass : #TPRBProgramNodeVisitor,
	#instVars : [
		'visitBlock'
	],
	#category : #'TemporaryParser-Visitors'
}

{ #category : #enumerating }
TPRBAbstractBlockVisitor class >> visit: aTree detect: aBlock [
	
	^self visit: aTree detect: aBlock ifNone: [ NotFound signalFor: aBlock ]
]

{ #category : #enumerating }
TPRBAbstractBlockVisitor class >> visit: aTree detect: aBlock ifNone: anErrorBlock [
	| result |
	
	result := OrderedCollection new.
	
	self visit: aTree do: [ :node |
		(aBlock value: node) ifTrue: [ ^node ] ].
	
	^anErrorBlock value
]

{ #category : #enumerating }
TPRBAbstractBlockVisitor class >> visit: aTree do: aBlock [
	^self new 
		visitBlock: aBlock;
		visitNode: aTree
]

{ #category : #enumerating }
TPRBAbstractBlockVisitor class >> visit: aTree select: aBlock [
	| result |
	result := OrderedCollection new.
	self visit: aTree do: [ :node |
		(aBlock value: node) ifTrue: [ result add: node ] ].
	^result
]

{ #category : #accessing }
TPRBAbstractBlockVisitor >> visitBlock [
	^ visitBlock
]

{ #category : #accessing }
TPRBAbstractBlockVisitor >> visitBlock: anObject [
	visitBlock := anObject
]
