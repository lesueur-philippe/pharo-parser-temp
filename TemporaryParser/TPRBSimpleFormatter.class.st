"
I'm a simple formatter that prints nodes (without using source code).
I'm useful when AST are programmatically assembled. 

I could be improved, but the goal is to get the information is a more or less ok form.

"
Class {
	#name : #TPRBSimpleFormatter,
	#superclass : #TPRBProgramNodeVisitor,
	#instVars : [
		'codeStream',
		'indent',
		'lineStart'
	],
	#classVars : [
		'FormatAsYouReadPolicy'
	],
	#category : #'TemporaryParser-Formatter'
}

{ #category : #public }
TPRBSimpleFormatter class >> format: aParseTree [ 
	^self format: aParseTree withIndents: 0
]

{ #category : #public }
TPRBSimpleFormatter class >> format: aParseTree withIndents: anInteger [ 
	^ self new
		indent: anInteger;
		format: aParseTree
]

{ #category : #accessing }
TPRBSimpleFormatter class >> formatAsYouReadPolicy [
	^ FormatAsYouReadPolicy
]

{ #category : #accessing }
TPRBSimpleFormatter class >> formatAsYouReadPolicy: anObject [
	FormatAsYouReadPolicy := anObject
]

{ #category : #'class initialization' }
TPRBSimpleFormatter class >> initialize [
  "self initialize"
  FormatAsYouReadPolicy := false.
 
]

{ #category : #private }
TPRBSimpleFormatter >> addSpaceIfNeededForLastArgument: aPragmaNode [
	aPragmaNode isUnary
		ifTrue: [ ^ self ].
	(self pragmaArgumentNeedsSeparator: aPragmaNode arguments last)
		ifTrue: [ self space ]
]

{ #category : #private }
TPRBSimpleFormatter >> basicFormatCommentFor: aComment [
	codeStream
		nextPut: $";
		nextPutAll: aComment contents;
		nextPut: $"
]

{ #category : #private }
TPRBSimpleFormatter >> bracketWith: bracketString around: aBlock [
	bracketString isEmpty
		ifTrue: [ ^ aBlock value ].
	codeStream nextPut: bracketString first.
	^ aBlock
		ensure: [ codeStream nextPut: bracketString last ] 
]

{ #category : #accessing }
TPRBSimpleFormatter >> codeStream [
	^ codeStream
]

{ #category : #accessing }
TPRBSimpleFormatter >> codeStream: anObject [
	codeStream := anObject
]

{ #category : #'public interface' }
TPRBSimpleFormatter >> format: aParseTree [
	self visitNode: aParseTree.
	^ codeStream contents
]

{ #category : #'private-formatting' }
TPRBSimpleFormatter >> formatArray: anArrayNode [
	anArrayNode statements
		do: [ :each | 
				self visitNode: each ]
		separatedBy: 
				[ codeStream nextPutAll: ' . '.
				self newLine ]
]

{ #category : #'private-formatting' }
TPRBSimpleFormatter >> formatBlock: aBlockNode [
	self 
		formatBlockArgumentsFor: aBlockNode;
		space;
		visitNode: aBlockNode body;
		space


]

{ #category : #'private-formatting' }
TPRBSimpleFormatter >> formatBlockArgumentsFor: aBlockNode [
	aBlockNode arguments isEmpty
		ifTrue: [ ^ self ].
	aBlockNode arguments
		do: [ :each | 
			   codeStream nextPut: $:.
			   self 
					visitNode: each;
			   		formatCommentsFor: each;
					space ].
	codeStream nextPutAll: '| '
]

{ #category : #'private-formatting' }
TPRBSimpleFormatter >> formatCommentsFor: aNode [

	aNode comments do: [ :each | 
			self
				basicFormatCommentFor: each;
				newLine
			]
]

{ #category : #'private-formatting' }
TPRBSimpleFormatter >> formatMethodBodyFor: aMethodNode [
	self
		indentAround: [ 
			self
				newLine;
				formatMethodCommentFor: aMethodNode;
				formatPragmasFor: aMethodNode;
				visitNode: aMethodNode body ]
]

{ #category : #'private-formatting' }
TPRBSimpleFormatter >> formatMethodCommentFor: aNode [

	aNode comments do: [ :each | 
			self
				basicFormatCommentFor: each;
				newLine
			]
]

{ #category : #'private-formatting' }
TPRBSimpleFormatter >> formatMethodPatternFor: aMethodNode [
	aMethodNode arguments isEmpty
		ifTrue: [ codeStream nextPutAll: aMethodNode selector ]
		ifFalse: [ self privateFormatMethodPatternMonoLineFor: aMethodNode ]
]

{ #category : #'private-formatting' }
TPRBSimpleFormatter >> formatPragmasFor: aMethodNode [
	aMethodNode pragmas do: [:each | self visitNode: each; newLine ]
]

{ #category : #'private-formatting' }
TPRBSimpleFormatter >> formatSelectorAndArguments: aMessageNode [
	
	self
		indent: 2
		around: [ 
			self
				formatSelectorAndArguments: aMessageNode
				firstSeparator: [ self space ]
				restSeparator: [ self space ] ]
]

{ #category : #'private-formatting' }
TPRBSimpleFormatter >> formatSelectorAndArguments: aMessageNode firstSeparator: firstBlock restSeparator: restBlock [
	aMessageNode isUnary
		ifTrue: [ 
			self space.
			self visitSelectorNode: aMessageNode selector]
		ifFalse: [ 
			aMessageNode selectorParts
				with: aMessageNode arguments
				do: [ :selector :argument | 
					self space.
					self
						indentAround: [ 
							codeStream nextPutAll: selector.
							self handleLineForArgument: argument ] ] ]
]

{ #category : #'private-formatting' }
TPRBSimpleFormatter >> formatSequenceNodeStatementsFor: aSequenceNode [
	| statements |
	statements := aSequenceNode statements.
	statements isEmpty
		ifTrue: [ ^ self ].
 
	statements doWithIndex: [ :el :i | 
		self visitNode: (statements at: i).
		i < statements size
			ifTrue: [ codeStream nextPut: $.. 
						self newLine].
		self formatStatementCommentsFor: el.
		i < statements size
			ifTrue: [  ] ]
]

{ #category : #'private-formatting' }
TPRBSimpleFormatter >> formatStatementCommentsFor: aStatementNode [

	aStatementNode statementComments do: [ :each | 
			self
				newLine;
				basicFormatCommentFor: each
			]
]

{ #category : #private }
TPRBSimpleFormatter >> formatTemporariesFor: aSequenceNode [
	aSequenceNode temporaries isEmpty
		ifTrue: [ ^ self ].
	self
		bracketWith: '|'
		around: [ 
			self space.
			aSequenceNode temporaries
				do:
					[ :each | 
					self 
						visitNode: each;
						formatStatementCommentsFor: each;
						space ]].
	self newLine.
]

{ #category : #private }
TPRBSimpleFormatter >> handleLineForArgument: anArgument [

  self 
		space;
		visitNode: anArgument
]

{ #category : #accessing }
TPRBSimpleFormatter >> indent [
	^ indent
]

{ #category : #accessing }
TPRBSimpleFormatter >> indent: anInteger [

	indent := anInteger
]

{ #category : #private }
TPRBSimpleFormatter >> indent: anInteger around: aBlock [
	self indent: self indent + anInteger.
	^ aBlock
		ensure: [ self indent: self indent - anInteger ]
]

{ #category : #private }
TPRBSimpleFormatter >> indentAround: aBlock [ 
	self indent: 1 around: aBlock
]

{ #category : #accessing }
TPRBSimpleFormatter >> indentString [
	^ '  '
]

{ #category : #initialization }
TPRBSimpleFormatter >> initialize [
	super initialize.
	lineStart := 0.
	self indent: 0.
	codeStream := (String new: 256) writeStream
	
]

{ #category : #accessing }
TPRBSimpleFormatter >> lineStart [
	^ lineStart
]

{ #category : #accessing }
TPRBSimpleFormatter >> lineStart: anObject [
	lineStart := anObject
]

{ #category : #private }
TPRBSimpleFormatter >> needsParenthesisFor: aNode [
	| parent |
	aNode ifNil: [ ^ false ].
	aNode isValue
		ifFalse: [ ^ false ].
	aNode isParseError 
		ifTrue: [ ^false ].
	parent := aNode parent ifNil: [ ^ false ].
	aNode precedence < parent precedence
		ifTrue: [ ^ false ].
	(aNode isAssignment and: [ parent isAssignment ])
		ifTrue: [ ^ false ].
	(aNode isAssignment and: [ aNode isCascade ])
		ifTrue: [ ^ true ].
	aNode precedence = 0
		ifTrue: [ ^ false ].
	aNode isMessage
		ifFalse: [ ^ true ].
	aNode isUnary
		ifTrue: [ ^ false ].
	aNode isKeyword
		ifTrue: [ ^ true ].
	(parent isMessage and: [ parent receiver == aNode ])
		ifFalse: [ ^ true ].
	aNode precedence = parent precedence
		ifFalse: [ ^ true ].
	^ self precedenceOf: parent selector value greaterThan: aNode selector value
]

{ #category : #private }
TPRBSimpleFormatter >> newLine [
	self newLines: 1
]

{ #category : #private }
TPRBSimpleFormatter >> newLines: anInteger [
	anInteger + self indentString size = 0
		ifTrue: 
			[ codeStream space ].
	anInteger
		timesRepeat: 
			[ codeStream cr ].
	lineStart := codeStream position.
	self
		indent
		timesRepeat: 
			[ codeStream nextPutAll: self indentString ]
]

{ #category : #private }
TPRBSimpleFormatter >> pragmaArgumentNeedsSeparator: anArgumentNode [
	^ anArgumentNode value isSymbol and: [ anArgumentNode value isBinary ]
]

{ #category : #private }
TPRBSimpleFormatter >> precedenceOf: parentSelector greaterThan: childSelector [
  "Put parenthesis around things that are preceived to have 'lower' precedence. For example, 'a + b * c' 
	-> '(a + b) * c' but 'a * b + c' -> 'a * b + c'"
  | childIndex parentIndex |
  childIndex := 0.
  parentIndex := 0.
  1 to: self traditionalBinaryPrecedenceArray size do: [:i | ((self traditionalBinaryPrecedenceArray at: i) includes: parentSelector first) ifTrue: [ parentIndex := i ].
        ((self traditionalBinaryPrecedenceArray at: i) includes: childSelector first) ifTrue: [ childIndex := i ] ].
  ^childIndex < parentIndex
]

{ #category : #private }
TPRBSimpleFormatter >> privateFormatMethodPatternMonoLineFor: aMethodNode [
	self
		with: aMethodNode selectorParts
		and: aMethodNode arguments
		do: [:key :arg | 
			codeStream nextPutAll: key.
			self space.
			self visitNode: arg ]
		separatedBy: [ self space ]
]

{ #category : #private }
TPRBSimpleFormatter >> space [
	codeStream space
]

{ #category : #accessing }
TPRBSimpleFormatter >> traditionalBinaryPrecedenceArray [
	^  #(#($| $& $?) #($= $~ $< $>) #($- $+) #($* $/ $% $\) #($@))
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitArrayNode: anArrayNode [
	self bracketWith: '{}' around: [ self formatArray: anArrayNode ]
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitAssignmentNode: anAssignmentNode [ 
	self visitNode: anAssignmentNode variable.
	codeStream space; nextPutAll: anAssignmentNode assignmentOperator; space.
	self visitNode: anAssignmentNode value
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitBlockNode: aBlockNode [
	self
		bracketWith: '[]'
		around: [ self formatBlock: aBlockNode ]
	
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitCascadeNode: aCascadeNode [
	self visitNode: aCascadeNode receiver.
	self
		indentAround: [ self newLine.
			aCascadeNode messages
				do: [ :each | each isFaulty ifFalse: [ 
					self
						indentAround: [ self
								formatSelectorAndArguments: each
								firstSeparator: [  ]
								restSeparator: [ self space ] ] ]
					 ifTrue: [ self visitParseErrorNode: each ] ]
				separatedBy: [ codeStream nextPut: $;.
					self newLine ] ]
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitLiteralArrayNode: aRBArrayLiteralNode [
	| brackets |
	codeStream nextPut: $#.
	brackets := aRBArrayLiteralNode isForByteArray
		ifTrue: [ '[]' ]
		ifFalse: [ '()' ].
	self
		bracketWith: brackets
		around: [ aRBArrayLiteralNode contents
				do: [ :each | self visitNode: each ]
				separatedBy: [ self space ] ]
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitLiteralNode: aLiteralNode [
	self
		writeString:
			(aLiteralNode value isLiteral
				ifFalse: [ '''<an unprintable nonliteral value>''' ]
				ifTrue: [ aLiteralNode sourceText ])
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitMessageNode: aMessageNode [ 
	self 
		visitNode: aMessageNode receiver;
		formatSelectorAndArguments: aMessageNode
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitMethodNode: aMethodNode [ 
	self 
		formatMethodPatternFor: aMethodNode;
		formatMethodBodyFor: aMethodNode
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitNode: aNode [
	| needsParenthesis |
	needsParenthesis := self needsParenthesisFor: aNode.
	self
		bracketWith:
			(needsParenthesis
				ifTrue: [ '()' ]
				ifFalse: [ '' ])
		around: [ super visitNode: aNode ]
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitParseErrorNode: aNode [
		self writeString: aNode value
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitPatternBlockNode: aRBPatternBlockNode [ 
	codeStream nextPut: $`.
	self 
		bracketWith: '{}' 
		around: [ self formatBlock: aRBPatternBlockNode ]
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitPatternWrapperBlockNode: aRBPatternWrapperBlockNode [
	self visitNode: aRBPatternWrapperBlockNode wrappedNode.
	codeStream nextPut: $`.
	self 
		bracketWith: '{}' 
		around: [ self formatBlock: aRBPatternWrapperBlockNode ]
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitPragmaNode: aPragmaNode [
	codeStream nextPut: $<.
	self 
		formatSelectorAndArguments: aPragmaNode 
		firstSeparator: [ 
			aPragmaNode selector isInfix
				ifTrue: [ self space ] ]
		restSeparator: [ self space ].
	self addSpaceIfNeededForLastArgument: aPragmaNode.
	codeStream nextPut: $>
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitReturnNode: aReturnNode [ 
	codeStream nextPut: $^.
	self visitNode: aReturnNode value
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitSelectorNode: aSelectorNode [
		codeStream nextPutAll: aSelectorNode value
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitSequenceNode: aSequenceNode [

	self 
		formatTemporariesFor: aSequenceNode;
		formatCommentsFor: aSequenceNode;
		formatSequenceNodeStatementsFor: aSequenceNode
]

{ #category : #visiting }
TPRBSimpleFormatter >> visitVariableNode: aVariableNode [ 
	codeStream nextPutAll: aVariableNode name
]

{ #category : #utilities }
TPRBSimpleFormatter >> with: firstCollection and: secondCollection do: aBlock separatedBy: separatorBlock [
	firstCollection isEmpty
		ifTrue: [ ^ self ].
	aBlock value: firstCollection first value: secondCollection first.
	2 to: firstCollection size do: [ :i | 
		separatorBlock value.
		aBlock value: (firstCollection at: i) value: (secondCollection at: i) ]
]

{ #category : #private }
TPRBSimpleFormatter >> writeString: aString [
	| index |
	index := aString lastIndexOf: Character cr ifAbsent: [ 0 ].
	 codeStream nextPutAll: aString .
	index > 0
		ifTrue: [ lineStart := codeStream position - (aString size - index) ]
]
