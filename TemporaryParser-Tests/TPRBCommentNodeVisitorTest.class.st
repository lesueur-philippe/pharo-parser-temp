"
SUnit tests for RBCommentNodeVisitor
"
Class {
	#name : #TPRBCommentNodeVisitorTest,
	#superclass : #TPRBParseTreeTest,
	#category : #'TemporaryParser-Tests-Nodes'
}

{ #category : #tests }
TPRBCommentNodeVisitorTest >> testVisitDetect [
	| node tree |
	tree := self parseExpression: '
	"comment 1"
	"comment 2"
	"comment 3"
	^true'.
	
	node := TPRBCommentNodeVisitor visit: tree detect: [ :n | n intersectsInterval: (20 to: 20) ].
	
	self 
		assert: node contents equals: 'comment 2'
]

{ #category : #tests }
TPRBCommentNodeVisitorTest >> testVisitDo [
	| node tree count |
	tree := self parseExpression: '
	"comment 1"
	"comment 2"
	"comment 3"
	^true'.
	
	count := 0.
	node := TPRBCommentNodeVisitor visit: tree do: [ :n | count := count + 1 ].
	
	self 
		assert: count equals: 3
]

{ #category : #tests }
TPRBCommentNodeVisitorTest >> testVisitSelect [
	| node tree |
	tree := self parseExpression: '
	"comment 1"
	"comment 2"
	"comment 3"
	^true'.
	
	node := TPRBCommentNodeVisitor visit: tree select: [ :n | n contents endsWith: '2'].
	
	self 
		assert: node first contents equals: 'comment 2'
]
