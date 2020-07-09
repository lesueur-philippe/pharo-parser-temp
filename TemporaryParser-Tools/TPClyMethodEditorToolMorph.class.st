Class {
	#name : #TPClyMethodEditorToolMorph,
	#superclass : #ClyTextEditorToolMorph,
	#instVars : [
		'methodTags',
		'extendingPackage',
		'targetClasses'
	],
	#category : #'TemporaryParser-Tools'
}

{ #category : #testing }
TPClyMethodEditorToolMorph class >> isAbstract [
	^self = TPClyMethodEditorToolMorph 
]

{ #category : #accessing }
TPClyMethodEditorToolMorph class >> tabOrder [
	^20
]

{ #category : #testing }
TPClyMethodEditorToolMorph >> allowsDifferentActivationPriority [
	^false
]

{ #category : #testing }
TPClyMethodEditorToolMorph >> belongsToRemovedBrowserContext [
	super belongsToRemovedBrowserContext ifTrue: [ ^true ].
	
	^self methodClass isObsolete
]

{ #category : #building }
TPClyMethodEditorToolMorph >> buildTextMorph [
	super buildTextMorph.
	
	self formatTextIfNeeded 
]

{ #category : #'events handling' }
TPClyMethodEditorToolMorph >> changesAreAboutApply [
	| tagsEditor |
	super changesAreAboutApply.
	
	tagsEditor := statusBar findDeeplyA: ClyMethodTagsEditorMorph.
	tagsEditor ifNil: [ ^self ].
	
	tagsEditor acceptTags
]

{ #category : #operations }
TPClyMethodEditorToolMorph >> chooseClassForNewMethodIfNone: aBlock [
	
	targetClasses size = 1 ifTrue: [ ^ targetClasses first].

	^[self browser searchDialog 
			requestSingleObject: 'Where install new method?'
			from: (ClyAllClassesQuery as: ClyMethodVisibilityProvider defaultHierarchy asQueryResult) 
			inScope: (ClyClassScope ofAll: targetClasses)]
		on: CmdCommandAborted do: [:err | aBlock value ]
]

{ #category : #accessing }
TPClyMethodEditorToolMorph >> editingClass [ 
	^self methodClass
]

{ #category : #accessing }
TPClyMethodEditorToolMorph >> extendingPackage [
	^ extendingPackage
]

{ #category : #accessing }
TPClyMethodEditorToolMorph >> extendingPackage: aPackage [
	extendingPackage := aPackage.
	methodTags := #().
]

{ #category : #building }
TPClyMethodEditorToolMorph >> fillStatusBar [
	| position |
	super fillStatusBar.
	
	position := statusBar addContextItem: (ClyCursorPositionLabelMorph of: textMorph).
	position comeToFront.
	statusBar addCommandItem: (ClyTextWrapModeSwitchMorph of: textMorph).
	statusBar addCommandItem: (ClyTextLineNumbersSwitchMorph of: textMorph).
	statusBar addCommandItem: (ClyFormatAsReadSwitchMorph of: textMorph).
	
	statusBar addCommandItem: (ClyMethodTagsAndPackageEditorMorph for: self).
	
	
]

{ #category : #operations }
TPClyMethodEditorToolMorph >> formatSourceCode [
	textMorph formatSourceCode 
]

{ #category : #building }
TPClyMethodEditorToolMorph >> formatTextIfNeeded [
	RBProgramNode formatterClass formatAsYouReadPolicy ifFalse: [ ^self].
	
	textMorph formatSourceCode. 
	textModel clearUserEdits
]

{ #category : #initialization }
TPClyMethodEditorToolMorph >> initialize [
	super initialize.
	
	methodTags := #()
]

{ #category : #testing }
TPClyMethodEditorToolMorph >> isCommandAvailable: aCommand [ 

	^ aCommand canBeExecutedInMethodEditor: self
]

{ #category : #'rubric interaction model' }
TPClyMethodEditorToolMorph >> isForScripting [
	^false
]

{ #category : #accessing }
TPClyMethodEditorToolMorph >> methodClass [
	self subclassResponsibility 	
]

{ #category : #accessing }
TPClyMethodEditorToolMorph >> methodTags [
	^methodTags
]

{ #category : #accessing }
TPClyMethodEditorToolMorph >> methodTags: tagsArray [
	methodTags := tagsArray.
	extendingPackage := nil
]

{ #category : #testing }
TPClyMethodEditorToolMorph >> modifiesExtension [
	"it should answer if tool is going to modify extension state of method.
	For example tool ca move method to another package
	ot it can move extension method back to class package"
	self subclassResponsibility 
]

{ #category : #operations }
TPClyMethodEditorToolMorph >> packageEditingMethod: aMethod [
	
	self applyChangesBy: [ 
		(extendingPackage notNil and: [aMethod package ~~ extendingPackage]) ifTrue: [
			^(SycMoveMethodsToPackageCommand for: {aMethod} to: extendingPackage) 
				execute].
	
		(extendingPackage isNil and: [ aMethod isExtension ]) ifTrue: [ 
			(SycMoveMethodsToPackageDefiningClassCommand for: {aMethod}) 
				execute]
	]
]

{ #category : #'rubric interaction model' }
TPClyMethodEditorToolMorph >> selectedClassOrMetaClass [
	^self methodClass
]

{ #category : #initialization }
TPClyMethodEditorToolMorph >> setUpParametersFromModel [
	super setUpParametersFromModel.

	self setUpTargetClasses 
]

{ #category : #initialization }
TPClyMethodEditorToolMorph >> setUpTargetClasses [
	self subclassResponsibility 
]

{ #category : #operations }
TPClyMethodEditorToolMorph >> tagAndPackageEditingMethod: aMethod [
	self tagEditingMethod: aMethod.
	"Tagging should be performed before package movement 
	because extending package is still based on protocol begining with star. 
	So it should override manual tagging"	
	self packageEditingMethod: aMethod
]

{ #category : #operations }
TPClyMethodEditorToolMorph >> tagEditingMethod: aMethod [
	| existingTags removedTags newTags |
	self applyChangesBy: [
		existingTags := aMethod tags reject: [:each | each beginsWith: '*'].
		removedTags := existingTags reject: [ :each | methodTags includes: each ].
		newTags := methodTags reject: [ :each | existingTags includes: each ].
	
		newTags do: [ :each | aMethod tagWith: each asSymbol].
		removedTags do: [ :each | aMethod untagFrom: each asSymbol]
	]
]

{ #category : #accessing }
TPClyMethodEditorToolMorph >> tagsAndPackageEditor [
	^(statusBar findDeeplyA: TPClyMethodRefactoringEditorMorph) ifNil: [ CmdCommandAborted signal ]
]

{ #category : #operations }
TPClyMethodEditorToolMorph >> toggleExtendingPackage [

	extendingPackage ifNotNil: [ ^extendingPackage := nil ].
	
	extendingPackage := browser searchDialog 
		requestSingleObject: 'Choose package for method' from: ClyAllPackagesQuery sorted
]
