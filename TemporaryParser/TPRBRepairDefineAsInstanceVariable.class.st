Class {
	#name : #TPRBRepairDefineAsInstanceVariable,
	#superclass : #TPRBAbstractReparation,
	#category : #'TemporaryParser-Repartions'
}

{ #category : #'as yet unclassified' }
TPRBRepairDefineAsInstanceVariable >> repair: aVariableNode [
	aVariableNode methodNode compilationContext class addInstVarNamed: aVariableNode name.
	self reparseSemantics: aVariableNode.
]
