"
RBStringReplacement represents replacing source in the original method with a different string. These are used when reformatting code after a parse tree change has been made. Depending on the change, it may be possible to minimally change the parse tree without needing to format it.

Instance Variables:
	startPosition	<Integer>	the start position in the original source
	stopPosition	<Integer>	the end position in the original source
	string	<String>	replaces everything from the startPosition to the endPosition with this string


"
Class {
	#name : #TPRBStringReplacement,
	#superclass : #Object,
	#instVars : [
		'startPosition',
		'stopPosition',
		'string'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBStringReplacement class >> replaceFrom: startInteger to: stopInteger with: aString [ 
	^(self new)
		startPosition: startInteger;
		stopPosition: stopInteger;
		string: aString;
		yourself
]

{ #category : #accessing }
TPRBStringReplacement >> startPosition [
	^startPosition
]

{ #category : #initialization }
TPRBStringReplacement >> startPosition: anInteger [ 
	startPosition := anInteger
]

{ #category : #accessing }
TPRBStringReplacement >> stopPosition [
	^stopPosition
]

{ #category : #initialization }
TPRBStringReplacement >> stopPosition: anInteger [ 
	stopPosition := anInteger
]

{ #category : #accessing }
TPRBStringReplacement >> string [
	^string
]

{ #category : #initialization }
TPRBStringReplacement >> string: aString [ 
	string := aString
]
