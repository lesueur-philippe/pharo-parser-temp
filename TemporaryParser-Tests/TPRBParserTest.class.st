"
SUnit tests for RBParser
"
Class {
	#name : #TPRBParserTest,
	#superclass : #TPRBParseTreeTest,
	#category : #'TemporaryParser-Tests-Parser'
}

{ #category : #accessing }
TPRBParserTest class >> parserClass [
	^ TPRBParser
]

{ #category : #accessing }
TPRBParserTest >> compare: anObject to: anotherObject [ 
	self assert: anObject hash equals: anotherObject hash.
	self assert: anObject equals: anotherObject
]

{ #category : #accessing }
TPRBParserTest >> exampleClasses [
	<sampleInstance>
	^ Array
		with: self parserClass
		with: TPRBScanner
		with: TPRBProgramNode
		with: TPRBComment
]

{ #category : #private }
TPRBParserTest >> parseError: each [
	
	self parseError: each first onError: [ :string :pos | ^ self assert: pos equals: each last ].
	self assert: false description: 'Parser didn''t fail'
	
]

{ #category : #private }
TPRBParserTest >> parseError: expression onError: aBlock [
	^ self parserClass parseExpression: expression onError: aBlock
]

{ #category : #private }
TPRBParserTest >> parseFaultyExpression: text [
	^ self parserClass parseFaultyExpression: text
]

{ #category : #tests }
TPRBParserTest >> parseTreeSearcher [
	^ RBParseTreeSearcher new
]

{ #category : #private }
TPRBParserTest >> parserClass [
	^ self class parserClass
]

{ #category : #testArray }
TPRBParserTest >> testArrayNodesContainRightAmountOfStatementsAndPeriods [
	"1. The array to be parsed into an array node.
	 2. The number of statements in the array node.
	 3. The number of periods in the array node."
	| tree |
	#(('{}' 0 0) 
	  ('{.}' 0 1) 
	  ('{..}' 0 2) 
	  ('{foo. bar}' 2 1) 
	  ('{foo. bar.}' 2 2) 
	  ('{foo. bar. .}' 2 3) 
	  ('{. foo. bar}' 2 2) 
	  ('{foo.. bar}' 2 2)) do: [ :each | tree := self parserClass parseExpression: each first.
													self assert: tree statements size equals: each second.
													self assert: tree periods size equals: each last. ]
]

{ #category : #'error testing' }
TPRBParserTest >> testBadlyPlacedPragmaRaiseError [
	"The placement in the string will have an impact on the parsing methods involved.
	 Pragmas are supposed to be written in the beginning of a method."
	self shouldnt: [(self parserClass parseMethod: 'foo | token | <some: #tag> ^true')] 
		  raise: SyntaxErrorNotification.
							
	self should: [(self parserClass parseMethod: 'foo | token | ^true <some: #tag>')]
		  raise: 	SyntaxErrorNotification.
			
	self should: [(self parserClass parseMethod: 'foo | token | token:= 5 <some: #tag> ^token')]
		  raise: 	SyntaxErrorNotification.
	
	self should: [(self parserClass parseMethod: 'foo | token |  token messaged <some: #tag> ^token')]
		  raise: 	SyntaxErrorNotification.
	
]

{ #category : #'tests interval' }
TPRBParserTest >> testBestNodeFor [
	| tree |
	tree := self treeWithReallyEverything.
	tree nodesDo: 
			[:each | 
			each sourceInterval isEmpty 
				ifFalse: 
					[self assert: ((tree bestNodeFor: each sourceInterval) = each 
								or: [each parent isCascade and: [each parent messages last = each]])]]
]

{ #category : #'tests parsing' }
TPRBParserTest >> testBinarySelectors [
	"ANSI Smalltalk Standard Draft, page 32:
		binaryCharacter ::=
			'!' | '%' | '&' | '*' | '+' | ','' | '/' | '<' | '=' | '>' | '?' | '@' | '\' | '~' | '|' | '-'
		binarySelector ::= binaryCharacter+"

	| binaryCharacters selectorStrings |
	"Create a collection of strings to parse.
	 The collection is made of every possible string sized from 1 to 3 selectors."
	binaryCharacters := '!%&*+,/<=>?@\~-'.
	selectorStrings := OrderedCollection new.
	binaryCharacters do: [:first |
		selectorStrings addLast: (String with: first).
		binaryCharacters do: [:second |
			selectorStrings addLast: (String with: first with: second).
			binaryCharacters do: [:third |
				selectorStrings addLast: (String with: first with: second with: third)]]].

	""
	selectorStrings do: [:each | | methodNode messageNode |
		methodNode := self parseMethod: each, 'anObject
	^self',each,'anObject'.
		self assert: methodNode selector equals: each asSymbol.
		self assert: methodNode argumentNames asArray equals: #(anObject).
		self assert: methodNode statements size equals: 1.
	
		messageNode := methodNode statements first value.
		self assert: messageNode isMessage.
		self assert: messageNode receiver name equals: #self.
		self assert: messageNode selector equals: each asSymbol.
		self assert: messageNode arguments size equals: 1.
		self assert: messageNode arguments first isValue.
		self assert: messageNode arguments first name equals: #anObject].
]

{ #category : #tests }
TPRBParserTest >> testBlockNodeIsUsed [
	| tree |
	" block node is not a used-node"
	tree := self parserClass parseMethod:
			'tmp [ 3+4 ]'.
	self deny: tree body statements last isUsed.
	" even a block node with non-local return is not *used* "
	tree := self parserClass parseMethod:
	      'tmp [^ 3+4 ]'.
	self deny: tree body statements last isUsed.
	
	"an explicit return node is *used*"
	tree := self parserClass parseMethod:
			'tmp ^[ 3+4 ]'.
	self assert: tree body statements last isUsed
	
]

{ #category : #tests }
TPRBParserTest >> testBlockReturnNode [
	| tree |
	" no explicit return"
	tree := self parserClass parseMethod:
			'tmp [ 3+4 ]'.
	self deny: tree lastIsReturn.
	" no explicit return the block local return should not count as method return "
	tree := self parserClass parseMethod:
	      'tmp [^ 3+4 ]'.
	self deny: tree lastIsReturn.
	
	" explicit return"
	tree := self parserClass parseMethod:
			'tmp ^ [ 3+4 ]'.
	self assert: tree lastIsReturn
	
]

{ #category : #testCascade }
TPRBParserTest >> testCascadeReplacement [
	"Cascade is composed of an ordered collection of messages, each with the same receiver."
	| cascade |
	cascade := self parserClass parseExpression: 'self foo; bar; baz'.
	"The replacement is made on the collection."
	(cascade messages at: 2) 
		replaceWith: (self parserClass parseExpression: 'self bar: 2').
	self assert: cascade
		  equals: (self parserClass parseExpression: 'self foo; bar: 2; baz').
		
	"The replacement can be a message with another receiver"
	(cascade messages at: 3) 
		replaceWith: (self parserClass parseExpression: 'notself barataba').
	self assert: (cascade messages at: 3) receiver 
		  equals: (self parserClass parseExpression: 'notself').
]

{ #category : #'garbage tests' }
TPRBParserTest >> testCascadeReplacementCanLeadToOddErrors [
	| cascade |
	cascade := self parserClass parseExpression: 'self foo; bar; baz'.
	(cascade messages at: 2) 
		replaceWith: (self parserClass parseExpression: '2').
		
	cascade := self parserClass parseExpression: 'self foo; bar; baz'.
	(cascade messages at: 2) 
		replaceWith: (TPRBParser parseExpression: 'temp := temp bar').
		
	"This tests create an error in the printing of self and parent of the node."
]

{ #category : #'error testing' }
TPRBParserTest >> testCascadeWithNoMessageRaiseError [
	self should: [ self parserClass parseExpression: ' (self msg); yourself' ] raise: SyntaxErrorNotification.
	self should: [ self parserClass parseExpression: ' self ; yourself' ] raise: SyntaxErrorNotification.
	self should: [ self parserClass parseExpression: ' (self) ; yourself' ] raise: SyntaxErrorNotification.
	self should: [ self parserClass parseExpression: ' self msg ;  ; yourself' ] raise: SyntaxErrorNotification
]

{ #category : #testCreationProtocol }
TPRBParserTest >> testCreationBlockNodeWithExpression [
	self compare: (self parserClass parseExpression: '[:a :b | a messaged. b messaged.]') 
		  to:(TPRBBlockNode
			   arguments: (OrderedCollection with: (TPRBVariableNode named: 'a') with: (TPRBVariableNode named: 'b'))
				body: (TPRBSequenceNode statements: (OrderedCollection with: (TPRBMessageNode receiver: (TPRBVariableNode named: #a) selector: #messaged) 
																						with: (TPRBMessageNode receiver: (TPRBVariableNode named: #b) selector: #messaged)))).
]

{ #category : #testCreationProtocol }
TPRBParserTest >> testCreationCascadeNodeFromExpression [
	self compare: (self parserClass parseExpression: 'cascade firstMessage; secondMessage; lastMessage')
		  to: (TPRBCascadeNode 
				messages: (OrderedCollection with: (TPRBMessageNode receiver: (TPRBVariableNode named: 'cascade') 
																					selector: #firstMessage) 
													  with: (TPRBMessageNode receiver: (TPRBVariableNode named: 'cascade') 
																					selector: #secondMessage)
													  with: (TPRBMessageNode receiver: (TPRBVariableNode named: 'cascade') 
																					selector: #lastMessage)) 
				semicolons: (OrderedCollection with: 21 with: 37)).
]

{ #category : #testCreationProtocol }
TPRBParserTest >> testCreationLiteralArrayNodeWithExpression [
	self compare: (self parserClass parseExpression: '#(literal1 literal2)')
		  to: (TPRBLiteralArrayNode
				startPosition: 1
				contents: (Array with: (TPRBLiteralValueNode value: #literal1) with: (TPRBLiteralValueNode value: #literal2))
				stopPosition: 20
				isByteArray: false).
]

{ #category : #testCreationProtocol }
TPRBParserTest >> testCreationLiteralValueNodeWithExpression [
	self compare: (self parserClass parseExpression: '#literal')
		  to: (TPRBLiteralValueNode
				value: #literal
				start: 1
				stop: 8).
]

{ #category : #testCreationProtocol }
TPRBParserTest >> testCreationLiteralValueNodeWithExpressionForNumber [
	self compare: (self parserClass parseExpression: '2r10100')
		  to: (TPRBLiteralValueNode
				value: 20
				start: 1
				stop: 7).
]

{ #category : #testCreationProtocol }
TPRBParserTest >> testCreationMessageNodeFromExpression [
	| messageNode |
	"Verify the good parsing of an expression."
	self compare: (self parserClass parseExpression: 'self + 0')
		  to: (TPRBMessageNode 
				receiver: (TPRBVariableNode named: 'self')
				selector: #+
				arguments: (Array with: (TPRBLiteralNode value: 0))).
]

{ #category : #testCreationProtocol }
TPRBParserTest >> testCreationSelfNodeWithExpression [
	self compare: (self parserClass parseExpression: 'self')
		  to: (TPRBSelfNode new).
]

{ #category : #testCreationProtocol }
TPRBParserTest >> testCreationSuperNodeWithExpression [
	self compare: (self parserClass parseExpression: 'super')
		  to: (TPRBSuperNode new).
]

{ #category : #testCreationProtocol }
TPRBParserTest >> testCreationThisContexNodeWithExpression [
	self compare: (self parserClass parseExpression: 'thisContext')
		  to: (TPRBThisContextNode new).
]

{ #category : #testCreationProtocol }
TPRBParserTest >> testCreationVariableNodeWithExpression [
	self compare: (self parserClass parseExpression: 'variable')
		  to: (TPRBVariableNode named: #variable start: 1).
]

{ #category : #testArray }
TPRBParserTest >> testDelimitationsOfArrayNodesAreBrackets [
	| tree |
	#('{}' '{.}' '{..}' '{foo. bar}' '{foo. bar.}' '{foo. bar. .}' '{. foo. bar}' '{foo.. bar}')
	do: [ :each |  tree := self parserClass parseExpression: each.
						self assert: tree left equals: 1.
						self assert: tree right equals: each size ]
]

{ #category : #'error testing' }
TPRBParserTest >> testFaultyLiteralRaiseSyntaxError [
	#('#"bar"foo' '# foo' '#1' '#12' '#12.3' '# 1' '##1' '#"bar"1') 
		do: [ :expr | 
		self should: [self parserClass parseExpression: expr] raise: SyntaxErrorNotification ]
]

{ #category : #'garbage tests' }
TPRBParserTest >> testGarbageAssignementOfANonVariable [
	"Raising a syntax exception when trying to do an assignement on a message."
	self should: [self parserClass parseExpression: 'receiver selector := 1 + 2'] raise: SyntaxErrorNotification.
]

{ #category : #'garbage tests' }
TPRBParserTest >> testGarbageAssignementWithMisplacedDot [
	"The idea is for the parser to realise the first dot isn't supposed to be here and select it. Also add a side note to give suggestion     on the provenance of the error."
	self should: [self parserClass parseExpression: 'temp := .1 + 2.'] raise: SyntaxErrorNotification.
	self should: [self parserClass parseExpression: 'temp := 1. + 2.'] raise: SyntaxErrorNotification.
	self should: [self parserClass parseExpression: 'temp := 1 +. 2.'] raise: SyntaxErrorNotification.
	
	"The same could be made for other special characters."
	self should: [self parserClass parseExpression: 'temp := ;1 + 2.'] raise: SyntaxErrorNotification.
	self should: [self parserClass parseExpression: 'temp := ,1 + 2.'] raise: SyntaxErrorNotification.
]

{ #category : #'garbage tests' }
TPRBParserTest >> testGarbageBadlyParenthesizedEndOfStatement [
	"Should propose a closing parenthese before the end of the statement. Should also offer possibility to quickly erase it."
	self should: [self parserClass parseExpression: '(temp := 1 + 3 .'] raise: SyntaxErrorNotification.
]

{ #category : #'garbage tests' }
TPRBParserTest >> testGarbageEncouteringEndOfStatement [
	"Could propose multiple reparations like assignement, period, array..."
	self should: [self parserClass parseExpression: 'temp 1 + 3'] raise: SyntaxErrorNotification.
]

{ #category : #'garbage tests' }
TPRBParserTest >> testGarbageFaultyCascadeGivesMultipleErrorAndNoMassage [
	| tree |
	tree := self parseFaultyExpression: 'faulty cascade; 1; node'.
	self assert: tree isSequence.
	self assert: tree statements size equals: 2.
	
	"The first node is meant to be a cascade but the failure prevent from having a cascade node which means having an error 
	 node instead. This has some repercutions : their is no cascade message and the name of the parents are wrong."
	self assert: tree statements first isFaulty.
	self assert: tree statements first errorMessage equals: 'Message expected'.
	
	self assert: tree statements last isFaulty.
	self assert: tree statements last errorMessage equals: 'End of statement list encountered'.
	
	self assert: tree parent printString equals: 'noMethod
  1; node.
  1; node'.
	
	"The problem is further enlightenned with longer cascades."
	tree := self parseFaultyExpression: 'faulty cascade; successful; until; not; 1; node'.
	self assert: tree isSequence.
	self assert: tree statements size equals: 2.
	
	self assert: tree statements first isFaulty.
	self assert: tree statements first errorMessage equals: 'Message expected'.
	
	self assert: tree statements last isFaulty.
	self assert: tree statements last errorMessage equals: 'End of statement list encountered'.
	
	self assert: tree parent printString equals: 'noMethod
  1; node.
  1; node'.
]

{ #category : #'garbage tests' }
TPRBParserTest >> testGarbageForgottenDotAfterAssignement [
	| tree child error |
	self shouldnt: [self parserClass parseExpression: '|temp | temp := 1 + 2 temp + 3'] raise: SyntaxErrorNotification.
	
	tree := self parserClass parseExpression: '|temp | temp := 1 + 2 temp + 3'.
	self assert: tree isSequence.
	
	"There should only be one statement as there is no dot."
	child := tree statements.
	self assert: (child size) equals: 1.
	self assert: child first isAssignment.
	
	"Getting the part changed by missing dot."
	error := child first value receiver arguments first.
	self assert: error isMessage.
	self assert: error receiver value equals: 2.
	self assert: error selector equals: #temp
	
	
	
]

{ #category : #'garbage tests' }
TPRBParserTest >> testGarbageForgottenReceiver [
	"Test made in sight of implementing the search of previous litterals when encountering an unknown 
	 variable in case it is, in fact, a selector. This works for cascade (forgotten ;) or missing 
	 receiver like self ..."
	self should: [self parserClass parseExpression: '|temp | temp := 1 + 2. + 3'] raise: SyntaxErrorNotification.
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralBlockIntervalsArray [
	"This tests that array nodes inside a block node correspond the right interval in the source code."
	| tree str |
	tree := (self parseExpression: '["comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node]').
	str := '{array node}'.
	self assert: ((tree body statements at: 4) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 4) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralBlockIntervalsAssignement [
	"This tests that assignement nodes inside a block node correspond the right interval in the source code."
	| tree str |
	tree := (self parseExpression: '["comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node]').
	str := 'assignement := node'.
	self assert: ((tree body statements at: 7) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 7) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralBlockIntervalsBlock [
	"This tests that block nodes inside a block node correspond the right interval in the source code."
	| tree str |
	tree := (self parseExpression: '["comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node]').
	str := '[block node]'.
	self assert: ((tree body statements at: 5) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 5) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralBlockIntervalsCascade [
	"This tests that cascade nodes inside a block node correspond the right interval in the source code."
	| tree str |
	tree := (self parseExpression: '["comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node]').
	str := 'cascade node; cascaded'.
	self assert: ((tree body statements at: 6) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 6) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralBlockIntervalsLiteralArray [
	"This tests that literal array nodes inside a block node correspond the right interval in the source code."
	| tree str |
	tree := (self parseExpression: '["comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node]').
	str := '#(literal array node)'.
	self assert: ((tree body statements at: 3) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 3) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralBlockIntervalsLiteralValue [
	"This tests that literal value nodes inside a block node correspond the right interval in the source code."
	| tree str |
	tree := (self parseExpression: '["comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node]').
	str := '#literalNode'.
	self assert: ((tree body statements at: 2) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 2) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralBlockIntervalsMessage [
	"This tests that message nodes inside a block node correspond the right interval in the source code."
	| tree str |
	tree := (self parseExpression: '["comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node]').
	str := 'message node'.
	self assert: ((tree body statements at: 1) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 1) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralBlockIntervalsReturn [
	"This tests that return nodes inside a block node correspond the right interval in the source code."
	| tree str |
	tree := (self parseExpression: '["comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node]').
	str := '^return node'.
	self assert: ((tree body statements at: 8) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 8) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralMethodIntervalsArray [
	"This tests that array nodes inside a method node correspond the right interval in the source code."
	| tree str |
	tree := (self parseMethod: 'Selector <pragmanode> "comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node').
	str := '{array node}'.
	self assert: ((tree body statements at: 4) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 4) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralMethodIntervalsAssignement [
	"This tests that assignement nodes inside a method node correspond the right interval in the source code."
	| tree str |
	tree := (self parseMethod: 'Selector <pragmanode> "comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node').
	str := 'assignement := node'.
	self assert: ((tree body statements at: 7) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 7) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralMethodIntervalsBlock [
	"This tests that block nodes inside a method node correspond the right interval in the source code."
	| tree str |
	tree := (self parseMethod: 'Selector <pragmanode> "comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node').
	str := '[block node]'.
	self assert: ((tree body statements at: 5) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 5) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralMethodIntervalsCascade [
	"This tests that cascade nodes inside a method node correspond the right interval in the source code."
	| tree str |
	tree := (self parseMethod: 'Selector <pragmanode> "comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node').
	str := 'cascade node; cascaded'.
	self assert: ((tree body statements at: 6) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 6) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralMethodIntervalsComment [
	"This tests that comment nodes inside a method node correspond the right interval in the source code."
	| tree str |
	tree := (self parseMethod: 'Selector <pragmanode> "comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node').
	str := '"comment node"'.
	self assert: ((tree comments at: 1) start) equals: (tree source findString: str).
	self assert: ((tree comments at: 1) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralMethodIntervalsLiteralArray [
	"This tests that literal array nodes inside a method node correspond the right interval in the source code."
	| tree str |
	tree := (self parseMethod: 'Selector <pragmanode> "comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node').
	str := '#(literal array node)'.
	self assert: ((tree body statements at: 3) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 3) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralMethodIntervalsLiteralValue [
	"This tests that literal value nodes inside a method node correspond the right interval in the source code."
	| tree str |
	tree := (self parseMethod: 'Selector <pragmanode> "comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node').
	str := '#literalNode'.
	self assert: ((tree body statements at: 2) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 2) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralMethodIntervalsMessage [
	"This tests that message nodes inside a method node correspond the right interval in the source code."
	| tree str |
	tree := (self parseMethod: 'Selector <pragmanode> "comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node').
	str := 'message node'.
	self assert: ((tree body statements at: 1) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 1) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralMethodIntervalsPragma [
	"This tests that pragma nodes inside a method node correspond the right interval in the source code."
	| tree str |
	tree := (self parseMethod: 'Selector <pragmanode> "comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node').
	str := '<pragmanode>'.
	self assert: (tree pragmas first left) equals: (tree source findString: str).
	self assert: (tree pragmas first right) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testIntervals }
TPRBParserTest >> testGeneralMethodIntervalsReturn [
	"This tests that return nodes inside a method node correspond the right interval in the source code."
	| tree str |
	tree := (self parseMethod: 'Selector <pragmanode> "comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node').
	str := '^return node'.
	self assert: ((tree body statements at: 8) start) equals: (tree source findString: str).
	self assert: ((tree body statements at: 8) stop) equals: ((tree source findString: str) + (str size - 1)).
]

{ #category : #testPragma }
TPRBParserTest >> testIdentificationOfPrimitiveMethods [
	"Verify if there is the pragma primitive in the parsed method."
	"The string is the element to be parsed.
	 The boolean is the expected result. true : is primitive
													false : is not primitive."
	#(('foo ^true' false ) 
	  ('foo <some: #tag> ^true' false ) 
	  (' foo <some: #tag> <primitive: 123> ^self' true ) 
	  ('foo primitive:= 123. ^self' false)) 
	do: [:each | self assert: (self parserClass parseMethod: each first) isPrimitive equals: each last]
]

{ #category : #'error testing' }
TPRBParserTest >> testInvalidPragmaPosition [
	#(
	'foo self. <foo: $a>'
	'<foo: $a>'
	'foo [:x | <foo: $a> ] value'
	'foo ^ <foo: $a>'
	) 
	do: [ :each | self should: [ self parserClass parseMethod: each ] raise: SyntaxErrorNotification ]
]

{ #category : #'foreign use of test' }
TPRBParserTest >> testLiteralArray [
	"Test the good parsing of the elements of a literal array which means treating each as a literal."
	| tree collection |
	tree := self parserClass parseExpression: 
			  '#( a #b #''c'' . + - 1 -2 3.4 #true true #false false #nil nil "comment" ''string'' #[ 1 2 3 ] #(1 2 3))'.
	collection := OrderedCollection new.
	"Create a collection with the expected values contained in the literal array."
	collection add: #a; 
				  add: #b; 
				  add: #c; 
				  add: #'.'; 
				  add: #+; 
				  add: #-; 
				  add: 1; 
				  add: -2; 
				  add: 3.4; 
				  add: #true; 
				  add: true; 
				  add: #false; 
				  add: false; 
				  add: #nil; 
				  add: nil; 
				  add: 'string'; 
				  add: #[1 2 3]; 
				  add: #(1 2 3).
	self assert: tree isLiteralArray.
	tree value with: collection do: [ :node :value | 
		self assert: node value equals: value ]
]

{ #category : #testArray }
TPRBParserTest >> testLiteralArrayContainsLiteralValues [
	"Test the good parsing of the elements of a literal array which means treating each as a literal."
	| tree collection |
	tree := self parserClass parseExpression: 
			  '#( a #b #''c'' . + - 1 -2 3.4 #true true #false false #nil nil "comment" ''string'' #[ 1 2 3 ] #(1 2 3))'.
	collection := OrderedCollection new.
	"Create a collection with the expected values contained in the literal array."
	collection add: #a; 
				  add: #b; 
				  add: #c; 
				  add: #'.'; 
				  add: #+; 
				  add: #-; 
				  add: 1; 
				  add: -2; 
				  add: 3.4; 
				  add: #true; 
				  add: true; 
				  add: #false; 
				  add: false; 
				  add: #nil; 
				  add: nil; 
				  add: 'string'; 
				  add: #[1 2 3]; 
				  add: #(1 2 3).
	self assert: tree isLiteralArray.
	tree value with: collection do: [ :node :value | 
		self assert: node value equals: value ]
]

{ #category : #testLiteral }
TPRBParserTest >> testLiteralIntevals [
	| tree |
	tree := self parserClass parseExpression: '#(#a b #( c ))'.
	self assert: tree contents first start equals: 3.
	self assert: tree contents first stop equals: 4.
	self assert: tree contents last contents first start equals: 11
]

{ #category : #testIntervals }
TPRBParserTest >> testMethodNodeEndAtTheEndOfTheString [
	| tree |
	"Expressions have an odd way of handling their stop position. The string is reformated to give a new source corresponding to the method #noMethod.
	 It seems the method node take this new source into account instead of the original one."
	tree := (self parserClass parseExpression: 'foo kung foo. 1+2+3. #''alabama''.  ').
	self assert: tree parent source equals: 'foo kung foo. 1+2+3. #''alabama''.  '.
	self assert: tree parent stop equals: tree parent newSource size.
	
	tree := (self parserClass parseMethod: 'foo kung foo. 1+2+3. #''alabama''.  ').
	self assert: tree source equals: 'foo kung foo. 1+2+3. #''alabama''.  '.
	self assert: tree stop equals: tree newSource size.
	
]

{ #category : #testIntervals }
TPRBParserTest >> testMethodNodeStartAtOne [
	| tree |
	"When there are multiple statements, the node returned is the Sequence node (child of the method node)."
	tree := (self parserClass parseExpression: 'foo koong. ^foo').
	self assert: tree parent start equals: 1.
	
	tree := (self parserClass parseExpression: '  foo koong. ^foo').
	self assert: tree parent start equals: 1.
	
	"parseMethod always return a method node."
	tree := (self parserClass parseMethod: 'foo koong. ^foo').
	self assert: tree start equals: 1.
	
	tree := (self parserClass parseMethod: '  foo koong. ^foo').
	self assert: tree start equals: 1.
	
	
]

{ #category : #'error testing' }
TPRBParserTest >> testNegativeNumberError [
	self should: [ self parserClass parseExpression: '- 2' ] raise: SyntaxErrorNotification
]

{ #category : #testNumber }
TPRBParserTest >> testNumberParsing [
	| numbers node |
	numbers := #(('1' 1) ('-1' -1) ('123' 123) ('123' 123) ('-123' -123) ('1.1' 1.1) ('-1.1' -1.1) ('1.23' 1.23) ('-1.23' -1.23) ('1e3' 1e3) ('1d3' 1d3) ('1q3' 1q3) ('-1e3' -1e3) ('1e-3' 1e-3) ('-1e-3' -1e-3) ('2r1e8'  2r1e8) ('-2r1e8' -2r1e8) ('2r1e-8' 2r1e-8) ('-2r1e-8' -2r1e-8) ('0.50s2' 0.50s2) ('0.500s3' 0.500s3) ('0.050s3' 0.050s3)).
	numbers do: [ :spec |
		node := self parserClass parseExpression: spec first.
		self assert: node source equals: spec first.
		self assert: node value equals: spec second ]
]

{ #category : #testNumber }
TPRBParserTest >> testNumberRadixParsing [
	2 to: 32 do: [ :radix | 
		| radixString |
		radixString := radix printString , 'r'.
		0 to: 72 do: [ :i | self assert: (self parserClass parseExpression: radixString , (i radix: radix)) value equals: i ] ]
]

{ #category : #testParentage }
TPRBParserTest >> testParentOfArgumentNodeIsMethodNode [
	| tree |
	tree := self parseMethod: 'Selector: argument ^return something.'.
	self assert: tree arguments first isVariable.
	self assert: tree arguments first parent equals: tree.
	
]

{ #category : #testParentage }
TPRBParserTest >> testParentOfMethodNodeIsNil [
	| tree |
	tree := self parseMethod: 'Selector ^return something.'.
	self assert: tree parent isNil.
]

{ #category : #testParentage }
TPRBParserTest >> testParentOfSequenceNodeIsMethodNode [
	| tree |
	tree := self parseMethod: 'Selector ^return something.'.
	self assert: tree body isSequence.
	self assert: tree body parent equals: tree.
	
]

{ #category : #testParentage }
TPRBParserTest >> testParentOfStatementsIsSequenceNode [
	| tree |
	tree := self parseMethod: 'Selector: argument "comment node" | temporaries | message node. #literalNode . #(literal array node). {array node}. [block node]. cascade node; cascaded. assignement := node. ^return node'.
	(tree body statements) do: [ :each | self assert: each parent equals: tree body].
	
]

{ #category : #'tests parsing' }
TPRBParserTest >> testParseExpressionGivesTheWriteAmountOfStatements [
	"Testing with a list of triplets.
	 1. The string parsed.
	 2. The number of statements expected in parsed string.
	 3. The number of dots marking a period expected in parsed string."
	| tree |
	#(
	('' 0 0) 
	('.' 0 1) 
	('| bar |' 0 0) 
	('| bar | .' 0 1) 
	('| bar | ..' 0 2) 
	('foo. bar' 2 1) 
	('foo. bar.' 2 2) 
	('foo. bar. .' 2 3) 
	('. foo. bar' 2 2)
	('foo. bar. foo bar.' 3 3)) do: [ :each |
		tree := self parserClass parseExpression: each first.
		self assert: tree statements size equals: each second.
		self assert: tree periods size equals: each last ]
]

{ #category : #'tests parsing faulty' }
TPRBParserTest >> testParseFaultyBlock [
	| node blockNoArgButBar blockNoArgButColon unfinishedBlock |
	"parsing block should mark this block as faulty, if it is unfinished no closing brace, or missing parts (colon but no arg, 
	no arg but vertical bar)"
	blockNoArgButBar := '[ | ]'.
	blockNoArgButColon := '[ : ]'.
	unfinishedBlock := '[  '.
	{blockNoArgButBar.
	blockNoArgButColon.
	unfinishedBlock}
		do: [ :faultyExpression | 
			node := self parseFaultyExpression: faultyExpression.
			self assert: node isBlock.
			self assert: node isFaulty]
]

{ #category : #'tests parsing faulty' }
TPRBParserTest >> testParseFaultyLiteral [
	| faultyLiteral faultyLiteralArray node |
	"a literal or literal array object with an unknown character can be parse
	as faulty expression. If so, the error token (unknown character) needs to be consumed
	otherwise we get an endless loop"
	faultyLiteral := '¿'.
	faultyLiteralArray  := '#(¿)'.
	node := self parseFaultyExpression: faultyLiteral.
	self assert: node isFaulty.
	self assert: node isSequence.
	self assert: node statements first errorMessage equals: 'Unknown character'.	
	node := self parseFaultyExpression: faultyLiteralArray.
	self assert: node isFaulty.
	self assert: node isLiteralArray.	
	self assert: node contents first errorMessage equals: 'Unknown character'
]

{ #category : #'tests parsing faulty' }
TPRBParserTest >> testParseFaultyMethod [
	| node strangeExpressions |
	
	strangeExpressions := OrderedCollection new .
	strangeExpressions 
		add: 'method: asd   self ,';
		add: 'method: asd   self a:'; "message without needed argument"
		add: 'method: asd   []]'; 
		add: 'method: asd  [  ] ,';"binary message without second argument"
		add: 'method:  ^^'; "returning twice"
		add: 'method: asd  ['; "opening a block"
		add: 'method: asd  ^ asd. n'; "invalid expresion after return"
		add: 'method: asd  ^ {'; "Only Open a literal array"
		add: 'selector '''; 
		add: 'selector ''part1''''part2'; "string with escaped ' does not end"
		add: 'selector #^';
		add: 'selector ¿';
		add: ':nl'.


	strangeExpressions do: [ :exp | 
			node := self parseFaultyMethod: exp.
			self assert: node isMethod.
			self assert: node isFaulty
	].

	
]

{ #category : #'tests parsing faulty' }
TPRBParserTest >> testParseFaultyMethodExpressionHasErrorNodeAsFinal [
	| node strangeExpression |
	
	strangeExpression := 'method: asd  ^ asd. n'.
	node := self parseFaultyMethod: strangeExpression.

	self assert: node isMethod.
	self assert: node isFaulty.
	self assert: node statements size equals: 2.
	self assert: node statements last isFaulty
	
]

{ #category : #'tests parsing faulty' }
TPRBParserTest >> testParseFaultyMethodMessagePattern [
	| node faultyMessagePattern |
	faultyMessagePattern := '1'.
	node := self parseFaultyMethod: faultyMessagePattern.
	self assert: node isFaulty
]

{ #category : #'tests parsing faulty' }
TPRBParserTest >> testParseFaultyPragma [
	| node |
	node := self parseFaultyMethod: 'a <b:'.
	self assert: node isMethod.
	self assert: node pragmas size equals: 1.
	self assert: node pragmas first isFaulty
]

{ #category : #'tests parsing' }
TPRBParserTest >> testParseGivesMethod [
	"The parsing of an expression or a method gives a method node.
	 For an expression we expect the selector to be #noMethod.
	 For a method we expect the selector to be the first identifier.
	 In the method node, we expect the original string (source) to be stored."
	| tree |
	"When there are multiple statements, the node returned is the Sequence node (child of the method node)."
	tree := (self parserClass parseExpression: 'foo koong. ^foo').
	self assert: tree parent isMethod.
	
	"When there is a single statement, the node returned is the overarching node of the statement (child of the sequence node)."
	tree := (self parserClass parseExpression: 'foo koong foo').
	self assert: tree parent parent isMethod.
	
	"parseMethod always return a method node."
	tree := (self parserClass parseMethod: 'foo koong. ^foo').
	self assert: tree isMethod.
	
	tree := (self parserClass parseMethod: 'foo koong foo').
	self assert: tree isMethod.
]

{ #category : #testPattern }
TPRBParserTest >> testParseMethodPatternGivesSelector [
	#(#('+ a ^self + a' 				#+) 
	  #('foo ^self foo' 				#foo)
	  #('foo: a b ^self foo: b'    #foo:) 
	  #('foo: a bar: b ^a + b' 		#foo:bar:))
		do: [ :each | self assert: (self parserClass parseMethodPattern: each first) identicalTo: each last ]
]

{ #category : #testCreationProtocol }
TPRBParserTest >> testParseMethodWhichEndsWithUncompleteStringWithEscapedMarkAtTheEnd [
	| node strangeMethod body statement message errorNode |
	strangeMethod := '
	selector  
		|temp| 
		temp := ''this is right'', ''wrong'''''.
	node := self parseFaultyMethod: strangeMethod.

	self assert: node isMethod.
	self assert: node isFaulty.
	self assertEmpty: node arguments.

	body := node body.
	self assert: body isSequence.
	self assert: body isFaulty.
	self assert: (body temporaries includes: (TPRBVariableNode named: 'temp')).

	statement := body statements first.
	self assert: statement isFaulty.
	self assert: statement isAssignment.

	message := statement value.
	self assert: message isFaulty.
	self assert: message arguments size equals: 1.

	errorNode := message arguments at: 1.
	self assert: errorNode isFaulty.
	self
		assert: errorNode value
		equals: 'wrong'''.
	self assert: errorNode errorMessage equals: 'Unmatched '' in string literal.' translated
]

{ #category : #testCreationProtocol }
TPRBParserTest >> testParseMethodWithErrorTokenIsWellFormed [
	| node strangeMethod body statement message errorNode |
	strangeMethod := '
	selector  
		|temp| 
		temp := ''this is right'', ''wrong because no end.
		^temp'.
	node := self parseFaultyMethod: strangeMethod.

	self assert: node isMethod.
	self assert: node isFaulty.
	self assertEmpty: node arguments.

	body := node body.
	self assert: body isSequence.
	self assert: body isFaulty.
	self assert: (body temporaries includes: (TPRBVariableNode named: 'temp')).

	statement := body statements first.
	self assert: statement isFaulty.
	self assert: statement isAssignment.

	message := statement value.
	self assert: message isFaulty.
	self assert: message arguments size equals: 1.

	errorNode := message arguments at: 1.
	self assert: errorNode isFaulty.
	self
		assert: errorNode value
		equals:
			'wrong because no end.
		^temp'.
	self assert: errorNode errorMessage equals: 'Unmatched '' in string literal.' translated
]

{ #category : #'tests parsing' }
TPRBParserTest >> testParseRegistersTheSourceInMethodNode [
	"The parsing of an expression or a method gives a method node.
	 For an expression we expect the selector to be #noMethod.
	 For a method we expect the selector to be the first identifier.
	 In the method node, we expect the original string (source) to be stored."
	| tree |
	"When there are multiple statements, the node returned is the Sequence node (child of the method node)."
	tree := (self parserClass parseExpression: 'foo koong. ^foo').
	self assert: tree parent source equals: 'foo koong. ^foo'.
	
	"When there is a single statement, the node returned is the overarching node of the statement (child of the sequence node)."
	tree := (self parserClass parseExpression: 'foo koong foo').
	self assert: tree parent parent source equals: 'foo koong foo'.
	
	"parseMethod always return a method node."
	tree := (self parserClass parseMethod: 'foo koong. ^foo').
	self assert: tree source equals: 'foo koong. ^foo'.
	
	tree := (self parserClass parseMethod: 'foo koong foo').
	self assert: tree source equals: 'foo koong foo'.
]

{ #category : #'tests parsing faulty' }
TPRBParserTest >> testParseUnfinishedBlockWithFaultyBody [
	| node unfinishedBlockExp missingArgExp unfinishedBlockAndMissingArgExp validBlock unfinishedBlockWithReturnExp|
	"Parsing a block as a faulty expression, where the block body is faulty and there is a missing closing bracket,
the whole expression is replaced by a single RBParseErrorNode, this makes it difficult for the highlighter to 
indicate the invalid expression."
	unfinishedBlockExp := '[:x | x missingArg: 3. '.
	missingArgExp := '[:x | x missingArg: . ]'.
	unfinishedBlockAndMissingArgExp := '[:x | x missingArg: . '.
	unfinishedBlockWithReturnExp := '[^ '.
	validBlock := '[:x | x missingArg: 3 ]. '.
	
	{unfinishedBlockExp. missingArgExp. unfinishedBlockAndMissingArgExp. unfinishedBlockWithReturnExp}
		do: [ :faultyExpression | 
			node := self parseFaultyExpression: faultyExpression.
			self assert: node isBlock.
			self assert: node isFaulty.
			self assert: node body isFaulty ].
		
	node := self parseFaultyExpression: validBlock.
	self assert: node isBlock.
	self deny: node isFaulty.
	self deny: node body isFaulty
]

{ #category : #'to be reworked' }
TPRBParserTest >> testParserErrors [
	#(#('self foo. + 3' 11) #('#(' 3) #('self 0' 6) #('self asdf;;asfd' 11)) 
		do: [:each | self parseError: each]
]

{ #category : #'to be reworked' }
TPRBParserTest >> testParserErrorsWithErrorBlock [
	"Parse source with errors and ensure we identify them"
	
	#(#('self foo. + 3' 2) #('#(' 1) #('self 0' 1) #('self asdf;;asfd' 2)) 
		do: [:each | |ast errorCount|
			   [ ast := self parseError: each first onError: 
					[:msg :pos :parser | parser step. parser parseErrorNode: msg]] 
						on: ReparseAfterSourceEditing do: [].
						
				errorCount := 0.
				TPRBParseErrorNodeVisitor visit: ast do: [ :n | errorCount := errorCount + 1 ].
				self assert: errorCount equals: each last ]
]

{ #category : #testArray }
TPRBParserTest >> testParsingArrayGivesArrayNode [
	| tree |
	#('{}' '{foo}' '{foo. bar.}')
	 do: [ :each |
		tree := self parserClass parseExpression: each .
		self assert: tree isDynamicArray.]
]

{ #category : #testPragma }
TPRBParserTest >> testParsingPragmaRecogniseAndStorePragmas [
	"Tests that the pragmas are correctly interpreted.
	 1. The string to be parsed.
	 2. The selector in parsed pragma.
	 3. The selector arguments."
	| tree |
	#('foo <foo>' 				
	'foo <foo: 1>' 			
	'foo <foo: 1.2>' 		
	'foo <foo: -3>' 	
	'foo <foo: #a>' 	
	'foo <foo: #< >' 
	'foo <foo: #> >' 
	'foo <foo: $a>'
	'foo <foo: ''bar''>'
	'foo <foo: true>' 	
	'foo <foo: false>' 
	'foo <foo: nil>' 	
	'foo <foo: #(1 2)>' 
	'foo <foo: 1 bar: 2>' 
	'foo |t| <foo: 1.2>'
	'foo |t| <foo: 1 bar: 2>' ) do: [ :each |
		tree := self parserClass parseMethod: each.
		self assert: tree pragmas size equals: 1.].
	
	self assert: (self parserClass parseMethod: 'foo |t| <pragma1> <pragma2>') pragmas size equals: 2.
]

{ #category : #testPragma }
TPRBParserTest >> testParsingPragmaRecogniseArguments [
	"Tests that the pragmas are correctly interpreted.
	 1. The string to be parsed.
	 2. The selector in parsed pragma.
	 3. The selector arguments."
	| tree node |
	#(('foo <foo>' 				#foo ()) 
	('foo <foo: 1>' 				#foo: (1)) 
	('foo <foo: 1.2>' 			#foo: (1.2)) 
	('foo <foo: -3>' 			#foo: (-3)) 
	('foo <foo: #a>' 			#foo: (a)) 
	('foo <foo: #< >' 			#foo: (<)) 
	('foo <foo: #> >' 			#foo: (>)) 
	('foo <foo: $a>' 			#foo: ($a)) 
	('foo <foo: ''bar''>' 		#foo: ('bar')) 
	('foo <foo: true>' 			#foo: (true)) 
	('foo <foo: false>' 			#foo: (false)) 
	('foo <foo: nil>' 			#foo: (nil)) 
	('foo <foo: #(1 2)>' 		#foo: ((1 2)))
	('foo <foo: 1 bar: 2>' 		#foo:bar: (1 2))
	('foo |t| <foo: 1.2>' 		#foo: (1.2))
	('foo |t| <foo: 1 bar: 2>' #foo:bar: (1 2))
	) do: [ :each |
		tree := self parserClass parseMethod: each first.
		self assert: tree pragmas size equals: 1.
		node := tree pragmas first.
		1 to: node arguments size do: [ :i |
			self assert: (node arguments at: i) value equals: (each last at: i) ].]
]

{ #category : #testPragma }
TPRBParserTest >> testParsingPragmaRecogniseSelector [
	"Tests that the pragmas are correctly interpreted.
	 1. The string to be parsed.
	 2. The selector in parsed pragma.
	 3. The selector arguments."
	| tree node |
	#(('foo <foo>' 				#foo ()) 
	('foo <foo: 1>' 				#foo: (1)) 
	('foo <foo: 1.2>' 			#foo: (1.2)) 
	('foo <foo: -3>' 			#foo: (-3)) 
	('foo <foo: #a>' 			#foo: (a)) 
	('foo <foo: #< >' 			#foo: (<)) 
	('foo <foo: #> >' 			#foo: (>)) 
	('foo <foo: $a>' 			#foo: ($a)) 
	('foo <foo: ''bar''>' 		#foo: ('bar')) 
	('foo <foo: true>' 			#foo: (true)) 
	('foo <foo: false>' 			#foo: (false)) 
	('foo <foo: nil>' 			#foo: (nil)) 
	('foo <foo: #(1 2)>' 		#foo: ((1 2)))
	('foo <foo: 1 bar: 2>' 		#foo:bar: (1 2))
	('foo |t| <foo: 1.2>' 		#foo: (1.2))
	('foo |t| <foo: 1 bar: 2>' #foo:bar: (1 2))
	) do: [ :each |
		tree := self parserClass parseMethod: each first.
		node := tree pragmas first.
		self assert: node selector equals: each second.]
]

{ #category : #'to be reworked' }
TPRBParserTest >> testPositions [
	| blockNode |
	blockNode := self parserClass parseExpression: '[:a :b | ]'.
	self assert: blockNode left equals: 1.
	self assert: blockNode right equals: 10.
	self assert: blockNode bar equals: 8.
	self assert: blockNode sourceInterval equals: (1 to: 10).
	self assert: blockNode size equals: 1.	"test dummy collection protocol"
	blockNode printString.	"coverage"
	self deny: (blockNode isLast: (TPRBVariableNode named: 'b')).
]

{ #category : #'error testing' }
TPRBParserTest >> testPragmaConstantLiteralArgument [
	| primitiveDeclartion validPragma invalidPragma |
	"primitive declarations with variable (code) are allowed"
	primitiveDeclartion := 'foo <primitive: #dooo module: #bar error: code> ^ nil'.
	"#Point as argument is allowed"
	validPragma := 'foo <return: #Point> ^ 0@0'.
	"Point as argument is not allowed"
	invalidPragma := 'foo <return: Point> ^ 0@0'.
	self shouldnt:[self parserClass parseMethod: primitiveDeclartion] raise: SyntaxErrorNotification.
	self shouldnt:[self parserClass 	parseMethod: validPragma] raise: SyntaxErrorNotification.
	self should:[self parserClass parseMethod: invalidPragma] raise: SyntaxErrorNotification.
	

]

{ #category : #'error testing' }
TPRBParserTest >> testPragmaImplicitLiteralArrayIsInvalid [
	| pragmaWithExpressionAsArgument pragmaWithLiteralArrayAsArgument pragmaWithStringAsArgument |
	"a pragma with arguments that look like code
	(3+4) were implicitly converted to a literal array
	#(3+4), this is not allowed anymore"
	pragmaWithExpressionAsArgument := 'foo 
	<func: (3+4) res: 7>
	^ self'.
	self should:[self parserClass parseMethod: pragmaWithExpressionAsArgument] raise: SyntaxErrorNotification.

	"an explicit literal array is allowed"
	pragmaWithLiteralArrayAsArgument := 'foo 
	<func: #(3+4) res: 7>
	^ self'.
	"Should work"
	self shouldnt: [self parserClass parseMethod: pragmaWithLiteralArrayAsArgument] raise: SyntaxErrorNotification.

	"and of course a string literal"
	pragmaWithStringAsArgument := 'foo 
	<func: ''(3+4)'' res: 7>
	^ self'.
	"should work"
	self shouldnt: [self parserClass parseMethod: pragmaWithStringAsArgument] raise: SyntaxErrorNotification.

]

{ #category : #'error testing' }
TPRBParserTest >> testPragmaInExpressionRaiseError [
	"Test if a working pragma in a method is faulty in an expression."
	self should: [(self parserClass parseExpression: '| token | <some: #tag> true')] 
		  raise: SyntaxErrorNotification.
		
	self shouldnt: [(self parserClass parseExpression: '| token | true')] 
		  raise: SyntaxErrorNotification.
]

{ #category : #'error testing' }
TPRBParserTest >> testPragmaPrimitiveError [
	| tree  pragma |
	tree := self parserClass 
				parseMethod: 'veryBasicAt: index 
	<primitive: #dooo module: #bar error: code>
	^ code'.
	
	self assert: tree pragmas size equals: 1.
	
	pragma := tree pragmas first.
	self assert: pragma selector equals: #primitive:module:error:
]

{ #category : #'to be reworked' }
TPRBParserTest >> testQuerying [
	| tree aNode arg1Node bNode |
	tree := self parserClass
		parseMethod:
			('test: a`	| b |`	b := (self foo: a; bar) baz.`	b := super test: b.`	^[:arg1 | self foa1 + (super foo: arg1 foo: a foo: b)]'
				copyReplaceAll: '`'
				with: (String with: (Character value: 13))).
	self assert: tree selfMessages asSortedCollection asArray equals: #(#bar #foa1 #foo:).
	self assert: tree superMessages asSortedCollection asArray equals: #(#foo:foo:foo: #test:).
	aNode := tree whichNodeIsContainedBy: (112 to: 112).
	self assert: aNode name equals: 'a'.
	bNode := tree whichNodeIsContainedBy: (119 to: 119).
	self assert: bNode name equals: 'b'.
	arg1Node := tree whichNodeIsContainedBy: (102 to: 105).
	self assert: arg1Node name equals: 'arg1'.
	self assert: (arg1Node statementNode isMessage and: [ arg1Node statementNode selector = #+ ]).
	self assert: (arg1Node whoDefines: 'arg1') isBlock.
	self assert: (aNode whoDefines: 'a') isMethod.
	self assert: (aNode whoDefines: 'b') isSequence.
	self assert: (tree whichNodeIsContainedBy: (91 to: 119)) selector equals: #foo:foo:foo:.
	self assert: (tree whichNodeIsContainedBy: (69 to: 121)) isBlock.
	self assert: (tree whichNodeIsContainedBy: (69 to: 118)) isNil.
	self assert: aNode blockVariables asSortedCollection asArray equals: #('arg1').
	self assert: aNode temporaryVariables asSortedCollection asArray equals: #('b').
	self assert: tree allDefinedVariables asSortedCollection asArray equals: #('a' 'arg1' 'b').
	self assert: tree allArgumentVariables asSortedCollection asArray equals: #('a' 'arg1').
	self assert: tree allTemporaryVariables asSortedCollection asArray equals: #('b')
]

{ #category : #'to be reworked' }
TPRBParserTest >> testQueryingPrimitiveErrorVar [
	| tree |
	tree := self parserClass 
				parseMethod: 'clone
	"Answer a shallow copy of the receiver."
	<primitive: 148 error: ec>
	| copy |
	ec == #''insufficient object memory'' ifFalse:
		[|nothing| nothing := nil.
		^ noting].
   copy := nil.
	^ copy'.
	self assert: (tree body whoDefines:'copy') equals: tree body.
	self assert: (tree blockNodes first body whoDefines: 'nothing') equals: tree blockNodes first body.
	self assert: (tree body whoDefines: 'ec') equals: tree.

]

{ #category : #testCascade }
TPRBParserTest >> testSemiColonAfterMessageIsCascade [
	self assert: (self parserClass parseExpression: ' self msg; yourself') isCascade.
	self assert: (self parserClass parseExpression: ' self msg:(arg msg:arg); yourself') isCascade.
	self assert: (self parserClass parseExpression: ' self msg: arg msga:arga ; ibm ; yourself') isCascade.
]

{ #category : #testIntervals }
TPRBParserTest >> testSequenceNodeEndAtTheEndOfTheString [
	| tree |

	tree := (self parserClass parseExpression: 'foo kung foo. 1+2+3. #''alabama''.').
	self assert: tree source equals: 'foo kung foo. 1+2+3. #''alabama''.'.
	self assert: tree stop equals: tree parent source size.
	
	tree := (self parserClass parseMethod: 'foo kung foo. 1+2+3. #''alabama''.').
	self assert: tree source equals: 'foo kung foo. 1+2+3. #''alabama''.'.
	self assert: tree body stop equals: tree source size.
	
]

{ #category : #testIntervals }
TPRBParserTest >> testSequenceNodeStartAtFirstTokenAfterTheSelector [
	"Beginning spaces are trimmed before the start of sequence node."
	| tree |
	"Here, the selector is the implicit #noMethod"
	tree := (self parserClass parseExpression: 'foo koong. ^foo').
	self assert: tree start equals: 1.
	
	"There are 2 spaces before foo."
	tree := (self parserClass parseExpression: '  foo koong. ^foo').
	self assert: tree start equals: 3.
	
	"Here, foo is the method selector so the sequence start at koong."
	tree := (self parserClass parseMethod: 'foo koong. ^foo').
	self assert: tree body start equals: 5.
	
	"There are 2 spaces before foo."
	tree := (self parserClass parseMethod: '  foo koong. ^foo').
	self assert: tree body start equals: 7.
	
	
]

{ #category : #'foreign use of test' }
TPRBParserTest >> testString [
	self assert: (self parserClass parseMethod: 'selector ^ ''<''') isMethod.
	self assert: (self parserClass parseMethod: 'selector ^ ''<'', self') isMethod.
	self assert: (self parserClass parseMethod: 'selector ''=''') isMethod.
	self assert: (self parserClass parseMethod: 'selector '':=''') isMethod.
	self assert: (self parserClass parseMethod: 'selector ''<''') isMethod.
	self assert: (self parserClass parseMethod: 'selector ''>''') isMethod.
	self assert: (self parserClass parseMethod: 'selector ^ ''<>''') isMethod.
]

{ #category : #testLiteral }
TPRBParserTest >> testSymbolLiteralSuccessfullyCreateLiteralNode [
	"Test if the parsing of the strings gives a literal node corresponding to its' pair."
	| tree |
	#(
	'#<' #<
	'#>' #>
	'#<>' #<>
	'##foo' #foo 
	'###foo' #foo 
	'#foo:' #foo:
	'#foo::' #'foo::'
	'#foo::bar' #'foo::bar'
	'#foo::bar:' #'foo::bar:'
	'#foo::bar::' #'foo::bar::') pairsDo: [ :parseString :expectedResult |
		tree := self parserClass parseExpression: parseString.
		self assert: tree isLiteralNode.
		self assert: tree value equals: expectedResult.		
		self assert: tree start equals: 1.
		self assert: tree stop equals: parseString size ].
]

{ #category : #private }
TPRBParserTest >> treeWithEverything [
	^ self parserClass
		parseMethod:
			'method: arg1 | temps | temps := #(10). temps foo; foo. ^(temps collect: [:e | ])'
]

{ #category : #private }
TPRBParserTest >> treeWithReallyEverything [
	^ self parserClass
		parseMethod:
			'method: arg1 <foo> <foo: 1.2> | temps | temps := #[ 1 2 3 ]. temps := #(true false nil 1 1.2 $a foo #foo ''foo'' #() #(1 2) #[] #[1 2]). { 1 negated. 1 + 2. 1 raisedTo: 2 }. temps foo; foo: self. ^ (temps collect: [:e | | btemps | ((e isNil)) ])'
]
