"
I am a specialized version for the 'self'
"
Class {
	#name : #TPRBSelfNode,
	#superclass : #TPRBVariableNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBSelfNode class >> new [
	^super new 
		named: 'self' start: 0;
		yourself.
]

{ #category : #visiting }
TPRBSelfNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitSelfNode: self
]

{ #category : #testing }
TPRBSelfNode >> isSelf [
	^ true
]

{ #category : #testing }
TPRBSelfNode >> isSelfOrSuper [
	^ true
]
