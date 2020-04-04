"
SUnit tests for RBScanner
"
Class {
	#name : #TPRBScannerTest,
	#superclass : #TestCase,
	#category : #'TemporaryParser-Tests-Parser'
}

{ #category : #initialize }
TPRBScannerTest >> buildScannerForText: source [
	^ self scannerClass on: source readStream
]

{ #category : #initialize }
TPRBScannerTest >> scannerClass [
	^ TPRBScanner
]

{ #category : #tests }
TPRBScannerTest >> testNextLiteralCharacterWithAMissingCharacter [
	| source scanner scannedToken |
	source := '$'.
	scanner := self buildScannerForText: source.
	scannedToken := scanner next.
	self verifyErrorToken: scannedToken message: 'A Character was expected' translated valueExpected: ''

]

{ #category : #tests }
TPRBScannerTest >> testNextWithAWrongSymbolGetError [
	| source scanner scannedToken |
	source := '#^'.
	scanner := self buildScannerForText: source.
	scannedToken := scanner next.
	self verifyErrorToken: scannedToken message: 'Expecting a literal type' translated valueExpected: '^'
]

{ #category : #tests }
TPRBScannerTest >> testNextWithAnIdentifierTokenGetTheIdentifierToken [
	| source scanner token |	
	source := 'identifierToken'.
	scanner := self buildScannerForText: source.
	token := scanner next.
	self assert: token isIdentifier.
	self deny: token isError.
	self assert: token value equals: source
]

{ #category : #tests }
TPRBScannerTest >> testNextWithAnOpeningCommentAtEndGetError [
	| source |	
	source := 'self "'.
	self should: [(self buildScannerForText: source) next] raise: SyntaxErrorNotification
]

{ #category : #tests }
TPRBScannerTest >> testNextWithAnOpeningCommentGetError [
	| source |	
	source := '"only the opening'.
	self should: [(self buildScannerForText: source) next] raise: SyntaxErrorNotification
]

{ #category : #tests }
TPRBScannerTest >> testNextWithAnOpeningStringsGetError [
	| source scannedToken |
	source := '''only the opening'.
	scannedToken := (self buildScannerForText: source) next.
	self verifyErrorToken: scannedToken message: 'Unmatched '' in string literal.' translated valueExpected: 'only the opening'
]

{ #category : #tests }
TPRBScannerTest >> testNextWithAnUnknownCharacterGetError [
	| source scanner scannedToken |	
	source := '¿'.
	scanner := self buildScannerForText: source.
	scannedToken := scanner next.
	self verifyErrorToken: scannedToken message: 'Unknown character' translated valueExpected: source
]

{ #category : #tests }
TPRBScannerTest >> testNextWithTwoDoubleQuotesInComment [
	| source token |
	source := '"only the"" opening"'.
	self
		shouldnt: [ token := (self buildScannerForText: source) next ]
		raise: SyntaxErrorNotification.
	self assert: token comments first equals: (1 to: source size)
]

{ #category : #tests }
TPRBScannerTest >> testNextWithTwoDoubleQuotesInCommentGetError [
	| source |
	source := '"only the"" opening'.
	self
		should: [ (self buildScannerForText: source) next ]
		raise: SyntaxErrorNotification
]

{ #category : #'tests - creation api' }
TPRBScannerTest >> testScanTokenObjects1 [
	| inp exp |
	inp := 'Object subclass: #NameOfSubclass'.
	exp := {'Object'.
	'subclass:'.
	#NameOfSubclass asString}.
	self assert: ((self scannerClass scanTokenObjects: inp) collect: [ :each | each value ]) equals: exp.
	
]

{ #category : #'tests - creation api' }
TPRBScannerTest >> testScanTokenObjects2 [
	| inp exp |
	inp := 'classVariableNames: '''' "ha ha"
package: ''UndefinedClasses-Experiment'.
	exp := {'classVariableNames:' . '' . 'package:' . 'UndefinedClasses-Experiment'}.
	self assert: ((self scannerClass scanTokenObjects: inp) collect: [ :each | each value ]) equals: exp
]

{ #category : #'tests - creation api' }
TPRBScannerTest >> testScanTokens1 [
	| inp exp |
	inp := 'Object subclass: #NameOfSubclass'.
	exp := {'Object'.
	'subclass:'.
	#NameOfSubclass asString}.
	self assert: (self scannerClass scanTokens: inp) equals: exp.
	
]

{ #category : #'tests - creation api' }
TPRBScannerTest >> testScanTokens2 [
	| inp exp |
	inp := 'classVariableNames: '''' "ha ha"
package: ''UndefinedClasses-Experiment'.
	exp := {'classVariableNames:' . '' . 'package:' . 'UndefinedClasses-Experiment'}.
	self assert: (self scannerClass scanTokens: inp) equals: exp
]

{ #category : #utilities }
TPRBScannerTest >> verifyErrorToken: scannedToken message: message valueExpected: valueExpected [
	self assert: scannedToken isError.
	self assert: scannedToken cause equals: message.
	self assert: scannedToken value equals: valueExpected.
	self assert: scannedToken start equals: 1.
]
