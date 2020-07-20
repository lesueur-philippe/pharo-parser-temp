Class {
	#name : #TPRBRepairDefineAsClassVariable,
	#superclass : #TPRBSemanticReparation,
	#category : #'TemporaryParser-Repartions'
}

{ #category : #'as yet unclassified' }
TPRBRepairDefineAsClassVariable >> repair: aVariableNode [
	self context: aVariableNode methodNode compilationContext.
	self context getClass instanceSide addClassVarNamed: aVariableNode name asSymbol.
	^self redoSemanticsFor: aVariableNode methodNode.
]
