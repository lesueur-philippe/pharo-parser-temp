Class {
	#name : #TPRBAbstractReparation,
	#superclass : #Object,
	#instVars : [
		'context'
	],
	#category : #'TemporaryParser-Repartions'
}

{ #category : #'as yet unclassified' }
TPRBAbstractReparation class >> repair: aNode [
	^self new repair: aNode.
]

{ #category : #accessing }
TPRBAbstractReparation >> context [
	 ^context
]

{ #category : #accessing }
TPRBAbstractReparation >> context: aContext [
	 context := aContext.
]

{ #category : #'as yet unclassified' }
TPRBAbstractReparation >> repair: aNode [
	self subclassResponsibility.
]

{ #category : #'as yet unclassified' }
TPRBAbstractReparation >> reparse: aString [
	| ast |
	ast := TPRBParser parseFaultyMethod: aString.
	context semanticAnalyzerClass new
   compilationContext: context;
   analyze: ast.
	ast compilationContext: context.
	^ast
]
