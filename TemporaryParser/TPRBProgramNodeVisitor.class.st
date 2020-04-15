"
RBProgramNodeVisitor is an abstract visitor for the RBProgramNodes.


"
Class {
	#name : #TPRBProgramNodeVisitor,
	#superclass : #Object,
	#category : #'TemporaryParser-Visitors'
}

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitArgumentNode: anArgumentNode [
	"Sent *each time* an argument node is found"

	^ self visitVariableNode: anArgumentNode
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitArgumentNodes: aNodeCollection [
	"Sent *once* when visiting method and block nodes"

	^ aNodeCollection do: [ :each | self visitArgumentNode: each ]
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitArrayNode: anArrayNode [
	anArrayNode children do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitAssignmentNode: anAssignmentNode [
	self visitNode: anAssignmentNode variable.
	self visitNode: anAssignmentNode value
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitBlockNode: aBlockNode [
	self visitArgumentNodes: aBlockNode arguments.
	self visitNode: aBlockNode body
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitCascadeNode: aCascadeNode [
	aCascadeNode messages do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitGlobalNode: aSelfNode [
	^ self visitVariableNode: aSelfNode
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitInstanceVariableNode: aSelfNode [
	^ self visitVariableNode: aSelfNode
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitLiteralArrayNode: aRBLiteralArrayNode [
	aRBLiteralArrayNode contents do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitLiteralNode: aLiteralNode [
	
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitLiteralValueNode: aRBLiteralValueNode [
	"Redirect the message by default to #visitLiteralNode: for retrocompatibility (pharo 8)"

	^ self visitLiteralNode: aRBLiteralValueNode
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitMessageNode: aMessageNode [
	(aMessageNode isCascaded not or: [ aMessageNode isFirstCascaded ])
		ifTrue: [ self visitNode: aMessageNode receiver ].
	aMessageNode arguments do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitMethodNode: aMethodNode [
	self visitArgumentNodes: aMethodNode arguments.
	aMethodNode pragmas do: [ :each | self visitNode: each ].
	self visitNode: aMethodNode body
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitNode: aNode [
	^ aNode acceptVisitor: self
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitParseErrorNode: anErrorNode [
	
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitPatternBlockNode: aRBPatternBlockNode [
	self visitArgumentNodes: aRBPatternBlockNode arguments.
	self visitNode: aRBPatternBlockNode body
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitPatternWrapperBlockNode: aRBPatternWrapperBlockNode [
	self visitNode: aRBPatternWrapperBlockNode wrappedNode.
	self visitArgumentNodes: aRBPatternWrapperBlockNode arguments.
	self visitNode: aRBPatternWrapperBlockNode body
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitPragmaNode: aPragmaNode [
	aPragmaNode arguments do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitReturnNode: aReturnNode [
	^ self visitNode: aReturnNode value
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitSelfNode: aSelfNode [
	^ self visitVariableNode: aSelfNode
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitSequenceNode: aSequenceNode [
	self visitTemporaryNodes: aSequenceNode temporaries.
	aSequenceNode statements do: [ :each | self visitNode: each ]
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitSuperNode: aSuperNode [
	^ self visitVariableNode: aSuperNode
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitTemporaryDeclarationNode: aTemporaryDeclarationNode [
	"| temp |
	temp is a temporary node as we can find in the body of methods, but it can't be visited the same way.
	Redirect the message on argumentNodeVisitor as a way to keep retrocompatibility"

	^ self visitArgumentNode: aTemporaryDeclarationNode
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitTemporaryNode: aNode [
	"Sent *each time* a temporary node is found"

	^ self visitVariableNode: aNode
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitTemporaryNodes: aNodeCollection [
	"This is triggered when defining the temporaries between the pipes"

	^ aNodeCollection
		do: [ :each | self visitTemporaryDeclarationNode: each ]
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitThisContextNode: aThisContextNode [
	^ self visitVariableNode: aThisContextNode
]

{ #category : #visiting }
TPRBProgramNodeVisitor >> visitVariableNode: aVariableNode [
	^ aVariableNode
]
