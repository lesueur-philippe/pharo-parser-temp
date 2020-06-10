Class {
	#name : #TPSemanticMessageIconStyler,
	#superclass : #TPIconStyler,
	#category : #TemporaryParser
}

{ #category : #styling }
TPSemanticMessageIconStyler >> addIconStyle: aNode from: start to: stop color: aColor [
	|conf|
	(self shouldStyleNode: aNode) ifFalse: [ ^self ].
	conf := RubConfigurationChange new.
	conf configurationBlock: [ :text| |r| 
		aNode selectorParts
		with: aNode keywordsPositions
		do: [ :keyword :position | 
		r := RubTextBackgroundColorSegmentMorph from: position to: position + keyword size.
		text addSegment: r].
		
		r label: (self iconLabelBlock: aNode).
		r icon: (self iconFor: aNode).
		r iconBlock: (self iconBlock: aNode).
		r color: aColor.
		r borderColor: self borderColor.
	].

	textModel announce: conf.
]

{ #category : #defaults }
TPSemanticMessageIconStyler >> borderColor [ 
	^Color red
]

{ #category : #defaults }
TPSemanticMessageIconStyler >> highlightColor [
	^(Color brown alpha: 0.2)
]

{ #category : #defaults }
TPSemanticMessageIconStyler >> iconFor: aNode [
	^ self iconNamed: #smallQuestion
]

{ #category : #defaults }
TPSemanticMessageIconStyler >> iconLabel: aNode [
	^ aNode selector value asString, ' is not a recognized method '.
]

{ #category : #testing }
TPSemanticMessageIconStyler >> shouldStyleNode: aNode [
	^aNode isMessage and: [ (Symbol findInternedSelector: aNode selector value asString) isNil ]
]
