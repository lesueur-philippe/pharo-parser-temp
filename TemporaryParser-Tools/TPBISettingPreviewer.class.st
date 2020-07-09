Class {
	#name : #TPBISettingPreviewer,
	#superclass : #ComposablePresenter,
	#instVars : [
		'settingsTree',
		'classSearchField',
		'methodSearchField',
		'formattedCheckBox',
		'sourceCodePane'
	],
	#category : #'TemporaryParser-Tools'
}

{ #category : #'build ui buttons' }
TPBISettingPreviewer class >> buildOpenBIInspectorButton [
	^ PluggableButtonMorph
		on: self
		getState: #openBIInspectorButtonState
		action: #openBIInspectorButtonAction
		label: #openBIInspectorButtonLabel
]

{ #category : #specs }
TPBISettingPreviewer class >> defaultSpec [
	<spec: #default>
	^ SpecLayout composed
		newColumn:
				[ :col | 
			col
				newRow: [ :rowUp | rowUp add: #settingsTree ];
				newRow:
						[ :rowMiddle | 
					rowMiddle
						add: #classSearchField;
						add: #methodSearchField;
						add: #formattedCheckBox ]
					height: 30;
				newRow:
						[ :rowDown | rowDown newColumn: [ :methodSourceCode | methodSourceCode add: #sourceCodePane ] ] ];
		yourself
]

{ #category : #settings }
TPBISettingPreviewer class >> dialogOpenBIPreviewer [
	^ self theme
		newRowIn: self
		for:
			{(self theme buttonLabelForText: 'Open Blue Ink Setting Previewer ').
			self buildOpenBIInspectorButton}
]

{ #category : #'instance creation' }
TPBISettingPreviewer class >> open [
	<script>
	self new openWithSpec 
]

{ #category : #'button behavior' }
TPBISettingPreviewer class >> openBIInspectorButtonAction [
	<script>
	BISettingPreviewer new openWithSpec
]

{ #category : #'button behavior' }
TPBISettingPreviewer class >> openBIInspectorButtonLabel [
	^ 'Open'
]

{ #category : #'button behavior' }
TPBISettingPreviewer class >> openBIInspectorButtonState [
	^ true
]

{ #category : #settings }
TPBISettingPreviewer class >> settingsOn: aBuilder [
	<systemsettings>
	(aBuilder group: #blueInkFormatterExtra)
		target: self;
		parent: #blueInkFormatter;
		label: 'BlueInk Formatting Editor';
		description: 'Open the BlueInk setting previewer to edit the formatting options';
		dialog: [ self dialogOpenBIPreviewer ]

	
]

{ #category : #'item creation' }
TPBISettingPreviewer >> buildClassSearchField [
	^ self newTextInput
		ghostText: 'Enter the class name...';
		autoAccept: true;
		yourself
]

{ #category : #'item creation' }
TPBISettingPreviewer >> buildFormattedCheckBox [
	^ self newCheckBox
		label: 'Formatted';
		state: true;
		whenActivatedDo:
				[ 
			formattedCheckBox toggleState.
			self selectorAndClassAreCorrect
				ifTrue: [ self formatSourceCode ] ];
		whenDeactivatedDo:
				[ 
			formattedCheckBox toggleState.
			self selectorAndClassAreCorrect 
				ifTrue: [ sourceCodePane text: self compiledMethodFromSearchFields sourceCode ] ];
		yourself
]

{ #category : #'item creation' }
TPBISettingPreviewer >> buildMethodSearchField [
	^ self newTextInput
		ghostText: 'Enter the method selector...';
		whenTextIsAccepted: [ self whenSelectorAccepted ];
		yourself
]

{ #category : #'item creation' }
TPBISettingPreviewer >> buildSettingsTreeModel [
	| settingsTreeModel |
	settingsTreeModel := self newTree.
	settingsTreeModel
		roots:
			((SettingTree acceptableKeywords: #(#systemsettings)) nodeList
				select: [ :node | node parentName = #blueInkFormatter ]).
	settingsTreeModel displayBlock: [ :node | self displayNodeFor: node ].
	^ settingsTreeModel
]

{ #category : #'item creation' }
TPBISettingPreviewer >> buildSourceCodePane [
	^ self newText
		aboutToStyle: true;
		yourself
]

{ #category : #accessing }
TPBISettingPreviewer >> classSearchField [
	^ classSearchField
]

{ #category : #accessing }
TPBISettingPreviewer >> compiledMethodFromSearchFields [
	"precondition text represent class and selector"
	
	^ (self class environment at: classSearchField text asSymbol)
			>> methodSearchField text asSymbol 
]

{ #category : #'item creation' }
TPBISettingPreviewer >> displayNodeFor: aNode [
	| nodeMorphLeft nodeMorphRight |
	nodeMorphLeft := StringMorph contents: aNode item label.
	nodeMorphRight := (self theme newRowIn: self for: {aNode settingDeclaration inputWidget})
		clipSubmorphs: true;
		cellInset: 0;
		width: 570;
		left: 400;
		yourself.
	^ PanelMorph new
		addAllMorphs:
			{nodeMorphLeft.
			nodeMorphRight}; 
		color: self theme lightBackgroundColor;
		hResizing: #shrinkWrap;
		yourself
]

{ #category : #api }
TPBISettingPreviewer >> formatSourceCode [
	| source tree formatted |
	source := self compiledMethodFromSearchFields sourceCode.
	tree := TPRBParser parseMethod: source onError: [ :msg :pos | ^ self ].
	formatted := tree formattedCode.
	sourceCodePane text: formatted
]

{ #category : #accessing }
TPBISettingPreviewer >> formattedCheckBox [
	^ formattedCheckBox
]

{ #category : #api }
TPBISettingPreviewer >> initialExtent [
	^ 1000 @ 700
]

{ #category : #initialization }
TPBISettingPreviewer >> initializeWidgets [
	sourceCodePane := self buildSourceCodePane.
	classSearchField := self buildClassSearchField.
	methodSearchField := self buildMethodSearchField.
	settingsTree := self buildSettingsTreeModel.
	formattedCheckBox := self buildFormattedCheckBox.
	SystemAnnouncer uniqueInstance weak when: BISettingsChanged send: #whenASettingChanged to: self.
	self focusOrder
		add: settingsTree;
		add: classSearchField;
		add: methodSearchField;
		add: formattedCheckBox;
		add: sourceCodePane
]

{ #category : #accessing }
TPBISettingPreviewer >> methodSearchField [
	^ methodSearchField
]

{ #category : #testing }
TPBISettingPreviewer >> selectorAndClassAreCorrect [
	| class |
	methodSearchField text
		ifNotNil:
			[ :method | 
			classSearchField text
				ifNotNil:
					[ 
					class := self class environment at: classSearchField text asSymbol ifAbsent: [ ^ false].
					(class includesSelector: method asSymbol)
								ifTrue: [ ^ true ]]].
	^ false 
]

{ #category : #accessing }
TPBISettingPreviewer >> settingsTree [
	^ settingsTree
]

{ #category : #accessing }
TPBISettingPreviewer >> sourceCodePane [
	^ sourceCodePane
]

{ #category : #api }
TPBISettingPreviewer >> title [
	^ 'Blue Ink Setting Previewer'
]

{ #category : #'event handling' }
TPBISettingPreviewer >> whenASettingChanged [
	(self formattedCheckBox state and: [ self selectorAndClassAreCorrect ])
		ifTrue: [ self formatSourceCode ] 
]

{ #category : #'event handling' }
TPBISettingPreviewer >> whenSelectorAccepted [
	| compiledMethod |
	self selectorAndClassAreCorrect
		ifTrue:
			[ 
			compiledMethod := self compiledMethodFromSearchFields.
			sourceCodePane behavior: compiledMethod methodClass.
			self formattedCheckBox state
				ifTrue: [ self formatSourceCode ]
				ifFalse: [ sourceCodePane text: compiledMethod sourceCode ]]
		ifFalse: [ 
			sourceCodePane behavior: nil.
			sourceCodePane text: ' ' ]
]
