"
I am a node representing a source code segment that could not be parsed. I am mainly used for source-code coloring where we should parse as far as possible and mark the rest as a failure.

Parsing faulty code without raising a syntax error is done by 
RBParser parseFaultyExpression:
or
RBParser parseFaultyMethod: 

The return value is either valid nodes representing the AST, or nodes representing the valid portion and an RBParseErrorNode for the remaining invalid code.


"
Class {
	#name : #TPRBParseErrorNode,
	#superclass : #TPRBValueNode,
	#instVars : [
		'errorMessage',
		'value',
		'start'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBParseErrorNode class >> errorMessage: aString value: aValue at: aPosition [

	^ self new
		errorMessage: aString;
		value: aValue;
		start: aPosition;
		yourself
]

{ #category : #comparing }
TPRBParseErrorNode >> = anObject [ 
	self == anObject ifTrue: [^true].
	self class = anObject class ifFalse: [^false].
	^anObject value = value and: [ anObject errorMessage = errorMessage ]
]

{ #category : #visiting }
TPRBParseErrorNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitParseErrorNode: self
]

{ #category : #converting }
TPRBParseErrorNode >> adaptToSemanticNode [
	" I can't provide more semantics "
]

{ #category : #converting }
TPRBParseErrorNode >> asSyntaxErrorNotification [
	^SyntaxErrorNotification new
		setClass: self methodNode methodClass
		code: self methodNode source
		doitFlag: false
		errorMessage: errorMessage
		location: self start
]

{ #category : #accessing }
TPRBParseErrorNode >> binding: anOCTempVariable [ 
	"only for compatibility"
	
]

{ #category : #accessing }
TPRBParseErrorNode >> body: aSequenceNode [
	"I am not a valid MethodNode, but go one with parsing"
]

{ #category : #accessing }
TPRBParseErrorNode >> errorMessage [
	^ errorMessage
]

{ #category : #accessing }
TPRBParseErrorNode >> errorMessage: anObject [
	errorMessage := anObject
]

{ #category : #comparing }
TPRBParseErrorNode >> hash [
	^ (self value hash bitXor: self errorMessage hash)
]

{ #category : #testing }
TPRBParseErrorNode >> isFaulty [
	^true
]

{ #category : #testing }
TPRBParseErrorNode >> isParseError [
	^true
]

{ #category : #accessing }
TPRBParseErrorNode >> name [
	"be polymorphic with variable nodes"

	^ ''
]

{ #category : #testing }
TPRBParseErrorNode >> needsParenthesis [
	^ false
]

{ #category : #accessing }
TPRBParseErrorNode >> source: aString [
	"I am not a valid MethodNode, but go one with parsing"
]

{ #category : #accessing }
TPRBParseErrorNode >> start [
	^ start
]

{ #category : #accessing }
TPRBParseErrorNode >> start: aPosition [
	start := aPosition
]

{ #category : #accessing }
TPRBParseErrorNode >> startWithoutParentheses [
	^ start
]

{ #category : #accessing }
TPRBParseErrorNode >> stop [
	^ start + value size - 1.
]

{ #category : #accessing }
TPRBParseErrorNode >> stopWithoutParentheses [
	^ self stop
]

{ #category : #evaluating }
TPRBParseErrorNode >> value [
	^value.
]

{ #category : #accessing }
TPRBParseErrorNode >> value: aString [
	value := aString.
]
