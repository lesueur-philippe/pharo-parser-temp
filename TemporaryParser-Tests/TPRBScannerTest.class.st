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

{ #category : #testLiteral }
TPRBScannerTest >> testNextAcceptAllAlphabeticAsLiteral [
	| scanner token |
	scanner := self buildScannerForText: '#alpha'.
	token := scanner next.
	self assert: token isLiteralToken.
]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextAcceptFloatNumbers [
	
	| scanner token |
	scanner := self buildScannerForText: '3.2'.
	token := scanner next.
	self assert: token isNumberLiteralToken.
]

{ #category : #testLiteral }
TPRBScannerTest >> testNextAcceptLiteralArray [
	"Note: RBScanner only spots the beginning of the array."
	| scanner token |
	scanner := self buildScannerForText: '#('.
	token := scanner next.
	self assert: token isLiteralArrayToken.
	
	scanner := self buildScannerForText: '#['.
	token := scanner next.
	self assert: token isLiteralArrayToken.
]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextAcceptRadixNumbers [
	
	| scanner token |
	scanner := self buildScannerForText: '10r10'.
	token := scanner next.
	self assert: token isNumberLiteralToken.
	
	scanner := self buildScannerForText: '2r10'.
	token := scanner next.
	self assert: token isNumberLiteralToken.
	
	scanner := self buildScannerForText: '16rfa'.
	token := scanner next.
	self assert: token isNumberLiteralToken.
	
	scanner := self buildScannerForText: '400r380'.
	token := scanner next.
	self assert: token isNumberLiteralToken.
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextAddsCommentToComments [
	| scanner token |
	scanner := self buildScannerForText: '"start comment"firstToken'.
	token := scanner next.
	self assert: token comments equals: (OrderedCollection newFrom: {(1 to: 15)}) .
	
]

{ #category : #testKeyword }
TPRBScannerTest >> testNextAllAlphabeticEndingWithColonGiveKeyword [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken:'.
	token := scanner next.
	self assert: token isKeyword.
]

{ #category : #testIdentifiers }
TPRBScannerTest >> testNextAllAlphabeticsGiveIdentifier [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken'.
	token := scanner next.
	self assert: token isIdentifier.
	
]

{ #category : #testKeyword }
TPRBScannerTest >> testNextAlphabeticAndDigitEndingWithColonGiveKeyword [
	| scanner token |
	scanner := self buildScannerForText: 'first123Token:'.
	token := scanner next.
	self assert: token isKeyword.
]

{ #category : #testIdentifiers }
TPRBScannerTest >> testNextAlphabeticsAndDigitGiveIdentifier [
	| scanner token |
	scanner := self buildScannerForText: 'first123Token'.
	token := scanner next.
	self assert: token isIdentifier.
	
]

{ #category : #testError }
TPRBScannerTest >> testNextBaseOfRadixNumbersCanNotBeOne [
	
	| scanner |
	scanner := self buildScannerForText: '1r1a'.
	self should: [scanner next] raise: SyntaxErrorNotification .
]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextBeginningWithDigitIsNumber [
	
	| scanner token |
	scanner := self buildScannerForText: '1'.
	token := scanner next.
	self assert: token isNumberLiteralToken.
	
	scanner := self buildScannerForText: '1a'.
	token := scanner next.
	self assert: token isNumberLiteralToken.
	
	scanner := self buildScannerForText: '1='.
	token := scanner next.
	self assert: token isNumberLiteralToken.
	
	scanner := self buildScannerForText: '1$'.
	token := scanner next.
	self assert: token isNumberLiteralToken.
	
	scanner := self buildScannerForText: '123'.
	token := scanner next.
	self assert: token isNumberLiteralToken.
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextDoesNotAddLineBreakToComments [
	| scanner token |
	scanner := self buildScannerForText: '
firstToken'.
	token := scanner next.
	self assert: token comments isNil.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextDoesNotAddSpacesToComments [
	| scanner token |
	scanner := self buildScannerForText: '   firstToken'.
	token := scanner next.
	self assert: token comments isNil.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextDoesNotAddTabToComments [
	| scanner token |
	scanner := self buildScannerForText: '	firstToken'.
	token := scanner next.
	self assert: token comments isNil.
	
]

{ #category : #testError }
TPRBScannerTest >> testNextDollarSignCanNotStandAlone [
	| scanner token |
	scanner := self buildScannerForText: '$'.
	token := scanner next.
	self assert: token isError.
]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextFloatNumbersCanBeNegative [
	
	| scanner token |
	scanner := self buildScannerForText: '-3.2'.
	token := scanner next.
	self assert: token isNumberLiteralToken.
	self assert: token value equals: -3.2.
]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextFloatNumbersCanBeNegativeNumbers [
	
	| scanner token |
	scanner := self buildScannerForText: '-3.2'.
	token := scanner next.
	self assert: token isNumberLiteralToken.
]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextFloatNumbersCanNotHaveSpaces [
	
	| scanner token |
	scanner := self buildScannerForText: '3 .2'.
	token := scanner next.
	self deny: token value equals: 3.2.
	
	scanner := self buildScannerForText: '3. 2'.
	token := scanner next.
	self deny: token value equals: 3.2.
]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextFloatNumbersHasFloatValue [
	
	| scanner token |
	scanner := self buildScannerForText: '3.2'.
	token := scanner next.
	self assert: token value equals: 3.2.
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextGeneralSeparatorsHandling [
	| scanner token |
	scanner := self buildScannerForText: 
	'  "star comment" firstToken 
   "inbetween comment" secondToken
	"second inbetween" "multiple comments"
   : "spaces and comments in affectation" =          
   "end comment"'.
	"Expecting all spaces and line breaks to be trimmed."
	
	"The first token 'firstToken' takes the previous comment and the following one"
	token := scanner next.
	self assert: token comments equals: (OrderedCollection newFrom: {(3 to: 16). (33 to: 51)}).
	self assert: token start equals: 18.
	
	"The next token 'secondToken' takes the following 2 comments."
	token := scanner next.
	self assert: token comments equals: (OrderedCollection newFrom: {(66 to: 83). (85 to: 103)}).
	self assert: token start equals: 53.
	
	"Separated by comments multiple symbol tokens don't create the one expacted token."
	token := scanner next.
	self assert: token comments equals: (OrderedCollection newFrom: {(110 to: 145)}).
	self assert: token start equals: 108.
	
	token := scanner next.
	self assert: token comments equals: (OrderedCollection newFrom: {(162 to: 174)}).
	self assert: token start equals: 147.
	
	token := scanner next.
	self assert: token comments isNil.
	self assert: token start equals: 175.
]

{ #category : #testError }
TPRBScannerTest >> testNextHashtagCanNotStandAlone [
	| scanner token |
	scanner := self buildScannerForText: '#'.
	token := scanner next.
	self assert: token isError.
]

{ #category : #testIdentifiers }
TPRBScannerTest >> testNextIdentifierCanContainUnderscore [
	| scanner token |
	scanner := self buildScannerForText: 'first_Token'.
	token := scanner next.
	self assert: token isIdentifier.
	self assert: token value equals: 'first_Token'.
	
	scanner := self buildScannerForText: '_firstToken'.
	token := scanner next.
	self assert: token isIdentifier.
	self assert: token value equals: '_firstToken'.
	
	scanner := self buildScannerForText: 'firstToken_'.
	token := scanner next.
	self assert: token isIdentifier.
	self assert: token value equals: 'firstToken_'.
	
]

{ #category : #testIdentifiers }
TPRBScannerTest >> testNextIdentifierCanNotBeginWithBinary [
	| scanner token |
	scanner := self buildScannerForText: '+firstToken'.
	token := scanner next.
	self deny: token isIdentifier.
	
]

{ #category : #testIdentifiers }
TPRBScannerTest >> testNextIdentifierCanNotBeginWithDigit [
	| scanner token |
	scanner := self buildScannerForText: '123firstToken'.
	token := scanner next.
	self deny: token isIdentifier.
	
]

{ #category : #testIdentifiers }
TPRBScannerTest >> testNextIdentifierCanNotEndWithBinary [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken+'.
	token := scanner next.
	self deny: token value equals: 'firstToken+'.
	
]

{ #category : #testIdentifiers }
TPRBScannerTest >> testNextIdentifierCanNotHaveBinary [
	| scanner token |
	scanner := self buildScannerForText: 'first+Token'.
	token := scanner next.
	self deny: token value equals: 'first+Token'.
	
]

{ #category : #testIdentifiers }
TPRBScannerTest >> testNextIdentifierStartAtFirstLetter [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken'.
	token := scanner next.
	self assert: token start equals: 1.
	
]

{ #category : #testIdentifiers }
TPRBScannerTest >> testNextIdentifierStopAtLastLetter [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken'.
	token := scanner next.
	self assert: token stop equals: 10.
	
]

{ #category : #testIdentifiers }
TPRBScannerTest >> testNextIdentifierValueIsName [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken'.
	token := scanner next.
	self assert: token value equals: 'firstToken'.
	
]

{ #category : #testKeyword }
TPRBScannerTest >> testNextKeyWordStartAtFirstLetter [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken:'.
	token := scanner next.
	self assert: token start equals: 1.
	
]

{ #category : #testKeyword }
TPRBScannerTest >> testNextKeywordBeginningWithSpecialCharacterIsNotKeyword [
	| scanner token |
	scanner := self buildScannerForText: '^firstToken:'.
	token := scanner next.
	self deny: token isKeyword.
	
	scanner := self buildScannerForText: '$firstToken:'.
	token := scanner next.
	self deny: token isKeyword.
	
	scanner := self buildScannerForText: '\firstToken:'.
	token := scanner next.
	self deny: token isKeyword.
	
	scanner := self buildScannerForText: '`firstToken:'.
	token := scanner next.
	self deny: token isKeyword.
	
	
]

{ #category : #testKeyword }
TPRBScannerTest >> testNextKeywordCanContainUnderscore [
	| scanner token |
	scanner := self buildScannerForText: 'first_Token:'.
	token := scanner next.
	self assert: token isKeyword.
	self assert: token value equals: 'first_Token:'.
	
	scanner := self buildScannerForText: '_firstToken:'.
	token := scanner next.
	self assert: token isKeyword.
	self assert: token value equals: '_firstToken:'.
	
	scanner := self buildScannerForText: '_firstToken:'.
	token := scanner next.
	self assert: token isKeyword.
	self assert: token value equals: '_firstToken:'.
]

{ #category : #testKeyword }
TPRBScannerTest >> testNextKeywordCanNotBeFullBinary [
	| scanner token |
	scanner := self buildScannerForText: '+-=:'.
	token := scanner next.
	self deny: token isKeyword.
	
	
]

{ #category : #testKeyword }
TPRBScannerTest >> testNextKeywordCanNotBeFullDigit [
	| scanner token |
	scanner := self buildScannerForText: '123:'.
	token := scanner next.
	self deny: token isKeyword.
	
	
]

{ #category : #testKeyword }
TPRBScannerTest >> testNextKeywordCanNotBeginWithBinary [
	| scanner token |
	scanner := self buildScannerForText: '+alpha:'.
	token := scanner next.
	self deny: token isKeyword.
	
	
]

{ #category : #testKeyword }
TPRBScannerTest >> testNextKeywordCanNotBeginWithDigit [
	| scanner token |
	scanner := self buildScannerForText: '123alpha:'.
	token := scanner next.
	self deny: token isKeyword.
	
	
]

{ #category : #testKeyword }
TPRBScannerTest >> testNextKeywordStopAtColon [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken:'.
	token := scanner next.
	self assert: token stop equals: 11.
	
	scanner := self buildScannerForText: 'first:Token'.
	token := scanner next.
	self assert: token stop equals: 6.
	
]

{ #category : #testKeyword }
TPRBScannerTest >> testNextKeywordValueIsStartToStop [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken:'.
	token := scanner next.
	self assert: token value equals: 'firstToken:'.
	
	scanner := self buildScannerForText: 'first:Token'.
	token := scanner next.
	self assert: token value equals: 'first:'.
	
]

{ #category : #testError }
TPRBScannerTest >> testNextLiteralBeginningWithDigitThrowsError [
	| scanner token |
	scanner := self buildScannerForText: '#123alpha'.
	token := scanner next.
	self assert: token isError.
]

{ #category : #testLiteral }
TPRBScannerTest >> testNextLiteralCanBeBinary [
	| scanner token |
	scanner := self buildScannerForText: '#+=-/'.
	token := scanner next.
	self assert: token isLiteralToken.
	self assert: token value equals: #+=-/.
]

{ #category : #testLiteral }
TPRBScannerTest >> testNextLiteralCanContainDigits [
	| scanner token |
	scanner := self buildScannerForText: '#alpha123beta456'.
	token := scanner next.
	self assert: token isLiteralToken.
]

{ #category : #testLiteral }
TPRBScannerTest >> testNextLiteralCanContainSomeSpecialCaracters [
	| scanner token |
	scanner := self buildScannerForText: '#_alpha'.
	token := scanner next.
	self assert: token value equals: #_alpha.
	
	scanner := self buildScannerForText: '#al:pha'.
	token := scanner next.
	self assert: token value equals: #'al:pha'.
	
	scanner := self buildScannerForText: '#alpha$'.
	token := scanner next.
	self assert: token value equals: #alpha.
]

{ #category : #testLiteral }
TPRBScannerTest >> testNextLiteralCanHaveMultipleHashtag [
	| scanner token |
	scanner := self buildScannerForText: '########literal'.
	token := scanner next.
	self assert: token isLiteralToken.
]

{ #category : #testLiteral }
TPRBScannerTest >> testNextLiteralCanNotBeginWithDigits [
	| scanner token |
	scanner := self buildScannerForText: '#123alpha'.
	token := scanner next.
	self deny: token isLiteralToken.
]

{ #category : #testLiteral }
TPRBScannerTest >> testNextLiteralCanNotContainBinaryAndAlphabetic [
	| scanner token |
	scanner := self buildScannerForText: '#+alpha'.
	token := scanner next.
	self assert: token value equals: #+.
	
	scanner := self buildScannerForText: '#al=pha'.
	token := scanner next.
	self assert: token value equals: #al.
	
	scanner := self buildScannerForText: '#alpha-'.
	token := scanner next.
	self assert: token value equals: #alpha.
]

{ #category : #testLiteral }
TPRBScannerTest >> testNextLiteralCharacterCanBeAnyCharacter [
	| scanner token |
	scanner := self buildScannerForText: '$1'.
	token := scanner next.
	self assert: token isLiteralToken.
	
	scanner := self buildScannerForText: '$a'.
	token := scanner next.
	self assert: token isLiteralToken.
	
	scanner := self buildScannerForText: '$+'.
	token := scanner next.
	self assert: token isLiteralToken.
	
	scanner := self buildScannerForText: '$#'.
	token := scanner next.
	self assert: token isLiteralToken.
	
	scanner := self buildScannerForText: '$$'.
	token := scanner next.
	self assert: token isLiteralToken.
	
	scanner := self buildScannerForText: '$_'.
	token := scanner next.
	self assert: token isLiteralToken.
	
	scanner := self buildScannerForText: '$^'.
	token := scanner next.
	self assert: token isLiteralToken.
]

{ #category : #testLiteral }
TPRBScannerTest >> testNextLiteralCharacterHasCharacterAsValue [
	| scanner token |
	scanner := self buildScannerForText: '$1'.
	token := scanner next.
	self assert: token value equals: $1.
	
	scanner := self buildScannerForText: '$a'.
	token := scanner next.
	self assert: token value equals: $a.
	
	scanner := self buildScannerForText: '$+'.
	token := scanner next.
	self assert: token value equals: $+.
	
	scanner := self buildScannerForText: '$#'.
	token := scanner next.
	self assert: token value equals: $#.
	
	scanner := self buildScannerForText: '$$'.
	token := scanner next.
	self assert: token value equals: $$.
	
	scanner := self buildScannerForText: '$_'.
	token := scanner next.
	self assert: token value equals: $_.
	
	scanner := self buildScannerForText: '$^'.
	token := scanner next.
	self assert: token value equals: $^.
]

{ #category : #testLiteral }
TPRBScannerTest >> testNextLiteralCharacterHasOnlyOneCharacter [
	| scanner token |
	scanner := self buildScannerForText: '$123'.
	token := scanner next.
	self assert: token value equals: $1.
]

{ #category : #tests }
TPRBScannerTest >> testNextLiteralCharacterWithAMissingCharacter [
	| source scanner scannedToken |
	source := '$'.
	scanner := self buildScannerForText: source.
	scannedToken := scanner next.
	self verifyErrorToken: scannedToken message: 'A Character was expected' translated valueExpected: ''

]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextNegativeNumberCanNotHaveSpaces [
	
	| scanner token |
	scanner := self buildScannerForText: '- 12'.
	token := scanner next.
	self deny: token isNumberLiteralToken.
]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextNegativeNumberIsNumberLiteral [
	
	| scanner token |
	scanner := self buildScannerForText: '-12'.
	token := scanner next.
	self assert: token isNumberLiteralToken.
]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextRadixNumbersCanBeFloatAsWell [
	
	| scanner token |
	scanner := self buildScannerForText: '10r10.2'.
	token := scanner next.
	self assert: token value equals: 10.2.
	
	scanner := self buildScannerForText: '2r1010.1'.
	token := scanner next.
	self assert: token value equals: 10.5.
	
	scanner := self buildScannerForText: '16ra.a'.
	token := scanner next.
	self assert: token value equals: 10.625.
	
	scanner := self buildScannerForText: '8r12.44'.
	token := scanner next.
	self assert: token value equals: 10.5625.
]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextRadixNumbersCanBeNegative [
	
	| scanner token |
	scanner := self buildScannerForText: '-10r10'.
	token := scanner next.
	self assert: token value equals: -10.
	
	scanner := self buildScannerForText: '-2r1010'.
	token := scanner next.
	self assert: token value equals: -10.
	
	scanner := self buildScannerForText: '-16ra'.
	token := scanner next.
	self assert: token value equals: -10.
	
	scanner := self buildScannerForText: '-8r12'.
	token := scanner next.
	self assert: token value equals: -10.
]

{ #category : #testSpecialCharacters }
TPRBScannerTest >> testNextSpecialCharactereCanBeAssignement [
	| scanner token |
	scanner := self buildScannerForText: ':='.
	token := scanner next.
	self assert: token isAssignment.
]

{ #category : #testSpecialCharacters }
TPRBScannerTest >> testNextSpecialCharactereCanBeShortAssignement [
	| scanner token |
	scanner := self buildScannerForText: '_'.
	token := scanner next.
	self assert: token isAssignment.
]

{ #category : #testSpecialCharacters }
TPRBScannerTest >> testNextSpecialCharactereisSingle [
	| scanner token |
	scanner := self buildScannerForText: '(]'.
	token := scanner next.
	self assert: token value equals: $(.
	
	scanner := self buildScannerForText: '^('.
	token := scanner next.
	self assert: token value equals: $^.
	
	scanner := self buildScannerForText: ']'.
	token := scanner next.
	self assert: token value equals: $].
	
]

{ #category : #testSpecialCharacters }
TPRBScannerTest >> testNextSpecialCharactereisSpecial [
	| scanner token |
	scanner := self buildScannerForText: '('.
	token := scanner next.
	self assert: token isSpecial.
	
	scanner := self buildScannerForText: '^'.
	token := scanner next.
	self assert: token isSpecial.
	
	scanner := self buildScannerForText: ']'.
	token := scanner next.
	self assert: token isSpecial.
	
]

{ #category : #testLiteral }
TPRBScannerTest >> testNextStringCanContainOtherString [
	| scanner token |
	scanner := self buildScannerForText: ''' The world has changed ''''I can feel it in the water'''' '''.
	token := scanner next.
	self assert: token isLiteralToken.
	self assert: token value equals: ' The world has changed ''I can feel it in the water'' '.
]

{ #category : #testLiteral }
TPRBScannerTest >> testNextStringContainsAllTheContent [
	| scanner token |
	scanner := self buildScannerForText: '''The world has changed'''.
	token := scanner next.
	self assert: token value equals: 'The world has changed'.
]

{ #category : #testLiteral }
TPRBScannerTest >> testNextStringErrorDoesNotPropagateInside [
	| scanner token |
	scanner := self buildScannerForText: ''' The world has changed ''''I feel it in the water'''.
	token := scanner next.
	self assert: token value equals: ' The world has changed ''I feel it in the water'.
]

{ #category : #testLiteral }
TPRBScannerTest >> testNextStringIsLiteral [
	| scanner token |
	scanner := self buildScannerForText: '''the world has changed'''.
	token := scanner next.
	self assert: token isLiteralToken.
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTokenStartAfterComment [
	"Tests that the next token adapts starting point according to it."
	| scanner token |
	scanner := self buildScannerForText: '"start comment"firstToken'.
	token := scanner next.
	self assert: token value equals: 'firstToken'.
	self assert: token start equals: 16.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTokenStartAfterLineBreak [
	"Tests that the next token adapts starting point according to it."
	| scanner token |
	scanner := self buildScannerForText: '
firstToken'.
	token := scanner next.
	self assert: token value equals: 'firstToken'.
	self assert: token start equals: 2.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTokenStartAfterSpaces [
	"Tests that the next token adapts starting point according to it."
	| scanner token |
	scanner := self buildScannerForText: '   firstToken'.
	token := scanner next.
	self assert: token value equals: 'firstToken'.
	self assert: token start equals: 4.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTokenStartAfterTab [
	"Tests that the next token adapts starting point according to it."
	| scanner token |
	scanner := self buildScannerForText: '	firstToken'.
	token := scanner next.
	self assert: token value equals: 'firstToken'.
	self assert: token start equals: 2.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsBeginningComment [
	| scanner token |
	scanner := self buildScannerForText: '"start comment"firstToken'.
	token := scanner next.
	self assert: token value equals: 'firstToken'.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsBeginningLineBreak [
	| scanner token |
	scanner := self buildScannerForText: '
firstToken'.
	token := scanner next.
	self assert: token value equals: 'firstToken'.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsBeginningSpaces [
	| scanner token |
	scanner := self buildScannerForText: '   firstToken'.
	token := scanner next.
	self assert: token value equals: 'firstToken'.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsBeginningTab [
	| scanner token |
	scanner := self buildScannerForText: '	firstToken'.
	token := scanner next.
	self assert: token value equals: 'firstToken'.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsEndComment [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken"end comment"'.
	scanner next.
	token := scanner next.
	self assert: token isEOF.
	self assert: token start equals: 24.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsEndLineBreak [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken
'.
	scanner next.
	token := scanner next.
	self assert: token isEOF.
	self assert: token start equals: 12.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsEndSpaces [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken    '.
	scanner next.
	token := scanner next.
	self assert: token isEOF.
	self assert: token start equals: 15.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsEndTab [
	| scanner token |
	"There are 2 spaces before tab."
	scanner := self buildScannerForText: 'firstToken  	'.
	scanner next.
	token := scanner next.
	self assert: token isEOF.
	self assert: token start equals: 14.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsMiddleComment [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken"middle comment"secondToken'.
	scanner next.
	token := scanner next.
	self deny: token isEOF.
	self assert: token start equals: 27.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsMiddleLineBreak [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken
secondToken'.
	scanner next.
	token := scanner next.
	self deny: token isEOF.
	self assert: token start equals: 12.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsMiddleSpaces [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken    secondToken'.
	scanner next.
	token := scanner next.
	self deny: token isEOF.
	self assert: token start equals: 15.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsMiddleTab [
	| scanner token |
	"There are 2 spaces before tab."
	scanner := self buildScannerForText: 'firstToken  	secondToken'.
	scanner next.
	token := scanner next.
	self deny: token isEOF.
	self assert: token start equals: 14.
	
]

{ #category : #testIdentifiers }
TPRBScannerTest >> testNextUnderscoreWithOnlyDigitsIsIdentifier [
	| scanner token |
	scanner := self buildScannerForText: '_123'.
	token := scanner next.
	self assert: token isIdentifier.
	self assert: token value equals: '_123'.
]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextValueOfNegativeNumbers [
	
	| scanner token |
	scanner := self buildScannerForText: '-12'.
	token := scanner next.
	self assert: token value equals: -12.
	
	scanner := self buildScannerForText: '-3'.
	token := scanner next.
	self assert: token value equals: -3.
]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextValueOfRadixNumbersCutsWhenValueIsImpossible [
	
	| scanner token |
	scanner := self buildScannerForText: '10r1a'.
	token := scanner next.
	self assert: token value equals: 1.
	
	scanner := self buildScannerForText: '2r10210'.
	token := scanner next.
	self assert: token value equals: 2.
	
	scanner := self buildScannerForText: '16r3g'.
	token := scanner next.
	self assert: token value equals: 3.
	
	scanner := self buildScannerForText: '8r192'.
	token := scanner next.
	self assert: token value equals: 1.
]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextValueOfRadixNumbersIsConvertedToDecimal [
	
	| scanner token |
	scanner := self buildScannerForText: '10r10'.
	token := scanner next.
	self assert: token value equals: 10.
	
	scanner := self buildScannerForText: '2r1010'.
	token := scanner next.
	self assert: token value equals: 10.
	
	scanner := self buildScannerForText: '16ra'.
	token := scanner next.
	self assert: token value equals: 10.
	
	scanner := self buildScannerForText: '8r12'.
	token := scanner next.
	self assert: token value equals: 10.
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

{ #category : #testError }
TPRBScannerTest >> testNextWithUnFinishedCommentGivesAnError [
	| scanner |
	scanner := self buildScannerForText: 'firstToken "unfinished comment secondToken'.
	self should: [scanner next] raise: SyntaxErrorNotification .
	
]

{ #category : #'scanBinary:' }
TPRBScannerTest >> testScanBinaryTrimSeparators [
	"This test is aimed at verifying that scanAnySymbol trims the separators."
		
	| token |
	token := (self buildScannerForText: ' "wtf"  +-   ') scanBinary: TPRBLiteralToken.
	self assert: token isLiteralToken.
	self assert: token value equals: '+-'.
]

{ #category : #'scanBinary:' }
TPRBScannerTest >> testScanBinaryWithAnyValueToken [
	"This test is a reminder that you can feed any Token that has a value and a start variable, hence 	every RBValueToken.
	
	binaryCharacter ::= '!' | '%' | '&' | '*' | '+' | ',' | '/' | '<' | '=' | '>' | '?' | '@' | '\' | 							 							 '~' | '|' | '-'"
	| token tokens |
	tokens := {TPRBBinarySelectorToken. TPRBErrorToken. TPRBIdentifierToken. TPRBKeywordToken.        	 	           TPRBLiteralToken. TPRBMultiKeywordLiteralToken. TPRBNumberLiteralToken. 	   	  	 	  	   	 				  TPRBPatternBlockToken. TPRBSpecialCharacterToken.}.
	"Test the creation of a literal for every binary."
	tokens do: [:tok | 
		token := (self buildScannerForText: '!') scanBinary: tok.
					 self assert: token class equals: tok.
					 self assert: token value equals: '!'].
]

{ #category : #'scanBinary:' }
TPRBScannerTest >> testScanBinaryWithLitteralToken [
"This test is aimed at verifying the production a litteral token with the right properties when 	scanning binary character.
	
	binaryCharacter ::= '!' | '%' | '&' | '*' | '+' | ',' | '/' | '<' | '=' | '>' | '?' | '@' | '\' | 							 							 '~' | '|' | '-'"
	| token binary |
	binary := #('!' '%' '&' '*' '+' ',' '/' '<' '=' '>' '?' '@' '\' '~' '|' '-').
	"Test the creation of a literal for every binary."
	binary do: [:sbin | token := (self buildScannerForText: sbin) scanBinary: TPRBLiteralToken.
							  self assert: token isLiteralToken.
							  self assert: token value equals: sbin].
]

{ #category : #'scanBinary:' }
TPRBScannerTest >> testScanBinaryWithLitteralTokenWithNonBinaryCharacterForFirstValue [
	"This test is aimed at verifying the production a litteral token with the right properties when 	scanning non binary character as first character.
	
	binaryCharacter ::= '!' | '%' | '&' | '*' | '+' | ',' | '/' | '<' | '=' | '>' | '?' | '@' | '\' | 							 							 '~' | '|' | '-'"
	| token nonbinary |
	nonbinary := #('1' 'p' '^' 'é' '1=' '1=+').
	"Test the creation of a literal for every binary."
	nonbinary do: [:snbin | token := (self buildScannerForText: snbin) scanBinary: TPRBLiteralToken.
							  self assert: token isLiteralToken.
							  self assert: token value equals: snbin].
]

{ #category : #'scanBinary:' }
TPRBScannerTest >> testScanBinaryWithLitteralTokenWithNonBinaryValues [
"This test is aimed at verifying the production a litteral token with the right properties when 	scanning binary character.
	
	binaryCharacter ::= '!' | '%' | '&' | '*' | '+' | ',' | '/' | '<' | '=' | '>' | '?' | '@' | '\' | 							 							 '~' | '|' | '-'"
	| token nonbinary |
	nonbinary := #(#('1' '1') #('p' 'p') #('^' '^') #('1alpha' '1') #('11' '1') #('a b' 'a')).
	"Test the creation of a literal for every binary."
	nonbinary do: [:snbin | token := (self buildScannerForText: (snbin first)) scanBinary: 																											 					                                                                     TPRBLiteralToken.
							  self assert: token isLiteralToken.
							  self assert: token value equals: (snbin last)].
]

{ #category : #'scanError:' }
TPRBScannerTest >> testScanErrorWithMultipleCharacters [
	"This test is aimed at verifying that the value of the token is only the first character of the 	string."
	| token example |
	"List of strings to test the scanner on paired with the expected value."
	example := #(#('1a+' '1') #('1+a' '1') #('a1+' 'a') #('+1' '+') #('éa' 'é') #('a$' 'a')).
	example do: [:ex | token := (self buildScannerForText: ex first) scanError: 'Generic error message'.
	                             self assert: token isError.
	                             self assert: token value equals: ex last.
										 self assert: token cause equals: 'Generic error message'].
]

{ #category : #'scanError:' }
TPRBScannerTest >> testScanErrorWithSinglecharacter [
	"This test is aimed at checking on the production of the error token."
	| token example |
	example := #('1' 'a' '+' 'é' '$').
	"Test the creation of an for every type of character."
	example do: [:ex | token := (self buildScannerForText: ex) scanError: 'Generic error message'.
	                             self assert: token isError.
	                             self assert: token value equals: ex.
										 self assert: token cause equals: 'Generic error message'].
]

{ #category : #scanIdentifierOrKeyword }
TPRBScannerTest >> testScanIdentifierOrKeywordAsKeyword [
	"This test is aimed at verifying if a keyword followed by an argument is scanned, only the keyword 	     will be taken as value."
	| token str |
	str := #(#('alpha: arg' 'alpha:') #(': arg' ':') #('12: arg' '12:')
		      #('alpha12: arg' 'alpha12:') #('12alpha: arg' '12alpha:')).
	"Test the creation of a literal for every binary."
	str do: [:s | token := (self buildScannerForText: (s first)) scanIdentifierOrKeyword.
							  self assert: token isKeyword.
							  self assert: token value equals: (s last)].
]

{ #category : #scanIdentifierOrKeyword }
TPRBScannerTest >> testScanIdentifierOrKeywordAsMultipleKeywords [
	"This test is aimed at verifying if scanning multiple keywords gives the right token with the right 	 	 values."
	"| token str |
	str := #(#('alpha: arg beta: arg2' 'alpha:beta:') 
		      #('1alpha: arg 2beta1: arg2 3gamma: arg3' '1alpha:2beta:3gamma')
		      #('alpha1: beta1: arg2 alpha2: arg2 beta2: arg' 'alpha1:beta1:alpha2:beta2:')).
	str do: [:s | token := (self buildScannerForText: (s first)) scanIdentifierOrKeyword.
							  self assert: token isMultiKeyword.
							  self assert: token value equals: (s last)]."
						
	"Test delayed as it is using the start and stop positions which are not initialized."
]

{ #category : #scanIdentifierOrKeyword }
TPRBScannerTest >> testScanIdentifierOrKeywordIdentifier [
	"This test is aimed at verifying the creation of the special identifiers true, false, nil."
	| token |
	token := (self buildScannerForText: 'identifier') scanIdentifierOrKeyword.
				 self assert: token isIdentifier.
				 self assert: token value equals:'identifier'.
	token := (self buildScannerForText: '123456') scanIdentifierOrKeyword.
				 self assert: token isIdentifier.
				 self assert: token value equals: '123456'.
	token := (self buildScannerForText: '1d3nt1f13r') scanIdentifierOrKeyword.
				 self assert: token isIdentifier.
				 self assert: token value equals: '1d3nt1f13r'.
]

{ #category : #scanKeyword }
TPRBScannerTest >> testScanKeywordWithArguments [
	"This test is aimed at verifying if a keyword followed by an argument is scanned, only the keyword 	     will be taken as value."
	| token str |
	str := #(#('alpha: arg' 'alpha:') #(': arg' ':') #('12: arg' '12:')
		      #('alpha12: arg' 'alpha12:') #('12alpha: arg' '12alpha:')).
	"Test the creation of a literal for every binary."
	str do: [:s | token := (self buildScannerForText: (s first)) scanName. 
			        token := token scanKeyword.
							  self assert: token isKeyword.
							  self assert: token value equals: (s last)].
]

{ #category : #scanKeyword }
TPRBScannerTest >> testScanKeywordWithoutArguments [
	"This test is aimed at verifying if a keyword followed by an argument is scanned, only the keyword 	     will be taken as value."
	| token str |
	str := #('alpha:' ':' '12:' 'alpha12:' '12alpha:').
	"Test the creation of a literal for every binary."
	str do: [:s | token := (self buildScannerForText: s) scanName. 
			        token := token scanKeyword.
							  self assert: token isKeyword.
							  self assert: token value equals: s].
]

{ #category : #scanLiteral }
TPRBScannerTest >> testScanLiteralBeginningWithAlphabetic [
	""
	| token |
	token := (self buildScannerForText: '#alpha') scanLiteral.
	self assert: token isLiteralToken.
	self assert: token value equals: #alpha.
	

]

{ #category : #scanLiteral }
TPRBScannerTest >> testScanLiteralBeginningWithKeywords [
	""
	| token |
	token := (self buildScannerForText: '#alpha:') scanLiteral.
			self assert: token isLiteralToken.
			self assert: token value equals: #alpha:.
			
	token := (self buildScannerForText: '#alpha:beta:gamma:') scanLiteral.
			self assert: token isLiteralToken.
			self assert: token value equals: #'alpha:beta:gamma:'.
	
	token := (self buildScannerForText: '#alpha:beta:gamma:arg') scanLiteral.
			self assert: token isLiteralToken.
			self assert: token value equals: #'alpha:beta:gamma:arg'.
	
	

]

{ #category : #scanLiteralCharacter }
TPRBScannerTest >> testScanLiteralCharacterWithAnyCharacterType [
	"Literal character should be introduced by $"
	| token characters |
	"Each string to scan paired with their expected value"
	characters := #(#('$a' $a) #('$1' $1) #('$é' $é) #('$^' $^) #('$+' $+)).
	
	characters do: [:chara | token := (self buildScannerForText: (chara first)) scanLiteralCharacter.
											self assert: token isLiteralToken.
											self assert: token value equals: (chara last)].
]

{ #category : #scanLiteralCharacter }
TPRBScannerTest >> testScanLiteralCharacterWithMultipleCharacters [
	"Literal character should be introduced by $. Only one character should be scanned"
	| token characters |
	"Each string to scan paired with their expected value"
	characters := #(#('$alpha' $a) #('$1234' $1) #('$ép12' $é) #('$^a1' $^) #('$+3a' $+)).
	
	characters do: [:chara | token := (self buildScannerForText: (chara first)) scanLiteralCharacter.
											self assert: token isLiteralToken.
											self assert: token value equals: (chara last)].
]

{ #category : #scanLiteralCharacter }
TPRBScannerTest >> testScanLiteralCharacterWithoutSpecialCharacter [
	"Literal character should be introduced by $"
	| token |
	token := (self buildScannerForText: 'a') scanLiteralCharacter.
			self assert: token isError.
			self assert: token value equals: ''.
			self assert: token cause equals: 'A Character was expected'.
]

{ #category : #scanLiteral }
TPRBScannerTest >> testScanLiteralDoNotAllowDigits [
	""
	| token |
	token := (self buildScannerForText: '#1alpha') scanLiteral.
			self assert: token isError.
			self assert: token value equals: '1'.
			self assert: token cause equals: 'Expecting a literal type'.
]

{ #category : #scanLiteral }
TPRBScannerTest >> testScanLiteralDoNotAllowSpaces [
	""
	| token |
	token := (self buildScannerForText: '# alpha') scanLiteral.
			self assert: token isError.
			self assert: token value equals: ' '.
			self assert: token cause equals: 'Expecting a literal type'.
]

{ #category : #scanLiteralString }
TPRBScannerTest >> testScanLiteralStringUnfinishedRaiseError [
	"Literal character should be introduced by '."
	| token |
	token := (self buildScannerForText: '''alpha') scanLiteralString.
			self assert: token isError.
			self assert: token value equals: 'alpha'.
		   self assert: token cause equals: 'Unmatched '' in string literal.'.
		
	token := (self buildScannerForText: '''123') scanLiteralString.
			self assert: token isError.
			self assert: token value equals: '123'.
		   self assert: token cause equals: 'Unmatched '' in string literal.'.
]

{ #category : #scanName }
TPRBScannerTest >> testScanNameDoesNothingWhenWrongCharacter [
	"This test is for verifying that nothing is made when the current character is not of type 	   	 	 			 	 alphabetic or digit."
	| scanner nonAlphaNonDigit |
	nonAlphaNonDigit := #('^' '=' '^ aplha' '+ 23' '-21' 'alpha+' '12-').
	nonAlphaNonDigit do: [:tok | scanner := (self buildScannerForText: tok) scanName. 
							  			  self deny: scanner atEnd].
]

{ #category : #scanName }
TPRBScannerTest >> testScanNameWithRightCharacterScanEverything [
	"This test is for verifying that nothing is made when the current character is not of type 	   	 	 			 	 alphabetic or digit."
	| scanner nonAlphaNonDigit |
	nonAlphaNonDigit := #('1' 'a' '1a2' 'a1b' 'aa' 'bb').
	nonAlphaNonDigit do: [:tok | scanner := (self buildScannerForText: tok) scanName. 
							  			  self assert: scanner atEnd].
]

{ #category : #scanSpecialCharacter }
TPRBScannerTest >> testScanSpecialCharacterWithAnyOtherCharacter [
	""
	| token character |
	"Each string to scan paired with their expected value"
	character := #(#('a' $a) #('1' $1) #('é' $é) #('^' $^) #('+' $+)).
	
	character do: [:chara | token := (self buildScannerForText: (chara first)) scanSpecialCharacter.
										self assert: token isSpecial.
										self assert: token value equals: (chara last).].
]

{ #category : #scanSpecialCharacter }
TPRBScannerTest >> testScanSpecialCharacterWithAnyOtherCharacters [
	""
	| token characters |
	"Each string to scan paired with their expected value"
	characters := #(#('ab' $a) #('12' $1) #('éà' $é) #('^`' $^) #('+=' $+)).
	
	characters do: [:chara | token := (self buildScannerForText: (chara first)) scanSpecialCharacter.
										self assert: token isSpecial.
										self assert: token value equals: (chara last).].
]

{ #category : #scanSpecialCharacter }
TPRBScannerTest >> testScanSpecialCharacterWithAssignment [
	""
	| token |
	token := (self buildScannerForText: ':=') scanSpecialCharacter.
			self assert: token isAssignment.
]

{ #category : #scanSpecialCharacter }
TPRBScannerTest >> testScanSpecialCharacterWithSimpleColon [
	""
	| token |
	token := (self buildScannerForText: ':') scanSpecialCharacter.
			self assert: token isSpecial.
]

{ #category : #scanSymbol }
TPRBScannerTest >> testScanStringSymbolWithAlphabeticOrDigitOrColonCharacters [
	"Gives empty Literal Tokens."
	| token characters |
	characters := #('alpha' 'alph:' 'alph4' 'alp:a' ':lpha' ':lph4' 'a1:h:b3t:' ).
	
	characters do: [:chara | token := (self buildScannerForText: chara) scanSymbol.
										self assert: token isLiteralToken.
										self assert: token value equals: chara.].
]

{ #category : #scanSymbol }
TPRBScannerTest >> testScanStringSymbolWithNonAlphabeticNonColonFirstCharacters [
	"Gives empty Literal Tokens."
	| token characters |
	characters := #('1' '^`' '12' '+' '=+').
	
	characters do: [:chara | token := (self buildScannerForText: chara) scanSymbol.
										self assert: token isLiteralToken.
										self assert: token value equals: ''.].
]

{ #category : #scanSymbol }
TPRBScannerTest >> testScanStringSymbolWithNonAlphabeticNonDigitCharacters [
	"Gives empty Literal Tokens."
	| token characters |
	"Each string to scan paired with their expected value"
	characters := #('1' '^`' '12' '+' '=+').
	
	characters do: [:chara | token := (self buildScannerForText: chara) scanSymbol.
										self assert: token isLiteralToken.
										self assert: token value equals: ''.].
]

{ #category : #scanSymbol }
TPRBScannerTest >> testScanStringSymbolWithNonAlphabeticNonDigitCharactersBegginingWithColon [
	"Gives empty Literal Tokens."
	| token characters |
	"Each string to scan paired with their expected value"
	characters := #(':=' ':^`' ':12' ':+' ':=+').
	
	characters do: [:chara | token := (self buildScannerForText: chara) scanSymbol.
										self assert: token isLiteralToken.
										self assert: token value equals: ':'.].
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
