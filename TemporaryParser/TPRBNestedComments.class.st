Class {
	#name : #TPRBNestedComments,
	#superclass : #Object,
	#category : #'TemporaryParser-Repartions'
}

{ #category : #'as yet unclassified' }
TPRBNestedComments >> nest: aString [
	| result stream |
	result := WriteStream with: ''.
	stream := ReadStream on: aString.
	result nextPut: $".
	[ stream atEnd ] whileFalse: 
			[ result nextPutAll: (stream upTo: $").
			  stream peekBack = $" ifTrue: [result nextPut: $"]. 
			  result nextPut: $".].
	stream peekBack = $" ifTrue: [result nextPut: $"].
	^result contents.
]

{ #category : #'as yet unclassified' }
TPRBNestedComments >> unNest: aString [
	| result stream |
	result := WriteStream with: ''.
	stream := ReadStream on: aString.
	[ stream atEnd ] whileFalse: 
			[ result nextPutAll: (stream upTo: $").
			  stream peek ifNotNil: [result nextPut: stream next]].
	^result contents.
]
