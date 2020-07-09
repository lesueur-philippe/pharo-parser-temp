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
	TPRBParser parseFaultyMethod: aString.
]

{ #category : #'as yet unclassified' }
TPRBAbstractReparation >> reparseSemantics: aNode [
	self context semanticAnalyzerClass new
   compilationContext: self context;
   analyze: aNode methodNode.
]