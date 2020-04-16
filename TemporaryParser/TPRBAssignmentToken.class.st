"
RBAssignmentToken is the first-class representation of the assignment token ':='

"
Class {
	#name : #TPRBAssignmentToken,
	#superclass : #TPRBToken,
	#category : #'TemporaryParser-Tokens'
}

{ #category : #testing }
TPRBAssignmentToken >> isAssignment [
	^true
]

{ #category : #accessing }
TPRBAssignmentToken >> length [

	^ 2
]
