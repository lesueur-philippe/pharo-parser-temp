"
I am a specialized variable node for temporary variables.

Parsing a method or block code will just use RBVariableNodes for block/method arguments until we call doSemanticAnalysis on the method node.
"
Class {
	#name : #TPRBTemporaryNode,
	#superclass : #TPRBVariableNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #visiting }
TPRBTemporaryNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitTemporaryNode: self
]

{ #category : #testing }
TPRBTemporaryNode >> isBlockVar [
	"true if a variable node is defined by a node whos parent is a block"

	^  (self whoDefines: self name) parent isBlock
]

{ #category : #testing }
TPRBTemporaryNode >> isTemp [
	^ true
]
