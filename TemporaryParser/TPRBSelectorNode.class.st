Class {
	#name : #TPRBSelectorNode,
	#superclass : #TPRBValueNode,
	#instVars : [
		'value',
		'start'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #accessing }
TPRBSelectorNode class >> value: aString [
	^ self value: aString start: Array new
]

{ #category : #accessing }
TPRBSelectorNode class >> value: aString start: anIntegerArray [
	^ self new value: aString ;
	           start: anIntegerArray.
]

{ #category : #comparing }
TPRBSelectorNode >> = anObject [ 
	self == anObject ifTrue: [^true].
	((anObject isKindOf: self class) or: [self isKindOf: anObject class]) 
		ifFalse: [^false].
	^self value = anObject value
]

{ #category : #visiting }
TPRBSelectorNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitSelectorNode: self
]

{ #category : #comparing }
TPRBSelectorNode >> hash [
	^ self value hash
]

{ #category : #testing }
TPRBSelectorNode >> isSelector [
	^true
]

{ #category : #testing }
TPRBSelectorNode >> needsParenthesis [
	^false
]

{ #category : #accessing }
TPRBSelectorNode >> start: aPositionsList [
	start := aPositionsList ifNotNil: [:list| list asIntegerArray ].
]

{ #category : #accessing }
TPRBSelectorNode >> startWithoutParentheses [
	^ start
]

{ #category : #accessing }
TPRBSelectorNode >> stopWithoutParentheses [
	| temp prev |
	temp := 0.
	^ (start collect: [ :each | prev := temp. temp := value findString: ':' startingAt: prev+1. temp=0 ifFalse: [each + temp - prev -1 ] ifTrue: [each + value size - 1]]) asIntegerArray.
	
]

{ #category : #accessing }
TPRBSelectorNode >> value [
	^value
]

{ #category : #accessing }
TPRBSelectorNode >> value: aString [
	value := aString asSymbol
]
