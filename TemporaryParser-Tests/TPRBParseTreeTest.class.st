"
This class contains tests
"
Class {
	#name : #TPRBParseTreeTest,
	#superclass : #AbstractEnvironmentTestCase,
	#category : #'TemporaryParser-Tests-Parser'
}

{ #category : #testing }
TPRBParseTreeTest class >> isAbstract [ 

	^self name = #RBParseTreeTest
]

{ #category : #helpers }
TPRBParseTreeTest >> parseExpression: aString [
	^ self parserClass parseExpression: aString
]

{ #category : #helpers }
TPRBParseTreeTest >> parseFaultyExpression: aString [
	^ self parserClass parseFaultyExpression: aString
]

{ #category : #private }
TPRBParseTreeTest >> parseFaultyMethod: text [
	^ self parserClass parseFaultyMethod: text
]

{ #category : #helpers }
TPRBParseTreeTest >> parseMethod: aString [
	^ self parserClass parseMethod: aString
]

{ #category : #helpers }
TPRBParseTreeTest >> parseRewriteMethod: aString [
	^ self parserClass parseRewriteMethod: aString
]

{ #category : #helpers }
TPRBParseTreeTest >> parserClass [
	^ TPRBParser
]
