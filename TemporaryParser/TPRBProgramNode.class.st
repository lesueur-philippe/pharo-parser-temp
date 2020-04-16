"
RBProgramNode is an abstract class that represents an abstract syntax tree node in a Smalltalk program.

Subclasses must implement the following messages:
	accessing
		start
		stop
	visitor
		acceptVisitor:
	testing
		isFaulty

The #start and #stop methods are used to find the source that corresponds to this node. ""source copyFrom: self start to: self stop"" should return the source for this node.

The #acceptVisitor: method is used by RBProgramNodeVisitors (the visitor pattern). This will also require updating all the RBProgramNodeVisitors so that they know of the new node.

The #isFaulty method is used to distinguish between valid nodes and nodes created from an invalid source Smalltalk code. For example, code parsed with RBParsers #parseFaultyExpression: or #parseFaultyMethod:.

Subclasses might also want to redefine match:inContext: and copyInContext: to do parse tree searching and replacing.

Subclasses that contain other nodes should override equalTo:withMapping: to compare nodes while ignoring renaming temporary variables, and children that returns a collection of our children nodes.

Instance Variables:
	properties	<Dictionary of: Symbol -> Object>	A set of properties set to this node, for example every node can have the Property #comment to attach the method comment or the comment of the code line this node represents. Other classes or tools may add more type of properties; for example, the reflectivity support adds properties for managing Metalinks. 
	parent	<RBProgramNode>	the node we're contained in

Class Variables:
	FormatterClass	<Behavior>	the formatter class that is used when we are formatted

"
Class {
	#name : #TPRBProgramNode,
	#superclass : #TPRBNode,
	#instVars : [
		'parent',
		'properties'
	],
	#classVars : [
		'FormatterClass'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #accessing }
TPRBProgramNode class >> formatterClass [
	^ FormatterClass ifNil: [ TPRBSimpleFormatter ] ifNotNil: [ FormatterClass ]
]

