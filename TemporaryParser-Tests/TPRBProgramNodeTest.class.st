"
SUnit tests for RBProgramNode
"
Class {
	#name : #TPRBProgramNodeTest,
	#superclass : #TPRBParseTreeTest,
	#instVars : [
		'node'
	],
	#category : #'TemporaryParser-Tests-Nodes'
}

{ #category : #accessing }
TPRBProgramNodeTest class >> packageNamesUnderTest [
	^ #('AST-Core')
]

{ #category : #accessing }
TPRBProgramNodeTest >> node [
	^ node ifNil: [ node := TPRBProgramNode new ]
]

{ #category : #'testing-adding' }
TPRBProgramNodeTest >> testAddNode [
	| tree treeNode |
	tree := self parseExpression: '1. 2'.
	treeNode := tree addNode: (self parseExpression: '3').
	self assert: (self parseExpression: '1. 2. 3') equals: tree.
	self assert: tree statements last equals: treeNode.
	
	tree := self parseExpression: '{ 1. 2 }'.
	treeNode := tree addNode: (self parseExpression: '3').
	self assert: (self parseExpression: '{ 1. 2. 3 }') equals: tree.
	self assert: tree statements last equals: treeNode
]

{ #category : #'testing-adding' }
TPRBProgramNodeTest >> testAddNodeBefore [
	| tree treeNode |
	tree := self parseExpression: '1. 3'.
	treeNode := tree
		addNode: (self parseExpression: '2')
		before: tree statements last.
	self assert: (self parseExpression: '1. 2. 3') equals: tree.
	self assert: (tree statements at: 2) equals: treeNode.
	
	tree := self parseExpression: '{ 1. 3 }'.
	treeNode := tree
		addNode: (self parseExpression: '2')
		before: tree statements last.
	self assert: (self parseExpression: '{ 1. 2. 3 }') equals: tree.
	self assert: (tree statements at: 2) equals: treeNode
]

{ #category : #'testing-adding' }
TPRBProgramNodeTest >> testAddNodeFirst [
	| tree treeNode |
	tree := self parseExpression: '2. 3'.
	treeNode := tree addNodeFirst: (self parseExpression: '1').
	self assert: (self parseExpression: '1. 2. 3') equals: tree.
	self assert: tree statements first equals: treeNode.
	
	tree := self parseExpression: '{ 2. 3 }'.
	treeNode := tree addNodeFirst: (self parseExpression: '1').
	self assert: (self parseExpression: '{ 1. 2. 3 }') equals: tree.
	self assert: tree statements first equals: treeNode
]

{ #category : #'testing-adding' }
TPRBProgramNodeTest >> testAddNodes [
	| tree treeNodes |
	tree := self parseExpression: '1. 2'.
	treeNodes := tree addNodes: (self parseExpression: '3. 4') statements.
	self assert: (self parseExpression: '1. 2. 3. 4') equals: tree.
	self assert: (tree statements at: 3) equals: treeNodes first.
	self assert: (tree statements at: 4) equals: treeNodes last.
	
	tree := self parseExpression: '{ 1. 2 }'.
	treeNodes := tree addNodes: (self parseExpression: '3. 4') statements.
	self assert: (self parseExpression: '{ 1. 2. 3. 4 }') equals: tree.
	self assert: (tree statements at: 3) equals: treeNodes first.
	self assert: (tree statements at: 4) equals: treeNodes last
]

{ #category : #'testing-adding' }
TPRBProgramNodeTest >> testAddNodesBefore [
	| tree treeNodes |
	tree := self parseExpression: '1. 4'.
	treeNodes := tree 
		addNodes: (self parseExpression: '2. 3') statements
		before: tree statements last.
	self assert: (self parseExpression: '1. 2. 3. 4') equals: tree.
	self assert: (tree statements at: 2) equals: treeNodes first.
	self assert: (tree statements at: 3) equals: treeNodes last.
	
	tree := self parseExpression: '{ 1. 4 }'.
	treeNodes := tree 
		addNodes: (self parseExpression: '2. 3') statements
		before: tree statements last.
	self assert: (self parseExpression: '{ 1. 2. 3. 4 }') equals: tree.
	self assert: (tree statements at: 2) equals: treeNodes first.
	self assert: (tree statements at: 3) equals: treeNodes last
]

{ #category : #'testing-adding' }
TPRBProgramNodeTest >> testAddNodesFirst [
	| tree treeNodes |
	tree := self parseExpression: '3. 4'.
	treeNodes := tree addNodesFirst: (self parseExpression: '1. 2') statements.
	self assert: (self parseExpression: '1. 2. 3. 4') equals: tree.
	self assert: (tree statements at: 1) equals: treeNodes first.
	self assert: (tree statements at: 2) equals: treeNodes last.
	
	tree := self parseExpression: '{ 3. 4 }'.
	treeNodes := tree addNodesFirst: (self parseExpression: '1. 2') statements.
	self assert: (self parseExpression: '{ 1. 2. 3. 4 }') equals: tree.
	self assert: (tree statements at: 1) equals: treeNodes first.
	self assert: (tree statements at: 2) equals: treeNodes last
]

{ #category : #'testing-adding' }
TPRBProgramNodeTest >> testAddReturn [
	| tree return |
	tree := self parseExpression: '1. 2'.
	return := tree addReturn.
	self assert: tree statements last equals: return.
	self assert: (self parseExpression: '1. ^ 2') equals: tree.
	
	tree := self parseExpression: '3. ^ 4'.
	return := tree addReturn.
	self assert: tree statements last equals: return.
	self assert: (self parseExpression: '3. ^ 4') equals: tree
]

{ #category : #'testing-adding' }
TPRBProgramNodeTest >> testAddSelfReturn [
	| tree return |
	tree := self parseExpression: '1. 2'.
	return := tree addSelfReturn.
	self assert: tree statements last equals: return.
	self assert: (self parseExpression: '1. 2. ^ self') equals: tree.
	
	tree := self parseExpression: '3. ^ 4'.
	return := tree addSelfReturn.
	self assert: tree statements last equals: return.
	self assert: (self parseExpression: '3. ^ 4') equals: tree
]

{ #category : #'testing-adding' }
TPRBProgramNodeTest >> testAddTemporariesNamed [
	| tree variables |
	tree := self parseExpression: '| a | a'.
	variables := tree addTemporariesNamed: #('b' 'c').
	self assert: variables first isVariable.
	self assert: variables first name equals: 'b'.
	self assert: variables second isVariable.
	self assert: variables second name equals: 'c'.
	self assert: tree temporaries second equals: variables first.
	self assert: tree temporaries last equals: variables second
	
]

{ #category : #'testing-adding' }
TPRBProgramNodeTest >> testAddTemporaryNamed [
	| tree variable |
	tree := self parseExpression: '| a | a'.
	variable := tree addTemporaryNamed: 'b'.
	self assert: variable isVariable.
	self assert: variable name equals: 'b'.
	self assert: tree temporaries last equals: variable
]

{ #category : #'testing-properties' }
TPRBProgramNodeTest >> testHasProperty [
	self deny: (self node hasProperty: #foo).
	self node propertyAt: #foo put: 123.
	self assert: (self node hasProperty: #foo)
]

{ #category : #'testing-properties' }
TPRBProgramNodeTest >> testPropertyAt [
	self should: [ self node propertyAt: #foo ] raise: Error.
	self node propertyAt: #foo put: true.
	self assert: (self node propertyAt: #foo)
]

{ #category : #'testing-properties' }
TPRBProgramNodeTest >> testPropertyAtIfAbsent [
	self assert: (self node propertyAt: #foo ifAbsent: [ true ]).
	self node propertyAt: #foo put: true.
	self assert: (self node propertyAt: #foo ifAbsent: [ false ])
]

{ #category : #'testing-properties' }
TPRBProgramNodeTest >> testPropertyAtIfAbsentPut [
	self assert: (self node propertyAt: #foo ifAbsentPut: [ true ]).
	self assert: (self node propertyAt: #foo ifAbsentPut: [ false ])
]

{ #category : #'testing-properties' }
TPRBProgramNodeTest >> testPropertyAtIfPresentIfAbsent [
	self assert: (self node propertyAt: #foo ifPresent:[ false ] ifAbsent: [ true ]) equals: true.
	self node propertyAt: #foo put: true.
	self assert: (self node propertyAt: #foo ifPresent:[ true ] ifAbsent: [ false ]).
	self assert: (self node propertyAt: #toto ifPresent:[ false ] ifAbsent: [ true ])
]

{ #category : #'testing-properties' }
TPRBProgramNodeTest >> testRemoveProperty [
	self should: [ self node removeProperty: #foo ] raise: Error.
	self node propertyAt: #foo put: true.
	self assert: (self node removeProperty: #foo)
]

{ #category : #'testing-properties' }
TPRBProgramNodeTest >> testRemovePropertyIfAbsent [
	self assert: (self node removeProperty: #foo ifAbsent: [ true ]).
	self node propertyAt: #foo put: true.
	self assert: (self node removeProperty: #foo ifAbsent: [ false ])
]

{ #category : #'testing-replacing' }
TPRBProgramNodeTest >> testReplaceAssignment [
	| tree expectedTree |
	tree := self parseMethod: 'run sum := 2 + 2'.
	expectedTree := self parseMethod: 'run multpppp := 2 * 2'.
	
	tree body statements first replaceWith: (self parseExpression: 'multpppp := 2 * 2').
	self assert: tree equals: expectedTree.
]

{ #category : #'testing-replacing' }
TPRBProgramNodeTest >> testReplaceBlock [
	| tree expectedTree |
	tree := self parseMethod: 'run self foo ifNil: [ ^ true ]'.
	expectedTree := self parseMethod: 'run self foo ifNil: [ ^ false ]'.
	
	tree body statements first arguments first replaceWith: (self parseExpression: '[ ^ false ]').
	self assert: tree  equals: expectedTree
]

{ #category : #'testing-messages' }
TPRBProgramNodeTest >> testSentMessages [
	| tree messages |
	tree := self
		parseRewriteMethod:
			'methodName
				| temp |
				1 send1 send2; send3.
				temp := [:each | {4 send4} send5].
				temp send6 `{:node | node notASentMessage}'.
	messages := tree sentMessages.
	self assert: messages size equals: 6.
	1 to: 6 do:
		[ :i | self assert: (messages includes: ('send' , i printString) asSymbol) ]
]

{ #category : #'testing-comments' }
TPRBProgramNodeTest >> testSetCommentsToNil [

	self node comments: nil.
	self assert: self node comments equals: #()
]
