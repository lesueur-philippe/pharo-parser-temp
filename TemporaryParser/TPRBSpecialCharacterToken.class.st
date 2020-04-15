"
RBSpecialCharacterToken is the first-class representation of special characters.


"
Class {
	#name : #TPRBSpecialCharacterToken,
	#superclass : #TPRBValueToken,
	#category : #'TemporaryParser-Tokens'
}

{ #category : #testing }
TPRBSpecialCharacterToken >> isSpecial [
	^true
]

{ #category : #private }
TPRBSpecialCharacterToken >> length [
	^1
]
