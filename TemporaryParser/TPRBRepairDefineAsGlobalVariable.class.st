Class {
	#name : #TPRBRepairDefineAsGlobalVariable,
	#superclass : #TPRBSemanticReparation,
	#category : #'TemporaryParser-Repartions'
}

{ #category : #'as yet unclassified' }
TPRBRepairDefineAsGlobalVariable >> repair: aVariableNode [
	Smalltalk at: aVariableNode name asSymbol put: nil.
	^self redoSemanticsFor: aVariableNode methodNode.
]
