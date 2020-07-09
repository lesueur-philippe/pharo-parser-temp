Class {
	#name : #TPRBArrayErrorNode,
	#superclass : #TPRBEnglobingErrorNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'as yet unclassified' }
TPRBArrayErrorNode class >> error: aToken withNodes: aCollection [
	| message |
	message := ('{' = aToken value asString) ifTrue: [ '''}'' expected' ] 
										  				 ifFalse: [ '''{'' expected' ].
	aCollection isEmpty
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aToken stop; errorMessage: message ].
	(message = '''}'' expected')
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aCollection last stop; errorMessage: message ]
		ifFalse: [ ^self new content: aCollection; start: aCollection first start; stop: aToken stop; errorMessage: message ]
]

{ #category : #testing }
TPRBArrayErrorNode >> isArrayError [
	^true
]

{ #category : #'as yet unclassified' }
TPRBArrayErrorNode >> repairCollection [
	^ (self errorMessage = '''}'' expected') ifTrue: [ self repairCollectionFromStart ]
													    ifFalse: [ self repairCollectionFromStop ]
]

{ #category : #'as yet unclassified' }
TPRBArrayErrorNode >> repairCollectionFromStart [
	" The repair process goes through goes through the statements that are compatible with an array.
	  Begins with all statements included in the array and gets one of every time.
	  The removed statements are to be added in the sequence node."
	| collection result removedStatements |
	collection := self content statements.
	result := OrderedCollection new.
	removedStatements := OrderedCollection new.
	[ collection isNotNil ] whileTrue: [ | statements node | statements := OrderedCollection new.
													node := TPRBArrayNode statements: collection.
													node start: self start.
													statements add: node .
													result add: statements, removedStatements.
													removedStatements addFirst: collection last.
												   collection removeLast. ].
	result add: removedStatements.
	^collection.
	
]

{ #category : #'as yet unclassified' }
TPRBArrayErrorNode >> repairCollectionFromStop [
	" The repair process goes through goes through the statements that are compatible with an array.
	  Begins with all statements included in the array and gets one of every time.
	  The removed statements are to be added in the sequence node."
	| collection result removedStatements |
	collection := self content statements.
	result := OrderedCollection new.
	removedStatements := OrderedCollection new.
	[ collection isNotNil ] whileTrue: [ | statements node | statements := OrderedCollection new.
													node := TPRBArrayNode statements: collection.
													node start: self start -1.
													statements add: ( node ).
													result add: removedStatements, statements.
													removedStatements add: collection first.
												   collection removeFirst. ].
	result add: removedStatements.
	^collection.
	
]

{ #category : #accessing }
TPRBArrayErrorNode >> value [
	^  self errorMessage = '''{'' expected' ifTrue: [ super value, '}' ] 
														ifFalse: [ '{ ', super value ] 
]
