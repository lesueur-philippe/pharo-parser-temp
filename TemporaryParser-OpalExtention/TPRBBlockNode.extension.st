Extension { #name : #TPRBBlockNode }

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBBlockNode >> ir [

	^ self propertyAt: #ir ifAbsent: [ self parent methodOrBlockNode ir ]
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBBlockNode >> ir: aIRMethodNode [

	^ self propertyAt: #ir put: aIRMethodNode.
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBBlockNode >> irInstruction [
	^ self parent methodOrBlockNode ir firstInstructionMatching: [:instr | instr sourceNode == self ]
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBBlockNode >> isClean [
	"a block is clean if it has no escaping vars, has no non local return and its children are clean"
	self isInlined ifTrue: [ ^ false ].
	self scope hasEscapingVars ifTrue: [ ^ false ].
	self hasBlockReturn ifTrue: [ ^ false ].
	^ super isClean
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBBlockNode >> isInlined [
	parent isMessage ifFalse: [ ^ false ].
	parent isInlineAndOr ifTrue: [^ true].
	parent isInlineIf ifTrue: [^ true].
	parent isInlineIfNil ifTrue: [^ true].
	^ self isInlinedLoop
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBBlockNode >> isInlinedLoop [
	parent isMessage ifFalse: [ ^ false ].
	parent isInlineToDo ifTrue: [^ true].
	parent isInlineWhile ifTrue: [^ true].
	parent isInlineTimesRepeat ifTrue: [^ true].
	parent isInlineRepeat ifTrue: [ ^true ].
	(parent parent isDynamicArray and: [parent parent parent isMessage and: [parent parent parent isInlineCase]]) ifTrue: [^ true].
	parent isInlineCase ifTrue: [^ true].  "otherwise branch"
	^ false
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBBlockNode >> owningScope [

	^ self scope ifNil: ["inlined" ^ parent owningScope]
]

{ #category : #'*TemporaryParser-OpalExtention' }
TPRBBlockNode >> sourceNodeForPC: anInteger [ 
	self methodNode ir.
	(self hasProperty: #ir) ifTrue: [ "FullBlockClosure"
		^(self ir fullBlockInstructionForPC: anInteger) sourceNode ].
	^ self methodNode sourceNodeForPC: anInteger
]