{ #category : #accessing }
TPRBProgramNode class >> formatterClass: aClass [
	FormatterClass := aClass
		
]

{ #category : #accessing }
TPRBProgramNode class >> optimizedSelectors [
	^ #( and: caseOf: caseOf:otherwise: ifFalse: ifFalse:ifTrue: ifNil: ifNil:ifNotNil: ifNotNil: ifNotNil:ifNil: ifTrue: ifTrue:ifFalse: or: to:by:do: to:do: whileFalse whileFalse: whileTrue whileTrue: )
]

{ #category : #accessing }
TPRBProgramNode class >> resetFormatter [

	self formatterClass: nil

	
]

{ #category : #replacing }
TPRBProgramNode >> addReplacement: aStringReplacement [
	parent ifNil: [^self].
	parent addReplacement: aStringReplacement
]

{ #category : #accessing }
TPRBProgramNode >> allArgumentVariables [
	| children |
	children := self children.
	children isEmpty ifTrue: [^#()].
	^children inject: OrderedCollection new
		into: 
			[:vars :each | 
			vars
				addAll: each allArgumentVariables;
				yourself]
]

{ #category : #iterating }
TPRBProgramNode >> allChildren [
	| children |
	children := OrderedCollection new.
	self nodesDo: [ :each | children addLast: each ].
	^ children
]

{ #category : #accessing }
TPRBProgramNode >> allDefinedVariables [
	| children |
	children := self children.
	children isEmpty ifTrue: [^#()].
	^children inject: OrderedCollection new
		into: 
			[:vars :each | 
			vars
				addAll: each allDefinedVariables;
				yourself]
]

{ #category : #accessing }
TPRBProgramNode >> allTemporaryVariables [
	| children |
	children := self children.
	children isEmpty ifTrue: [^#()].
	^children inject: OrderedCollection new
		into: 
			[:vars :each | 
			vars
				addAll: each allTemporaryVariables;
				yourself]
]

{ #category : #accessing }
TPRBProgramNode >> allVariables [
	"Return all the variables in subnodes"

	^ self allChildren select: [ :each | each isVariable ]
]

{ #category : #accessing }
TPRBProgramNode >> asReturn [
	"Change the current node to a return node."

	parent ifNil: [self error: 'Cannot change to a return without a parent node.'].
	parent isSequence 
		ifFalse: [self error: 'Parent node must be a sequence node.'].
	(parent isLast: self) ifFalse: [self error: 'Return node must be last.'].
	^parent addReturn
]

{ #category : #converting }
TPRBProgramNode >> asSequenceNode [
	^RBSequenceNode statements: {self} 
]

{ #category : #querying }
TPRBProgramNode >> assignmentNodes [
	^self allChildren select: [:each | each isAssignment].
]

{ #category : #testing }
TPRBProgramNode >> assigns: aVariableName [ 
	^self children anySatisfy: [:each | each assigns: aVariableName]
]

{ #category : #querying }
TPRBProgramNode >> bestNodeFor: anInterval [ 

	| selectedChildren |
	
	anInterval ifNil: [ ^ nil ].
	
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	
	selectedChildren := self children select: [:each | 
		each intersectsInterval: anInterval
	].

	^ selectedChildren size = 1 
		ifTrue: [ selectedChildren first bestNodeFor: anInterval ]
		ifFalse: [ self ]
]

{ #category : #querying }
TPRBProgramNode >> blockNodes [
	^self allChildren select: [:each | each isBlock].
]

{ #category : #accessing }
TPRBProgramNode >> blockVariables [
	^parent ifNil: [#()] ifNotNil: [parent blockVariables]
]

{ #category : #'testing-matching' }
TPRBProgramNode >> canMatchMethod: aCompiledMethod [ 
	^self sentMessages allSatisfy: 
			[:each | 
			(self class optimizedSelectors includes: each) 
				or: [aCompiledMethod refersToLiteral: each]]
]

{ #category : #'meta variable-accessing' }
TPRBProgramNode >> cascadeListCharacter [
	^$;
]

{ #category : #accessing }
TPRBProgramNode >> children [
	^#()
]

{ #category : #replacing }
TPRBProgramNode >> clearReplacements [
	parent ifNil: [^self].
	parent clearReplacements
]

{ #category : #enumeration }
TPRBProgramNode >> collect: aBlock [ 
	"Hacked to fit collection protocols"

	^aBlock value: self
]

{ #category : #accessing }
TPRBProgramNode >> comments [
	"Answer the comments of the receiving parse tree node"
	
	^ (self propertyAt: #comments ifAbsent: [ #() ]) ifNil:[ #() ]
]

{ #category : #accessing }
TPRBProgramNode >> comments: aCollection [

	(aCollection ifNil: [#()])
		ifEmpty: [ self removeProperty: #comments ifAbsent: [] ] 
		ifNotEmpty: [ self propertyAt: #comments put: aCollection ].
]

{ #category : #testing }
TPRBProgramNode >> containedBy: anInterval [ 
	^anInterval first <= self start and: [anInterval last >= self stop]
]

{ #category : #testing }
TPRBProgramNode >> containsReturn [
	^self children anySatisfy: [:each | each containsReturn]
]

{ #category : #copying }
TPRBProgramNode >> copyCommentsFrom: aNode [ 
	"Add all comments from aNode to us. If we already have the comment, then don't add it."

	| newComments |
	newComments := OrderedCollection new.
	aNode nodesDo: [:each | newComments addAll: each comments].
	self nodesDo: 
			[:each | 
			each comments do: [:comment | newComments remove: comment ifAbsent: []]].
	newComments isEmpty ifTrue: [^self].
	newComments := newComments asSortedCollection: [:a :b | a start < b start].
	self comments: newComments
]

{ #category : #matching }
TPRBProgramNode >> copyInContext: aDictionary [
	^ self copy
]

{ #category : #matching }
TPRBProgramNode >> copyList: matchNodes inContext: aDictionary [ 
	| newNodes |
	newNodes := OrderedCollection new.
	matchNodes do: 
			[:each | 
			| object |
			object := each copyInContext: aDictionary.
			newNodes addAll: object].
	^newNodes
]

{ #category : #accessing }
TPRBProgramNode >> debugHighlightRange [

	^ self debugHighlightStart to: self debugHighlightStop
]

{ #category : #accessing }
TPRBProgramNode >> debugHighlightStart [

	^ self start 
]

{ #category : #accessing }
TPRBProgramNode >> debugHighlightStop [

	^ self stop 
]

{ #category : #testing }
TPRBProgramNode >> defines: aName [
	^false
]

{ #category : #testing }
TPRBProgramNode >> directlyUses: aNode [
	^true
]

{ #category : #enumeration }
TPRBProgramNode >> do: aBlock [ 
	"Hacked to fit collection protocols"

	aBlock value: self
]

{ #category : #generation }
TPRBProgramNode >> dump [
	"Generate a literal expression that recreates the receiver"

	| visitor |
	visitor := TPRBDumpVisitor new.
	self acceptVisitor: visitor.
	^ visitor stream contents
]

{ #category : #comparing }
TPRBProgramNode >> equalTo: aNode exceptForVariables: variableNameCollection [ 
	| dictionary |
	dictionary := Dictionary new.
	(self equalTo: aNode withMapping: dictionary) ifFalse: [^false].
	dictionary keysAndValuesDo: 
			[:key :value | 
			(key = value or: [variableNameCollection includes: key]) ifFalse: [^false]].
	^true
]

{ #category : #comparing }
TPRBProgramNode >> equalTo: aNode withMapping: aDictionary [ 
	^self = aNode
]

{ #category : #testing }
TPRBProgramNode >> evaluatedFirst: aNode [ 
	self children do: 
			[:each | 
			each == aNode ifTrue: [^true].
			each isImmediateNode ifFalse: [^false]].
	^false
]

{ #category : #accessing }
TPRBProgramNode >> formattedCode [
	^ self formatterClass new format: self
]

{ #category : #accessing }
TPRBProgramNode >> formatterClass [
	^ self class formatterClass
]

{ #category : #testing }
TPRBProgramNode >> hasComments [
	"Answer whether the receiver as comments"
	
	^ self comments isNotEmpty
	
]

{ #category : #testing }
TPRBProgramNode >> hasMultipleReturns [
	| count |
	count := 0.
	self nodesDo: [:each | each isReturn ifTrue: [count := count + 1]].
	^count > 1
]

{ #category : #properties }
TPRBProgramNode >> hasProperty: aKey [
	"Test if the property aKey is present."
	
	^ properties notNil and: [ properties includesKey: aKey ]
]

{ #category : #comparing }
TPRBProgramNode >> hashForCollection: aCollection [
	^ aCollection isEmpty ifTrue: [ 0 ] ifFalse: [ aCollection first hash ]
]

{ #category : #querying }
TPRBProgramNode >> instanceVariableNodes [
		^self variableNodes select: [:each | each isInstance]
]

{ #category : #querying }
TPRBProgramNode >> instanceVariableReadNodes [
		^self variableReadNodes select: [:each | each isInstance]
]

{ #category : #querying }
TPRBProgramNode >> instanceVariableWriteNodes [
		^self variableWriteNodes select: [:each | each isInstance]
]

{ #category : #testing }
TPRBProgramNode >> intersectsInterval: anInterval [ 
	^(anInterval first between: self start and: self stop) 
		or: [self start between: anInterval first and: anInterval last]
]

{ #category : #testing }
TPRBProgramNode >> isArgument [
	^false
]

{ #category : #testing }
TPRBProgramNode >> isAssignment [
	^false
]

{ #category : #testing }
TPRBProgramNode >> isBlockVar [
	"true if a variable node is defined by a block"

	^ false
]

{ #category : #testing }
TPRBProgramNode >> isCascade [
	^false
]

{ #category : #testing }
TPRBProgramNode >> isDirectlyUsed [
	"This node is directly used as an argument, receiver, or part of an assignment."

	^parent ifNil: [false] ifNotNil: [parent directlyUses: self]
]

{ #category : #testing }
TPRBProgramNode >> isDynamicArray [
	^ false
]

{ #category : #testing }
TPRBProgramNode >> isEvaluatedFirst [
	"Return true if we are the first thing evaluated in this statement."

	^parent isNil or: [parent isSequence or: [parent evaluatedFirst: self]]
]

{ #category : #testing }
TPRBProgramNode >> isFaulty [
	"return true if the AST contains a RBParseErrorNode"
	^false
]

{ #category : #deprecated }
TPRBProgramNode >> isImmediate [
	^self isImmediateNode
]

{ #category : #testing }
TPRBProgramNode >> isImmediateNode [
	^false
]

{ #category : #testing }
TPRBProgramNode >> isLast: aNode [ 
	| children |
	children := self children.
	^children notEmpty and: [children last == aNode]
]

{ #category : #'testing-matching' }
TPRBProgramNode >> isList [
	^false
]

{ #category : #testing }
TPRBProgramNode >> isLiteralArray [
	^false
]

{ #category : #testing }
TPRBProgramNode >> isLiteralNode [
	^false
]

{ #category : #testing }
TPRBProgramNode >> isMessage [
	^false
]

{ #category : #testing }
TPRBProgramNode >> isMethod [
	^false
]

{ #category : #testing }
TPRBProgramNode >> isParseError [
	^false
]

{ #category : #'testing-matching' }
TPRBProgramNode >> isPatternNode [
	^false
]

{ #category : #testing }
TPRBProgramNode >> isPragma [
	^false
]

{ #category : #testing }
TPRBProgramNode >> isReturn [
	^false
]

{ #category : #testing }
TPRBProgramNode >> isSelf [
	^ false
]

{ #category : #testing }
TPRBProgramNode >> isSelfOrSuper [
	^ false
]

{ #category : #testing }
TPRBProgramNode >> isSequence [
	^false
]

{ #category : #testing }
TPRBProgramNode >> isSuper [
	^false
]

{ #category : #testing }
TPRBProgramNode >> isTemp [
	^ false
]

{ #category : #testing }
TPRBProgramNode >> isThisContext [
	^ false
]

{ #category : #testing }
TPRBProgramNode >> isUsed [
	"Answer true if this node could be used as part of another expression. For example, you could use the 
	result of this node as a receiver of a message, an argument, the right part of an assignment, or the 
	return value of a block. This differs from isDirectlyUsed in that it is conservative since it also includes 
	return values of blocks."

	^parent ifNil: [false] ifNotNil: [parent uses: self]
]

{ #category : #testing }
TPRBProgramNode >> isValue [
	^false
]

{ #category : #testing }
TPRBProgramNode >> isVariable [
	^false
]

{ #category : #testing }
TPRBProgramNode >> lastIsReturn [
	^self isReturn
]

{ #category : #'meta variable-accessing' }
TPRBProgramNode >> listCharacter [
	^$@
]

{ #category : #'meta variable-accessing' }
TPRBProgramNode >> literalCharacter [
	^$#
]

{ #category : #accessing }
TPRBProgramNode >> mappingFor: aNode [
	| method |
	method := self methodNode.
	method ifNil: [^aNode].
	^method mappingFor: aNode
]

{ #category : #matching }
TPRBProgramNode >> match: aNode inContext: aDictionary [ 
	^ self = aNode
]

{ #category : #matching }
TPRBProgramNode >> matchList: matchNodes against: programNodes inContext: aDictionary [ 
	^self
		matchList: matchNodes
		index: 1
		against: programNodes
		index: 1
		inContext: aDictionary
]

{ #category : #matching }
TPRBProgramNode >> matchList: matchNodes index: matchIndex against: programNodes index: programIndex inContext: aDictionary [ 
	| node currentIndex currentDictionary nodes |
	matchNodes size < matchIndex ifTrue: [^programNodes size < programIndex].
	node := matchNodes at: matchIndex.
	node isList 
		ifTrue: 
			[currentIndex := programIndex - 1.
			
			[currentDictionary := aDictionary copy.
			programNodes size < currentIndex or: 
					[nodes := programNodes copyFrom: programIndex to: currentIndex.
					(currentDictionary at: node ifAbsentPut: [nodes]) = nodes and: 
							[(self 
								matchList: matchNodes
								index: matchIndex + 1
								against: programNodes
								index: currentIndex + 1
								inContext: currentDictionary) 
									ifTrue: 
										[currentDictionary 
											keysAndValuesDo: [:key :value | aDictionary at: key put: value].
										^true].
							false]]] 
					whileFalse: [currentIndex := currentIndex + 1].
			^false].
	programNodes size < programIndex ifTrue: [^false].
	(node match: (programNodes at: programIndex) inContext: aDictionary) 
		ifFalse: [^false].
	^self 
		matchList: matchNodes
		index: matchIndex + 1
		against: programNodes
		index: programIndex + 1
		inContext: aDictionary
]

{ #category : #accessing }
TPRBProgramNode >> methodComments [
	^self comments
]

{ #category : #accessing }
TPRBProgramNode >> methodNode [
	^parent ifNotNil: [parent methodNode]
]

{ #category : #accessing }
TPRBProgramNode >> methodOrBlockNode [
	^ parent ifNotNil: [ parent methodOrBlockNode ]
]

{ #category : #accessing }
TPRBProgramNode >> newSource [
	^self formattedCode
]

{ #category : #'node access' }
TPRBProgramNode >> nodeForOffset: anInteger [
	| children |
	"choosing the best node on the specific offset"
	children := self children.
	"when we are on a leaf, we take the leaf node"
	(children isEmpty) ifTrue: [ (self sourceInterval includes: anInteger) ifTrue: [^self]].
	"if the node has children then we check the children"
	children do: [:each | (each sourceInterval includes: anInteger) ifTrue: [^each nodeForOffset: anInteger] ].
]

{ #category : #iterating }
TPRBProgramNode >> nodesDo: aBlock [ 
	aBlock value: self.
	self children do: [ :each | each nodesDo: aBlock ]
]

{ #category : #accessing }
TPRBProgramNode >> parent [
	^parent
]

{ #category : #accessing }
TPRBProgramNode >> parent: aRBProgramNode [ 
	parent := aRBProgramNode
]

{ #category : #accessing }
TPRBProgramNode >> parents [
	^ parent 
		ifNil: [ OrderedCollection with: self ]
		ifNotNil: [ 
			parent parents
				addLast: self;
				yourself ]
]

{ #category : #copying }
TPRBProgramNode >> postCopy [
	super postCopy.
	properties := properties copy
]

{ #category : #accessing }
TPRBProgramNode >> precedence [
	^6
]

{ #category : #printing }
TPRBProgramNode >> printOn: aStream [ 
	aStream
		nextPutAll: self class name;
		nextPut: $(;
		nextPutAll: self formattedCode;
		nextPut: $)
]

{ #category : #properties }
TPRBProgramNode >> propertyAt: aKey [
	"Answer the property value associated with aKey."
	
	^ self propertyAt: aKey ifAbsent: [ self error: 'Property not found' ]
]

{ #category : #properties }
TPRBProgramNode >> propertyAt: aKey ifAbsent: aBlock [
	"Answer the property value associated with aKey or, if aKey isn't found, answer the result of evaluating aBlock."
	
	^ properties 
		ifNil: aBlock
		ifNotNil: [ properties at: aKey ifAbsent: aBlock ]
]

{ #category : #properties }
TPRBProgramNode >> propertyAt: aKey ifAbsentPut: aBlock [
	"Answer the property associated with aKey or, if aKey isn't found store the result of evaluating aBlock as new value."
	
	^ self propertyAt: aKey ifAbsent: [ self propertyAt: aKey put: aBlock value ]
]

{ #category : #properties }
TPRBProgramNode >> propertyAt: aKey ifPresent: aPresentBlock ifAbsent: anAbsentBlock [
	"Answer the property value associated with aKey or, if aKey is found, answer the result of evaluating aPresentBlock, else evaluates anAbsentBlock."

	^ properties ifNil: anAbsentBlock ifNotNil: [ properties at: aKey ifPresent: aPresentBlock ifAbsent: anAbsentBlock ]
]

{ #category : #properties }
TPRBProgramNode >> propertyAt: aKey put: anObject [
	"Set the property at aKey to be anObject. If aKey is not found, create a new entry for aKey and set is value to anObject. Answer anObject."

	^ (properties ifNil: [ properties := SmallDictionary new: 1 ])
		at: aKey put: anObject
]

{ #category : #'testing-matching' }
TPRBProgramNode >> recurseInto [
	^false
]

{ #category : #'meta variable-accessing' }
TPRBProgramNode >> recurseIntoCharacter [
	^$`
]

{ #category : #testing }
TPRBProgramNode >> references: aVariableName [ 
	^self children anySatisfy: [:each | each references: aVariableName]
]

{ #category : #replacing }
TPRBProgramNode >> removeDeadCode [
	self children do: [:each | each removeDeadCode]
]

{ #category : #properties }
TPRBProgramNode >> removeProperty: aKey [
	"Remove the property with aKey. Answer the property or raise an error if aKey isn't found."
	
	^ self removeProperty: aKey ifAbsent: [ self error: 'Property not found' ].
]

{ #category : #properties }
TPRBProgramNode >> removeProperty: aKey ifAbsent: aBlock [
	"Remove the property with aKey. Answer the value or, if aKey isn't found, answer the result of evaluating aBlock."
	
	| answer |
	properties ifNil: [ ^ aBlock value ].
	answer := properties removeKey: aKey ifAbsent: aBlock.
	properties isEmpty ifTrue: [ properties := nil ].
	^ answer
]

{ #category : #replacing }
TPRBProgramNode >> replaceMethodSource: aNode [ 
	"We are being replaced with aNode -- if possible try to perform an in place edit of the source."

	| method |
	method := self methodNode.
	method notNil ifTrue: [method map: self to: aNode].
	aNode parent: self parent.
	[self replaceSourceWith: aNode] on: Error
		do: 
			[:ex | 
			self clearReplacements.
			ex return]
]

{ #category : #replacing }
TPRBProgramNode >> replaceNode: aNode withNode: anotherNode [ 
	self error: 'I don''t store other nodes'
]

{ #category : #'private-replacing' }
TPRBProgramNode >> replaceSourceFrom: aNode [
	self == aNode
		ifFalse: [ self clearReplacements ]
]

{ #category : #'private-replacing' }
TPRBProgramNode >> replaceSourceWith: aNode [ 
	aNode replaceSourceFrom: self
]

{ #category : #replacing }
TPRBProgramNode >> replaceWith: aNode [ 
	parent ifNil: [self error: 'This node doesn''t have a parent'].
	self replaceMethodSource: aNode.
	parent replaceNode: self withNode: aNode
]

{ #category : #enumeration }
TPRBProgramNode >> reverseNodesDo: aBlock [ 
	self children reverseDo: [ :each | each reverseNodesDo: aBlock ].
	aBlock value: self
]

{ #category : #querying }
TPRBProgramNode >> selfMessages [
	^(self sendNodes select: [ :node | node isSelfSend ] thenCollect: [ :node | node selector ]) asSet
]

{ #category : #accessing }
TPRBProgramNode >> sendNodes [
	^self allChildren select: [:each | each isMessage].
]

{ #category : #accessing }
TPRBProgramNode >> sentMessages [
	^ self children
		inject: Set new
		into: [ :messages :each | 
			messages
				addAll: each sentMessages;
				yourself ]
]

{ #category : #enumeration }
TPRBProgramNode >> size [
	"Hacked to fit collection protocols"

	^1
]

{ #category : #accessing }
TPRBProgramNode >> source [
	^ parent notNil ifTrue: [ parent source ] ifFalse: [ nil ]
]

{ #category : #accessing }
TPRBProgramNode >> sourceCode [

	| interval |
	interval := self sourceInterval.
	interval ifEmpty: [ ^ '' ].
	
	^ self source 
		copyFrom: interval first
		to: interval last
]

{ #category : #accessing }
TPRBProgramNode >> sourceInterval [
	^ self start to: self stop
]

{ #category : #accessing }
TPRBProgramNode >> start [
	self subclassResponsibility
]

{ #category : #'meta variable-accessing' }
TPRBProgramNode >> statementCharacter [
	^$.
]

{ #category : #accessing }
TPRBProgramNode >> statementComments [
	| statementComments |
	statementComments := OrderedCollection withAll: self comments.
	self children do: [:each | statementComments addAll: each statementComments].
	^statementComments asSortedCollection: [:a :b | a start < b start]
]

{ #category : #querying }
TPRBProgramNode >> statementNode [
	"Return your topmost node that is contained by a sequence node."

	(parent isNil or: [parent isSequence]) ifTrue: [^self].
	^parent statementNode
]

{ #category : #accessing }
TPRBProgramNode >> statements [
	^ #()
	
]

{ #category : #accessing }
TPRBProgramNode >> stop [
	self subclassResponsibility
]

{ #category : #querying }
TPRBProgramNode >> superMessages [
	^(self sendNodes select: [ :node | node isSuperSend ] thenCollect: [ :node | node selector ]) asSet
]

{ #category : #querying }
TPRBProgramNode >> tempVariableReadNodes [
		^self variableReadNodes select: [:each | each isTemp]
]

{ #category : #accessing }
TPRBProgramNode >> temporaryVariables [
	^parent ifNil: [#()] ifNotNil: [parent temporaryVariables]
]

{ #category : #testing }
TPRBProgramNode >> uses: aNode [
	^true
]

{ #category : #querying }
TPRBProgramNode >> variableNodes [
		^self allChildren select: [:each | 
			each isVariable and: [each isDefinition not]].
]

{ #category : #querying }
TPRBProgramNode >> variableReadNodes [
	^self variableNodes select: [:each | each isRead]
]

{ #category : #querying }
TPRBProgramNode >> variableWriteNodes [
		^self variableNodes select: [:each | each isWrite]
]

{ #category : #querying }
TPRBProgramNode >> whichNodeIsContainedBy: anInterval [ 
	| selectedChildren |
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	selectedChildren := self children 
				select: [:each | each intersectsInterval: anInterval].
	^selectedChildren size == 1 
		ifTrue: [selectedChildren first whichNodeIsContainedBy: anInterval]
		ifFalse: [nil]
]

{ #category : #querying }
TPRBProgramNode >> whoDefines: aName [ 
	^(self defines: aName) 
		ifTrue: [self]
		ifFalse: [parent notNil ifTrue: [parent whoDefines: aName] ifFalse: [nil]]
]
