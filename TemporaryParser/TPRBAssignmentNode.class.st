"
RBAssignmentNode is an AST node for assignment statements.

Instance Variables:
	assignment	<Integer>	position of the :=
	value	<RBValueNode>	the value that we're assigning
	variable	<RBVariableNode>	the variable being assigned


"
Class {
	#name : #TPRBAssignmentNode,
	#superclass : #TPRBValueNode,
	#instVars : [
		'variable',
		'assignment',
		'value'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBAssignmentNode class >> variable: aVariableNode value: aValueNode [ 
	^self 
		variable: aVariableNode
		value: aValueNode
		position: nil
]

{ #category : #'instance creation' }
TPRBAssignmentNode class >> variable: aVariableNode value: aValueNode position: anInteger [ 
	^(self new)
		variable: aVariableNode
			value: aValueNode
			position: anInteger;
		yourself
]

{ #category : #comparing }
TPRBAssignmentNode >> = anObject [ 
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	^self variable = anObject variable and: [self value = anObject value]
]

{ #category : #visiting }
TPRBAssignmentNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitAssignmentNode: self
]

{ #category : #'accessing-token' }
TPRBAssignmentNode >> assignment [
	^ assignment
]

{ #category : #'accessing-token' }
TPRBAssignmentNode >> assignment: anInteger [
	assignment := anInteger
]

{ #category : #accessing }
TPRBAssignmentNode >> assignmentOperator [
	^  ':=' 
]

{ #category : #accessing }
TPRBAssignmentNode >> assignmentPosition [
	^ assignment
]

{ #category : #testing }
TPRBAssignmentNode >> assigns: aVariableName [ 
	^variable name = aVariableName or: [value assigns: aVariableName]
]

{ #category : #querying }
TPRBAssignmentNode >> bestNodeFor: anInterval [ 
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	assignment ifNil: [^super bestNodeFor: anInterval].
	((anInterval first between: assignment and: assignment + 1) 
		or: [assignment between: anInterval first and: anInterval last]) 
			ifTrue: [^self].
	self children do: 
			[:each | 
			| node |
			node := each bestNodeFor: anInterval.
			node notNil ifTrue: [^node]]
]

{ #category : #accessing }
TPRBAssignmentNode >> children [
	^Array with: value with: variable
]

{ #category : #matching }
TPRBAssignmentNode >> copyInContext: aDictionary [ 
	^ self class new
		variable: (self variable copyInContext: aDictionary);
		value: (self value copyInContext: aDictionary);
		yourself
]

{ #category : #testing }
TPRBAssignmentNode >> directlyUses: aNode [ 
	^aNode = value ifTrue: [true] ifFalse: [self isDirectlyUsed]
]

{ #category : #comparing }
TPRBAssignmentNode >> equalTo: anObject withMapping: aDictionary [ 
	^self class = anObject class and: 
			[(self variable equalTo: anObject variable withMapping: aDictionary) 
				and: [self value equalTo: anObject value withMapping: aDictionary]]
]

{ #category : #comparing }
TPRBAssignmentNode >> hash [
	^self variable hash bitXor: self value hash
]

{ #category : #testing }
TPRBAssignmentNode >> isAssignment [
	^true
]

{ #category : #testing }
TPRBAssignmentNode >> isFaulty [
	^self variable isFaulty or: [ self value isFaulty ]
]

{ #category : #matching }
TPRBAssignmentNode >> match: aNode inContext: aDictionary [ 
	aNode class = self class ifFalse: [^false].
	^(variable match: aNode variable inContext: aDictionary)
		and: [value match: aNode value inContext: aDictionary]
]

{ #category : #testing }
TPRBAssignmentNode >> needsParenthesis [
	^parent
		ifNil: [false]
		ifNotNil: [self precedence > parent precedence]
]

{ #category : #copying }
TPRBAssignmentNode >> postCopy [
	super postCopy.
	self variable: self variable copy.
	self value: self value copy
]

{ #category : #accessing }
TPRBAssignmentNode >> precedence [
	^5
]

{ #category : #'adding/removing' }
TPRBAssignmentNode >> removeNode: aNode [

	self replaceNode: aNode withNode: aNode receiver
]

{ #category : #replacing }
TPRBAssignmentNode >> replaceNode: aNode withNode: anotherNode [ 
	value == aNode ifTrue: [self value: anotherNode].
	variable == aNode ifTrue: [self variable: anotherNode]
]

{ #category : #replacing }
TPRBAssignmentNode >> replaceSourceWith: aNode [ 
	"Check if we need to convert the assignment. Also check if we are being replaced with a setter message send. If so, create the replacements to edit the original source."

	(aNode isAssignment and: [ aNode assignmentOperator ~= self assignmentOperator ]) ifTrue: [
		self addReplacement: (RBStringReplacement 
			replaceFrom: self assignmentPosition
			to: self assignmentPosition + self assignmentOperator size - 1
			with: aNode assignmentOperator).
		(aNode variable = variable and: [ aNode value = value ])
			ifTrue: [ ^ self ] ].
	aNode isMessage ifFalse: [^super replaceSourceWith: aNode].
	aNode receiver isVariable ifFalse: [^super replaceSourceWith: aNode].
	aNode numArgs = 1 ifFalse: [^super replaceSourceWith: aNode].
	(self mappingFor: self value) = aNode arguments first 
		ifFalse: [^super replaceSourceWith: aNode].
	(self value hasParentheses not 
		and: [aNode arguments first precedence >= aNode precedence]) 
			ifTrue: 
				[self
					addReplacement: (RBStringReplacement 
								replaceFrom: self value start
								to: self value start - 1
								with: '(');
					addReplacement: (RBStringReplacement 
								replaceFrom: self value stop + 1
								to: self value stop
								with: ')')].
	self addReplacement: (RBStringReplacement 
				replaceFrom: self variable start
				to: self assignmentPosition + 1
				with: aNode receiver name , ' ' , aNode selector)
]

{ #category : #accessing }
TPRBAssignmentNode >> startWithoutParentheses [
	^variable start
]

{ #category : #accessing }
TPRBAssignmentNode >> stopWithoutParentheses [
	^value stop
]

{ #category : #testing }
TPRBAssignmentNode >> uses: aNode [ 
	^aNode = value ifTrue: [true] ifFalse: [self isUsed]
]

{ #category : #accessing }
TPRBAssignmentNode >> value [
	^value
]

{ #category : #accessing }
TPRBAssignmentNode >> value: aValueNode [ 
	value := aValueNode.
	value parent: self
]

{ #category : #accessing }
TPRBAssignmentNode >> variable [
	^variable
]

{ #category : #accessing }
TPRBAssignmentNode >> variable: varNode [ 
	variable := varNode.
	variable parent: self
]

{ #category : #initialization }
TPRBAssignmentNode >> variable: aVariableNode value: aValueNode position: anInteger [ 
	self variable: aVariableNode.
	self value: aValueNode.
	assignment := anInteger
]
