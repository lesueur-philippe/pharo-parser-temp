"
RBLiteralToken is the first-class representation of a literal token (entire literals, even literal arrays, are a single token in the ST80 grammar.).

Instance Variables:
	stopPosition	<Integer>	The position within the source code where the token terminates.


"
Class {
	#name : #TPRBLiteralToken,
	#superclass : #TPRBValueToken,
	#instVars : [
		'stopPosition',
		'source'
	],
	#category : #'TemporaryParser-Tokens'
}

{ #category : #'instance creation' }
TPRBLiteralToken class >> value: anObject [ 
	| literal |
	literal := anObject class == Array 
				ifTrue: [anObject collect: [:each | self value: each]]
				ifFalse: [anObject].
	^self 
		value: literal
		start: nil
		stop: nil
]

{ #category : #'instance creation' }
TPRBLiteralToken class >> value: aString start: anInteger stop: stopInteger [ 
	^ self value: aString start: anInteger stop: stopInteger source: nil
]

{ #category : #'instance creation' }
TPRBLiteralToken class >> value: aString start: anInteger stop: stopInteger source: sourceText [
	^(self new)
		value: aString
			start: anInteger
			stop: stopInteger;
			source: sourceText;
		yourself
]

{ #category : #testing }
TPRBLiteralToken >> isLiteralToken [
	^true
]

{ #category : #testing }
TPRBLiteralToken >> isMultiKeyword [
	^false
]

{ #category : #private }
TPRBLiteralToken >> length [
	^stopPosition - self start + 1
]

{ #category : #accessing }
TPRBLiteralToken >> realValue [
	^value
]

{ #category : #accessing }
TPRBLiteralToken >> source [
	^source
]

{ #category : #initialization }
TPRBLiteralToken >> source: aString [ 
	source := aString
]

{ #category : #accessing }
TPRBLiteralToken >> stop: anObject [ 
	stopPosition := anObject
]

{ #category : #printing }
TPRBLiteralToken >> storeOn: aStream [ 
	value isSymbol 
		ifTrue: 
			[aStream nextPut: $#.
			((TPRBScanner isSelector: value) and: [value ~~ #'||']) 
				ifTrue: [aStream nextPutAll: value]
				ifFalse: [value asString printOn: aStream].
			^self].
	value class == Character 
		ifTrue: 
			[aStream
				nextPut: $$;
				nextPut: value.
			^self].
	value storeOn: aStream
]

{ #category : #initialization }
TPRBLiteralToken >> value: aString start: anInteger stop: stopInteger [ 
	value := aString.
	sourcePointer := anInteger.
	stopPosition := stopInteger
]
