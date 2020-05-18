Class {
	#name : #TPRBASTTest,
	#superclass : #TPRBParserTest,
	#category : #'TemporaryParser-Tests-Parser'
}

{ #category : #'test utils' }
TPRBASTTest >> testCopyInContext [
	| tree |
	self deprecated: 'This test should be in the nodes tests'.
	tree := self treeWithEverything.
	self compare: tree to: (tree copyInContext: Dictionary new).
	tree := self treeWithReallyEverything.
	self compare: tree to: (tree copyInContext: Dictionary new).
	
	self exampleClasses do: [ :class |
		class selectors do: [ :each |
			tree := class parseTreeFor: each.
			self compare: tree to: (tree copyInContext: Dictionary new) ] ]
]

{ #category : #'test utils' }
TPRBASTTest >> testCopyReproduceGivenTree [
	| tree |
	tree := self treeWithEverything.
	self compare: tree to: tree copy.
	tree := self treeWithReallyEverything.
	self compare: tree to: tree copy.
]

{ #category : #'to be reworked' }
TPRBASTTest >> testEqualToWithMapping [
	| tree |
	tree := self treeWithEverything.
	self assert: (tree equalTo: tree withMapping: Dictionary new).
	tree := self treeWithReallyEverything.
	self assert: (tree equalTo: tree withMapping: Dictionary new).
	
	self exampleClasses do: [ :class |
		class selectors do: [ :each |
			tree := class parseTreeFor: each.
			self assert: (tree equalTo: tree withMapping: Dictionary new) ] ]
]

{ #category : #'test utils' }
TPRBASTTest >> testEquivalentExceptRenaming [
	#(#('a 3-4' 'a 4-3' false) 
	  #('a #[3 4]' 'a #(3 4)' false) 
	  #('a variable1 ~~ "comment" variable2' 'a variable1 ~~ variable2' true) 
	  #('a variable1' 'a variable2' false) 
	  #('a [:a :b | a + b]' 'a [:b :a | a + b]' false) 
	  #('a | a b | a + b' 'a | b a | a + b' true) 
	  #('a | a | a msg1; msg2' 'a | b | b msg2; msg2' false) 
	  #('a c' 'a d' true) 
	  #('a | a b | a := b. ^b msg1' 'a | a b | b := a. ^a msg1' true) 
	  #('a | a b | a := b. ^b msg1: a' 'a | a b | b := a. ^b msg1: a' false) 
	  #('a: b b + 4' 'a: e e + 4' true) #('a: b b + 4' 'b: b b + 4' false) 
	  #('a: b b: c b + c' 'a: c b: b c + b' true) 
	  #('a: a b: b a + b' 'a: b b: a a + b' false))
		do: [ :each | 
			self
				assert: ((self parserClass parseMethod: each first) equalTo: (self parserClass parseMethod: (each at: 2)) exceptForVariables: #('c'))
				identicalTo: each last ]
]

{ #category : #'to be reworked' }
TPRBASTTest >> testIsA [
	"Test that for a given tree, "
	| nodes types |
	nodes := Bag new.
	types := Set new.
	#(#(#isAssignment 1) 
	  #(#isBlock 1) 
	  #(#isCascade 1) 
	  #(#isLiteralNode 2) 
	  #(#isMessage 3) 
	  #(#isMethod 1) 
	  #(#isReturn 1) 
	  #(#isSequence 2) 
	  #(#isValue 15) 
	  #(#isVariable 7) 
	  #(#isUsed 10) 
	  #(#isDirectlyUsed 9) 
	  #(#hasParentheses 1) 
	  #(#isBinary 0) 
	  #(#isPrimitive 0) 
	  #(#isImmediateNode 10) 
	  #(#isWrite 1) 
	  #(#isRead 3))
		do: [ :each | each last timesRepeat: [ nodes add: each first ]. 
			   types add: each first ].
	self treeWithEverything nodesDo: [ :each | types do: [ :sel | ((each respondsTo: sel) and: [ each perform: sel ]) ifTrue: [ nodes remove: sel ] ] ].
	self assertEmpty: nodes
]

{ #category : #'to be reworked' }
TPRBASTTest >> testMatchInContext [
	| tree |
	tree := self treeWithEverything.
	self assert: (tree match: tree inContext: Dictionary new).
	tree := self treeWithReallyEverything.
	self assert: (tree match: tree inContext: Dictionary new).
	
	self exampleClasses do: [ :class |
		class selectors do: [ :each |
			tree := class parseTreeFor: each.
			self assert: (tree match: tree inContext: Dictionary new) ] ]
]

{ #category : #'to be reworked' }
TPRBASTTest >> testNodesDo [
	| size |
	size := 0.
	self treeWithEverything nodesDo: [ :e | size := size + 1 ].
	self assert: size equals: 19
]
