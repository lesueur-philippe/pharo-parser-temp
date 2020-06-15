Class {
	#name : #TPRBBlockErrorNode,
	#superclass : #TPRBEnglobingErrorNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'as yet unclassified' }
TPRBBlockErrorNode class >> error: aToken withNodes: aCollection [
	aCollection isEmpty
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aToken stop ].
	('[' = aToken value asString)
		ifTrue: [ ^self new content: aCollection; start: aToken start; stop: aCollection last stop ; errorMessage: ''']'' expected']
		ifFalse: [ ^self new content: aCollection; start: aCollection first start; stop: aToken stop; errorMessage: '''['' expected' ]
]

{ #category : #testing }
TPRBBlockErrorNode >> isBlockError [
	^true
]

{ #category : #accessing }
TPRBBlockErrorNode >> value [
	^  self errorMessage = '''['' expected' ifTrue: [ super value, ']' ] 
														ifFalse: [ '[ ', super value ] 
]
