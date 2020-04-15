"
I am a specific variable node for method and block arguments.

Parsing a method or block code will just use RBVariableNodes for block/method arguments until we call doSemanticAnalysis on the method node.
"
Class {
	#name : #TPRBArgumentNode,
	#superclass : #TPRBVariableNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #visiting }
TPRBArgumentNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitArgumentNode: self
]

{ #category : #converting }
TPRBArgumentNode >> adaptToSemanticNode [
	" I can't provide more semantics "
]

{ #category : #testing }
TPRBArgumentNode >> isArgument [
	^ true
]

{ #category : #testing }
TPRBArgumentNode >> isBlockVar [
	"true if a variable node is defined by a block node"

	^ (self whoDefines: self name) isBlock
]
