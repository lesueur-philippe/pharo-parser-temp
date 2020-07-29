Class {
	#name : #TPSycCodeRepairCommand,
	#superclass : #SycSourceCodeCmCommand,
	#category : #'TemporaryParser-Tools'
}

{ #category : #accessing }
TPSycCodeRepairCommand >> doSemanticAnalysis [ 
	| ast compilationContext compilationContextOptions |
	ast := self context selectedSourceNode methodNode.
	compilationContext := OpalCompiler new compilationContext.
	compilationContext class: ast methodClass.
	compilationContextOptions := CompilationContext defaultOptions copy.
	compilationContextOptions add: #optionSkipSemanticWarnings.
	compilationContext setOptions: compilationContextOptions.
	compilationContext semanticAnalyzerClass new
 	compilationContext: compilationContext;
  	analyze: ast.
	
]

{ #category : #accessing }
TPSycCodeRepairCommand >> icon [

	^ self iconNamed: #add
]

{ #category : #accessing }
TPSycCodeRepairCommand >> isApplicable [
	^ self hasContext ifTrue: [ | node | 
										 self doSemanticAnalysis.
										 node := self context selectedSourceNode. 
										 node isVariable and: [ node isUndeclaredVariable ]. ]
							ifFalse: [ false ].
]

{ #category : #accessing }
TPSycCodeRepairCommand >> name [ 
	^ 'Repair selection'
]
