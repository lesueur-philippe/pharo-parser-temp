"
I am testing AST evaluation 
"
Class {
	#name : #TPASTEvaluationTest,
	#superclass : #TestCase,
	#category : #'TemporaryParser-Tests-Nodes'
}

{ #category : #tests }
TPASTEvaluationTest >> testEvaluate [
	self assert: (TPRBLiteralNode value: 5) evaluate equals: 5
]

{ #category : #tests }
TPASTEvaluationTest >> testEvaluateForContext [
	| varForTesting node |
	varForTesting := 4@5.

	"first we test if we can read the temp varForTesting"
	node := thisContext method variableNodes first.
	self assert: (node evaluateForContext: thisContext) equals: varForTesting.

	"lets check self, super"
	node := TPRBVariableNode named: 'self'.
	self assert: (node evaluateForContext: thisContext) equals: thisContext receiver.
	node := TPRBVariableNode named: 'super'.
	self assert: (node evaluateForContext: thisContext) equals: thisContext receiver.

	"thisContext is not the thisContext of this method though... it is the context of the evaluating doit"
	node := TPRBVariableNode named: 'thisContext'.
	self deny: (node evaluateForContext: thisContext) equals: thisContext.	

	"reading ivars works, too"
	node := TPRBVariableNode named: 'testSelector'.
	self assert: (node evaluateForContext: thisContext) equals: #testEvaluateForContext.
]

{ #category : #tests }
TPASTEvaluationTest >> testEvaluateForReceiver [
	| receiver node |
	receiver := 4@5.
	node := (receiver class>>#x) variableNodes first.
	self assert: (node evaluateForReceiver: receiver) equals: 4.
	node := TPRBVariableNode named: 'self'.
	self assert: (node evaluateForReceiver: receiver) equals: receiver.
	node := TPRBVariableNode named: 'super'.
	self assert: (node evaluateForReceiver: receiver) equals: receiver.
]
