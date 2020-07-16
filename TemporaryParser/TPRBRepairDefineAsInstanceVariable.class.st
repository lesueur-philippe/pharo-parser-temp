Class {
	#name : #TPRBRepairDefineAsInstanceVariable,
	#superclass : #TPRBAbstractReparation,
	#category : #'TemporaryParser-Repartions'
}

{ #category : #'as yet unclassified' }
TPRBRepairDefineAsInstanceVariable >> repair: aVariableNode [
	self context: aVariableNode methodNode compilationContext.
	self context class addInstVarNamed: aVariableNode name.
	self reparse: aVariableNode source.
]
