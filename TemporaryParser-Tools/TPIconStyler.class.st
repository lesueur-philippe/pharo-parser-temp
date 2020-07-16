Class {
	#name : #TPIconStyler,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'textModel'
	],
	#category : #'TemporaryParser-Tools'
}

{ #category : #options }
TPIconStyler class >> shouldStyle [
	^true
]

{ #category : #style }
TPIconStyler class >> style: textModel [
	^self new textModel: textModel.
]

{ #category : #api }
TPIconStyler class >> styleText: textModel withAst: ast [
	self allSubclassesDo: [ :styleClass | 
			styleClass shouldStyle
				ifTrue: [ ast acceptVisitor: (styleClass style: textModel) ] ]
]

{ #category : #styling }
TPIconStyler >> addIconMethodStyle: aMethodNode [
	self addIconStyle: aMethodNode from: 1 to: 0
]

{ #category : #styling }
TPIconStyler >> addIconStyle: aNode [
	self addIconStyle: aNode from: aNode start to: aNode stop.
]

{ #category : #styling }
TPIconStyler >> addIconStyle: aNode from: start to: stop [
	
	self addIconStyle: aNode from: start to: stop color: self highlightColor 
]

{ #category : #styling }
TPIconStyler >> addIconStyle: aNode from: start to: stop color: aColor [
	|conf|
	(self shouldStyleNode: aNode) ifFalse: [ ^self ].
	conf := RubConfigurationChange new.
	conf configurationBlock: [ :text| |r| 
		r := RubTextSegmentMorph from: start to: stop + 1.
		text addSegment: r.
		
		r label: (self iconLabelBlock: aNode).
		r icon: (self iconFor: aNode).
		r iconBlock: (self iconBlock: aNode).
		r color: aColor.
		r borderColor: self borderColor.
	].

	textModel announce: conf
]

{ #category : #defaults }
TPIconStyler >> borderColor [ 
	^Color gray
]

{ #category : #defaults }
TPIconStyler >> highlightColor [
	^(Color green alpha: 0.1)
]

{ #category : #defaults }
TPIconStyler >> iconBlock: aNode [
	^ [ ] 
]

{ #category : #defaults }
TPIconStyler >> iconFor: aNode [
	^nil
]

{ #category : #defaults }
TPIconStyler >> iconLabel: aNode [
	^ ''
]

{ #category : #defaults }
TPIconStyler >> iconLabelBlock: aNode [
	^ [self iconLabel: aNode]
]

{ #category : #testing }
TPIconStyler >> shouldStyleNode: aNode [
	^false 
]

{ #category : #accessing }
TPIconStyler >> textModel [
	^ textModel
]

{ #category : #accessing }
TPIconStyler >> textModel: anObject [
	textModel := anObject
]

{ #category : #visiting }
TPIconStyler >> visitArgumentNode: anArgumentNode [ 
	self addIconStyle: anArgumentNode.
	super visitArgumentNode: anArgumentNode.
]

{ #category : #visiting }
TPIconStyler >> visitArrayNode: anArrayNode [ 
	self addIconStyle: anArrayNode.
	super visitArrayNode: anArrayNode.
]

{ #category : #visiting }
TPIconStyler >> visitAssignmentNode: anAssignmentNode [ 
	self addIconStyle: anAssignmentNode.
	super visitAssignmentNode: anAssignmentNode.
]

{ #category : #visiting }
TPIconStyler >> visitBlockNode: aBlockNode [ 
	self addIconStyle: aBlockNode.
	super visitBlockNode: aBlockNode.
]

{ #category : #visiting }
TPIconStyler >> visitCascadeNode: aCascadeNode [ 
	self addIconStyle: aCascadeNode.
	super visitCascadeNode: aCascadeNode.
]

{ #category : #visiting }
TPIconStyler >> visitEnglobingErrorNode: anEnglobingNode [
	self addIconStyle: anEnglobingNode.
	anEnglobingNode content do: [ :each | self visitNode: each ].
]

{ #category : #visiting }
TPIconStyler >> visitGlobalNode: aSelfNode [ 
	self addIconStyle: aSelfNode.
	super visitGlobalNode: aSelfNode.
]

{ #category : #visiting }
TPIconStyler >> visitInstanceVariableNode: aSelfNode [ 
	self addIconStyle: aSelfNode.
	super visitInstanceVariableNode: aSelfNode.
]

{ #category : #visiting }
TPIconStyler >> visitLiteralArrayNode: aRBLiteralArrayNode [ 
	self addIconStyle: aRBLiteralArrayNode.
	super visitLiteralArrayNode: aRBLiteralArrayNode.
]

{ #category : #visiting }
TPIconStyler >> visitLiteralNode: aLiteralNode [ 
	self addIconStyle: aLiteralNode.
	super visitLiteralNode: aLiteralNode.
]

{ #category : #visiting }
TPIconStyler >> visitMessageNode: aMessageNode [ 
	self addIconStyle: aMessageNode.
	super visitMessageNode: aMessageNode.
]

{ #category : #visiting }
TPIconStyler >> visitMethodNode: aMethodNode [ 
	self addIconMethodStyle: aMethodNode.
	super visitMethodNode: aMethodNode.
]

{ #category : #visiting }
TPIconStyler >> visitParseErrorNode: anErrorNode [ 
	self addIconMethodStyle: anErrorNode.
	super visitParseErrorNode: anErrorNode.
]

{ #category : #visiting }
TPIconStyler >> visitPragmaNode: aPragmaNode [ 
	self addIconStyle: aPragmaNode.
	super visitPragmaNode: aPragmaNode.
]

{ #category : #visiting }
TPIconStyler >> visitReturnNode: aReturnNode [ 
	self addIconStyle: aReturnNode.
	super visitReturnNode: aReturnNode 
]

{ #category : #visiting }
TPIconStyler >> visitSelectorNode: aSelectorNode [
	self addIconStyle: aSelectorNode
]

{ #category : #visiting }
TPIconStyler >> visitSelfNode: aSelfNode [ 
	self addIconStyle: aSelfNode.
	super visitSelfNode: aSelfNode 
]

{ #category : #visiting }
TPIconStyler >> visitSequenceNode: aSequenceNode [ 
	self addIconStyle: aSequenceNode.
	super visitSequenceNode: aSequenceNode.
]

{ #category : #visiting }
TPIconStyler >> visitSuperNode: aSuperNode [ 
	self addIconStyle: aSuperNode.
	super visitSuperNode: aSuperNode.
]

{ #category : #visiting }
TPIconStyler >> visitTemporaryNode: aNode [ 
	self addIconStyle: aNode.
	super visitTemporaryNode: aNode.
]

{ #category : #visiting }
TPIconStyler >> visitThisContextNode: aThisContextNode [ 
	self addIconStyle: aThisContextNode.
	super visitThisContextNode: aThisContextNode.
]

{ #category : #visiting }
TPIconStyler >> visitVariableNode: aNode [ 
	self addIconStyle: aNode.
	super visitVariableNode: aNode.
]
