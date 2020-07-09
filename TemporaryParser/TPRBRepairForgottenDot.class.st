Class {
	#name : #TPRBRepairForgottenDot,
	#superclass : #TPRBAbstractReparation,
	#category : #'TemporaryParser-Repartions'
}

{ #category : #'as yet unclassified' }
TPRBRepairForgottenDot >> repair: aNode [
		^self reparse: ((aNode source copyFrom: 1 to: aNode stop), '.', (aNode source copyFrom: aNode stop + 1 to: aNode methodNode stop)).
	
	
]
