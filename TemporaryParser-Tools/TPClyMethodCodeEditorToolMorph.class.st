Class {
	#name : #TPClyMethodCodeEditorToolMorph,
	#superclass : #TPClyMethodEditorToolMorph,
	#instVars : [
		'editingMethod'
	],
	#category : #'TemporaryParser-Tools'
}

{ #category : #activation }
TPClyMethodCodeEditorToolMorph class >> browserTabActivation [
	"This declaration specifies that in any browser when methods are selected, a method editor will be available in a tab."
	
	<classAnnotation>
	^ClyTabActivationStrategy for: ClyMethod asCalypsoItemContext
]

{ #category : #testing }
TPClyMethodCodeEditorToolMorph class >> shouldBeActivatedInContext: aBrowserContext [
	^aBrowserContext isMethodSelected
]

{ #category : #operations }
TPClyMethodCodeEditorToolMorph >> applyChanges [
	| selector methodClass currentMethod |
	methodClass := self chooseClassForNewMethodIfNone: [^false].
	selector := methodClass compile: self pendingText classified: editingMethod protocol notifying: textMorph.
	selector ifNil: [^false ].
	currentMethod := methodClass >> selector.
	self tagAndPackageEditingMethod: currentMethod.
	self switchToMethod: currentMethod.
	^true
]

{ #category : #building }
TPClyMethodCodeEditorToolMorph >> applyDecorations [
	| hasEdits |
	hasEdits := textMorph hasUnacceptedEdits.
	textMorph segments copy do: #delete.	
	"literal methods do not need ot be stylized and this is an operation that can take 
	 a lot of time, we will skip it when it is the case"
	editingMethod isLiteralMethod ifFalse: [ 
		TPIconStyler styleText: textModel withAst: editingMethod astForStylingInCalypso ].	
	textMorph hasUnacceptedEdits: hasEdits.
	
	super applyDecorations.
	
	browser decorateMethodEditor: self
]

{ #category : #controlling }
TPClyMethodCodeEditorToolMorph >> attachToSystem [

	browser system 
		when: (ClyMethodChange of: self editingMethod)
		send: #triggerUpdate
		to: self
]

{ #category : #testing }
TPClyMethodCodeEditorToolMorph >> belongsToCurrentBrowserContext [
	^browser methodSelection isEmpty 
		ifTrue: [ browser isClassSelected: self editingMethod origin ]
		ifFalse: [ browser isMethodSelected: self editingMethod]
]

{ #category : #testing }
TPClyMethodCodeEditorToolMorph >> belongsToRemovedBrowserContext [
	| actualMethod |
	super belongsToRemovedBrowserContext ifTrue: [ ^true ].
	
	actualMethod := editingMethod origin 
		localMethodNamed: editingMethod selector ifAbsent: [^true].
		
	self editingMethod: actualMethod.
	^false
]

{ #category : #building }
TPClyMethodCodeEditorToolMorph >> buildLeftSideBar [
	super buildLeftSideBar.

	self leftSideBar enableMouseCommands: CmdTextLeftBarClickActivation withContextFrom: self
]

{ #category : #operations }
TPClyMethodCodeEditorToolMorph >> cancelChanges [
	self updateMethodTagsAndPackage.
	
	super cancelChanges
]

{ #category : #contexts }
TPClyMethodCodeEditorToolMorph >> createCommandContextForCursorAt: aCursorPoint [

	| sourceNode |
	sourceNode := self findSourceNodeAt: aCursorPoint.
	
	^ClyMethodSourceCodeContext for: self selectedNode: sourceNode
]

{ #category : #contexts }
TPClyMethodCodeEditorToolMorph >> createTextContext [
	^self selectedSourceNode
		ifNil: [super createTextContext]
		ifNotNil: [ :astNode | ClyMethodSourceCodeContext for: self selectedNode: astNode]
]

{ #category : #building }
TPClyMethodCodeEditorToolMorph >> decorateContainerTab [
	| title |
	super decorateContainerTab.
	title := editingMethod selector.

	editingMethod origin isClassSide ifTrue: [ 
		title := title asText allBold ].

	containerTab label: title
]

{ #category : #initialization }
TPClyMethodCodeEditorToolMorph >> defaultIconName [
	^#scriptManagerIcon
]

{ #category : #controlling }
TPClyMethodCodeEditorToolMorph >> detachFromSystem [

	browser system unsubscribe: self
]

{ #category : #accessing }
TPClyMethodCodeEditorToolMorph >> editingMethod [
	^editingMethod 
]

{ #category : #accessing }
TPClyMethodCodeEditorToolMorph >> editingMethod: aMethod [
	editingMethod := aMethod
]

{ #category : #accessing }
TPClyMethodCodeEditorToolMorph >> editingText [
	^editingMethod sourceCode
]

{ #category : #accessing }
TPClyMethodCodeEditorToolMorph >> extendingPackage: aPackage [
	super extendingPackage: aPackage.
	
	self hasUnacceptedEdits ifFalse: [self packageEditingMethod: editingMethod]
]

{ #category : #'selecting text' }
TPClyMethodCodeEditorToolMorph >> findAnySelectorInSourceCode: selectors [

	| foundSelector foundNode positions ast |
	ast := editingMethod astForStylingInCalypso.
	foundNode := ast sendNodes 
		detect: [:each | selectors includes: (foundSelector := each selector) ] 
		ifNone: [ 
			ast allChildren
				detect: [:each | each isLiteralNode and: [ selectors includes: each value ]]
				ifFound: [:literal | ^ literal sourceInterval ].
			^0 to: -1].
		
	positions := foundNode keywordsPositions.
	^positions first to: positions last + foundSelector keywords last size - 1.
]

{ #category : #'selecting text' }
TPClyMethodCodeEditorToolMorph >> findAnySelectorOrString: selectors inSourceCode: aText [

	^(self findAnySelectorInSourceCode: selectors) 
		ifEmpty: [ self findAnyString: selectors in: aText ]
]

{ #category : #'selecting text' }
TPClyMethodCodeEditorToolMorph >> findAnyVariableInSourceCode: varNames [
	| foundNode |
	
	foundNode := editingMethod variableNodes 
		detect: [ :each | varNames includes: each name ] ifNone: [ ^0 to: -1 ].
		
	^foundNode start to: foundNode stop
]

{ #category : #contexts }
TPClyMethodCodeEditorToolMorph >> findSourceNodeAt: aCursorPoint [
	| startPosition endPosition line lineIndex  selection ast |
	lineIndex := self leftSideBar lineIndexForPoint: aCursorPoint. "strangely we can't ask text morph about it"
	line := textMorph paragraph lines at: lineIndex.	
	startPosition := line first.
	endPosition := line last.

	selection := self selectedTextInterval.
	selection ifNotNil: [ 
		selection first >= startPosition & (selection last <= endPosition) ifTrue: [ 
			startPosition := selection first max: 1.
			endPosition := selection last min: self editingText size]].
	
	ast := self editingMethod astForStylingInCalypso.	
	^(ast bestNodeFor: (startPosition to: endPosition)) ifNil: [ ast ]
]

{ #category : #'as yet unclassified' }
TPClyMethodCodeEditorToolMorph >> getASTFor: aString [
	| compilationContext compilationContextOptions ast |
	ast :=TPRBParser parseFaultyMethod: aString.
	compilationContext := OpalCompiler new compilationContext.
	compilationContext class: self methodClass.
	compilationContextOptions := CompilationContext defaultOptions copy.
	compilationContextOptions add: #optionSkipSemanticWarnings.
	compilationContext setOptions: compilationContextOptions.
	compilationContext semanticAnalyzerClass new
 	compilationContext: compilationContext;
  	analyze: ast.
	^ ast
]

{ #category : #testing }
TPClyMethodCodeEditorToolMorph >> isCommandAvailable: aCommand [ 

	^ aCommand canBeExecutedInCodeMethodEditor: self
]

{ #category : #testing }
TPClyMethodCodeEditorToolMorph >> isSimilarTo: anotherBrowserTool [
	(super isSimilarTo: anotherBrowserTool) ifFalse: [ ^false ].
	
	^editingMethod == anotherBrowserTool editingMethod or: 
		[ editingMethod selector == anotherBrowserTool editingMethod selector
			and: [ editingMethod origin == anotherBrowserTool editingMethod origin ] ]
]

{ #category : #accessing }
TPClyMethodCodeEditorToolMorph >> methodClass [

	self belongsToCurrentBrowserContext ifFalse: [ ^editingMethod origin ].
	
	^browser chooseClassForEditorOfMethod: editingMethod
]

{ #category : #accessing }
TPClyMethodCodeEditorToolMorph >> methodTags: tagsArray [
	super methodTags: tagsArray.
	
	self hasUnacceptedEdits ifFalse: [ self tagEditingMethod: editingMethod]
]

{ #category : #testing }
TPClyMethodCodeEditorToolMorph >> modifiesExtension [
	^editingMethod isExtension 
		ifTrue: [ extendingPackage ~~ editingMethod package  ]
		ifFalse: [ extendingPackage notNil and: [extendingPackage ~~ self methodClass package] ]
]

{ #category : #printing }
TPClyMethodCodeEditorToolMorph >> printContext [
	^self editingMethod printSystemPath
]

{ #category : #'selecting text' }
TPClyMethodCodeEditorToolMorph >> selectAnySelector: selectors [

	textMorph setSelection: (self findAnySelectorInSourceCode: selectors)
]

{ #category : #'selecting text' }
TPClyMethodCodeEditorToolMorph >> selectAnyVariable: varNames [

	textMorph setSelection: (self findAnyVariableInSourceCode: varNames)
]

{ #category : #'selecting text' }
TPClyMethodCodeEditorToolMorph >> selectSourceNode: anASTNode [

	textMorph setSelection: anASTNode sourceInterval
]

{ #category : #'selecting text' }
TPClyMethodCodeEditorToolMorph >> selectVariableNamed: varName [

	self selectAnyVariable: { varName }
]

{ #category : #accessing }
TPClyMethodCodeEditorToolMorph >> selectedSourceNode [

	| selectedInterval |
	selectedInterval := self selectedTextInterval.
	^(editingMethod astForStylingInCalypso bestNodeFor: selectedInterval)
		ifNil: [ editingMethod astForStylingInCalypso ]
]

{ #category : #initialization }
TPClyMethodCodeEditorToolMorph >> setUpModelFromContext [
	super setUpModelFromContext.

	editingMethod := context lastSelectedMethod
]

{ #category : #initialization }
TPClyMethodCodeEditorToolMorph >> setUpParametersFromModel [
	super setUpParametersFromModel.

	self updateMethodTagsAndPackage
]

{ #category : #initialization }
TPClyMethodCodeEditorToolMorph >> setUpTargetClasses [

	targetClasses := browser chooseClassesForNewMethod: editingMethod
]

{ #category : #operations }
TPClyMethodCodeEditorToolMorph >> switchToMethod: aMethod [
	self detachFromSystem.
	editingMethod := aMethod.
	self attachToSystem.	
	browser selectMethod: editingMethod.
	self update.
]

{ #category : #'events handling' }
TPClyMethodCodeEditorToolMorph >> textChanged: aTextChanged [
	| ast |
	super textChanged: aTextChanged.
	ast := self getASTFor: self pendingText.
	textMorph segments copy do: #delete.
	TPIconStyler styleText: textModel withAst: ast.
]

{ #category : #operations }
TPClyMethodCodeEditorToolMorph >> toggleExtendingPackage [
	super toggleExtendingPackage.
	
	self hasUnacceptedEdits ifFalse: [self packageEditingMethod: editingMethod]
]

{ #category : #updating }
TPClyMethodCodeEditorToolMorph >> update [

	editingMethod := editingMethod origin 
		localMethodNamed: editingMethod selector ifAbsent: [^self].
	
	super update.
	
	self formatTextIfNeeded.
	
]

{ #category : #updating }
TPClyMethodCodeEditorToolMorph >> updateMethodTagsAndPackage [
	
	methodTags := editingMethod tags reject: [ :each | each beginsWith: '*' ].	
	extendingPackage := editingMethod isExtension ifTrue: [ editingMethod package ] ifFalse: [ nil ].
]
