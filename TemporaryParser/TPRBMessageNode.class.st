"
RBMessageNode is an AST node that represents a message send.

Instance Variables:
	arguments	<SequenceableCollection of: RBValueNode>	 our argument nodes
	receiver	<RBValueNode>	the receiver's node
	selector	<Symbol>	the selector we're sending
	keywordsPositions	<IntegerArray | nil>	the positions of the selector keywords


"
Class {
	#name : #TPRBMessageNode,
	#superclass : #TPRBValueNode,
	#instVars : [
		'receiver',
		'selector',
		'keywordsPositions',
		'arguments'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBMessageNode class >> receiver: aValueNode selector: aSelector [ 
	^self 
		receiver: aValueNode
		selector: aSelector
		arguments: #()
]

{ #category : #'instance creation' }
TPRBMessageNode class >> receiver: aValueNode selector: aSelector arguments: valueNodes [ 
	^self
		receiver: aValueNode
		selector: aSelector
		keywordsPositions: nil
		arguments: valueNodes.
]

{ #category : #'instance creation' }
TPRBMessageNode class >> receiver: aValueNode selector: aSelector keywordsPositions: positionList arguments: valueNodes [
	^(self new)
		receiver: aValueNode
			selector: aSelector
			keywordsPositions: positionList 
			arguments: valueNodes;
		yourself.
]

{ #category : #comparing }
TPRBMessageNode >> = anObject [ 
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	(self receiver = anObject receiver 
		and: [self selector = anObject selector]) ifFalse: [^false].
	self arguments
		with: anObject arguments
		do: [:first :second | first = second ifFalse: [^false]].
	^true
]

{ #category : #visiting }
TPRBMessageNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitMessageNode: self
]

{ #category : #accessing }
TPRBMessageNode >> argumentPartStrings [
	"Return a collection of string representing the code of the argument."
	^ arguments collect: [ :each | each formattedCode asString 
			"strangely enough literal formatted code is not a string" ]  
]

{ #category : #accessing }
TPRBMessageNode >> arguments [
	^arguments ifNil: [#()] ifNotNil: [arguments]
]

{ #category : #accessing }
TPRBMessageNode >> arguments: argCollection [ 
	arguments := argCollection.
	arguments do: [:each | each parent: self]
]

{ #category : #querying }
TPRBMessageNode >> bestNodeFor: anInterval [ 
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	self keywordsIntervals do:
			[:each | 
			((each rangeIncludes: anInterval first) 
				or: [anInterval rangeIncludes:  each first]) 
					ifTrue: [^self]].
	self children do: 
			[:each | 
			| node |
			node := each bestNodeFor: anInterval.
			node notNil ifTrue: [^node]]
]

{ #category : #accessing }
TPRBMessageNode >> children [
	^(OrderedCollection with: self receiver)
		addAll: self arguments;
		yourself
]

{ #category : #matching }
TPRBMessageNode >> copyInContext: aDictionary [ 
	^self class
		receiver: (self receiver copyInContext: aDictionary)
		selector: self selector
		arguments: (self arguments collect: [ :each | each copyInContext: aDictionary ])
]

{ #category : #accessing }
TPRBMessageNode >> debugHighlightStart [

	^ self  keywordsPositions first
]

{ #category : #accessing }
TPRBMessageNode >> debugHighlightStop [

	^ self stopWithoutParentheses
]

{ #category : #comparing }
TPRBMessageNode >> equalTo: anObject withMapping: aDictionary [ 
	self class = anObject class ifFalse: [^false].
	((self receiver equalTo: anObject receiver withMapping: aDictionary)
		and: [self selector = anObject selector]) ifFalse: [^false].
	self arguments
		with: anObject arguments
		do: [:first :second | (first equalTo: second withMapping: aDictionary) ifFalse: [^false]].
	^true
]

{ #category : #comparing }
TPRBMessageNode >> hash [
	^ (self receiver hash bitXor: self selector hash) bitXor: (self hashForCollection: self arguments)
]

{ #category : #testing }
TPRBMessageNode >> isBinary [
	^(self isUnary or: [self isKeyword]) not
]

{ #category : #testing }
TPRBMessageNode >> isCascaded [
	^parent notNil and: [parent isCascade]
]

{ #category : #'private-replacing' }
TPRBMessageNode >> isContainmentReplacement: aNode [ 
	^(self mappingFor: self receiver) = aNode 
		or: [self arguments anySatisfy: [:each | (self mappingFor: each) = aNode]]
]

{ #category : #testing }
TPRBMessageNode >> isFaulty [
	^self receiver isFaulty or: [self arguments anySatisfy: #isFaulty]
]

{ #category : #testing }
TPRBMessageNode >> isFirstCascaded [
	^self isCascaded and: [parent messages first == self]
]

{ #category : #testing }
TPRBMessageNode >> isKeyword [
	^(selector value indexOf: $:) ~= 0.
]

{ #category : #testing }
TPRBMessageNode >> isMessage [
	^true
]

{ #category : #testing }
TPRBMessageNode >> isSelfSend [
	^ self receiver isSelf
]

{ #category : #testing }
TPRBMessageNode >> isSuperSend [
	^ self receiver isVariable and: [ self receiver name = 'super' ]
]

{ #category : #testing }
TPRBMessageNode >> isUnary [
	^arguments isEmpty
]

{ #category : #accessing }
TPRBMessageNode >> keywords [
	^ selector value keywords.
]

{ #category : #accessing }
TPRBMessageNode >> keywordsIntervals [
	^ selector value keywords
		with: self keywordsPositions 
		collect: [ :keyword :start | start to: (start == 0 ifTrue: [ -1 ] ifFalse: [ start + keyword size - 1]) ].
]

{ #category : #accessing }
TPRBMessageNode >> keywordsPositions [
	^keywordsPositions ifNil: [ (selector keywords collect: [:char| 0 ]) asIntegerArray ]
]

{ #category : #accessing }
TPRBMessageNode >> keywordsPositions: aPositionsList [
	keywordsPositions := aPositionsList ifNotNil: [:list| list asIntegerArray ].
]

{ #category : #testing }
TPRBMessageNode >> lastIsReturn [
	(self isInlineIf or: [ self isInlineIfNil]) ifFalse: [ ^false ].
	arguments size = 1 ifTrue: [ ^false ].
	^ arguments first isBlock and: [ arguments first body lastIsReturn 
		and: [ arguments last isBlock and: [ arguments last body lastIsReturn ]]] 
]

{ #category : #accessing }
TPRBMessageNode >> leftmostChainReceiver [

	^ self receiver isMessage
		ifTrue: [ self receiver receiver ]
		ifFalse: [ self receiver ]
]

{ #category : #matching }
TPRBMessageNode >> match: aNode inContext: aDictionary [ 
	aNode class = self class ifFalse: [^false].
	self selector = aNode selector ifFalse: [^false].
	(receiver match: aNode receiver inContext: aDictionary) ifFalse: [^false].
	self arguments
		with: aNode arguments
		do: [:first :second | (first match: second inContext: aDictionary) ifFalse: [^false]].
	^true
]

{ #category : #testing }
TPRBMessageNode >> needsParenthesis [
	^parent 
		ifNil: [false]
		ifNotNil: 
			[self precedence > parent precedence 
				or: [self precedence = parent precedence and: [self isUnary not]]]
]

{ #category : #accessing }
TPRBMessageNode >> numArgs [
	^self selector numArgs
]

{ #category : #copying }
TPRBMessageNode >> postCopy [
	super postCopy.
	self receiver: self receiver copy.
	self arguments: (self arguments collect: [ :each | each copy ])
]

{ #category : #accessing }
TPRBMessageNode >> precedence [
	^self isUnary 
		ifTrue: [1]
		ifFalse: [self isKeyword ifTrue: [3] ifFalse: [2]]
]

{ #category : #accessing }
TPRBMessageNode >> receiver [
	^receiver
]

{ #category : #accessing }
TPRBMessageNode >> receiver: aValueNode [ 
	receiver := aValueNode.
	receiver parent: self
]

{ #category : #initialization }
TPRBMessageNode >> receiver: aValueNode selector: aSelector keywordsPositions: positionList arguments: valueNodes [
	aSelector value numArgs == valueNodes size
		ifFalse: 
			[self error: 'Attempting to assign selector with wrong number of arguments.'].

	self 
		receiver: aValueNode;
		arguments: valueNodes;
		selector: aSelector;
		keywordsPositions: positionList.
]

{ #category : #'adding/removing' }
TPRBMessageNode >> removeFromTree [

	self parent removeNode: self
]

{ #category : #'adding/removing' }
TPRBMessageNode >> removeNode: aNode [

	self replaceNode: aNode withNode: aNode receiver
]

{ #category : #accessing }
TPRBMessageNode >> renameSelector: newSelector andArguments: varNodeCollection [ 
	self
		arguments: varNodeCollection;
		selector: newSelector
]

{ #category : #'private-replacing' }
TPRBMessageNode >> replaceContainmentSourceWith: aNode [ 
	| originalNode needsParenthesis |
	needsParenthesis := aNode hasParentheses not and: [aNode needsParenthesis].
	originalNode := (self mappingFor: self receiver) = aNode 
				ifTrue: [self receiver]
				ifFalse: [self arguments detect: [:each | (self mappingFor: each) = aNode]].
	self
		addReplacement: (RBStringReplacement 
					replaceFrom: self start
					to: originalNode start - 1
					with: (needsParenthesis ifTrue: ['('] ifFalse: ['']));
		addReplacement: (RBStringReplacement 
					replaceFrom: originalNode stop + 1
					to: self stop
					with: (needsParenthesis ifTrue: [')'] ifFalse: ['']))
]

{ #category : #replacing }
TPRBMessageNode >> replaceNode: aNode withNode: anotherNode [ 
	"If we're inside a cascade node and are changing the receiver, change all the receivers"

	receiver == aNode 
		ifTrue: 
			[self receiver: anotherNode.
			(parent notNil and: [parent isCascade]) 
				ifTrue: [parent messages do: [:each | each receiver: anotherNode]]].
	self arguments: (arguments 
				collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
]

{ #category : #'private-replacing' }
TPRBMessageNode >> replaceSourceWith: aNode [ 
	(self isContainmentReplacement: aNode) 
		ifTrue: [^self replaceContainmentSourceWith: aNode].
	aNode isMessage ifFalse: [^super replaceSourceWith: aNode].
	^self replaceSourceWithMessageNode: aNode
]

{ #category : #'private-replacing' }
TPRBMessageNode >> replaceSourceWithMessageNode: aNode [ 
	| isBinaryToKeyword newSelectorParts  oldkeywordsIntervals|
	self numArgs = aNode numArgs ifFalse: [^super replaceSourceWith: aNode].
	self arguments with: aNode arguments
		do: [:old :new | (self mappingFor: old) = new ifFalse: [^super replaceSourceWith: aNode]].
	(self mappingFor: self receiver) = aNode receiver 
		ifFalse:
			[(self receiver isVariable and: [aNode receiver isVariable])
				ifFalse:
					[^super replaceSourceWith: aNode].
			self addReplacement:
				(RBStringReplacement
					replaceFrom: self receiver start
					to: self receiver stop
					with: aNode receiver name)].
	(isBinaryToKeyword := self isBinary and: [aNode isKeyword]) 
		ifTrue: 
			[(self hasParentheses not and: [self parent precedence <= aNode precedence]) 
				ifTrue: 
					[self
						addReplacement: (RBStringReplacement 
									replaceFrom: self start
									to: self start - 1
									with: '(');
						addReplacement: (RBStringReplacement 
									replaceFrom: self stop + 1
									to: self stop
									with: ')')]].
							
	newSelectorParts := aNode selectorParts.
	oldkeywordsIntervals := self keywordsIntervals.
	
	self selectorParts keysAndValuesDo: [:index :oldPart| 
			(newSelectorParts at: index) ~= oldPart
				ifTrue: 
					[self addReplacement: (RBStringReplacement 
								replaceFrom: (oldkeywordsIntervals at: index) first
								to: (oldkeywordsIntervals at: index) last
								with: ((isBinaryToKeyword 
										and: [(self source at: (oldkeywordsIntervals at: index) first - 1) isSeparator not]) 
											ifTrue: [' ' , newSelectorParts at: index]
											ifFalse: [newSelectorParts at: index]))]].
]

{ #category : #accessing }
TPRBMessageNode >> selector [
	^ selector value.
]

{ #category : #accessing }
TPRBMessageNode >> selector: aSelector [
	keywordsPositions := nil.
	selector := aSelector.
	aSelector parent: self
]

{ #category : #accessing }
TPRBMessageNode >> selectorAndArgumentNames [
	"Returns the selector and argument names portion of a method as a string"

	^ self arguments
		ifEmpty: [ self keywords first ]
		ifNotEmpty: [
			(String streamContents: [ :st | 
				self selectorParts
			 		with: self arguments 
					do: [:sel :arg | 
							st 
								<< sel asString;
								<< ' ';
								<< arg formattedCode;
								<< ' ']]) allButLast ]
								
					
]

{ #category : #accessing }
TPRBMessageNode >> selectorInterval [
	| positions |
	positions := self keywordsIntervals. 
	^positions first first to: positions last last.
]

{ #category : #'as yet unclassified' }
TPRBMessageNode >> selectorNode [
	^selector.
]

{ #category : #accessing }
TPRBMessageNode >> selectorParts [
	"Returns a collection containing all the selector composing a message"
	
	^ self keywords collect: [ :each | each asSymbol]
]

{ #category : #accessing }
TPRBMessageNode >> sentMessages [
	^ super sentMessages
		add: self selector;
		yourself
]

{ #category : #accessing }
TPRBMessageNode >> startWithoutParentheses [
	^receiver start
]

{ #category : #accessing }
TPRBMessageNode >> stopWithoutParentheses [
	^arguments isEmpty 
		ifTrue: [self keywordsIntervals first last]
		ifFalse: [arguments last stop]
]
