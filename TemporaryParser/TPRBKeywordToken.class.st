"
RBKeywordToken is the first-class representation of a keyword token (e.g. add:)
"
Class {
	#name : #TPRBKeywordToken,
	#superclass : #TPRBValueToken,
	#category : #'TemporaryParser-Tokens'
}

{ #category : #testing }
TPRBKeywordToken >> isKeyword [
	^true
]

{ #category : #testing }
TPRBKeywordToken >> isPatternVariable [
	^value first = TPRBScanner patternVariableCharacter
]

{ #category : #testing }
TPRBKeywordToken >> isPrimitiveKeyword [
	^ self value = #primitive:
]
