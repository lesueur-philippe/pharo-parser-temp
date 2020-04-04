"
RBLiteralNode is an AST node that represents literal values (e.g., #foo, true, 1, etc.), but not literal arrays.

The sourceText field is needed for the formatter for the correct printing of strings vs symbols. If we just call
value asString, both a string and a symbol print itself as a string.

Instance Variables
	value	<Numeric | Symbol | String  | Character>	the literal value I represent
	sourceText <String> the original source text of this literal
"
Class {
	#name : #TPRBLiteralValueNode,
	#superclass : #TPRBLiteralNode,
	#instVars : [
		'value',
		'sourceText'
	],
	#category : #'TemporaryParser-Nodes'
}

{ #category : #'instance creation' }
TPRBLiteralValueNode class >> value: aValue [
	^ self value: aValue start: 0 stop: -1
]

{ #category : #'instance creation' }
TPRBLiteralValueNode class >> value: aValue start: aPosition stop: anotherPosition [ 
 	^ self new
		value: aValue start: aPosition stop: anotherPosition;
		yourself.
]

{ #category : #'instance creation' }
TPRBLiteralValueNode class >> value: aValue start: aPosition stop: anotherPosition  source: aString [ 
 	^ self new
		value: aValue start: aPosition stop: anotherPosition source: aString;
		yourself.
]

{ #category : #comparing }
TPRBLiteralValueNode >> = anObject [ 
	^ super = anObject 
		and: [ self value = anObject value 
		and: [ self value species = anObject value species ] ]
]

{ #category : #visiting }
TPRBLiteralValueNode >> acceptVisitor: aProgramNodeVisitor [
	^ aProgramNodeVisitor visitLiteralValueNode: self
]

{ #category : #matching }
TPRBLiteralValueNode >> copyInContext: aDictionary [
	^ self class value: self value
]

{ #category : #accessing }
TPRBLiteralValueNode >> sourceText [
	^ sourceText ifNil: [
		String streamContents: [:aStream|			
			value isSymbol
				ifTrue: [
					aStream nextPut: $#.
					((TPRBScanner isSelector: value) and: [value ~~ #'||']) 
						ifTrue: [aStream nextPutAll: value]
						ifFalse: [value asString printOn: aStream]]
				ifFalse: [ 
					value class == Character 
						ifTrue: 
							[aStream nextPut: $$;	nextPut: value]
						ifFalse: [ value storeOn: aStream ]]] ]
]

{ #category : #accessing }
TPRBLiteralValueNode >> value [
	^ value
]

{ #category : #initialization }
TPRBLiteralValueNode >> value: aValue start: aPosition stop: anotherPosition [

	value := aValue.
	start := aPosition. 
	stop := anotherPosition.
]

{ #category : #initialization }
TPRBLiteralValueNode >> value: aValue start: aPosition stop: anotherPosition source: aString [ 

	self value: aValue start: aPosition stop: anotherPosition.
	sourceText := aString.
]
