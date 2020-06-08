"
An RBComment represents a text comment associated with an AST node.

An RBComment is not an AST-Node (not a subclass of program node). But its instances are just wrapping the comment text and (start-) position.

Due to the way the parser handles comments, the RBComment is assigned to its preceding (real) AST node, although we often write the comment prior to a statement.

For example:

foo
""method comment""

self firstStatement.

""comment about the return""
^ self

The ""method comment"" is assigned to the method node, the ""comment about the return"" is assigned
to the ""self firstStatement"" node!

instance variables
	contents 	<String> the comment text
	start	<Number> (start-) position within the method source

"
Class {
	#name : #TPRBComment,
	#superclass : #TPRBNode,
	#instVars : [
		'contents',
		'start',
		'stop'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBComment class >> with: aCommentToken [
	"To respect the previously implemented comment node content, 
	 we strip the surrounding quotes of the comment."
	| str cpystr |
	str := aCommentToken value.
	cpystr := str size > 2 
		ifTrue: [str copyFrom:2 to: str size - 1]
		ifFalse: [''].
	^ self new
		with: cpystr from: aCommentToken start to: aCommentToken stop;
		yourself. 
	
]

{ #category : #'instance creation' }
TPRBComment class >> with: aString at: startPosition [
	self deprecated: 'Should use method with: with a comment token as parameter.'.
	^ self new
		with: aString at: startPosition;
		yourself. 
	
]

{ #category : #comparing }
TPRBComment >> = anObject [
	(self == anObject) ifTrue: [ ^true ].
	^ (self class = anObject class) ifTrue: [ (self contents = anObject contents) and: [ self start = anObject start ] ] ifFalse: [ false ]
]

{ #category : #visiting }
TPRBComment >> acceptVisitor: aProgramNodeVisitor [
	"At some point we will have to think what we do to visit comment. 
	It may have an impact on visitors so this should be done carefully.
	Since by default previously comment node were not subclass of ProgramNode 
	we do nothing by default."

	
]

{ #category : #accessing }
TPRBComment >> contents [
	"The content of a comment node doesn't contain the quotes surrounding the comment.
	 However, the quotes inside of the comment remain nested."
	^ contents
]

{ #category : #testing }
TPRBComment >> intersectsInterval: anInterval [ 
	"Make comments polymorphic with program nodes for hit detection"
	
	^(anInterval first between: self start and: self stop) 
		or: [ self start between: anInterval first and: anInterval last ]
]

{ #category : #printing }
TPRBComment >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' "'.
	aStream nextPutAll: contents.
	aStream nextPutAll: '" '.
]

{ #category : #accessing }
TPRBComment >> size [
	^ contents size + 2 "must take into account quotation marks"
]

{ #category : #accessing }
TPRBComment >> start [
	^ start
]

{ #category : #accessing }
TPRBComment >> stop [
	^ stop
]

{ #category : #initialization }
TPRBComment >> with: aString at: startPosition [
	self deprecated: 'The use of a comment token implies a preexisting stop position. 
	                  Should use with: from: to:'. 
	start := startPosition.
	contents := aString.
	stop := startPosition + aString size - 1.

]

{ #category : #initialization }
TPRBComment >> with: aString from: aStartPosition to: aStopPosition [
	start := aStartPosition.
	stop := aStopPosition.
	contents := aString.

]
