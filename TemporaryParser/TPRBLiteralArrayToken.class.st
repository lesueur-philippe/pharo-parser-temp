"
I am the start of a literal array, normal literal arrays
#() or byte arrays #[].

"
Class {
	#name : #TPRBLiteralArrayToken,
	#superclass : #TPRBValueToken,
	#category : #'TemporaryParser-Tokens'
}

{ #category : #testing }
TPRBLiteralArrayToken >> isForByteArray [
	^value last = $[
]

{ #category : #testing }
TPRBLiteralArrayToken >> isLiteralArrayToken [
	^true
]
