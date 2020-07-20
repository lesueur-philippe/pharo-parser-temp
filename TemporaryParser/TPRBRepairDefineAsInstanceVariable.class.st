Class {
	#name : #TPRBRepairDefineAsInstanceVariable,
	#superclass : #TPRBSemanticReparation,
	#category : #'TemporaryParser-Repartions'
}

{ #category : #'as yet unclassified' }
TPRBRepairDefineAsInstanceVariable >> repair: aVariableNode [
	self context: aVariableNode methodNode compilationContext.
	self context getClass addInstVarNamed: aVariableNode name.
	^ self redoSemanticsFor: aVariableNode methodNode.
]
