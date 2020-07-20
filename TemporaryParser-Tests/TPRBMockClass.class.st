Class {
	#name : #TPRBMockClass,
	#superclass : #Object,
	#instVars : [
		'slots',
		'classVariables'
	],
	#category : #'TemporaryParser-Tests-Parser'
}

{ #category : #accessing }
TPRBMockClass >> addClassVarNamed: aString [ 
	self classVariables add: ( ClassVariable named: aString).
]

{ #category : #access }
TPRBMockClass >> addInstVarNamed: aString [ 
	slots add: (InstanceVariableSlot named: aString).
]

{ #category : #acccessing }
TPRBMockClass >> allSlots [
	^ slots.
]

{ #category : #accessing }
TPRBMockClass >> classVariables [
	^classVariables
]

{ #category : #accessing }
TPRBMockClass >> environment [
	^self class environment.
]

{ #category : #initialization }
TPRBMockClass >> initialize [ 
	super initialize .
	slots := classVariables := OrderedCollection new.
]

{ #category : #accesing }
TPRBMockClass >> innerBindingOf: aString [ 
	^nil
]

{ #category : #accessing }
TPRBMockClass >> instanceSide [
	^self
]
