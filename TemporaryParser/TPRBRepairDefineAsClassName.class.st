Class {
	#name : #TPRBRepairDefineAsClassName,
	#superclass : #TPRBSemanticReparation,
	#category : #'TemporaryParser-Repartions'
}

{ #category : #'as yet unclassified' }
TPRBRepairDefineAsClassName >> repair: aVariableNode [
	| classSymbol systemCategory classDefinition |
	classSymbol := aVariableNode name asSymbol.
	systemCategory := aVariableNode methodNode compilationContext getClass category
		ifNil: [ 'Unknown' ].
	classDefinition := 'Object subclass: #' , classSymbol , '
		instanceVariableNames: '''' 
		classVariableNames: ''''
		category: ''' , systemCategory , ''''.
	classDefinition := UIManager default 
		multiLineRequest: 'Edit class definition:'
		initialAnswer: classDefinition
		answerHeight: 150.
	(classDefinition isNil or: [ classDefinition isEmpty ])
		ifTrue: [ ^ Abort signal ].
	OpalCompiler new compilationContext: aVariableNode methodNode compilationContext;
		source: classDefinition;
		logged: true;
		evaluate.
	^self redoSemanticsFor: aVariableNode methodNode.
]
