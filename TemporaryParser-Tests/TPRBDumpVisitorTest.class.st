"
SUnit tests for the RBDumpVisitor visit, called by the #dump method on RBProgramNodes.
"
Class {
	#name : #TPRBDumpVisitorTest,
	#superclass : #TPRBParseTreeTest,
	#category : #'TemporaryParser-Tests-Visitors'
}

{ #category : #tests }
TPRBDumpVisitorTest >> testArrayNodeDump [
	| node dumpedNode |
	"Empty Array"
	node := self parseExpression: '{}'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBArrayNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
	"non-empty Array"
	node := self parseExpression: '{1 + 1. true. Object new}'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBArrayNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
	
]

{ #category : #tests }
TPRBDumpVisitorTest >> testAssignmentNodeDump [
	| node dumpedNode |
	node := self parseExpression: 'a := 3.'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBAssignmentNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
	
]

{ #category : #tests }
TPRBDumpVisitorTest >> testBlockNodeDump [
	| node dumpedNode |
	"Simple block"
	node := self parseExpression: '[self]'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBBlockNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
	"Block with argument"
	node := self parseExpression: '[:each | each]'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBBlockNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
	"Block with arguments and temps"
	node := self parseExpression: '[:each :i | |a b| a := each. b := i.]'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBBlockNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
]

{ #category : #tests }
TPRBDumpVisitorTest >> testCascadeNodeDump [
	| node dumpedNode |
	node := self parseExpression: 'self foo; bar'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBCascadeNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
]

{ #category : #tests }
TPRBDumpVisitorTest >> testErrorNodeDump [
	| node dumpedNode |
	node := self parseFaultyExpression: '( +'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBParseErrorNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
]

{ #category : #tests }
TPRBDumpVisitorTest >> testLiteralArrayNodeDump [
	| node dumpedNode |
	node := self parseExpression: '#(1 $a true ''a'')'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBLiteralArrayNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
]

{ #category : #tests }
TPRBDumpVisitorTest >> testLiteralValueNodeDump [
	| node dumpedNode |
	"Numeric are literals"
	node := self parseExpression: '1'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBLiteralValueNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
	"Symbol are literals"
	node := self parseExpression: '#foo'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBLiteralValueNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
	"Booleans are literals"
	node := self parseExpression: 'true'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBLiteralValueNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
	"char are literals"
	node := self parseExpression: '$a'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBLiteralValueNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
	"String are literals"
	node := self parseExpression: '''a'''.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBLiteralValueNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
]

{ #category : #tests }
TPRBDumpVisitorTest >> testMessageNodeDump [
	| node dumpedNode |
	"Simple selector"
	node := self parseExpression: 'self foo'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBMessageNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
	"With an argument"
	node := self parseExpression: 'self foo: 1'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBMessageNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
	"With many arguments"
	node := self parseExpression: 'self foo: 1 bar: 2'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBMessageNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
	"Binary message"
	node := self parseExpression: '1 + 2'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBMessageNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
]

{ #category : #tests }
TPRBDumpVisitorTest >> testMethodNodeDump [
	| node dumpedNode |
	node := self parseMethod: 'foo <useless>'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBMethodNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
	
	
]

{ #category : #tests }
TPRBDumpVisitorTest >> testPragmaNodeDump [
	| node dumpedNode |
	node := self parseMethod: 'foo <useless>'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode pragmas first class equals: TPRBPragmaNode. 
	self assert: node pragmas first class equals: dumpedNode pragmas first class.
	self assert: node printString equals: dumpedNode printString.
	
	
	
]

{ #category : #tests }
TPRBDumpVisitorTest >> testReturnNodeDump [
	| node dumpedNode |
	node := self parseExpression: '^ 1 + 1'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBReturnNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
	
	
]

{ #category : #tests }
TPRBDumpVisitorTest >> testSelfNodeDump [
	| node dumpedNode |
	node := self parseExpression: 'self'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBSelfNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
]

{ #category : #tests }
TPRBDumpVisitorTest >> testSequenceNodeDump [
	| node dumpedNode |
	node := self parseExpression: 'foo. bar.'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBSequenceNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
	
	
]

{ #category : #tests }
TPRBDumpVisitorTest >> testSuperNodeDump [
	| node dumpedNode |
	node := self parseExpression: 'super'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBSuperNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
]

{ #category : #tests }
TPRBDumpVisitorTest >> testThisContextNodeDump [
	| node dumpedNode |
	node := self parseExpression: 'thisContext'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBThisContextNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
]

{ #category : #tests }
TPRBDumpVisitorTest >> testVariableNodeDump [
	| node dumpedNode |
	node := self parseExpression: 'a'.
	dumpedNode := Smalltalk compiler evaluate: node dump.
	
	self assert: dumpedNode class equals: TPRBVariableNode. 
	self assert: node class equals: dumpedNode class.
	self assert: node printString equals: dumpedNode printString.
	
]

{ #category : #tests }
TPRBDumpVisitorTest >> uselessMethod [
	<useless>
	
]
