Class {
	#name : #TPRBLiteralByteArrayErrorNode,
	#superclass : #TPRBEnglobingErrorNode,
	#category : #'TemporaryParser-Nodes'
}

{ #category : #testing }
TPRBLiteralByteArrayErrorNode >> isLiteralByteArrayError [
	^true
]

{ #category : #accessing }
TPRBLiteralByteArrayErrorNode >> value [
	^  '#[ ', super value 
]
