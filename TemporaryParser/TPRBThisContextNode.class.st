"
I represent the specialized variable named 'thisContext'
"
Class {
	#name : #TPRBThisContextNode,
	#superclass : #TPRBVariableNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBThisContextNode class >> new [
	^super new 
		named: 'thisContext' start: 0;
		yourself.
]

{ #category : #visiting }
TPRBThisContextNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitThisContextNode: self
]

{ #category : #testing }
TPRBThisContextNode >> isThisContext [
	^ true
]
