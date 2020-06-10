Class {
	#name : #TPErrorNodeStyler,
	#superclass : #TPIconStyler,
	#category : #TemporaryParser
}

{ #category : #styling }
TPErrorNodeStyler >> addIconStyle: aNode from: start to: stop color: aColor [
	|conf|
	(self shouldStyleNode: aNode) ifFalse: [ ^self ].
	conf := RubConfigurationChange new.
	conf configurationBlock: [ :text| |r| 
		r := RubUnderlinedSegmentMorph from: aNode start to: aNode stop + 1.
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
TPErrorNodeStyler >> borderColor [ 
	^Color red
]

{ #category : #defaults }
TPErrorNodeStyler >> highlightColor [
	^nil
]

{ #category : #defaults }
TPErrorNodeStyler >> iconFor: aNode [
	^ self iconNamed: #error
]

{ #category : #defaults }
TPErrorNodeStyler >> iconLabel: aNode [
	^ aNode errorMessage, ' instead of : ', aNode value.
]

{ #category : #visiting }
TPErrorNodeStyler >> shouldStyleNode: aNode [
	^ aNode isParseError
]
