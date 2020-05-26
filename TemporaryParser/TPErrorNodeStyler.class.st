Class {
	#name : #TPErrorNodeStyler,
	#superclass : #TPIconStyler,
	#category : #TemporaryParser
}

{ #category : #styling }
TPErrorNodeStyler >> addIconStyle: aNode from: start to: stop color: aColor [
	|conf|
	(self shouldStyleNode: aNode) ifFalse: [ ^self ].
	self haltOnce.
	conf := RubConfigurationChange new.
	conf configurationBlock: [ :text| |r| 
		r := RubUnderlinedSegmentMorph from: start to: stop + 1.
		text addSegment: r.
		
		r label: (self iconLabelBlock: aNode).
		r icon: (self iconFor: aNode).
		r iconBlock: (self iconBlock: aNode).
		r color: aColor.
		r borderColor: self borderColor.
	].

	textModel announce: conf.
]

{ #category : #defaults }
TPErrorNodeStyler >> iconFor: aNode [
	^ self iconNamed: #error
]

{ #category : #defaults }
TPErrorNodeStyler >> iconLabel: aNode [
	^ aNode errorMessage, ' for: ', aNode value.
]

{ #category : #visiting }
TPErrorNodeStyler >> shouldStyleNode: aNode [
self haltOnce.
	^aNode isParseError.
]
