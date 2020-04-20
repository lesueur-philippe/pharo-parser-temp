"
RBValueToken is the abstract superclass of all tokens that have additional information attached. For example, the BinarySelector token holds onto the actual character (e.g. $+).

Instance Variables:
	value	<String>	The value of this token


"
Class {
	#name : #TPRBValueToken,
	#superclass : #TPRBToken,
	#instVars : [
		'value'
	],
	#category : #'TemporaryParser-Tokens'
}

{ #category : #'instance creation' }
TPRBValueToken class >> value: aString start: anInteger [ 
	^self new value: aString start: anInteger
]

{ #category : #private }
TPRBValueToken >> length [
	^value size
]

{ #category : #printing }
TPRBValueToken >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	value printOn: aStream.
	aStream nextPutAll: ')'
]

{ #category : #accessing }
TPRBValueToken >> source [
	^ self value
]

{ #category : #accessing }
TPRBValueToken >> value [
	^value
]

{ #category : #accessing }
TPRBValueToken >> value: anObject [
	value := anObject
]

{ #category : #initialization }
TPRBValueToken >> value: aString start: anInteger [ 
	value := aString.
	sourcePointer := anInteger
]
