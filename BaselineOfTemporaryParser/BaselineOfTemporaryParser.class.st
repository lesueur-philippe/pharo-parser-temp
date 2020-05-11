Class {
	#name : #BaselineOfTemporaryParser,
	#superclass : #BaselineOf,
	#category : #BaselineOfTemporaryParser
}

{ #category : #baseline }
BaselineOfTemporaryParser >> baseline: spec [
	<baseline>
	spec for: #common do: [ spec
		package: 'TemporaryParser';
		package: 'TemporaryParser-Tests' with: [ spec requires: #('TemporaryParser') ] ]
]
