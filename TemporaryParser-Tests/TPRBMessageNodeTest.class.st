"
This class contains tests
"
Class {
	#name : #TPRBMessageNodeTest,
	#superclass : #TPRBParseTreeTest,
	#category : #'TemporaryParser-Tests-Nodes'
}

{ #category : #testing }
TPRBMessageNodeTest >> testArgumentPartsForBinaryMessages [
	| tree message |
	tree := self parseMethod: 'test 1 + 2 '.
	message := tree sendNodes first.
	self assert: message argumentPartStrings equals: #('2').
		
		
]

{ #category : #testing }
TPRBMessageNodeTest >> testArgumentPartsForKeywordMessages [
	| tree message |
	tree := self parseMethod: 'test self between: x + 2 and: (y foo: 3)'.
	message := tree sendNodes first.
	self assert: message argumentPartStrings asArray equals: #('x + 2' '(y foo: 3)')
		
		
]

{ #category : #testing }
TPRBMessageNodeTest >> testArgumentPartsForKeywordMessages1 [
	| tree message |
	tree := self parseMethod: 'test self between: 2 and: 3'.
	message := tree sendNodes first.
	self assert: message argumentPartStrings asArray equals: #('2' '3').
		
		
]

{ #category : #testing }
TPRBMessageNodeTest >> testArgumentPartsForKeywordMessages2 [

		| tree message |
		tree := self parseMethod: 'test self between: x and: y'.
		message := tree sendNodes first.
		self assert: message argumentPartStrings asArray equals: #('x' 'y').
		
		tree := self parseMethod: 'test self between: x and: y and: zzz'.
		message := tree sendNodes first.
		self assert: message argumentPartStrings asArray equals: #('x' 'y' 'zzz')
]

{ #category : #testing }
TPRBMessageNodeTest >> testArgumentPartsForUnaryMessages [
	| tree message |
	tree := self parseMethod: 'test 1 foo '.
	message := tree sendNodes first.
	self assert: message argumentPartStrings equals: #().
		
		
]

{ #category : #testing }
TPRBMessageNodeTest >> testSelectorAndArgumentNamesForComposedKeywords [
		| tree message |
		tree := self parseMethod: 'test self between: x and: y'.
		message := tree sendNodes first.
		self assert: message selectorAndArgumentNames equals: 'between: x and: y'.
		
		tree := self parseMethod: 'test self between: x and: y and: zzz'.
		message := tree sendNodes first.
		self assert: message selectorAndArgumentNames equals: 'between: x and: y and: zzz'
]

{ #category : #testing }
TPRBMessageNodeTest >> testSelectorAndArgumentNamesForComposedKeywordsAndComplexArgs [
		| tree message |
		tree := self parseMethod: 'test self between: x + 2 and: (y foo: 3)'.
		message := tree sendNodes first.
		self assert: message selectorAndArgumentNames equals: 'between: x + 2 and: (y foo: 3)'.
		
		
]

{ #category : #testing }
TPRBMessageNodeTest >> testSelectorAndArgumentNamesForSimpleKeywords [
		| tree message |
		tree := self parseMethod: 'test self doit: 5'.
		message := tree sendNodes first.
		self assert: message selectorAndArgumentNames equals: 'doit: 5'
		
		
]

{ #category : #testing }
TPRBMessageNodeTest >> testSelectorAndArgumentNamesForUnary [
		| tree message |
		tree := self parseMethod: 'test self doit'.
		message := tree sendNodes first.
		self assert: message selectorAndArgumentNames equals: 'doit'
		
		
]

{ #category : #testing }
TPRBMessageNodeTest >> testSelectorInterval [
		| tree message |
		tree := self parseMethod: 'test self doit'.
		message := tree sendNodes first.
		self assert: message selectorInterval equals: (11 to: 14).
		tree := self parseMethod: 'test self doit: #nice with: 5'.
		message := tree sendNodes first.
		self assert: message selectorInterval equals: (11 to: 27).
]

{ #category : #testing }
TPRBMessageNodeTest >> testSelectorPartsForBinaryMessages [
	| tree message |
	tree := self parseMethod: 'test 1 + 2 '.
	message := tree sendNodes first.
	self assert: message selectorParts equals: #(#+).
		
		
]

{ #category : #testing }
TPRBMessageNodeTest >> testSelectorPartsForKeywordMessages [
		| tree message |
		tree := self parseMethod: 'test self doit: 5'.
		message := tree sendNodes first.
		self assert: message selectorParts equals: #(#doit:).
		
		tree := self parseMethod: 'test self between: 0 and: 5 '.
		message := tree sendNodes first.
		self assert: message selectorParts equals: #(#between: #and:).
		
]

{ #category : #testing }
TPRBMessageNodeTest >> testSelectorPartsForUnaryMessages [
		| tree message |
		tree := self parseMethod: 'test self doit'.
		message := tree sendNodes first.
		self assert: message selectorParts equals: #(#doit).
		
		
]
