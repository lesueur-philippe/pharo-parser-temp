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
