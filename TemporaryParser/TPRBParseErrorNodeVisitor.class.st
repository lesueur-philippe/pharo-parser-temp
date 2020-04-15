"
Visit any RBParseErrorNode in the syntax tree and evaluate a generic block
"
Class {
	#name : #TPRBParseErrorNodeVisitor,
	#superclass : #TPRBAbstractBlockVisitor,
	#category : #'TemporaryParser-Visitors'
}

{ #category : #accessing }
TPRBParseErrorNodeVisitor >> visitParseErrorNode: aNode [
	self visitBlock value: aNode
]
