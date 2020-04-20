"
RBPragmaNode is an AST node that represents a method pragma.

We have a fixed set of allowed ""primitive"" pragma keywords. Every method implemented as a primitive call uses one of this pragmas.
And as we need some special treatment for methods implemented as primitive, the RBPragmaNode adds the #isPrimitive testing method.

Instance Variables:
	arguments <SequenceableCollection of: RBLiteralNode> our argument nodes
	left <Integer | nil> position of <
	right <Integer | nil> position of >
	selector	<Symbol>	the selector we're sending
	keywordsPositions	<IntegerArray | nil>	the positions of the selector keywords
"
Class {
	#name : #TPRBPragmaNode,
	#superclass : #TPRBProgramNode,
	#instVars : [
		'selector',
		'keywordsPositions',
		'arguments',
		'left',
		'right'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBPragmaNode class >> selector: aSymbol arguments: valueNodes [
	^ self selector: aSymbol keywordsPositions: nil arguments: valueNodes 
]

{ #category : #'instance creation' }
TPRBPragmaNode class >> selector: aSymbol keywordsPositions: positionList arguments: valueNodes [
	^ self new selector: aSymbol keywordsPositions: positionList arguments: valueNodes 
]

{ #category : #comparing }
TPRBPragmaNode >> = anObject [ 
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	self selector = anObject selector ifFalse: [^false].
	self arguments size = anObject arguments size ifFalse: [^false].
	self arguments
		with: anObject arguments
		do: [:first :second | first = second ifFalse: [^false]].
	^true
]

{ #category : #visiting }
TPRBPragmaNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitPragmaNode: self
]

{ #category : #accessing }
TPRBPragmaNode >> argumentAt: keywordSelector [
	^ self 
		argumentAt: keywordSelector
		ifAbsent: [ KeyNotFound signalFor: keywordSelector ]
]

{ #category : #accessing }
TPRBPragmaNode >> argumentAt: keywordSelector ifAbsent: absentBlock [
	self selectorParts with: self arguments do: [ :selectorPart :argument |
		selectorPart value = keywordSelector
			ifTrue: [ ^ argument ]].
	^ absentBlock value
]

{ #category : #accessing }
TPRBPragmaNode >> arguments [
	^ arguments ifNil: [ #() ]
]

{ #category : #accessing }
TPRBPragmaNode >> arguments: aLiteralCollection [ 
	arguments := aLiteralCollection.
	arguments do: [ :each | each parent: self ]
]

{ #category : #accessing }
TPRBPragmaNode >> children [
	^ self arguments
]

{ #category : #matching }
TPRBPragmaNode >> copyInContext: aDictionary [ 
	^ self class
		selector: self selector
		arguments: (self arguments collect: [ :each | each copyInContext: aDictionary ])
]

{ #category : #testing }
TPRBPragmaNode >> defines: aName [
	^ self isPrimitive and: [ arguments anySatisfy: [ :each | each value = aName ] ]
]

{ #category : #comparing }
TPRBPragmaNode >> equalTo: anObject withMapping: aDictionary [ 
	self class = anObject class ifFalse: [ ^ false ].
	self selector = anObject selector ifFalse: [ ^ false ].
	self arguments size = anObject arguments size ifFalse: [ ^ false ].
	self arguments with: anObject arguments do: [ :first :second |
		(first equalTo: second withMapping: aDictionary) 
			ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #comparing }
TPRBPragmaNode >> hash [
	^ self selector hash bitXor: (self hashForCollection: self arguments)
]

{ #category : #initialization }
TPRBPragmaNode >> initialize [
	super initialize.

	arguments := #().
	keywordsPositions := #().
	left := 0.
	right := 0
]

{ #category : #testing }
TPRBPragmaNode >> isBinary [
	^ (self isUnary or: [self isKeyword]) not
]

{ #category : #testing }
TPRBPragmaNode >> isFaulty [
	^self arguments anySatisfy: #isFaulty
]

{ #category : #testing }
TPRBPragmaNode >> isKeyword [
	^(selector indexOf: $:) ~= 0.
]

{ #category : #testing }
TPRBPragmaNode >> isPragma [
	^ true
]

{ #category : #testing }
TPRBPragmaNode >> isPrimitive [
	^ #(primitive: primitive:error: primitive:error:module: primitive:module: primitive:module:error:) includes: self selector
]

{ #category : #testing }
TPRBPragmaNode >> isUnary [
	^ arguments isEmpty
]

{ #category : #accessing }
TPRBPragmaNode >> keywordsIntervals [
	^selector keywords
		with: self keywordsPositions 
		collect: [:keyword :start| start to: (start = 0 ifTrue: [ -1 ] ifFalse: [ start + keyword size - 1]) ].
]

{ #category : #accessing }
TPRBPragmaNode >> keywordsPositions [
	^keywordsPositions ifNil: [ (selector keywords collect: [:char| 0 ]) asIntegerArray ]
]

{ #category : #accessing }
TPRBPragmaNode >> keywordsPositions: aPositionsList [
	keywordsPositions := aPositionsList ifNotNil: [:list| list asIntegerArray ].
]

{ #category : #'accessing-token' }
TPRBPragmaNode >> left [
	^ left
]

{ #category : #'accessing-token' }
TPRBPragmaNode >> left: anInteger [
	left := anInteger
]

{ #category : #matching }
TPRBPragmaNode >> match: aNode inContext: aDictionary [ 
	aNode class = self class
		ifFalse: [ ^ false ].
	self selector = aNode selector
		ifFalse: [ ^ false ].
	self arguments with: aNode arguments do: [ :first :second |
		(first match: second inContext: aDictionary)
			ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #accessing }
TPRBPragmaNode >> numArgs [
	^ self selector numArgs
]

{ #category : #copying }
TPRBPragmaNode >> postCopy [
	super postCopy.
	self arguments: (self arguments collect: [ :each | each copy ])
]

{ #category : #replacing }
TPRBPragmaNode >> replaceNode: aNode withNode: anotherNode [ 
	self arguments: (arguments collect: [ :each | 
		each == aNode 
			ifTrue: [ anotherNode ]
			ifFalse: [ each ] ])
]

{ #category : #'accessing-token' }
TPRBPragmaNode >> right [
	^ right
]

{ #category : #'accessing-token' }
TPRBPragmaNode >> right: anInteger [
	right := anInteger
]

{ #category : #accessing }
TPRBPragmaNode >> selector [
	^ selector
]

{ #category : #accessing }
TPRBPragmaNode >> selector: aSelector [ 
	keywordsPositions := nil.
	selector := aSelector asSymbol.
]

{ #category : #initialization }
TPRBPragmaNode >> selector: aSymbol keywordsPositions: positionList arguments: valueNodes [
	aSymbol numArgs == valueNodes size
		ifFalse: 
			[self error: 'Attempting to assign selector with wrong number of arguments.'].

	self 
		arguments: valueNodes;
		selector: aSymbol;
		keywordsPositions: positionList.
]

{ #category : #accessing }
TPRBPragmaNode >> selectorParts [
	^ selector keywords collect: [:keyword| keyword asSymbol ].
]

{ #category : #accessing }
TPRBPragmaNode >> sentMessages [
	^ super sentMessages
		add: self selector;
		yourself
]

{ #category : #accessing }
TPRBPragmaNode >> start [
	^ left
]

{ #category : #accessing }
TPRBPragmaNode >> stop [
	^ right
]
