Class {
	#name : #TPRBRepairDefineAsTemporaryVariable,
	#superclass : #TPRBSemanticReparation,
	#category : #'TemporaryParser-Repartions'
}

{ #category : #'as yet unclassified' }
TPRBRepairDefineAsTemporaryVariable >> repair: aVariableNode [
	| methodNode tempsMark characterBeforeMark insertion delta source |
	methodNode := aVariableNode methodNode.
	self context: methodNode compilationContext.
	source := methodNode source.
	"We check if there is a declaration of temporary variables"
	tempsMark :=  methodNode body  rightBar ifNil: [ methodNode body start ].	
	
	characterBeforeMark := source at: tempsMark-1 ifAbsent: [$ ].

	(source at: tempsMark) = $| ifTrue:  [
  		"Paste it before the second vertical bar"
		insertion := aVariableNode name, ' '.
		
		characterBeforeMark isSeparator ifFalse: [insertion := ' ', insertion].
		delta := 0.
	] ifFalse: [
		"No bars - insert some with CR, tab"
		insertion := '| ' , aVariableNode name , ' |',String cr.
		delta := 2.	"the bar and CR"
		characterBeforeMark = Character tab ifTrue: [
			insertion := insertion , String tab.
			delta := delta + 1.	"the tab" ]
		].
	source := (source copyFrom: 1 to: tempsMark - 1), insertion, (source copyFrom: tempsMark to: source size).
	^ self reparse: source.
]
