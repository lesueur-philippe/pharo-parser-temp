"
RBBlockNode is an AST node that represents a block ""[...]"".

Like RBMethodNode, the scope attribute is only valid after doing a semantic analyzing step.

Instance Variables:
	arguments	<SequenceableCollection of: RBVariableNode>	the arguments for the block
	bar	<Integer | nil>	position of the | after the arguments
	body	<RBSequenceNode>	the code inside the block
	colons	<SequenceableCollection of: Integer>	positions of each : before each argument
	left	<Integer>	position of [
	right	<Integer>	position of ]
	scope	<OCBlockScope | OCOptimizedBlockScope | nil> the scope associated with this code of this block


"
Class {
	#name : #TPRBBlockNode,
	#superclass : #TPRBValueNode,
	#instVars : [
		'left',
		'right',
		'colons',
		'arguments',
		'bar',
		'body',
		'scope'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBBlockNode class >> arguments: argNodes body: sequenceNode [ 
	^(self new)
		arguments: argNodes;
		body: sequenceNode;
		yourself
]

{ #category : #'instance creation' }
TPRBBlockNode class >> body: sequenceNode [ 
	^self arguments: #() body: sequenceNode
]

{ #category : #comparing }
TPRBBlockNode >> = anObject [ 
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	self body = anObject body ifFalse: [^false].
	self arguments size = anObject arguments size ifFalse: [^false].
	self arguments with: anObject arguments do: [:first :second | first = second ifFalse: [^false]].
	^true
]

{ #category : #visiting }
TPRBBlockNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitBlockNode: self
]

{ #category : #accessing }
TPRBBlockNode >> allArgumentVariables [
	^(self argumentNames asOrderedCollection)
		addAll: super allArgumentVariables;
		yourself
]

{ #category : #accessing }
TPRBBlockNode >> allDefinedVariables [
	^(self argumentNames asOrderedCollection)
		addAll: super allDefinedVariables;
		yourself
]

{ #category : #accessing }
TPRBBlockNode >> argumentNames [
	^ self arguments collect: [:each | each name] as: Array 
]

{ #category : #accessing }
TPRBBlockNode >> arguments [
	^arguments
]

{ #category : #accessing }
TPRBBlockNode >> arguments: argCollection [ 
	arguments := argCollection.
	arguments do: [:each | each parent: self ]
]

{ #category : #'accessing-token' }
TPRBBlockNode >> bar [
	^ bar
]

{ #category : #'accessing-token' }
TPRBBlockNode >> bar: anInteger [
	bar := anInteger
]

{ #category : #accessing }
TPRBBlockNode >> blockVariables [
	| vars |
	vars := super blockVariables asOrderedCollection.
	vars addAll: self argumentNames.
	^vars
]

{ #category : #accessing }
TPRBBlockNode >> body [
	^body
]

{ #category : #accessing }
TPRBBlockNode >> body: stmtsNode [ 
	body := stmtsNode.
	body parent: self
]

{ #category : #accessing }
TPRBBlockNode >> children [
	^self arguments copyWith: self body
]

{ #category : #'accessing-token' }
TPRBBlockNode >> colons [
	^ colons
]

{ #category : #'accessing-token' }
TPRBBlockNode >> colons: anArray [ 
	colons := anArray
]

{ #category : #matching }
TPRBBlockNode >> copyInContext: aDictionary [ 
	^ self class new
		arguments: (self copyList: self arguments inContext: aDictionary);
		body: (self body copyInContext: aDictionary);
		yourself
]

{ #category : #testing }
TPRBBlockNode >> defines: aName [ 
	^arguments anySatisfy: [:each | each name = aName]
]

{ #category : #testing }
TPRBBlockNode >> directlyUses: aNode [ 
	^false
]

{ #category : #comparing }
TPRBBlockNode >> equalTo: anObject withMapping: aDictionary [ 
	self class = anObject class ifFalse: [^false].
	self arguments size = anObject arguments size ifFalse: [^false].
	self arguments
		with: anObject arguments
		do: [:first :second |	(first equalTo: second withMapping: aDictionary) ifFalse: [^false]].
	(self body equalTo: anObject body withMapping: aDictionary)
		ifFalse: [^false].
	self arguments do: [:each | aDictionary removeKey: each name].
	^true
]

{ #category : #testing }
TPRBBlockNode >> hasArgumentNamed: aString [	
	^ self arguments anySatisfy: [ :argument| argument name = aString ]
]

{ #category : #testing }
TPRBBlockNode >> hasBlockReturn [
	^ self body lastIsReturn
]

{ #category : #testing }
TPRBBlockNode >> hasTemporaryNamed: aString [	
	^ self temporaries anySatisfy: [ :temp| temp name = aString ]
]

{ #category : #comparing }
TPRBBlockNode >> hash [
	^ (self hashForCollection: self arguments) bitXor: self body hash
]

{ #category : #initialization }
TPRBBlockNode >> initialize [
	super initialize.

	arguments := #().
	colons := #().
	left := 0.
	right := 0
]

{ #category : #testing }
TPRBBlockNode >> isBlock [
	^true
]

{ #category : #testing }
TPRBBlockNode >> isFaulty [
	^(self arguments anySatisfy:  #isFaulty ) or: [ self body isFaulty]
]

{ #category : #testing }
TPRBBlockNode >> isImmediateNode [
	^true
]

{ #category : #testing }
TPRBBlockNode >> isLast: aNode [ 
	^body isLast: aNode
]

{ #category : #testing }
TPRBBlockNode >> lastIsReturn [
	^ false
]

{ #category : #'accessing-token' }
TPRBBlockNode >> left [
	^ left
]

{ #category : #'accessing-token' }
TPRBBlockNode >> left: anInteger [
	left := anInteger
]

{ #category : #matching }
TPRBBlockNode >> match: aNode inContext: aDictionary [ 
	aNode class = self class ifFalse: [^false].
	^(self 
		matchList: arguments
		against: aNode arguments
		inContext: aDictionary) 
			and: [body match: aNode body inContext: aDictionary]
]

{ #category : #accessing }
TPRBBlockNode >> methodOrBlockNode [
	"^ self"
]

{ #category : #testing }
TPRBBlockNode >> needsParenthesis [
	^false
]

{ #category : #copying }
TPRBBlockNode >> postCopy [
	super postCopy.
	self arguments: (self arguments collect: [ :each | each copy ]).
	self body: self body copy
]

{ #category : #accessing }
TPRBBlockNode >> precedence [
	^0
]

{ #category : #testing }
TPRBBlockNode >> references: aVariableName [ 
	^body references: aVariableName
]

{ #category : #'adding/removing' }
TPRBBlockNode >> removeTemporaryNamed: aName [

	self body removeTemporaryNamed: aName
]

{ #category : #replacing }
TPRBBlockNode >> replaceNode: aNode withNode: anotherNode [ 
	body == aNode ifTrue: [self body: anotherNode].
	self arguments: (arguments 
				collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
]

{ #category : #'accessing-token' }
TPRBBlockNode >> right [
	^ right
]

{ #category : #'accessing-token' }
TPRBBlockNode >> right: anInteger [
	right := anInteger
]

{ #category : #accessing }
TPRBBlockNode >> scope [
	^ scope
]

{ #category : #accessing }
TPRBBlockNode >> scope: aScopedNode [
	scope := aScopedNode
]

{ #category : #accessing }
TPRBBlockNode >> startWithoutParentheses [
	^ left
]

{ #category : #accessing }
TPRBBlockNode >> statementComments [
	"this is used for formatting comments for this node as a statement, but I don't have a single statement comment, my comments are place within the block code"

	^ ''
]

{ #category : #accessing }
TPRBBlockNode >> statements [
	^ self body statements
]

{ #category : #accessing }
TPRBBlockNode >> stopWithoutParentheses [
	^ right
]

{ #category : #accessing }
TPRBBlockNode >> temporaries [
	^ self body temporaries
]

{ #category : #accessing }
TPRBBlockNode >> temporaryNames [
	^ self body temporaryNames
]

{ #category : #testing }
TPRBBlockNode >> uses: aNode [ 
	aNode = body ifFalse: [^false].
	^parent isMessage 
		ifTrue: 
			[(#(#ifTrue:ifFalse: #ifTrue: #ifFalse: #ifFalse:ifTrue:) 
				includes: parent selector) not 
				or: [parent isUsed]]
		ifFalse: [self isUsed]
]
