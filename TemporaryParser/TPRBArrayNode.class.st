"
An RBArrayNode is an AST node for runtime arrays.

Instance Variables
	left:	 <Integer | nil> position of {
	periods: <SequenceableCollection of: Integer> the positions of all the periods that separate the statements
	right: <Integer | nil> position of }
	statements: <SequenceableCollection of: RBValueNode> the statement nodes
"
Class {
	#name : #TPRBArrayNode,
	#superclass : #TPRBValueNode,
	#instVars : [
		'left',
		'right',
		'statements',
		'periods'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBArrayNode class >> statements: statements [
	^ self new statements: statements
]

{ #category : #comparing }
TPRBArrayNode >> = anObject [ 
	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	self statements size = anObject statements size ifFalse: [ ^ false ].
	self statements with: anObject statements do: [ :first :second | first = second ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #visiting }
TPRBArrayNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitArrayNode: self
]

{ #category : #'adding nodes' }
TPRBArrayNode >> addNode: aNode [
	statements := statements asOrderedCollection
		add: aNode;
		yourself.
	aNode parent: self.
	^ aNode
]

{ #category : #'adding nodes' }
TPRBArrayNode >> addNode: aNode before: anotherNode [ 
	| index |
	aNode isReturn 
		ifTrue: [ self error: 'Cannot add return node' ].
	index := self indexOfNode: anotherNode.
	index = 0 ifTrue: [ ^ self addNode: aNode ].
	statements := statements asOrderedCollection
		add: aNode beforeIndex: index;
		yourself.
	aNode parent: self.
	^ aNode
]

{ #category : #'adding nodes' }
TPRBArrayNode >> addNodeFirst: aNode [
	statements := statements asOrderedCollection
		addFirst: aNode;
		yourself.
	aNode parent: self.
	^ aNode
]

{ #category : #'adding nodes' }
TPRBArrayNode >> addNodes: aCollection [
	statements := statements asOrderedCollection
		addAll: aCollection;
		yourself.
	aCollection do: [ :each | each parent: self ].
	^ aCollection
]

{ #category : #'adding nodes' }
TPRBArrayNode >> addNodes: aCollection before: anotherNode [ 
	aCollection do: [ :each | self addNode: each before: anotherNode ].
	^ aCollection
]

{ #category : #'adding nodes' }
TPRBArrayNode >> addNodesFirst: aCollection [
	statements := statements asOrderedCollection
		addAllFirst: aCollection;
		yourself.
	aCollection do: [ :each | each parent: self ].
	^ aCollection
]

{ #category : #accessing }
TPRBArrayNode >> children [
	^ self statements
]

{ #category : #matching }
TPRBArrayNode >> copyInContext: aDictionary [ 
	^ self class statements: (self copyList: self statements inContext: aDictionary)
]

{ #category : #comparing }
TPRBArrayNode >> equalTo: anObject withMapping: aDictionary [ 
	self class = anObject class 
		ifFalse: [ ^ false ].
	self statements size = anObject statements size 
		ifFalse: [ ^ false ].
	self statements with: anObject statements do: [ :first :second |
		(first equalTo: second withMapping: aDictionary)
			ifFalse: [ ^ false ] ].
	aDictionary values asSet size = aDictionary size 
		ifFalse: [ ^ false ].
	^ true
]

{ #category : #comparing }
TPRBArrayNode >> hash [
	^ self hashForCollection: self statements
]

{ #category : #private }
TPRBArrayNode >> indexOfNode: aNode [ 
	"Try to find the node by first looking for ==, and then for ="

	^ (1 to: statements size) 
		detect: [ :each | (statements at: each) == aNode ]
		ifNone: [ statements indexOf: aNode ]
]

{ #category : #initialization }
TPRBArrayNode >> initialize [
	super initialize.
	statements := OrderedCollection new.
	periods := #().
	left := right := 0.
]

{ #category : #testing }
TPRBArrayNode >> isDynamicArray [
	^ true
]

{ #category : #testing }
TPRBArrayNode >> isFaulty [
	^self statements anySatisfy: #isFaulty
]

{ #category : #testing }
TPRBArrayNode >> lastIsReturn [
	statements isEmpty ifTrue:[ ^false ].
	^statements last lastIsReturn
]

{ #category : #'accessing-token' }
TPRBArrayNode >> left [
	^ left
]

{ #category : #'accessing-token' }
TPRBArrayNode >> left: anInteger [
	left := anInteger
]

{ #category : #matching }
TPRBArrayNode >> match: aNode inContext: aDictionary [ 
	aNode class = self class ifFalse: [ ^ false ].
	^ self matchList: statements against: aNode statements inContext: aDictionary
]

{ #category : #testing }
TPRBArrayNode >> needsParenthesis [
	^ false
]

{ #category : #'accessing-token' }
TPRBArrayNode >> periods [
	^ periods
]

{ #category : #'accessing-token' }
TPRBArrayNode >> periods: anArray [
	periods := anArray
]

{ #category : #copying }
TPRBArrayNode >> postCopy [
	super postCopy.
	self statements: (self statements collect: [ :each | each copy ])
]

{ #category : #accessing }
TPRBArrayNode >> precedence [
	^0
]

{ #category : #testing }
TPRBArrayNode >> references: aVariableName [ 
	^ statements anySatisfy: [ :each | each references: aVariableName ]
]

{ #category : #replacing }
TPRBArrayNode >> replaceNode: oldNode  withNode: newNode [
	self statements: (statements collect: [ :statement |
		statement == oldNode 
			ifTrue: [ newNode ]
			ifFalse: [ statement ] ])
]

{ #category : #'accessing-token' }
TPRBArrayNode >> right [
	^ right
]

{ #category : #'accessing-token' }
TPRBArrayNode >> right: anInteger [
	right := anInteger
]

{ #category : #accessing }
TPRBArrayNode >> startWithoutParentheses [ 
	^ left
]

{ #category : #accessing }
TPRBArrayNode >> statementComments [
	^self comments
]

{ #category : #accessing }
TPRBArrayNode >> statements [
	^statements
]

{ #category : #accessing }
TPRBArrayNode >> statements: statements0 [ 
	statements := statements0.
	statements do: [:statement | statement parent: self]
]

{ #category : #accessing }
TPRBArrayNode >> stopWithoutParentheses [ 
	^ right
]

{ #category : #testing }
TPRBArrayNode >> uses: aNode [ 
	^ (statements anySatisfy: [ :each | each == aNode ]) or: [ self isUsed ]
]
