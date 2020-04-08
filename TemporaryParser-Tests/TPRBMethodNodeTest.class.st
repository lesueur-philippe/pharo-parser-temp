"
SUnit tests for RBMethodNode
"
Class {
	#name : #TPRBMethodNodeTest,
	#superclass : #TPRBParseTreeTest,
	#category : #'TemporaryParser-Tests-Nodes'
}

{ #category : #helpers }
TPRBMethodNodeTest >> methodWithArg: someArgName and: someAnotherArgName [

]

{ #category : #helpers }
TPRBMethodNodeTest >> parseMethod: aString [
	^ self parserClass parseMethod: aString
]

{ #category : #tests }
TPRBMethodNodeTest >> testAddingMethodProperties [

	| ast |
	ast := self parseMethod: 'one ^ self'.
	self assert: ast methodProperties isNil. 
	
	ast methodPropertyAt: #testKey put: #testValue.
	ast methodPropertyAt: #testKey2 put: #testValue2.
	self assert: (ast methodPropertyAt: #testKey) equals: #testValue.
	self assert: (ast methodPropertyAt: #testKey2) equals: #testValue2.
	self assert: ast methodProperties class equals: AdditionalMethodState
]

{ #category : #tests }
TPRBMethodNodeTest >> testCachingMethodArguments [

	| ast |
	ast := (self class >> #methodWithArg:and:) ast.
	ast propertyAt: #argumentNames put: #(wrongArg wrongArg2).
	
	ast ensureCachedArgumentNames.
	self assert: (ast methodPropertyAt: #argumentNames) equals: #(someArgName someAnotherArgName)
]

{ #category : #'testing-comments' }
TPRBMethodNodeTest >> testCommentedMethodHasComments [

	| tree |
	tree := self parseMethod: 'foo: abd bar: cde  
		"this is comment"
		"this is another comment"
^ abd + cde'.

	self assert: tree hasComments.
	

]

{ #category : #'tests - primitives' }
TPRBMethodNodeTest >> testIsPrimitive [
	"see other testPrimitive... tests"
	"This test brings the test button in the browser and test negatively
	The others are for each specific kind of primitive:..."
	| ast |
	ast := (SmallInteger >> #+) ast.
	self assert: ast isPrimitive.
	ast := (Bitmap >> #primFill:) ast.
	self assert: ast isPrimitive.
	
	ast := (Integer >> #+) ast.
	self deny: ast isPrimitive.
]

{ #category : #tests }
TPRBMethodNodeTest >> testNodeForOffsetAssignment [
	"test the case of a Assignment"

	| source ast foundNode |
	source := 'method Object := Class'.
	ast := self parserClass parseMethod: source.
	foundNode := ast nodeForOffset: 9.
	self assert: foundNode class identicalTo: TPRBVariableNode.
	foundNode := ast nodeForOffset: 14.
	self assert: foundNode class identicalTo: TPRBAssignmentNode.
	foundNode := ast nodeForOffset: 19.
	self assert: foundNode class identicalTo: TPRBVariableNode
]

{ #category : #tests }
TPRBMethodNodeTest >> testNodeForOffsetMessage [
	"test the case of Messages"

	| source ast foundNode |
	source := 'method Object doit: Class'.
	ast := self parserClass parseMethod: source.
	foundNode := ast nodeForOffset: 9.
	self assert: foundNode class identicalTo: TPRBVariableNode.
	foundNode := ast nodeForOffset: 14.
	self assert: foundNode class identicalTo: TPRBMessageNode.
	foundNode := ast nodeForOffset: 22.
	self assert: foundNode class identicalTo: TPRBVariableNode
]

{ #category : #tests }
TPRBMethodNodeTest >> testNodeForOffsetTempDefinition [
	"test the case of Messages"

	| source ast foundNode |
	source := 'method | temp |'.
	ast := self parserClass parseFaultyMethod: source.
	foundNode := ast nodeForOffset: 12.
	self assert: foundNode class identicalTo: TPRBVariableNode
]

{ #category : #tests }
TPRBMethodNodeTest >> testNodeForOffsetVar [
	"test the case of a variable"

	| source ast foundNode |
	source := 'method Object'.
	ast := self parserClass parseMethod: source.
	foundNode := ast nodeForOffset: 9.
	self assert: foundNode class identicalTo: TPRBVariableNode
]

{ #category : #'tests - primitives' }
TPRBMethodNodeTest >> testPrimitiveErrorIsPrimitive [

	"isPinnedInMemory
		<primitive: 183 error: ec>
		^self primitiveFailed
	"
	
	| ast |
	ast := (Object >> #isPinnedInMemory) ast.
	self assert: ast isPrimitive.

	ast := (MirrorPrimitives class >> #makeObject:readOnly:) ast.
	self assert: ast isPrimitive.
	
]

{ #category : #'tests - primitives' }
TPRBMethodNodeTest >> testPrimitiveIsPrimitive [
	"primFill: aPositiveInteger
		<primitive: 145>
		self errorImproperStore."
	
	| ast |
	ast := (SmallInteger >> #+) ast.
	self assert: ast isPrimitive.
	ast := (Bitmap >> #primFill:) ast.
	self assert: ast isPrimitive.
	
]

{ #category : #'tests - primitives' }
TPRBMethodNodeTest >> testPrimitiveModuleErrorIsPrimitive [
	"
	primClosedir: directoryPointerBytes
		<primitive: 'primitiveClosedir' module: 'FileAttributesPlugin' error: error>
		...
	"
	| ast |
	ast := (File class >> #primClosedir:) ast.
	self assert: ast isPrimitive.


	
]

{ #category : #'tests - primitives' }
TPRBMethodNodeTest >> testPrimitiveModuleIsPrimitive [
	"
	stringHash: aString initialHash: speciesHash

		| stringSize hash low |
		<primitive: 'primitiveStringHash' module: 'MiscPrimitivePlugin'>

		<var: #aHash declareC: 'int speciesHash'>
		<var: #aString declareC: 'unsigned char *aString'>

	"
	| ast |
	ast := (ByteString class >> #stringHash:initialHash:) ast.
	self assert: ast isPrimitive.

	ast := (Integer >> #digitSubtract:) ast.
	self assert: ast isPrimitive.

	
]

{ #category : #tests }
TPRBMethodNodeTest >> testSelectorAndArgumentNames [

	self assert: (self parseMethod: 'one ^ self') selectorAndArgumentNames equals: 'one'.
	self assert: (self parseMethod: 'one:   aOne ^ self') selectorAndArgumentNames equals: 'one:   aOne'.
	self assert: (self parseMethod: 'one:   aOne two:   aTwo ^ self') selectorAndArgumentNames equals: 'one:   aOne two:   aTwo'.
	self assert: (self parseMethod: '*   aOne') selectorAndArgumentNames equals: '*   aOne'.
	self assert: (self parseMethod: '**   aOne') selectorAndArgumentNames equals: '**   aOne'
]

{ #category : #tests }
TPRBMethodNodeTest >> testSizeOfSignatureOfBinaryMethod [
	| tree |
	tree := self
		parseMethod:
			' + x   
^ 2 + 3'.
	self assert: tree conceptualSelectorSize equals: '+' size.
	self assert: tree conceptualArgumentSize equals: 'x'  size.
	self assert: tree conceptualSignatureSize equals: '+' size + tree conceptualArgumentSize + 1
]

{ #category : #tests }
TPRBMethodNodeTest >> testSizeOfSignatureOfKeywordsMethod [
	| tree |
	tree := self
		parseMethod:
			'foo: abd bar: cde  
^ abd + cde'.
	self assert: tree conceptualSelectorSize equals: 'foo:bar:' size.
	self assert: tree conceptualArgumentSize equals: 'abdcde' size.
	self
		assert: tree conceptualSignatureSize
		equals: 'abdcde' size + 'foo:bar:' size + 3.
	
]

{ #category : #tests }
TPRBMethodNodeTest >> testSizeOfSignatureOfUnaryMethod [
	| tree |
	tree := self
		parseMethod:
			'foo  
^ 2 + 3'.
	self assert: tree conceptualSelectorSize equals: 'foo' size.
	self assert: tree conceptualArgumentSize isZero.
	self assert: tree conceptualSignatureSize equals: 'foo' size
]

{ #category : #'testing-comments' }
TPRBMethodNodeTest >> testUncommentMethodDoesNotHaveComments [

	| tree |
	tree := self parseMethod: 'foo: abd bar: cde  
^ abd + cde'.

	self deny: tree hasComments.
	

]
