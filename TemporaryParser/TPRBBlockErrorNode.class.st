Class {
	#name : #TPRBBlockErrorNode,
	#superclass : #TPRBEnglobingErrorNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'as yet unclassified' }
TPRBBlockErrorNode class >> error: aToken withNodes: aCollection [
	| message |
	message := ('[' = aToken value asString) ifTrue: [ ''']'' expected' ] 
										  				 ifFalse: [ '''['' expected' ].
	aCollection isEmpty
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aToken stop; errorMessage: message ].
	(message = ''']'' expected')
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aCollection last stop; errorMessage: message ]
		ifFalse: [ ^self new content: aCollection; start: aCollection first start; stop: aToken stop; errorMessage: message ]
]

{ #category : #testing }
TPRBBlockErrorNode >> isBlockError [
	^true
]

{ #category : #'as yet unclassified' }
TPRBBlockErrorNode >> repairCollectionFromStart [
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

{ #category : #accessing }
TPRBBlockErrorNode >> value [
	^  self errorMessage = '''['' expected' ifTrue: [ super value, ']' ] 
														ifFalse: [ '[ ', super value ] 
]
