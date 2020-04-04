"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #TPManifestASTCoreTests,
	#superclass : #PackageManifest,
	#category : #'TemporaryParser-Tests-Manifest'
}

{ #category : #'code-critics' }
TPManifestASTCoreTests class >> ruleGRTemporaryNeitherReadNorWrittenRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#ASTEvaluationTest #testEvaluateForContext #false)) #'2019-07-05T11:16:20.959329+02:00') )
]
