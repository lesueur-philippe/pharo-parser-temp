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
TPRBScannerTest >> testNextAcceptLiteralArrayWithBracket [
	"Note: RBScanner only spots the beginning of the array."
	| scanner token |
	
	scanner := self buildScannerForText: '#['.
	token := scanner next.
	self assert: token isLiteralArrayToken.
]

{ #category : #testLiteral }
TPRBScannerTest >> testNextAcceptLiteralArrayWithParenthesis [
	"Note: RBScanner only spots the beginning of the array."
	| scanner token |
	scanner := self buildScannerForText: '#('.
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
	scanner := self buildScannerForText: String space, String space,'firstToken'.
	token := scanner next.
	self assert: token comments isNil.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextDoesNotAddTabToComments [
	| scanner token |
	scanner := self buildScannerForText: String tab, 'firstToken'.
	token := scanner next.
	self assert: token comments isNil.
	
]

{ #category : #testError }
TPRBScannerTest >> testNextDollarSignCanNotStandAlone [
	| scanner token |
	scanner := self buildScannerForText: '$'.
	token := scanner next.
	self assert: token isError.
	self assert: token value equals: ''.
	self assert: token cause equals: 'A Character was expected'.
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextEOFContainsCommentsWhenNoOtherToken [
	| scanner token |
	scanner := self buildScannerForText: '"start comment"'.
	
	token := scanner next.
	self assert: token isEOF.
	self assert: token comments equals:(OrderedCollection newFrom: {(1 to: 15)}).
	self assert: token start equals: 16.
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextFirstTokenContainsFollowingComments [ 
	| scanner token |
	scanner := self buildScannerForText: 'firstToken "following comment"'.
	
	"The first token 'firstToken' takes the previous comment and the following one"
	token := scanner next.
	self assert: token comments equals: (OrderedCollection newFrom: {(12 to: 30)}).
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextFirstTokenContainsPrecedingComments [
	| scanner token |
	scanner := self buildScannerForText: '"start comment"firstToken'.
	token := scanner next.
	self assert: token comments equals: (OrderedCollection newFrom: {(1 to: 15)}) .
	
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
	self assert: token value equals: 3.
	
	scanner := self buildScannerForText: '3. 2'.
	token := scanner next.
	self assert: token value equals: 3.
]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextFloatNumbersHasFloatValue [
	
	| scanner token |
	scanner := self buildScannerForText: '3.2'.
	token := scanner next.
	self assert: token value equals: 3.2.
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
	
	"Scanner doesn't recognise + as the beginning of an Identifier."
	scanner := self buildScannerForText: '+firstToken'.
	token := scanner next.
	self assert: token isBinary.
	self assert: token value equals: '+'.
	
	"Scanner separate them into 2 tokens with the second corresponding to an Identifier."
	token := scanner next.
	self assert: token isIdentifier.
	self assert: token value equals: 'firstToken'.
]

{ #category : #testIdentifiers }
TPRBScannerTest >> testNextIdentifierCanNotBeginWithDigit [
	| scanner token |
	scanner := self buildScannerForText: '123firstToken'.
	
	"Scanner doesn't recognise 123 as the beginning of an Identifier."
	token := scanner next.
	self assert: token isNumberLiteralToken.
	self assert: token value equals: 123.
	
	"Scanner separate them into 2 tokens with the second corresponding to an Identifier."
	token := scanner next.
	self assert: token isIdentifier.
	self assert: token value equals: 'firstToken'.
	
]

{ #category : #testIdentifiers }
TPRBScannerTest >> testNextIdentifierCanNotEndWithBinary [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken+'.
	
	"The first token is still recognised as Identifier but the + insn't taken into account."
	token := scanner next.
	self assert: token isIdentifier.
	self assert: token value equals: 'firstToken'.
	
	token := scanner next.
	self assert: token isBinary.
	self assert: token value equals: '+'.
]

{ #category : #testIdentifiers }
TPRBScannerTest >> testNextIdentifierCanNotHaveBinary [
	| scanner token |
	scanner := self buildScannerForText: 'first+Token'.
	
	token := scanner next.
	self assert: token isIdentifier.
	self assert: token value equals: 'first'.
	
	token := scanner next.
	self assert: token isBinary.
	self assert: token value equals: '+'.
	
	token := scanner next.
	self assert: token isIdentifier.
	self assert: token value equals: 'Token'.
	
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
	self assert: token isSpecial.
	self assert: token value equals: $^.
	
	scanner := self buildScannerForText: '$firstToken:'.
	token := scanner next.
	self assert: token isLiteralToken.
	self assert: token value equals: $f.
	
	scanner := self buildScannerForText: '\firstToken:'.
	token := scanner next.
	self assert: token isBinary.
	self assert: token value equals: '\'.
	
	scanner := self buildScannerForText: '`firstToken:'.
	token := scanner next.
	self assert: token isError.
	self assert: token value equals: '`'.
	
	
	
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
	
	"The scanner doesn't understand it as a keyword."
	token := scanner next.
	self assert: token isBinary.
	self assert: token value equals: '+-='.
	
	"The colon is therefor identified as a special character as it stands alone."
	token := scanner next.
	self assert: token isSpecial.
	self assert: token value equals: $:.
	
	
]

{ #category : #testKeyword }
TPRBScannerTest >> testNextKeywordCanNotBeFullDigit [
	| scanner token |
	scanner := self buildScannerForText: '123:'.
	
	"The scanner doesn't understand it as a keyword."
	token := scanner next.
	self assert: token isNumberLiteralToken.
	self assert: token value equals: 123.
	
	"The colon is therefor identified as a special character as it stands alone."
	token := scanner next.
	self assert: token isSpecial.
	self assert: token value equals: $:.
	
]

{ #category : #testKeyword }
TPRBScannerTest >> testNextKeywordCanNotBeginWithBinary [
	| scanner token |
	scanner := self buildScannerForText: '+alpha:'.
	
	token := scanner next.
	self assert: token isBinary.
	self assert: token value equals: '+'.
	
	token := scanner next.
	self assert: token isKeyword.
	self assert: token value equals: 'alpha:'.
	
]

{ #category : #testKeyword }
TPRBScannerTest >> testNextKeywordCanNotBeginWithDigit [
	| scanner token |
	scanner := self buildScannerForText: '123alpha:'.
	
	token := scanner next.
	self assert: token isNumberLiteralToken.
	self assert: token value equals: 123.
	
	token := scanner next.
	self assert: token isKeyword.
	self assert: token value equals: 'alpha:'.
	
	
]

{ #category : #testKeyword }
TPRBScannerTest >> testNextKeywordStopAtColon [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken:'.
	token := scanner next.
	self assert: token isKeyword.
	self assert: token stop equals: 11.
	
	scanner := self buildScannerForText: 'first:Token'.
	token := scanner next.
	self assert: token isKeyword.
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
	self assert: token value equals: '1'.
	self assert: token cause equals: 'Expecting a literal type'.
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

{ #category : #testLiteral }
TPRBScannerTest >> testNextLiteralWithMultipleHashtagTrimThem [
	| scanner token |
	scanner := self buildScannerForText: '########literal'.
	token := scanner next.
	self assert: token value equals: 'literal'.
]

{ #category : #testNumberLiteral }
TPRBScannerTest >> testNextNegativeNumberCanNotHaveSpaces [
	
	| scanner token |
	scanner := self buildScannerForText: '- 12'.
	
	token := scanner next.
	self assert: token isBinary.
	self assert: token value equals: '-'.
	
	token := scanner next.
	self assert: token isNumberLiteralToken.
	self assert: token value equals: 12.
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

{ #category : #testSeparators }
TPRBScannerTest >> testNextSecondTokenDoesNotConsumePrecedingComment [
	| scanner token |
	scanner := self buildScannerForText: 
	'firstToken 
   "inbetween comment" secondToken
	"second inbetween" "multiple comments"'.
	"Expecting all spaces and line breaks to be trimmed."
	
	"The first token 'firstToken' takes the previous comment and the following one"
	token := scanner next.
	"The next token 'secondToken' takes the following 2 comments."
	token := scanner next.
	self assert: token comments equals: (OrderedCollection newFrom: {(49 to: 66). (68 to: 86)}).
	self assert: token start equals: 36.
]

{ #category : #testSpecialCharacters }
TPRBScannerTest >> testNextSpecialCharactereCanBeAssignement [
	| scanner token |
	scanner := self buildScannerForText: ':='.
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
	scanner := self buildScannerForText: String space, String space, 'firstToken'.
	token := scanner next.
	self assert: token value equals: 'firstToken'.
	self assert: token start equals: 3.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTokenStartAfterTab [
	"Tests that the next token adapts starting point according to it."
	| scanner token |
	scanner := self buildScannerForText: String tab, 'firstToken'.
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
	scanner := self buildScannerForText: String space, String space, 'firstToken'.
	token := scanner next.
	self assert: token value equals: 'firstToken'.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsBeginningTab [
	| scanner token |
	scanner := self buildScannerForText: String tab, 'firstToken'.
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
	scanner := self buildScannerForText: 'firstToken', String space, String space.
	scanner next.
	token := scanner next.
	self assert: token isEOF.
	self assert: token start equals: 13.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsEndTab [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken', String tab.
	scanner next.
	token := scanner next.
	self assert: token isEOF.
	self assert: token start equals: 12.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsMiddleComment [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken"middle comment"secondToken'.
	scanner next.
	token := scanner next.
	self assert: token isIdentifier.
	self assert: token start equals: 27.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsMiddleLineBreak [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken
secondToken'.
	scanner next.
	token := scanner next.
	self assert: token isIdentifier.
	self assert: token start equals: 12.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsMiddleSpaces [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken',String space, String space,'secondToken'.
	scanner next.
	token := scanner next.
	self assert: token isIdentifier.
	self assert: token start equals: 13.
	
]

{ #category : #testSeparators }
TPRBScannerTest >> testNextTrimsMiddleTab [
	| scanner token |
	scanner := self buildScannerForText: 'firstToken', String tab, 'secondToken'.
	scanner next.
	token := scanner next.
	self assert: token isIdentifier.
	self assert: token start equals: 12.
	
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
