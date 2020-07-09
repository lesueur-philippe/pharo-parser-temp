Class {
	#name : #TPRBEnglobingErrorNode,
	#superclass : #TPRBParseErrorNode,
	#instVars : [
		'content'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'as yet unclassified' }
TPRBEnglobingErrorNode class >> error: aToken withNodes: aCollection [
	"Realise a selection between the different englobing error node classes possible according to the 
	 received token. If the value of the token is not recognised, we create an undetermined one."
	('()' includes: aToken value)
		ifTrue: [ ^TPRBParenthesisErrorNode error: aToken withNodes: aCollection ].
	('[]' includes: aToken value)
		ifTrue: [ ^TPRBBlockErrorNode error: aToken withNodes: aCollection ].
	('#(' = aToken value asString)
		ifTrue: [ ^TPRBLiteralArrayErrorNode error: aToken withNodes: aCollection ].
	('#[' = aToken value asString)
		ifTrue: [ ^TPRBLiteralByteArrayErrorNode error: aToken withNodes: aCollection ].
	('{}' includes: aToken value)
		ifTrue: [ ^TPRBArrayErrorNode error: aToken withNodes: aCollection ].
	('|' = aToken value asString)
		ifTrue: [ ^TPRBTemporariesErrorNode error: aToken withNodes: aCollection ].
	('<' = aToken value asString)
		ifTrue: [ ^TPRBPragmaErrorNode error: aToken withNodes: aCollection ].
	^self new content: aCollection; start: aCollection first start; stop: aToken stop; errorMessage: 'complementary of''',aToken value,''' expected'
]

{ #category : #visiting }
TPRBEnglobingErrorNode >> acceptVisitor: aVisitor [
	[ aVisitor visitEnglobingErrorNode: self ] on: Error do: [super acceptVisitor: aVisitor ].
]

{ #category : #accessing }
TPRBEnglobingErrorNode >> content [
	^content 
]

{ #category : #accessing }
TPRBEnglobingErrorNode >> content: aCollection [
	content := aCollection
]

{ #category : #initialization }
TPRBEnglobingErrorNode >> initialize [ 
	super initialize.
	content := OrderedCollection new.
]

{ #category : #testing }
TPRBEnglobingErrorNode >> isArrayError [
	^false
]

{ #category : #testing }
TPRBEnglobingErrorNode >> isBlockError [
	^false
]

{ #category : #testing }
TPRBEnglobingErrorNode >> isEnglobingError [
	^true
]

{ #category : #testing }
TPRBEnglobingErrorNode >> isLiteralArrayError [
	^false
]

{ #category : #testing }
TPRBEnglobingErrorNode >> isParenthesisError [
	^false
]

{ #category : #testing }
TPRBEnglobingErrorNode >> isPragmaError [
	^false
]

{ #category : #testing }
TPRBEnglobingErrorNode >> isTemporariesError [
	^false
]

{ #category : #accessing }
TPRBEnglobingErrorNode >> value [
	^ String streamContents: [ :s |
			content do: [ :each | s nextPutAll: each formattedCode. s nextPutAll: String space. ]]
]
