"
RBIdentifierToken is the first-class representation of an identifier token (e.g. Class)

"
Class {
	#name : #TPRBIdentifierToken,
	#superclass : #TPRBValueToken,
	#category : #'TemporaryParser-Tokens'
}

{ #category : #testing }
TPRBIdentifierToken >> isIdentifier [
	^true
]

{ #category : #testing }
TPRBIdentifierToken >> isKeywordPattern [
	^ self isPatternVariable	and: [ value second = TPRBScanner keywordPatternCharacter
				and: [ value third ~= TPRBScanner cascadePatternCharacter ] ]
]

{ #category : #testing }
TPRBIdentifierToken >> isPatternVariable [
	^value first = TPRBScanner patternVariableCharacter
]
