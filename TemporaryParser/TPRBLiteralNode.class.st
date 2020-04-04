"
RBLiteralNode is an AST node that represents literals.

Instance Variables
	start: <Integer | nil> source position for the literal's beginning
	stop: <Integer | nil> source position for the literal's end
"
Class {
	#name : #TPRBLiteralNode,
	#superclass : #TPRBValueNode,
	#instVars : [
		'start',
		'stop'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBLiteralNode class >> value: aValue [ 
	^((aValue class == Array or: [aValue class == ByteArray]) 
		ifTrue: [TPRBLiteralArrayNode]
		ifFalse: [TPRBLiteralValueNode]) value: aValue
]

{ #category : #comparing }
TPRBLiteralNode >> = anObject [ 
	self == anObject ifTrue: [^true].
	^self class = anObject class
]

{ #category : #visiting }
TPRBLiteralNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitLiteralNode: self
]

{ #category : #comparing }
TPRBLiteralNode >> hash [
	^self value hash
]

{ #category : #initialization }
TPRBLiteralNode >> initialize [

	super initialize.

	start := 0.
	stop := 0.
]

{ #category : #testing }
TPRBLiteralNode >> isImmediateNode [
	^true
]

{ #category : #testing }
TPRBLiteralNode >> isLiteralNode [
	^true
]

{ #category : #testing }
TPRBLiteralNode >> needsParenthesis [
	^false
]

{ #category : #accessing }
TPRBLiteralNode >> precedence [
	^0
]

{ #category : #'private-replacing' }
TPRBLiteralNode >> replaceSourceFrom: aNode [ 
	self addReplacement: (RBStringReplacement 
				replaceFrom: aNode start
				to: aNode stop
				with: self formattedCode)
]

{ #category : #'private-replacing' }
TPRBLiteralNode >> replaceSourceWith: aNode [ 
	self addReplacement: (RBStringReplacement 
				replaceFrom: self start
				to: self stop
				with: aNode formattedCode)
]

{ #category : #accessing }
TPRBLiteralNode >> start: anInteger [
	start := anInteger
]

{ #category : #accessing }
TPRBLiteralNode >> startWithoutParentheses [
	^start
]

{ #category : #accessing }
TPRBLiteralNode >> stop: anInteger [
	stop := anInteger
]

{ #category : #accessing }
TPRBLiteralNode >> stopWithoutParentheses [
	^stop
]

{ #category : #accessing }
TPRBLiteralNode >> value [
	^self subclassResponsibility
]
