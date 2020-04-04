"
An RBLiteralArrayNode is an AST node that represents literal arrays #(1 2 3) and literal byte arrays #[ 1 2 3 ].

Instance Variables
	contents: <Array of: RBLiteralNode> literal nodes of the array
	isByteArray: <Boolean> if the receiver is a literal byte array

"
Class {
	#name : #TPRBLiteralArrayNode,
	#superclass : #TPRBLiteralNode,
	#instVars : [
		'isByteArray',
		'contents'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBLiteralArrayNode class >> startPosition: startInteger contents: anArray stopPosition: stopInteger isByteArray: aBoolean [ 
	^(self new)
		startPosition: startInteger
			contents: anArray
			stopPosition: stopInteger
			isByteArray: aBoolean;
		yourself
]

{ #category : #'instance creation' }
TPRBLiteralArrayNode class >> value: aValue [ 
	^(self new)
		startPosition: 0
			contents: (aValue asArray collect: [:each | TPRBLiteralNode value: each])
			stopPosition: -1
			isByteArray: aValue class ~~ Array;
		yourself
]

{ #category : #comparing }
TPRBLiteralArrayNode >> = anObject [ 
	super = anObject ifFalse: [^false].
	self isForByteArray = anObject isForByteArray ifFalse: [^false].
	self contents size = anObject contents size ifFalse: [^false].
	self contents
		with: anObject contents
		do: [:first :second | first = second ifFalse: [^false]].
	^true
]

{ #category : #visiting }
TPRBLiteralArrayNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitLiteralArrayNode: self
]

{ #category : #accessing }
TPRBLiteralArrayNode >> children [
	^contents
]

{ #category : #accessing }
TPRBLiteralArrayNode >> contents [
	^contents
]

{ #category : #initialization }
TPRBLiteralArrayNode >> contents: aRBLiteralNodeCollection [ 
	contents := aRBLiteralNodeCollection.
	contents do: [:each | each parent: self]
]

{ #category : #matching }
TPRBLiteralArrayNode >> copyInContext: aDictionary [ 
	^ self class 
		startPosition: 0
		contents: (self copyList: self contents inContext: aDictionary)
		stopPosition: -1
		isByteArray: isByteArray
]

{ #category : #comparing }
TPRBLiteralArrayNode >> equalTo: anObject withMapping: aDictionary [ 
	self class = anObject class ifFalse: [^false].
	self isForByteArray = anObject isForByteArray ifFalse: [^false].
	self contents size = anObject contents size ifFalse: [^false].
	self contents
		with: anObject contents
		do: [:first :second | (first equalTo: second withMapping: aDictionary) ifFalse: [^false]].
	^true
]

{ #category : #testing }
TPRBLiteralArrayNode >> isFaulty [
	^self contents anySatisfy: #isFaulty
]

{ #category : #testing }
TPRBLiteralArrayNode >> isForByteArray [
	^isByteArray
]

{ #category : #testing }
TPRBLiteralArrayNode >> isLiteralArray [
	^true
]

{ #category : #matching }
TPRBLiteralArrayNode >> match: aNode inContext: aDictionary [ 
	aNode class = self class ifFalse: [^false].
	self isForByteArray = aNode isForByteArray ifFalse: [^false].
	^self 
		matchList: contents
		against: aNode contents
		inContext: aDictionary
]

{ #category : #copying }
TPRBLiteralArrayNode >> postCopy [
	super postCopy.
	self contents: (self contents collect: [ :each | each copy ])
]

{ #category : #replacing }
TPRBLiteralArrayNode >> replaceNode: aNode withNode: anotherNode [ 
	self contents: (contents 
				collect: [:each | each == aNode ifTrue: [anotherNode] ifFalse: [each]])
]

{ #category : #'private-replacing' }
TPRBLiteralArrayNode >> replaceSourceWith: aNode [ 
	(self class = aNode class and: 
			[self isForByteArray = aNode isForByteArray 
				and: [self contents size = aNode contents size]]) 
		ifFalse: [^super replaceSourceWith: aNode].
	self contents
		with: aNode contents 
		do: [:first :second | first = second ifFalse: [ first replaceSourceWith: second]]
]

{ #category : #initialization }
TPRBLiteralArrayNode >> startPosition: startInteger contents: anArray stopPosition: stopInteger isByteArray: aBoolean [ 
	start := startInteger.
	self contents: anArray.
	stop := stopInteger.
	isByteArray := aBoolean
]

{ #category : #accessing }
TPRBLiteralArrayNode >> value [
	| array |
	array := (isByteArray ifTrue: [ByteArray] ifFalse: [Array]) 
				new: contents size.
	1 to: contents size
		do: [:each | array at: each put: (contents at: each) value].
	^array
]
