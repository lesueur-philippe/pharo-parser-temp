"
Visit any RBProgrmNode in the syntax tree and evaluate a generic block
"
Class {
	#name : #TPRBGenericNodeVisitor,
	#superclass : #TPRBAbstractBlockVisitor,
	#category : #'TemporaryParser-Visitors'
}

{ #category : #accessing }
TPRBGenericNodeVisitor >> visitNode: aNode [
	super visitNode: aNode.
	self visitBlock value: aNode
]
