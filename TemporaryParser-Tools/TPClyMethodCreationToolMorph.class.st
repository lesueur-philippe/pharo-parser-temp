Class {
	#name : #TPClyMethodCreationToolMorph,
	#superclass : #TPClyMethodEditorToolMorph,
	#instVars : [
		'methodClass',
		'state'
	],
	#category : #'TemporaryParser-Tools'
}

{ #category : #testing }
TPClyMethodCreationToolMorph class >> shouldBeActivatedInContext: aBrowserContext [
	^aBrowserContext isClassSelected
]

{ #category : #accessing }
TPClyMethodCreationToolMorph class >> tabOrder [
	^ 1000
]

{ #category : #accessing }
TPClyMethodCreationToolMorph >> activationPriority [
	"We want creation tool be active by default only when user select method group.
	Instead when user select class creation tool should not be activated"
	^browser methodGroupSelection isEmpty 
		ifTrue: [ 0]
		ifFalse: [ ClyClassDefinitionEditorToolMorph tabOrder + 1 ]
]

{ #category : #operations }
TPClyMethodCreationToolMorph >> applyChanges [
	| newMethod selector selectedClass |
	selectedClass := self chooseClassForNewMethodIfNone: [^false].
	
	selector := methodTags 
		ifEmpty: [ selectedClass compile: self pendingText asString notifying: textMorph]
		ifNotEmpty: [
			selectedClass compile: self pendingText asString classified: methodTags anyOne notifying: textMorph].
			
	selector ifNil: [ ^false ].
	
	newMethod := selectedClass >> selector.
	methodTags ifEmpty: [ 
		MethodClassifier classify: newMethod.
		methodTags := newMethod tags ].
	self tagAndPackageEditingMethod: newMethod.
	
	self removeFromBrowser.
	browser tabManager desiredSelection: {TPClyMethodCodeEditorToolMorph}.
	browser selectMethod: newMethod.
	^true
]

{ #category : #testing }
TPClyMethodCreationToolMorph >> belongsToCurrentBrowserContext [
	^browser isClassSelected: methodClass instanceSide
]

{ #category : #initialization }
TPClyMethodCreationToolMorph >> decorateContainerTab [
	| title |
	
	super decorateContainerTab.
	
	browser metaLevelScope == ClyClassSideScope ifFalse: [ ^ self ].
	 
	title := self defaultTitle asText allBold. 
	containerTab label: title
]

{ #category : #initialization }
TPClyMethodCreationToolMorph >> defaultIconName [
	^#add
]

{ #category : #initialization }
TPClyMethodCreationToolMorph >> defaultTitle [

	^browser metaLevelScope defaultName capitalized, ' AST method'
]

{ #category : #accessing }
TPClyMethodCreationToolMorph >> editingText [
	^methodClass sourceCodeTemplate
]

{ #category : #initialization }
TPClyMethodCreationToolMorph >> initialize [
	super initialize.
	state := false.
]

{ #category : #testing }
TPClyMethodCreationToolMorph >> isSimilarTo: anotherBrowserTool [
	(super isSimilarTo: anotherBrowserTool) ifFalse: [ ^false ].
	
	^methodClass == anotherBrowserTool methodClass
		and: [ methodTags = anotherBrowserTool methodTags 
				and: [ extendingPackage = anotherBrowserTool extendingPackage ] ]
]

{ #category : #accessing }
TPClyMethodCreationToolMorph >> methodClass [
	^methodClass
]

{ #category : #testing }
TPClyMethodCreationToolMorph >> modifiesExtension [
	"I create new method. So I am not modify anything"
	^false
]

{ #category : #printing }
TPClyMethodCreationToolMorph >> printContext [
	^methodClass printSystemPath, ' / ' , methodClass name
]

{ #category : #controlling }
TPClyMethodCreationToolMorph >> restoreBrowserState [

	browser selectClass: methodClass
]

{ #category : #accessing }
TPClyMethodCreationToolMorph >> selectedSourceNode [

	| selectedInterval |
	selectedInterval := self selectedTextInterval.
	^(methodClass astForStylingInCalypso bestNodeFor: selectedInterval)
		ifNil: [ methodClass astForStylingInCalypso ]
]

{ #category : #initialization }
TPClyMethodCreationToolMorph >> setUpModelFromContext [
	| selectedGroup |
	super setUpModelFromContext.

	methodClass := context selectedClassSide.
	context isMethodGroupSelected ifFalse: [ ^self].
	selectedGroup := context lastSelectedMethodGroup.
	(selectedGroup isKindOf: ClyExternalPackageMethodGroup) ifTrue: [ 
		^extendingPackage := selectedGroup package].
	(selectedGroup isKindOf: ClyTaggedMethodGroup) ifTrue: [ 
		^methodTags := {selectedGroup tag}]
]

{ #category : #initialization }
TPClyMethodCreationToolMorph >> setUpTargetClasses [

	targetClasses := browser chooseClassesForNewMethod.
	(targetClasses includes: methodClass) ifFalse: [ 
		targetClasses := {methodClass}, targetClasses ]
]

{ #category : #'events handling' }
TPClyMethodCreationToolMorph >> textChanged: aTextChanged [
	"To avoid parsing the ast of a the pending text at every input, we use a small automaton with 2 	 	states. state 1 : text is being changed so the presence of a separator triggers the 							ast update and changes to state 2.
			  state 2 : just received a separator so other separators don't trigger an update a change 							which is not a separator changes state to state 1.
	The exception being a deletion, AST is updated at every deletion."
	aTextChanged text isEmpty ifTrue: [ self updateASTStyler.]
									 ifFalse: [ | char | char := aTextChanged text first.
					state ifTrue: [ (char isSeparator or: char isClosePunctuation) 
										ifTrue: [ self updateASTStyler. state := false. ] ] 
						   ifFalse: [ (char isSeparator or: char isClosePunctuation)
										ifFalse: [ state := true ] ] ].
	super textChanged: aTextChanged.
]

{ #category : #'as yet unclassified' }
TPClyMethodCreationToolMorph >> updateASTStyler [
	| ast compilationContext compilationContextOptions |
	ast := TPRBParser parseFaultyMethod: self pendingText.
	compilationContext := OpalCompiler new compilationContext.
	compilationContext class: self methodClass.
	compilationContextOptions := CompilationContext defaultOptions copy.
	compilationContextOptions add: #optionSkipSemanticWarnings.
	compilationContext setOptions: compilationContextOptions.
	compilationContext semanticAnalyzerClass new
 	compilationContext: compilationContext;
  	analyze: ast. 
	textMorph segments copy do: #delete.
	TPIconStyler styleText: textModel withAst: ast.
]
