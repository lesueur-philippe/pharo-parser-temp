"
RBCascadeNode is an AST node for cascaded messages (e.g., ""self print1 ; print2"").

Instance Variables:
	messages	<SequenceableCollection of: RBMessageNode>	the messages 
	semicolons	<SequenceableCollection of: Integer>	positions of the ; between messages


"
Class {
	#name : #TPRBCascadeNode,
	#superclass : #TPRBValueNode,
	#instVars : [
		'messages',
		'semicolons'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBCascadeNode class >> messages: messageNodes [ 
	^self new messages: messageNodes
]

{ #category : #'instance creation' }
TPRBCascadeNode class >> messages: messageNodes semicolons: integerCollection [ 
	^self new messages: messageNodes semicolons: integerCollection
]

{ #category : #comparing }
TPRBCascadeNode >> = anObject [ 
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	self messages size = anObject messages size ifFalse: [^false].
	self messages with: anObject messages do: [:first :second | first = second ifFalse: [^false]].
	^true
]

{ #category : #visiting }
TPRBCascadeNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitCascadeNode: self
]

{ #category : #querying }
TPRBCascadeNode >> bestNodeFor: anInterval [ 
	| selectedChildren |
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	messages 
		reverseDo: [:each | (each containedBy: anInterval) ifTrue: [^each]].
	selectedChildren := (messages 
				collect: [:each | each bestNodeFor: anInterval]) 
					reject: [:each | each isNil].
	^selectedChildren detect: [:each | true] ifNone: [nil]
]

{ #category : #accessing }
TPRBCascadeNode >> children [
	^self messages
]

{ #category : #matching }
TPRBCascadeNode >> copyInContext: aDictionary [ 
	^ self class new
		messages: (self copyList: self messages inContext: aDictionary);
		yourself
]

{ #category : #testing }
TPRBCascadeNode >> directlyUses: aNode [ 
	^messages last = aNode and: [self isDirectlyUsed]
]

{ #category : #comparing }
TPRBCascadeNode >> equalTo: anObject withMapping: aDictionary [ 
	self class = anObject class ifFalse: [^false].
	self messages size = anObject messages size ifFalse: [^false].
	self messages
		with: anObject messages
		do: [:first :second | (first equalTo: second withMapping: aDictionary) ifFalse: [^false]].
	^true
]

{ #category : #comparing }
TPRBCascadeNode >> hash [
	^ self hashForCollection: self messages
]

{ #category : #testing }
TPRBCascadeNode >> isCascade [
	^true
]

{ #category : #testing }
TPRBCascadeNode >> isFaulty [
	^self messages anySatisfy: #isFaulty
]

{ #category : #accessing }
TPRBCascadeNode >> leftmostChainReceiver [

	^ self receiver isMessage
		ifTrue: [ self receiver receiver ]
		ifFalse: [ self receiver ]
]

{ #category : #matching }
TPRBCascadeNode >> match: aNode inContext: aDictionary [ 
	aNode class = self class ifFalse: [^false].
	^self 
		matchList: messages
		against: aNode messages
		inContext: aDictionary
]

{ #category : #accessing }
TPRBCascadeNode >> messages [
	^messages
]

{ #category : #accessing }
TPRBCascadeNode >> messages: messageNodeCollection [ 
	messages := messageNodeCollection.
	messages do: [:each | each parent: self]
]

{ #category : #initialization }
TPRBCascadeNode >> messages: messageNodes semicolons: integerCollection [ 
	self messages: messageNodes.
	semicolons := integerCollection
]

{ #category : #testing }
TPRBCascadeNode >> needsParenthesis [
	^parent 
		ifNil: [false]
		ifNotNil: [self precedence > parent precedence]
]

{ #category : #copying }
TPRBCascadeNode >> postCopy [
	super postCopy.
	self messages: (self messages collect: [ :each | each copy ])
]

{ #category : #accessing }
TPRBCascadeNode >> precedence [
	^4
]

{ #category : #accessing }
TPRBCascadeNode >> receiver [
	^self messages first receiver
]

{ #category : #'adding/removing' }
TPRBCascadeNode >> removeNode: aNode [

	self messages remove: aNode ifAbsent: [ ]
]

{ #category : #replacing }
TPRBCascadeNode >> replaceNode: aNode withNode: anotherNode [ 
	self messages: (messages 
				collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
]

{ #category : #'accessing-token' }
TPRBCascadeNode >> semicolons [
	^ semicolons
]

{ #category : #'accessing-token' }
TPRBCascadeNode >> semicolons: anArray [
	semicolons := anArray
]

{ #category : #accessing }
TPRBCascadeNode >> startWithoutParentheses [
	^messages first start
]

{ #category : #accessing }
TPRBCascadeNode >> statementComments [
	| statementComments |
	statementComments := OrderedCollection withAll: self comments.
	statementComments addAll: messages first receiver statementComments.
	"For each message of the cascade, we have to verify if it is a message node or an error node because     error nodes don't understand 'arguments'."
	messages do: 
			[:each | each isFaulty ifFalse: [ 
			each arguments 
				do: [:arg | statementComments addAll: arg statementComments]]].
	^statementComments asSortedCollection: [:a :b | a start < b start]
]

{ #category : #accessing }
TPRBCascadeNode >> stopWithoutParentheses [
	^messages last stop
]

{ #category : #testing }
TPRBCascadeNode >> uses: aNode [ 
	^messages last = aNode and: [self isUsed]
]

{ #category : #querying }
TPRBCascadeNode >> whichNodeIsContainedBy: anInterval [ 
	| selectedChildren |
	(self intersectsInterval: anInterval) ifFalse: [^nil].
	(self containedBy: anInterval) ifTrue: [^self].
	messages 
		reverseDo: [:each | (each containedBy: anInterval) ifTrue: [^each]].
	selectedChildren := (messages 
				collect: [:each | each whichNodeIsContainedBy: anInterval]) 
					reject: [:each | each isNil].
	^selectedChildren detect: [:each | true] ifNone: [nil]
]
