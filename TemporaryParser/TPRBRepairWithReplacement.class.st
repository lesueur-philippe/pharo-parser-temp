Class {
	#name : #TPRBRepairWithReplacement,
	#superclass : #TPRBAbstractReparation,
	#instVars : [
		'replacement'
	],
	#category : #'TemporaryParser-Repartions'
}

{ #category : #'as yet unclassified' }
TPRBRepairWithReplacement class >> repair: aNode with: aString [
	^self new replacement: aString;
				 repair: aNode.
]

{ #category : #initialization }
TPRBRepairWithReplacement >> initialize [ 
	super initialize.
	replacement := ''.
]

{ #category : #'as yet unclassified' }
TPRBRepairWithReplacement >> repair: aNode [
	| beginning end |
	self context: aNode methodNode compilationContext.
	beginning := aNode start = 1 ifFalse: [ (aNode source copyFrom: 1 to: aNode start -1) ]
									   ifTrue: [ '' ].
	end := aNode stop = aNode source size ifFalse: [ (aNode source copyFrom: aNode stop + 1 to: aNode source size) ]
									             ifTrue: [ '' ].
	^self reparse: (beginning , replacement , end).
]

{ #category : #accessing }
TPRBRepairWithReplacement >> replacement: aString [
	replacement := aString
]
