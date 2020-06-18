Class {
	#name : #TPClyRequestMethodTestCommand,
	#superclass : #ClyMethodEditorCommand,
	#category : #TemporaryParser
}

{ #category : #testing }
TPClyRequestMethodTestCommand class >> canBeExecutedInMethodEditor: aTool [

	^ true
]

{ #category : #activation }
TPClyRequestMethodTestCommand class >> methodEditorShorcutActivation [
	<classAnnotation>
	
	^CmdShortcutActivation by: $e meta, $p meta for: ClyTextEditorContext
]

{ #category : #accessing }
TPClyRequestMethodTestCommand >> defaultMenuItemName [
	^'Select toto '
]

{ #category : #execution }
TPClyRequestMethodTestCommand >> execute [
	| packageEditor |
	packageEditor := methodEditor tagsAndPackageEditor.
	packageEditor requestChangeBy: [ packageEditor requestPackage]
]
