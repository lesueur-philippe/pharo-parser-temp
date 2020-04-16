"
RBEOFToken is the representation of the End Of File token '#eof'
"
Class {
	#name : #TPRBEOFToken,
	#superclass : #TPRBToken,
	#category : #'TemporaryParser-Tokens'
}

{ #category : #testing }
TPRBEOFToken >> isEOF [
	^true
]

{ #category : #accessing }
TPRBEOFToken >> length [
	^ 0
]
