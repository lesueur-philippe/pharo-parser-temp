Class {
	#name : #TPClyMethodCreationToolMorph,
	#superclass : #ClyMethodEditorToolMorph,
	#instVars : [
		'methodClass'
	],
	#category : #TemporaryParser
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
	| ast |
	super textChanged: aTextChanged.
	ast := TPRBParser parseFaultyMethod: self pendingText.
	TPIconStyler styleText: textModel withAst: ast.
]
