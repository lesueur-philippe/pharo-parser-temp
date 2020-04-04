"
RBToken is the abstract superclass of all of the RB tokens. These tokens (unlike the standard parser's) remember where they came from in the original source code.

Subclasses must implement the following messages:
	accessing
		length

Instance Variables:
	sourcePointer	<Integer>	The position in the original source code where this token began.

"
Class {
	#name : #TPRBToken,
	#superclass : #Object,
	#instVars : [
		'sourcePointer',
		'comments'
	],
	#category : #'TemporaryParser-Tokens'
}

{ #category : #'instance creation' }
TPRBToken class >> start: anInterval [ 
	^self new start: anInterval
]

{ #category : #accessing }
TPRBToken >> comments [
	^comments
]

{ #category : #accessing }
TPRBToken >> comments: anObject [
	comments := anObject
]

{ #category : #testing }
TPRBToken >> isAssignment [
	^false
]

{ #category : #testing }
TPRBToken >> isBinary [
	^false
]

{ #category : #testing }
TPRBToken >> isError [
	^false
]

{ #category : #testing }
TPRBToken >> isIdentifier [
	^false
]

{ #category : #testing }
TPRBToken >> isKeyword [
	^false
]

{ #category : #testing }
TPRBToken >> isKeywordPattern [
	^ false
]

{ #category : #testing }
TPRBToken >> isLiteralArrayToken [
	^false
]

{ #category : #testing }
TPRBToken >> isLiteralToken [
	^false
]

{ #category : #testing }
TPRBToken >> isNumberLiteralToken [
	^false
]

{ #category : #testing }
TPRBToken >> isPatternBlock [
	^false
]

{ #category : #testing }
TPRBToken >> isPatternVariable [
	^false
]

{ #category : #testing }
TPRBToken >> isPrimitiveKeyword [
	^ false
]

{ #category : #testing }
TPRBToken >> isSpecial [
	^false
]

{ #category : #accessing }
TPRBToken >> length [
	^self subclassResponsibility
]

{ #category : #printing }
TPRBToken >> printOn: aStream [ 
	aStream
		nextPut: $ ;
		nextPutAll: self class name
]

{ #category : #accessing }
TPRBToken >> removePositions [
	sourcePointer := nil
]

{ #category : #accessing }
TPRBToken >> start [
	^ sourcePointer ifNil: [ 0 ]
]

{ #category : #initialization }
TPRBToken >> start: anInteger [ 
	sourcePointer := anInteger
]

{ #category : #accessing }
TPRBToken >> stop [
	^ sourcePointer 
		ifNil: [ -1 ]
		ifNotNil: [ self start + self length - 1 ]
]
