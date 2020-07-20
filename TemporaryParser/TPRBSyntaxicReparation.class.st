Class {
	#name : #TPRBSyntaxicReparation,
	#superclass : #TPRBAbstractReparation,
	#instVars : [
		'replacement'
	],
	#category : #'TemporaryParser-Repartions'
}

{ #category : #initialization }
TPRBSyntaxicReparation >> initialize [ 
	super initialize.
	replacement := ''.
]

{ #category : #'as yet unclassified' }
TPRBSyntaxicReparation >> repair: aNode [
	self subclassResponsibility.
]

{ #category : #accessing }
TPRBSyntaxicReparation >> replacement [
	^replacement
]

{ #category : #accessing }
TPRBSyntaxicReparation >> replacement: aString [
	replacement := aString
]
