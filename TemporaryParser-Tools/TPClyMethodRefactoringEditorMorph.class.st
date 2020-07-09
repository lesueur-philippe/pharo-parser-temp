Class {
	#name : #TPClyMethodRefactoringEditorMorph,
	#superclass : #ClyStatusBarItemMorph,
	#instVars : [
		'extensionCheckbox',
		'editButton',
		'label',
		'resetButton'
	],
	#category : #'TemporaryParser-Tools'
}

{ #category : #building }
TPClyMethodRefactoringEditorMorph >> build [	
	self buildResetButton.
	self addMorphBack: resetButton.
	
	self buildEditButton.
	self addMorphBack: editButton.
	
	self buildLabel.
	self addMorphBack: label.
	
	self buildExtensionCheckBoxButton.
	self addMorphBack: extensionCheckbox.
	
	self update
]

{ #category : #building }
TPClyMethodRefactoringEditorMorph >> buildEditButton [
	"editButton := IconicButton new
		target: self;
		actionSelector: #openEditor;
		arguments: #();
		labelGraphic: (self iconNamed: #edit);
		color: Color transparent;
		borderWidth: 0"
]

{ #category : #building }
TPClyMethodRefactoringEditorMorph >> buildExtensionCheckBoxButton [
	"extensionCheckbox := self theme 
		newCheckboxIn: self 
		for: self 
		getSelected: #isExtensionActive 
		setSelected: #toggleExtension
		getEnabled: nil 
		label: 'extension'
		help: 'toggle check box to choose/reset package of method'.
	extensionCheckbox
		changeTableLayout;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap"
]

{ #category : #building }
TPClyMethodRefactoringEditorMorph >> buildLabel [

	label := self theme newLabelIn: self label: self printMethodTagsOrPackage.
	label on: #click send: #openEditor to: self
]

{ #category : #building }
TPClyMethodRefactoringEditorMorph >> buildResetButton [

	resetButton := IconicButton new
		target: self;
		actionSelector: #resetTagsAndPackage;
		arguments: #();
		labelGraphic: (self iconNamed: #glamorousClose);
		color: Color transparent;
		borderWidth: 0;
		hResizing: #shinkWrap;
		layoutInset: 4@0
]

{ #category : #initialization }
TPClyMethodRefactoringEditorMorph >> initialize [
	super initialize.	
	self cellInset: 2@2
]

{ #category : #testing }
TPClyMethodRefactoringEditorMorph >> isExtensionActive [

	^ownerTool extendingPackage notNil
]

{ #category : #operations }
TPClyMethodRefactoringEditorMorph >> openEditor [

	self requestChangeBy: [
		self isExtensionActive 
			ifTrue: [ self requestPackage]
			ifFalse: [ self requestTag ]
	]
]

{ #category : #accessing }
TPClyMethodRefactoringEditorMorph >> ownerTool: anObject [

	super ownerTool: anObject
]

{ #category : #printing }
TPClyMethodRefactoringEditorMorph >> printMethodTags [

	^ownerTool methodTags 
		ifEmpty: [ 'as yet unclassified' asText makeAllColor: Color red ]
		ifNotEmpty: [ :tags | tags joinUsing: ', ' ]
]

{ #category : #printing }
TPClyMethodRefactoringEditorMorph >> printMethodTagsOrPackage [

	^self isExtensionActive 
		ifTrue: [ ownerTool extendingPackage name]
		ifFalse: [ self printMethodTags ]
]

{ #category : #'as yet unclassified' }
TPClyMethodRefactoringEditorMorph >> requestChangeBy: aBlock [
	aBlock on: CmdCommandAborted do: [ :err ].
	
	self update
]

{ #category : #'as yet unclassified' }
TPClyMethodRefactoringEditorMorph >> requestNode [
	| selectedNode existingNode |
	existingNode := ownerTool methodTags
		ifEmpty: [ '' ]
		ifNotEmpty: [ :tags | tags anyOne ].
	selectedNode := self ownerTool context
		requestSingleMethodTag: 'Repair selection'
		suggesting: existingNode.
	selectedNode = existingNode
		ifTrue: [ ^ CmdCommandAborted signal ].
	ownerTool methodTags: {selectedNode asSymbol}
]

{ #category : #operations }
TPClyMethodRefactoringEditorMorph >> requestPackage [

	| extendingPackage |
	extendingPackage := ownerTool context requestSinglePackage: 'Choose package for method'.
		
	ownerTool extendingPackage: extendingPackage
]

{ #category : #'as yet unclassified' }
TPClyMethodRefactoringEditorMorph >> requestTag [
	| selectedTag existingTag |
	existingTag := ownerTool methodTags
		ifEmpty: [ '' ]
		ifNotEmpty: [ :tags | tags anyOne ].
	selectedTag := self ownerTool context
		requestSingleMethodTag: 'New prototocol name'
		suggesting: existingTag.
	selectedTag = existingTag
		ifTrue: [ ^ CmdCommandAborted signal ].
	ownerTool methodTags: {selectedTag asSymbol}
]

{ #category : #operations }
TPClyMethodRefactoringEditorMorph >> resetTagsAndPackage [
	ownerTool methodTags: #().
	self update
]

{ #category : #operations }
TPClyMethodRefactoringEditorMorph >> toggleExtension [

	self requestChangeBy: [ 
		self isExtensionActive 
			ifTrue: [ self requestTag ]
			ifFalse: [ self requestPackage]
	]
]

{ #category : #building }
TPClyMethodRefactoringEditorMorph >> update [
	label color: label defaultColor.
	label contents: self printMethodTagsOrPackage.
	self isExtensionActive 
		ifTrue: [ editButton helpText: 'Choose refactoring node']
		ifFalse: [ editButton helpText: 'Classify method']
]
