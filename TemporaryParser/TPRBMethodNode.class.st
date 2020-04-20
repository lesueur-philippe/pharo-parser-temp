"
RBMethodNode is the node that represents AST of a Smalltalk method.

Some properties aren't known to the parser creating this Object. For example, the scope value isn't known by parsing the code but only after doing a
semantic analysis. Likewise, the compilation context isn't needed until we try to do the semantic analysis. 

Instance Variables:
	arguments	<SequenceableCollection of: RBVariableNode>	the arguments to the method
	body	<BRSequenceNode>	the body/statements of the method
	nodeReplacements	<Dictionary>	a dictionary of oldNode -> newNode replacements
	replacements	<Collection of: RBStringReplacement>	the collection of string replacements for each node replacement in the parse tree
	selector	<Symbol>	the method name
	keywordsPositions	<IntegerArray | nil>	the positions of the selector keywords
	source	<String>	the source we compiled
	scope	<OCMethodScope | nil> the scope associated with this code of this method
	pragmas	< SequenceableCollection of: RBPragmaNodes > Nodes representing the pragma statements in this method
	compilationContext	<CCompilationContext | CompilationContext>

"
Class {
	#name : #TPRBMethodNode,
	#superclass : #TPRBProgramNode,
	#instVars : [
		'scope',
		'selector',
		'keywordsPositions',
		'body',
		'source',
		'arguments',
		'pragmas',
		'replacements',
		'nodeReplacements',
		'compilationContext'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBMethodNode class >> selector: aSymbol arguments: valueNodes [
	^(self new)
		selector: aSymbol;
		arguments: valueNodes;
		yourself
]

{ #category : #'instance creation' }
TPRBMethodNode class >> selector: aSymbol arguments: variableNodes body: aSequenceNode [ 
	^(self new)
		arguments: variableNodes;
		selector: aSymbol;
		body: aSequenceNode;
		yourself
]

{ #category : #'instance creation' }
TPRBMethodNode class >> selector: aSymbol body: aSequenceNode [ 
	^self 
		selector: aSymbol
		arguments: #()
		body: aSequenceNode
]

{ #category : #'instance creation' }
TPRBMethodNode class >> selector: aSymbol keywordsPositions: positionList arguments: valueNodes [
	^(self new)
		selector: aSymbol
			keywordsPositions: positionList 
			arguments: valueNodes;
		yourself.
]

{ #category : #comparing }
TPRBMethodNode >> = anObject [ 
	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	(self selector = anObject selector
		and: [ self pragmas size = anObject pragmas size
		and: [ self body = anObject body ] ])
			ifFalse: [ ^ false ].
	self arguments with: anObject arguments do: [ :first :second |
		first = second 
			ifFalse: [ ^ false ] ].
	self pragmas with: anObject pragmas do: [ :first :second |
		first = second 
			ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #visiting }
TPRBMethodNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitMethodNode: self
]

{ #category : #'adding/removing' }
TPRBMethodNode >> addNode: aNode [
	^ body addNode: aNode
]

{ #category : #'adding/removing' }
TPRBMethodNode >> addPragma: aPragmaNode [

	pragmas ifNil: [ self pragmas: OrderedCollection new ].
	pragmas add: aPragmaNode
]

{ #category : #replacing }
TPRBMethodNode >> addReplacement: aStringReplacement [ 
	replacements ifNil: [^self].
	replacements add: aStringReplacement
]

{ #category : #'adding/removing' }
TPRBMethodNode >> addReturn [
	^ body addReturn
]

{ #category : #'adding/removing' }
TPRBMethodNode >> addSelfReturn [
	^ body addSelfReturn
]

{ #category : #accessing }
TPRBMethodNode >> allArgumentVariables [
	^(self argumentNames asOrderedCollection)
		addAll: super allArgumentVariables;
		yourself
]

{ #category : #accessing }
TPRBMethodNode >> allDefinedVariables [
	^(self argumentNames asOrderedCollection)
		addAll: super allDefinedVariables;
		yourself
]

{ #category : #iterating }
TPRBMethodNode >> allSequenceNodes [

	^ self allChildren select: #isSequence
]

{ #category : #accessing }
TPRBMethodNode >> argumentNames [
	^ self arguments collect: [:each | each name] as: Array
]

{ #category : #accessing }
TPRBMethodNode >> arguments [
	^arguments
]

{ #category : #accessing }
TPRBMethodNode >> arguments: variableNodes [ 
	arguments := variableNodes.
	arguments do: [:each | each parent: self]
]

{ #category : #converting }
TPRBMethodNode >> asSequenceNode [
	^body
]

{ #category : #accessing }
TPRBMethodNode >> body [
	^body
]

{ #category : #accessing }
TPRBMethodNode >> body: stmtsNode [ 
	body := stmtsNode.
	body parent: self
]

{ #category : #'private-replacing' }
TPRBMethodNode >> changeSourceSelector: oldSelector keywordsIntervals: oldIntervals arguments: oldArguments [
	"If this is the same number of arguments, we try a one to one replacement of selector parts and arguments. If this is not the c
ase try to rewrite the signature as a whole, what unfortunately drops the comments within the signature."

	[ (oldIntervals size = self keywordsPositions size and: [ oldArguments size = arguments size ])
		ifTrue: [
			self selectorParts keysAndValuesDo: [ :index :part |
				self addReplacement: (RBStringReplacement 
					replaceFrom: (oldIntervals at: index) first
					to: (oldIntervals at: index) last
					with: part) ].
			oldArguments with: arguments do: [ :old :new | 
				self addReplacement: (RBStringReplacement 
					replaceFrom: old start
					to: old stop
					with: new name) ] ]
		ifFalse: [
			self addReplacement: (RBStringReplacement
				replaceFrom: oldIntervals first first
				to: (oldArguments notEmpty
					ifTrue: [ oldArguments last stop ]
					ifFalse: [ oldIntervals last last ])
				with: (String streamContents: [ :stream |
					self selectorParts keysAndValuesDo: [ :index :part |
						index = 1 ifFalse: [ stream space ].
						stream nextPutAll: part.
						index <= arguments size
							ifTrue: [ stream space; nextPutAll: (arguments at: index) name ] ] ])) ] ]
		on: Error
		do: [ :ex | ex return ]
]

{ #category : #accessing }
TPRBMethodNode >> children [
	^ OrderedCollection new
		addAll: self arguments;
		addAll: self pragmas;
		add: self body;
		yourself
]

{ #category : #replacing }
TPRBMethodNode >> clearReplacements [
	replacements := nil
]

{ #category : #'accessing compiled method' }
TPRBMethodNode >> compilationContext [
	^ compilationContext
]

{ #category : #'accessing compiled method' }
TPRBMethodNode >> compilationContext: aCompilationContext [
	compilationContext := aCompilationContext.
]

{ #category : #completion }
TPRBMethodNode >> completionToken [
	^ self selector
]

{ #category : #'accessing - conceptual' }
TPRBMethodNode >> conceptualArgumentSize [
	"Return the cumulted length of the parameters (yes parameters are called arguments in Pharo - not good!). It does not count spaces and the selectors.
	Note that this length is based on the tree structure and not the source code. It does not reflect the selection interval but the space the selector would take if displayed on a single line without any space."

	^ self arguments
		inject: 0
		into: [ :sum :each | sum + each name size ]
]

{ #category : #'accessing - conceptual' }
TPRBMethodNode >> conceptualSelectorSize [
	"Return the length of the selector. It does not take into length of parameters nor the spaces.
	Note that this length is based on the tree structure and not the source code. It does not reflect the selection interval but the space the selector would take if displayed on a single line without any space."

	^ selector size
]

{ #category : #'accessing - conceptual' }
TPRBMethodNode >> conceptualSignatureSize [
	"Return the full length of the method signature (called with a strange name in Pharo: the patterned selector. Note that this length is based on the tree structure and not the source code. It does not reflect the selection interval but the space the signature would take if displayed on a single line."

	"When we count foo: a b: b, we add three extras spaces so args size * 2 - 1"

	^ self conceptualSelectorSize + self conceptualArgumentSize
		+ (self arguments
		ifNotEmpty: [ self arguments size * 2 - 1 ]
		ifEmpty: [ 0 ])
]

{ #category : #matching }
TPRBMethodNode >> copyInContext: aDictionary [
	^ self class new
		selector: self selector;
		arguments: (self arguments collect: [ :each | each copyInContext: aDictionary ]);
		pragmas: (self pragmas isEmpty
			ifTrue: [ aDictionary at: '-pragmas-' ifAbsent: [ #() ] ]
			ifFalse: [ self copyList: self pragmas inContext: aDictionary ]);
		body: (self body copyInContext: aDictionary);
		source: (aDictionary at: '-source-' ifAbsentPut: [ self source ]);
		yourself
]

{ #category : #accessing }
TPRBMethodNode >> decompileString [ 

	^ self formattedCode 

]

{ #category : #testing }
TPRBMethodNode >> defines: aName [
^ (arguments anySatisfy: [ :each | each name = aName ])

		or: [ self pragmas anySatisfy: [ :pragma | pragma defines: aName ] ]
]

{ #category : #comparing }
TPRBMethodNode >> equalTo: anObject withMapping: aDictionary [ 
	self class = anObject class ifFalse: [ ^ false ].
	(self selector = anObject selector
		and: [ self pragmas size = anObject pragmas size
		and: [ self body equalTo: anObject body withMapping: aDictionary ] ]) 
			ifFalse: [ ^ false ].
	self arguments with: anObject arguments do: [ :first :second |
		(first equalTo: second	withMapping: aDictionary)
			ifFalse: [ ^ false ].
		aDictionary removeKey: first name ].
	self pragmas with: anObject pragmas do: [ :first :second |
		(first equalTo: second	withMapping: aDictionary) 
			ifFalse: [ ^ false ] ].
	^ true
]

{ #category : #'tree accessing' }
TPRBMethodNode >> extractSubtreeWith: aSourceCode [
	| extractedTree |
	extractedTree := self parserClass
		parseExpression: aSourceCode
		onError: [ :string :pos | ^ nil ].
	extractedTree ifNil: [ ^ nil ].
	(extractedTree isSequence and: [ extractedTree statements isEmpty ])
		ifTrue: [ ^ nil ].
	extractedTree := extractedTree isSequence
		ifTrue:
			[ RBParseTreeSearcher treeMatchingStatements: aSourceCode in: self ]
		ifFalse:
			[ RBParseTreeSearcher treeMatching: aSourceCode in: self ].	"or: [aTree isReturn]"
	^ extractedTree
		ifNotNil: [ extractedTree parent: (self parentOfSubtree: extractedTree) ]
]

{ #category : #accessing }
TPRBMethodNode >> firstPrecodeComment [
	| comment  | 
	self comments ifEmpty: [ ^nil ].
	comment :=  self comments first.
	^self source copyFrom: comment start to: comment stop.
]

{ #category : #testing }
TPRBMethodNode >> hasArgumentNamed: aString [	
	^ self arguments anySatisfy: [ :argument| argument name = aString ]
]

{ #category : #testing }
TPRBMethodNode >> hasPragmaNamed: aSymbol [	
	self pragmaNamed: aSymbol ifAbsent: [ ^ false ].
	^ true
]

{ #category : #testing }
TPRBMethodNode >> hasTemporaryNamed: aString [	
	^ self temporaries anySatisfy: [ :temp| temp name = aString ]
]

{ #category : #comparing }
TPRBMethodNode >> hash [
	^ ((self selector hash bitXor: (self hashForCollection: self arguments)) bitXor: (self hashForCollection: self pragmas)) bitXor: self body hash
]

{ #category : #initialization }
TPRBMethodNode >> initialize [
	replacements := SortedCollection sortBlock: 
					[:a :b | 
					a startPosition < b startPosition 
						or: [a startPosition = b startPosition and: [a stopPosition < b stopPosition]]].
	nodeReplacements := IdentityDictionary new
]

{ #category : #testing }
TPRBMethodNode >> isFaulty [
	(self arguments anySatisfy: #isFaulty) ifTrue:[ ^true].
	(self pragmas anySatisfy: #isFaulty) ifTrue:[ ^true].
	^self body isFaulty
]

{ #category : #testing }
TPRBMethodNode >> isLast: aNode [ 
	^body isLast: aNode
]

{ #category : #testing }
TPRBMethodNode >> isMethod [
	^true
]

{ #category : #testing }
TPRBMethodNode >> isPrimitive [
	^ self pragmas anySatisfy: [ :each | each isPrimitive ]
]

{ #category : #accessing }
TPRBMethodNode >> keywords [
	^ selector keywords.
]

{ #category : #accessing }
TPRBMethodNode >> keywordsIntervals [
	^selector keywords
		with: self keywordsPositions 
		collect: [:keyword :start| start to: (start = 0 ifTrue: [ -1 ] ifFalse: [ start + keyword size - 1]) ]
]

{ #category : #accessing }
TPRBMethodNode >> keywordsPositions [
	^keywordsPositions ifNil: [ (selector keywords collect: [:char| 0 ]) asIntegerArray ]
]

{ #category : #accessing }
TPRBMethodNode >> keywordsPositions: aPositionsList [
	keywordsPositions := aPositionsList ifNotNil: [:list| list asIntegerArray ]
]

{ #category : #testing }
TPRBMethodNode >> lastIsReturn [
	^body lastIsReturn
]

{ #category : #replacing }
TPRBMethodNode >> map: oldNode to: newNode [ 
	nodeReplacements at: oldNode put: newNode
]

{ #category : #replacing }
TPRBMethodNode >> mappingFor: oldNode [ 
	^nodeReplacements at: oldNode ifAbsent: [oldNode]
]

{ #category : #matching }
TPRBMethodNode >> match: aNode inContext: aDictionary [ 
	self class = aNode class ifFalse: [ ^ false ].
	aDictionary at: '-source-' put: aNode source.
	self selector = aNode selector ifFalse: [ ^ false ].
	^ (self matchList: arguments against: aNode arguments inContext: aDictionary)
		and: [ (self matchPragmas: self pragmas against: aNode pragmas inContext: aDictionary)
		and: [ body match: aNode body inContext: aDictionary ] ]
]

{ #category : #matching }
TPRBMethodNode >> matchPragmas: matchNodes against: pragmaNodes inContext: aDictionary [
	matchNodes isEmpty ifTrue: [ 
		aDictionary at: '-pragmas-' put: pragmaNodes.
		^ true ].
	^ matchNodes allSatisfy: [ :matchNode |
		pragmaNodes anySatisfy: [ :pragmaNode |
			matchNode match: pragmaNode inContext: aDictionary ] ]
]

{ #category : #'accessing compiled method' }
TPRBMethodNode >> method [
	"return the method that I have been compiled for"
	self compilationContext ifNil: [ ^nil ].
	^self compilationContext getClass >> self selector
]

{ #category : #'accessing compiled method' }
TPRBMethodNode >> methodClass [
	^self compilationContext getClass 
]

{ #category : #'accessing compiled method' }
TPRBMethodNode >> methodClass: aClass [	
	compilationContext ifNil: [compilationContext := aClass compiler compilationContext].
	self compilationContext class: aClass
]

{ #category : #accessing }
TPRBMethodNode >> methodComments [
	| methodComments |
	methodComments := OrderedCollection withAll: self comments.
	arguments do: [:each | methodComments addAll: each comments].
	^methodComments asSortedCollection: [:a :b | a start < b start]
]

{ #category : #accessing }
TPRBMethodNode >> methodNode [
	^self
]

{ #category : #accessing }
TPRBMethodNode >> methodOrBlockNode [
	"^ self"
]

{ #category : #accessing }
TPRBMethodNode >> newSource [
	replacements ifNil: [^self formattedCode].
	^[self reformatSource] on: Error do: [:ex | ex return: self formattedCode]
]

{ #category : #accessing }
TPRBMethodNode >> numArgs [
	^self selector numArgs
]

{ #category : #'tree accessing' }
TPRBMethodNode >> parentOfSubtree: subtree [

	| sourceCode |
	sourceCode := subtree formattedCode.
	^ self allChildren reversed
		detect: [ :e | e formattedCode includesSubstring: sourceCode ]
		ifFound: [ :e | e parent ] 
		ifNone: [ nil ]
]

{ #category : #copying }
TPRBMethodNode >> postCopy [
	super postCopy.
	self arguments: (self arguments collect: [ :each | each copy ]).
	self pragmas: (self pragmas collect: [ :each | each copy ]).
	self body: self body copy
]

{ #category : #testing }
TPRBMethodNode >> pragmaNamed: aSymbol [	
	^ self pragmaNamed: aSymbol ifAbsent: [ KeyNotFound signalFor: aSymbol  ]
]

{ #category : #testing }
TPRBMethodNode >> pragmaNamed: aSymbol ifAbsent: absentBlock [
	^ self pragmas 
		detect: [ :pragma| pragma selector = aSymbol ]
		ifNone: absentBlock
]

{ #category : #testing }
TPRBMethodNode >> pragmaNamed: aSymbol ifPresent: foundBlock [
	^ self pragmas 
		detect: [ :pragma| pragma selector = aSymbol ]
		ifFound: foundBlock
]

{ #category : #testing }
TPRBMethodNode >> pragmaNamed: aSymbol ifPresent: presentBlock ifAbsent: absentBlock [
	^ self pragmas 
		detect: [ :pragma| pragma selector = aSymbol ]
		ifFound: presentBlock
		ifNone: absentBlock
]

{ #category : #accessing }
TPRBMethodNode >> pragmas [
	^ pragmas ifNil: [ #() ]
]

{ #category : #accessing }
TPRBMethodNode >> pragmas: aCollection [
	pragmas := aCollection.
	pragmas do: [ :each | each parent: self ]
]

{ #category : #accessing }
TPRBMethodNode >> primitiveSources [
	^ self pragmas collect: [ :each | self source copyFrom: each first to: each last ]
]

{ #category : #printing }
TPRBMethodNode >> printOn: aStream [ 
	aStream nextPutAll: self formattedCode
]

{ #category : #testing }
TPRBMethodNode >> references: aVariableName [ 
	^body references: aVariableName
]

{ #category : #private }
TPRBMethodNode >> reformatSource [
	| stream newSource newTree |
	stream := (String new: source size + 100) writeStream.
	stream
		nextPutAll:
			(source
				copyFrom:
					(replacements
						inject: 1
						into: [ :sum :each | 
							stream
								nextPutAll: (source copyFrom: sum to: each startPosition - 1);
								nextPutAll: each string.
							each stopPosition + 1 ])
				to: source size).
	newSource := stream contents.
	newTree := self parserClass parseFaultyMethod: newSource.
	self = newTree
		ifFalse: [ ^ self formattedCode ].
	^ newSource
]

{ #category : #'adding/removing' }
TPRBMethodNode >> removePragma: aPragmaNode [

	pragmas remove: aPragmaNode ifAbsent: [ ]
]

{ #category : #'adding/removing' }
TPRBMethodNode >> removeSubtree: aTree [

	^ aTree isReturn 
		ifTrue: [ RBParseTreeRewriter 
					 replace: aTree formattedCode
					 with: '' in: self
					 onInterval: aTree sourceInterval ]
		ifFalse: [ RBParseTreeRewriter 
					  replaceStatements: aTree formattedCode
		 			  with: '' in: self
					  onInterval: aTree sourceInterval ]
]

{ #category : #accessing }
TPRBMethodNode >> renameSelector: newSelector andArguments: varNodeCollection [ 
	| oldIntervals oldArguments oldSelector |
	oldSelector := selector.
	oldIntervals := self keywordsIntervals.
	oldArguments := arguments.
	self
		arguments: varNodeCollection;
		selector: newSelector.
	self changeSourceSelector: oldSelector keywordsIntervals: oldIntervals arguments: oldArguments
]

{ #category : #replacing }
TPRBMethodNode >> replaceNode: aNode withNode: anotherNode [ 
	aNode == body ifTrue: [self body: anotherNode].
	self arguments: (arguments 
				collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
]

{ #category : #accessing }
TPRBMethodNode >> scope [
	^ scope
]

{ #category : #accessing }
TPRBMethodNode >> scope: aScopedNode [
	scope := aScopedNode
]

{ #category : #accessing }
TPRBMethodNode >> selector [
	^ selector
]

{ #category : #accessing }
TPRBMethodNode >> selector: aSelector [
	keywordsPositions := nil.
	selector := aSelector asSymbol.
]

{ #category : #initialization }
TPRBMethodNode >> selector: aSymbol keywordsPositions: positionList arguments: valueNodes [
	self 
		arguments: valueNodes;
		selector: aSymbol;
		keywordsPositions: positionList.
]

{ #category : #accessing }
TPRBMethodNode >> selectorAndArgumentNames [
	"Returns the selector and argument names portion of a method as a string"

	^ self arguments
		ifEmpty: [self keywords first]
		ifNotEmpty: [| lastArgument |
			lastArgument := self arguments last.
			self source first: lastArgument start + (lastArgument name size - 1)]
]

{ #category : #accessing }
TPRBMethodNode >> selectorParts [
	^ self keywords collect: #asSymbol.
]

{ #category : #accessing }
TPRBMethodNode >> source [
	^source
]

{ #category : #accessing }
TPRBMethodNode >> source: anObject [
	source := anObject
]

{ #category : #accessing }
TPRBMethodNode >> sourceCode [
	"compatibility to MethodNode"
	^source
]

{ #category : #accessing }
TPRBMethodNode >> start [
	^ 1
]

{ #category : #accessing }
TPRBMethodNode >> statements [
	^ self body statements
]

{ #category : #accessing }
TPRBMethodNode >> statements: aCollection [
	self body statements: aCollection 
]

{ #category : #accessing }
TPRBMethodNode >> stop [
	^ self newSource size
]

{ #category : #accessing }
TPRBMethodNode >> tempNames [
	"compatibility method to old MethodNode"
	self deprecated: 'This method was flagged for cleaning. We have the impression it might not be used so we are deprecating it. If you encounter this deprecation, please report with the scenario to reproduce.'.
	^ self argumentNames, self temporaryNames
]

{ #category : #accessing }
TPRBMethodNode >> temporaries [
	^ self body temporaries
]

{ #category : #accessing }
TPRBMethodNode >> temporaryNames [
	^ self body temporaryNames
]

{ #category : #testing }
TPRBMethodNode >> uses: aNode [ 
	^body == aNode and: [aNode lastIsReturn]
]

{ #category : #'tree accessing' }
TPRBMethodNode >> variableWith: aSymbol [

	| matcher block |
	matcher := RBParseTreeSearcher new.
	block := [ :aNode :answer | aNode ].
	
	matcher
		matches: aSymbol do: block;
		matchesArgument: aSymbol do: block.
	^ matcher executeTree: self initialAnswer: nil
]
