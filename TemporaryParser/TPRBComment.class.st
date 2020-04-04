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
		'start'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBComment class >> with: aString at: startPosition [
	^ self new
		with: aString at: startPosition;
		yourself. 
	
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
	^ start + self size - 1
]

{ #category : #initialization }
TPRBComment >> with: aString at: startPosition [
	start := startPosition.
	contents := aString

]
