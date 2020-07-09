Class {
	#name : #TPRBRepairTest,
	#superclass : #TPRBParserTest,
	#category : #'TemporaryParser-Tests-Parser'
}

{ #category : #'as yet unclassified' }
TPRBRepairTest >> parseFaultyMethodWithSemantic: aString [
	| ast compilationContext compilationContextOptions |
	ast := TPRBParser parseFaultyMethod: aString.
	compilationContext := OpalCompiler new compilationContext.
	compilationContextOptions := CompilationContext defaultOptions copy.
	compilationContextOptions add: #optionSkipSemanticWarnings.
	compilationContext setOptions: compilationContextOptions.
	compilationContext semanticAnalyzerClass new
   compilationContext: compilationContext;
   analyze: ast.
	^ast
]

{ #category : #'as yet unclassified' }
TPRBRepairTest >> testRepairForMissingDot [
	| faultyNode repairedNode |
	faultyNode := self parseFaultyMethod: 'toto message isNil message := 1+2'.
	repairedNode := self parseFaultyMethod: 'toto message isNil. message := 1+2'.
	TPRBRepairForgottenDot repair: faultyNode body statements first.
	self assert: faultyNode equals: repairedNode.
]

{ #category : #'as yet unclassified' }
TPRBRepairTest >> testSemanticRepairForUndeclaredInstanceVar [
	| faultyNode context options |
	faultyNode := self parseFaultyMethod: 'toto message isNil'.
	context := OpalCompiler new compilationContext.
	context class: TPMockClass new.
	options := CompilationContext defaultOptions copy.
	options add: #optionSkipSemanticWarnings.
	context setOptions: options.
	context semanticAnalyzerClass new
   compilationContext: context;
   analyze: faultyNode.
	faultyNode := faultyNode body statements first receiver.
	self assert: faultyNode isUndeclared.
	TPRBRepairDefineAsInstanceVariable repair: faultyNode.
	self assert: faultyNode isInstanceVariable.
]

{ #category : #'as yet unclassified' }
TPRBRepairTest >> testSemanticRepairForUndeclaredTemporary [
	| faultyNode context options |
	faultyNode := self parseFaultyMethod: 'toto message isNil'.
	context := OpalCompiler new compilationContext.
	options := CompilationContext defaultOptions copy.
	options add: #optionSkipSemanticWarnings.
	context setOptions: options.
	context semanticAnalyzerClass new
   compilationContext: context;
   analyze: faultyNode.
	faultyNode := faultyNode body statements first receiver.
	self assert: faultyNode isUndeclared.
	TPRBRepairDefineAsTemporaryVariable repair: faultyNode withContext: context.
	self assert: faultyNode isTemp.
]
