"
I am a specialized variable node for 'super'
"
Class {
	#name : #TPRBSuperNode,
	#superclass : #TPRBVariableNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBSuperNode class >> new [
	^super new 
		named: 'super' start: 0;
		yourself.
]

{ #category : #visiting }
TPRBSuperNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitSuperNode: self
]

{ #category : #testing }
TPRBSuperNode >> isSelfOrSuper [

	^ true
]

{ #category : #testing }
TPRBSuperNode >> isSuper [
	^ true
]
