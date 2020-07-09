Class {
	#name : #TPRBASTRepairTest,
	#superclass : #TPRBParserTest,
	#category : #'TemporaryParser-Tests-Tools'
}

{ #category : #tests }
TPRBASTRepairTest >> testRepairListForParenthesisedExpression [
	| ast |
	ast := self parseFaultyExpression: 'message node)'.
	self assert: ast isParenthesisError.
	self assert: ast repairList first equals: (TPRBMessageNode receiver: (TPRBVariableNode named: 'massage' start: 1) selector: (TPRBSelectorNode value: 'node' start: 9)).
	
]

{ #category : #tests }
TPRBASTRepairTest >> testRepairListForParenthesisedExpressionFromClosure [
	| ast unparenthesisedNode parenthesisedNode |
	ast := self parseFaultyExpression: 'message node)'.
	unparenthesisedNode := (TPRBMessageNode receiver: (TPRBVariableNode named: 'message' start: 1) selector: (TPRBSelectorNode value: 'node' start: 9)).
	parenthesisedNode := (TPRBMessageNode receiver: (TPRBVariableNode named: 'message' start: 2) selector: (TPRBSelectorNode value: 'node' start: 10)) addParenthesis: (1 to: 14).
	
	self assert: ast isParenthesisError.
	self assert: ast repairList first equals: ( OrderedCollection with: unparenthesisedNode with: parenthesisedNode ) 
	
]
