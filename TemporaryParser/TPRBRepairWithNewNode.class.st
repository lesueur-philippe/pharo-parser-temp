Class {
	#name : #TPRBRepairWithNewNode,
	#superclass : #TPRBAbstractReparation,
	#instVars : [
		'replacement'
	],
	#category : #'TemporaryParser-Repartions'
}

{ #category : #'as yet unclassified' }
TPRBRepairWithNewNode class >> repair: aNode with: aString [
	^self new replacement: aString;
				 repair: aNode.
]

{ #category : #initialization }
TPRBRepairWithNewNode >> initialize [ 
	super initialize.
	replacement := ''.
]

{ #category : #'as yet unclassified' }
TPRBRepairWithNewNode >> repair: aNode [
	| beginning end |
	self context: aNode methodNode compilationContext.
	beginning := aNode start = 1 ifFalse: [ (aNode source copyFrom: 1 to: aNode stop) ]
									   ifTrue: [ '' ].
	end := aNode stop = aNode source size ifFalse: [ (aNode source copyFrom: aNode stop + 1 to: aNode source size) ]
									             ifTrue: [ '' ].
	^self reparse: (beginning , replacement , end).
]

{ #category : #accessing }
TPRBRepairWithNewNode >> replacement: aString [
	replacement := aString
]
