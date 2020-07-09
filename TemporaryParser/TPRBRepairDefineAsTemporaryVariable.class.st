Class {
	#name : #TPRBRepairDefineAsTemporaryVariable,
	#superclass : #TPRBAbstractReparation,
	#category : #'TemporaryParser-Repartions'
}

{ #category : #'as yet unclassified' }
TPRBRepairDefineAsTemporaryVariable >> repair: aVariableNode [
	aVariableNode methodNode temporaries add: aVariableNode.
	self reparseSemantics: aVariableNode.
]
