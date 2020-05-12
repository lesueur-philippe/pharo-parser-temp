"
RBCommentToken is the first-class representation of a comment token (e.g. ""comment"")
"
Class {
	#name : #TPRBCommentToken,
	#superclass : #TPRBValueToken,
	#instVars : [
		'stopPosition'
	],
	#category : #'TemporaryParser-Tokens'
}

{ #category : #'instance creation' }
TPRBCommentToken class >> value: aString start: aStartPosition stop: aStopPosition [
	^self new value: aString;
		   		 start: aStartPosition;
				 stop: aStopPosition.
]

{ #category : #testing }
TPRBCommentToken >> isComment [
	^true
]

{ #category : #accessing }
TPRBCommentToken >> stop [
	^ stopPosition
]

{ #category : #accessing }
TPRBCommentToken >> stop: aPosition [
	stopPosition := aPosition
]
