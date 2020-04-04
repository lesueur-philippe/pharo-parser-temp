"
RBValueNode is an abstract class that represents a node that returns some value.

Subclasses must implement the following messages:
	accessing
		startWithoutParentheses
		stopWithoutParentheses
	testing
		needsParenthesis

Instance Variables:
	parentheses	<SequenceableCollection of: Inteval>	the positions of the parentheses around this node. We need a collection of intervals for stupid code such as ""((3 + 4))"" that has multiple parentheses around the same expression.


"
Class {
	#name : #TPRBValueNode,
	#superclass : #TPRBProgramNode,
	#instVars : [
		'parentheses'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #accessing }
TPRBValueNode >> addParenthesis: anInterval [ 
	parentheses ifNil: [parentheses := OrderedCollection new: 1].
	parentheses add: anInterval
]

{ #category : #testing }
TPRBValueNode >> containedBy: anInterval [ 
	^anInterval first <= self startWithoutParentheses 
		and: [anInterval last >= self stopWithoutParentheses]
]

{ #category : #evaluating }
TPRBValueNode >> evaluate [
	"evaluate the AST without taking variables into account"
	^self asDoit generateWithSource valueWithReceiver: nil arguments: #().


]

{ #category : #evaluating }
TPRBValueNode >> evaluateForContext: aContext [
	"evaluate the AST taking variables from the context"
	^(self asDoitForContext: aContext) 
		generateWithSource valueWithReceiver: aContext receiver arguments: {aContext}.


]

{ #category : #evaluating }
TPRBValueNode >> evaluateForReceiver: aReceicer [
	"evaluate the AST without taking variables into account"
	| methodNode |
	
	methodNode := self asDoit.
	methodNode methodClass: aReceicer class.
	^methodNode generateWithSource valueWithReceiver: aReceicer arguments: #().


]

{ #category : #testing }
TPRBValueNode >> hasParentheses [
	^self parentheses notEmpty
]

{ #category : #testing }
TPRBValueNode >> isValue [
	^true
]

{ #category : #testing }
TPRBValueNode >> needsParenthesis [
	^self subclassResponsibility
]

{ #category : #accessing }
TPRBValueNode >> parentheses [
	^parentheses ifNil: [#()] ifNotNil: [parentheses]
]

{ #category : #accessing }
TPRBValueNode >> start [
	^ parentheses ifNil: [ self startWithoutParentheses ] ifNotNil: [ parentheses last first ]
]

{ #category : #accessing }
TPRBValueNode >> startWithoutParentheses [
	^self subclassResponsibility
]

{ #category : #accessing }
TPRBValueNode >> stop [
	^ parentheses ifNil: [ self stopWithoutParentheses ] ifNotNil: [ parentheses last last ]
]

{ #category : #accessing }
TPRBValueNode >> stopWithoutParentheses [
	^self subclassResponsibility
]
