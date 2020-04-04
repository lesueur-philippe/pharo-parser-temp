"
I'm a scanned error.
I can have multiple causes.
"
Class {
	#name : #TPRBErrorToken,
	#superclass : #TPRBValueToken,
	#instVars : [
		'cause',
		'location'
	],
	#category : #'TemporaryParser-Tokens'
}

{ #category : #'instance creation' }
TPRBErrorToken class >> value: value start: tokenStart cause: errorCause location: thePosition [
	^ self new
		value: value
			start: tokenStart
			cause: errorCause
			location: thePosition;
		yourself
]

{ #category : #accesing }
TPRBErrorToken >> cause [
	^ cause
]

{ #category : #testing }
TPRBErrorToken >> isError [
	^true
]

{ #category : #accessing }
TPRBErrorToken >> location [
	^ location
]

{ #category : #testing }
TPRBErrorToken >> value: theValue start: tokenStart cause: errorCause location: errorPosition [
	self value: theValue start: tokenStart .
	location := errorPosition.
	cause := errorCause .
]
