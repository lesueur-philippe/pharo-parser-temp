"
RBVariableNode is an AST node that represents a variable (global, inst var, temp, etc.).

Although this is the basic class for the concrete variable types, this is not an abstract class and is actually used
by the parser for all variables that aren't special builtin types like self/super/thisContext. All other variables are
just RBVariableNodes until the semantic analyser can deduce the type.

Instance Variables:
	name	<RBValueToken>	the variable's name I represent
	nameStart <Integer>	the position where I was found at the source code

"
Class {
	#name : #TPRBVariableNode,
	#superclass : #TPRBValueNode,
	#instVars : [
		'name',
		'variable',
		'start'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBVariableNode class >> identifierNamed: anIdentifierName at: aPosition [
	
	anIdentifierName = 'self'
		ifTrue: [ ^ TPRBSelfNode named: anIdentifierName start: aPosition ].
	anIdentifierName = 'thisContext'
		ifTrue: [ ^ TPRBThisContextNode named: anIdentifierName start: aPosition ].
	anIdentifierName = 'super'
		ifTrue: [ ^ TPRBSuperNode named: anIdentifierName start: aPosition ].
	^ self named: anIdentifierName start: aPosition.
]

{ #category : #'instance creation' }
TPRBVariableNode class >> named: aName [
	^self named: aName start: 0.
]

{ #category : #'instance creation' }
TPRBVariableNode class >> named: aName start: aPosition [
	^self new 
		named: aName start: aPosition; 
		yourself.
]

{ #category : #comparing }
TPRBVariableNode >> = anObject [ 
	self == anObject ifTrue: [^true].
	((anObject isKindOf: self class) or: [self isKindOf: anObject class]) 
		ifFalse: [^false].
	^self name = anObject name
]

{ #category : #visiting }
TPRBVariableNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitVariableNode: self
]

{ #category : #converting }
TPRBVariableNode >> adaptToSemanticNode [
	
	self primitiveChangeClassTo: self binding semanticNodeClass new
]

{ #category : #matching }
TPRBVariableNode >> copyInContext: aDictionary [ 
	^ self class named: name.
]

{ #category : #comparing }
TPRBVariableNode >> equalTo: anObject withMapping: aDictionary [ 
	^self class = anObject class and: 
			[(aDictionary at: self name ifAbsentPut: [anObject name]) = anObject name]
]

{ #category : #testing }
TPRBVariableNode >> hasIncompleteIdentifier [
	^ self binding isUndeclared
		ifTrue: [ (self scope findVariable: [ :v | v name beginsWith: self name ] ifNone: [ nil ]) notNil]
]

{ #category : #comparing }
TPRBVariableNode >> hash [
	^self name hash
]

{ #category : #initialization }
TPRBVariableNode >> initialize [
	super initialize.
	name := ''.
	start := 0
]

{ #category : #testing }
TPRBVariableNode >> isArgument [
	^ false
]

{ #category : #testing }
TPRBVariableNode >> isDefinition [
	^self parent isSequence and: [ self parent defines: name ]
]

{ #category : #testing }
TPRBVariableNode >> isImmediateNode [
	^true
]

{ #category : #testing }
TPRBVariableNode >> isRead [
	^ self isWrite not and: [ self isUsed ]
]

{ #category : #testing }
TPRBVariableNode >> isSelf [
	"normally this method is not needed (if all the RBVariable creations create RBSelfNode instead but
	since we do not control this."
	
	^ self name = 'self'
]

{ #category : #testing }
TPRBVariableNode >> isSuper [
	"normally this method is not needed (if all the RBVariable creations create RBSuperNode instead but
	since we do not control this."
	
	^ self name = 'super'
]

{ #category : #testing }
TPRBVariableNode >> isTemp [
	^ false
]

{ #category : #testing }
TPRBVariableNode >> isThisContext [
	^ false
]

{ #category : #testing }
TPRBVariableNode >> isVariable [
	^true
]

{ #category : #testing }
TPRBVariableNode >> isWrite [
	^ self parent notNil and: [ self parent isAssignment and: [ self parent variable == self ] ]
]

{ #category : #accessing }
TPRBVariableNode >> name [
	^ name
]

{ #category : #accessing }
TPRBVariableNode >> name: aName [
	name := aName asSymbol.
]

{ #category : #initialization }
TPRBVariableNode >> named: aName start: aPosition [

	self name: aName.
	self start: aPosition.
]

{ #category : #testing }
TPRBVariableNode >> needsParenthesis [
	^false
]

{ #category : #accessing }
TPRBVariableNode >> precedence [
	^0
]

{ #category : #testing }
TPRBVariableNode >> references: aVariableName [ 
	^self name = aVariableName
]

{ #category : #replacing }
TPRBVariableNode >> replaceSourceFrom: aNode [ 
	self addReplacement: (RBStringReplacement 
				replaceFrom: aNode start
				to: aNode stop
				with: self name)
]

{ #category : #replacing }
TPRBVariableNode >> replaceSourceWith: aNode [
	self addReplacement: (RBStringReplacement 
				replaceFrom: self start
				to: self stop
				with: aNode formattedCode)
]

{ #category : #accessing }
TPRBVariableNode >> start [
	^ start
]

{ #category : #accessing }
TPRBVariableNode >> start: aPosition [
	start := aPosition
]

{ #category : #accessing }
TPRBVariableNode >> startForReplacement [
	"Return the start of the variable,  taking into account characters before the variable.
	This method is used when unused temporary variables are removed"
	| src t |
	src := self source.
	t := self start - 1.
	[ (src at: t) isSeparator ] whileTrue: [ t := t - 1 ].
	^ t + 1
]

{ #category : #accessing }
TPRBVariableNode >> startWithoutParentheses [
	^ start
]

{ #category : #accessing }
TPRBVariableNode >> stopWithoutParentheses [
	^ start + name size - 1.
]
