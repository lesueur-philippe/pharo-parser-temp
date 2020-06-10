Extension { #name : #TPRBProgramNode }

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBProgramNode >> asDoit [
	"The VM can only evaluate methods. wrap this ast in a doit MethodNode"
	^TPRBMethodNode 
		selector: #DoIt
		body: self asSequenceNode transformLastToReturn.
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBProgramNode >> asDoitForContext: aContext [
	"The VM can only evaluate methods. wrap this ast in a doitIn MethodNode to evaluate in a context"
	| methodNode |
	
	methodNode := RBMethodNode 
		selector: #DoItIn:
		arguments: { TPRBVariableNode named: 'ThisContext' } 
		body: self asSequenceNode transformLastToReturn.
	
	methodNode methodClass: aContext receiver class.
	methodNode rewriteTempsForContext: aContext.
	^methodNode
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBProgramNode >> asSequenceNode [
	^TPRBSequenceNode statements: {self} 
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBProgramNode >> doSemanticAnalysis [
	self methodNode ifNil: [ ^self ].
	^ self methodNode doSemanticAnalysis.
	
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBProgramNode >> doSemanticAnalysisIn: aClass [
	self methodNode ifNil: [ ^self ].
	^ self methodNode doSemanticAnalysisIn: aClass
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBProgramNode >> irInstruction [
	^ self methodOrBlockNode ir firstInstructionMatching: [:instr | instr sourceNode == self ]
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBProgramNode >> isClean [
	^ self children allSatisfy: [ :child | child isClean ]
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBProgramNode >> owningScope [

	^ parent owningScope 
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBProgramNode >> printAsIfCompiledOn: aStream [ 
	aStream nextPutAll: self formattedCode
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBProgramNode >> scope [
	^ self methodOrBlockNode scope
]
