Class {
	#name : #TPRBRepairTest,
	#superclass : #TPRBParserTest,
	#instVars : [
		'mockClass'
	],
	#category : #'TemporaryParser-Tests-Parser'
}

{ #category : #'as yet unclassified' }
TPRBRepairTest >> parseFaultyMethodWithSemantic: aString [
	| ast compilationContext compilationContextOptions |
	ast := TPRBParser parseFaultyMethod: aString.
	compilationContext := OpalCompiler new compilationContext.
	compilationContext class: mockClass.
	compilationContextOptions := CompilationContext defaultOptions copy.
	compilationContextOptions add: #optionSkipSemanticWarnings.
	compilationContext setOptions: compilationContextOptions.
	compilationContext semanticAnalyzerClass new
		compilationContext: compilationContext;
		analyze: ast.
	ast compilationContext: compilationContext.
	^ ast
]

{ #category : #running }
TPRBRepairTest >> setUp [
	super setUp.
	mockClass := TPRBMockClass new.
]

{ #category : #'as yet unclassified' }
TPRBRepairTest >> testRepairForMissingDot [
	| faultyNode repairedNode reparation |
	faultyNode := self parseFaultyMethodWithSemantic: 'toto message isNil message := 1+2'.
	repairedNode := self parseFaultyMethodWithSemantic: 'toto message isNil. message := 1+2'.
	
	reparation := TPRBRepairWithNewNode new.
	reparation replacement: '.'.
	
	faultyNode := reparation repair: faultyNode body statements first receiver.
	
	self deny: faultyNode isFaulty.
	self assert: faultyNode equals: repairedNode.
]

{ #category : #'as yet unclassified' }
TPRBRepairTest >> testRepairForMissingMessage [
	| faultyNode repairedNode |
	faultyNode := self parseFaultyMethodWithSemantic: 'toto message. message := 1+2'.
	repairedNode := self parseFaultyMethodWithSemantic: 'toto message isNil. message := 1+2'.
	faultyNode := TPRBRepairWithNewNode repair: faultyNode body statements first with: ' isNil'.
	self deny: faultyNode isFaulty.
	self assert: faultyNode equals: repairedNode.
]

{ #category : #'as yet unclassified' }
TPRBRepairTest >> testRepairForWrongMessage [
	| faultyNode repairedNode |
	faultyNode := self parseFaultyMethodWithSemantic: 'toto message isNil. message := 1+2'.
	repairedNode := self parseFaultyMethodWithSemantic: 'toto message isNotNil. message := 1+2'.
	faultyNode := TPRBRepairWithNewNode repair: faultyNode body statements first selector with: ' isNotNil'.
	self deny: faultyNode isFaulty.
	self assert: faultyNode equals: repairedNode.
]

{ #category : #'as yet unclassified' }
TPRBRepairTest >> testSemanticRepairForUndeclaredClassVar [
	| faultyNode reparation |
	faultyNode := self parseFaultyMethodWithSemantic:
		              'toto message isNil'.
	faultyNode := faultyNode body statements first receiver.
	self assert: faultyNode isUndeclaredVariable.
	reparation := TPRBRepairDefineAsClassVariable new.
	faultyNode := reparation repair: faultyNode.
	faultyNode := faultyNode body statements first receiver.
	self assert: faultyNode isInstanceVariable
]

{ #category : #'as yet unclassified' }
TPRBRepairTest >> testSemanticRepairForUndeclaredInstanceVar [
	| faultyNode reparation |
	faultyNode := self parseFaultyMethodWithSemantic:
		              'toto message isNil'.
	faultyNode := faultyNode body statements first receiver.
	self assert: faultyNode isUndeclaredVariable.
	reparation := TPRBRepairDefineAsInstanceVariable new.
	faultyNode := reparation repair: faultyNode.
	faultyNode := faultyNode body statements first receiver.
	self assert: faultyNode isInstanceVariable
]

{ #category : #'as yet unclassified' }
TPRBRepairTest >> testSemanticRepairForUndeclaredTemporary [
	| faultyNode |
	faultyNode := self parseFaultyMethodWithSemantic:
		              'toto message isNil'.
	faultyNode := faultyNode body statements first receiver.
	self assert: faultyNode isUndeclaredVariable.
	faultyNode := TPRBRepairDefineAsTemporaryVariable repair: faultyNode.
	faultyNode := faultyNode body statements first receiver.
	self assert: faultyNode isTemp
]
