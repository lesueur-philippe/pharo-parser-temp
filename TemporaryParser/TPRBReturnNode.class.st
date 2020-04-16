"
RBReturnNode is an AST node that represents a return expression.

Instance Variables:
	return	<Integer>	the position of the ^ character
	value	<RBValueNode>	the value that is being returned


"
Class {
	#name : #TPRBReturnNode,
	#superclass : #TPRBProgramNode,
	#instVars : [
		'return',
		'value'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBReturnNode class >> return: returnInteger value: aValueNode [ 
	^self new return: returnInteger value: aValueNode
]

{ #category : #'instance creation' }
TPRBReturnNode class >> value: aNode [
	^self return: 0 value: aNode
]

{ #category : #comparing }
TPRBReturnNode >> = anObject [
	self == anObject
		ifTrue: [ ^ true ].
	self class = anObject class
		ifFalse: [ ^ false ].
	^ self value = anObject value
]

{ #category : #visiting }
TPRBReturnNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitReturnNode: self
]

{ #category : #accessing }
TPRBReturnNode >> children [
	^ Array with: value
]

{ #category : #testing }
TPRBReturnNode >> containsReturn [
	^ true
]

{ #category : #matching }
TPRBReturnNode >> copyInContext: aDictionary [ 
	^ self class new
		value: (self value copyInContext: aDictionary);
		yourself
]

{ #category : #comparing }
TPRBReturnNode >> equalTo: anObject withMapping: aDictionary [ 
	^self class = anObject class 
		and: [self value equalTo: anObject value withMapping: aDictionary]
]

{ #category : #comparing }
TPRBReturnNode >> hash [
	^self value hash
]

{ #category : #initialization }
TPRBReturnNode >> initialize [
	super initialize.

	return := 0
]

{ #category : #testing }
TPRBReturnNode >> isFaulty [
	^self value isFaulty
]

{ #category : #testing }
TPRBReturnNode >> isReturn [
	^true
]

{ #category : #matching }
TPRBReturnNode >> match: aNode inContext: aDictionary [ 
	aNode class = self class ifFalse: [^false].
	^value match: aNode value inContext: aDictionary
]

{ #category : #copying }
TPRBReturnNode >> postCopy [
	super postCopy.
	self value: self value copy
]

{ #category : #'adding/removing' }
TPRBReturnNode >> removeNode: aNode [

	self parent removeNode: self
]

{ #category : #replacing }
TPRBReturnNode >> replaceNode: aNode withNode: anotherNode [ 
	value == aNode ifTrue: [ self value: anotherNode ]
]

{ #category : #'accessing-token' }
TPRBReturnNode >> return [
	^ return
]

{ #category : #'accessing-token' }
TPRBReturnNode >> return: anInteger [
	return := anInteger
]

{ #category : #initialization }
TPRBReturnNode >> return: returnInteger value: anExpression [ 
	return := returnInteger.
	self value: anExpression
]

{ #category : #accessing }
TPRBReturnNode >> start [
	^ return
]

{ #category : #accessing }
TPRBReturnNode >> stop [
	value ifNil:[^ 0].
	^ value stop
]

{ #category : #accessing }
TPRBReturnNode >> stop: anInteger [
	self value stop: anInteger
]

{ #category : #evaluating }
TPRBReturnNode >> value [
	^ value
]

{ #category : #accessing }
TPRBReturnNode >> value: anExpression [ 
	value := anExpression.
	value parent: self
]
