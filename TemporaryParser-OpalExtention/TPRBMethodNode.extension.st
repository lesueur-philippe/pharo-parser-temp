Extension { #name : #TPRBMethodNode }

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> compiledMethod [
	^ self ir compiledMethod
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> doSemanticAnalysis [

	self compilationContext ifNil: [ self methodClass: nil class ].

	self
		compilationContext semanticAnalyzerClass new
			compilationContext: self compilationContext;
			analyze: self
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> doSemanticAnalysisIn: behavior [
	behavior ifNotNil: [self methodClass: behavior].
	self doSemanticAnalysis
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> ensureCachedArgumentNames [
	^self methodPropertyAt: #argumentNames put: self argumentNames
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> generate [
	"The receiver is the root of a parse tree. Answer a CompiledMethod. The
	argument, trailer, is the references to the source code that is stored with 
	every CompiledMethod."

	^ self generate: CompiledMethodTrailer empty
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> generate: trailer [
	^ self generateIR compiledMethodWith: trailer.
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> generateIR [
	| ir |
	scope ifNil: [self doSemanticAnalysis].
 	ir := (self compilationContext astTranslatorClass new
			visitNode: self)
			ir.
	^ self ir: ir
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> generateWithSource [
	"Answer a CompiledMethod with source encoded in trailer."

	
	"for doits, we need to store the source pretty printed from the 
	AST to get the return and methodName correct"
	self selector isDoIt ifTrue: [source := self formattedCode].
	
	^self generate: (CompiledMethodTrailer new sourceCode: source).
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> ir [

	^ self propertyAt: #ir ifAbsent: [self generateIR].
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> ir: aIRMethodNode [

	^ self propertyAt: #ir put: aIRMethodNode.
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> irInstruction [
	^ self ir
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> methodProperties [
	^self propertyAt: #methodProperties ifAbsent: nil
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> methodPropertyAt: aKey [
	
	^self methodPropertyAt: aKey ifAbsent: [ self error: 'Property not found' ]
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> methodPropertyAt: aKey ifAbsent: absentBlock [
	| existingProperties |
	existingProperties := self propertyAt: #methodProperties ifAbsent: absentBlock.
	
	^existingProperties propertyAt: aKey ifAbsent: absentBlock
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> methodPropertyAt: aKey put: anObject [
	| existingProperties newProperties |
	existingProperties := self propertyAt: #methodProperties ifAbsentPut: [ 
		AdditionalMethodState forSelector: self selector].
	
	existingProperties at: aKey ifPresent: [:existingValue |
		existingProperties at: aKey put: anObject.
		^self].
	
	newProperties := existingProperties copyWith: aKey -> anObject.
	self propertyAt: #methodProperties put: newProperties
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> notShadowedTemporaryNamesFrom: aContext [
	| ownVariableNames |
	ownVariableNames := self allDefinedVariables collect: [ :var | var asString ].
	^ aContext tempNames difference: ownVariableNames
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> owningScope [
	^ self scope
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> primitiveFromPragma [
	pragmas ifNil: [ ^ IRPrimitive null ].
	^ pragmas
		detect: [ :each | each isPrimitive ]
		ifFound: [ :aPragmaPrimitive | aPragmaPrimitive asPrimitive ]
		ifNone: [ IRPrimitive null ]
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> rewriteTempsForContext: aContext [
	| rewriter contextOnlyTemps |
	rewriter := RBParseTreeRewriter new.
	contextOnlyTemps := self notShadowedTemporaryNamesFrom: aContext.
	aContext tempNames do:
			[ :tempName | 
			(contextOnlyTemps includes: tempName)
				ifTrue:
					[ rewriter
						replace: tempName , ' := ``@object' with: 'ThisContext tempNamed: ', tempName asString printString  , ' put: ``@object';
						replace: tempName with: 'ThisContext tempNamed: ' , tempName asString printString ] ].
	^ rewriter
		executeTree: self;
		tree
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> sourceNodeForPC: anInteger [
	^(self ir instructionForPC: anInteger) sourceNode
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> sourceText: aString [
	self source: aString
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBMethodNode >> startWithoutParentheses [
	^ 1
]
