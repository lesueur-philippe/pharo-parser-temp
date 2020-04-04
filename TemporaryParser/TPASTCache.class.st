"
I am a simple cache for AST nodes corresponding to CompiledMethods in the image. The cache is emptied when the image is saved.

The cached #ast is for one interesting for speed (that is, in situations where you ask for it often).

The other use-case is if you want to annotate the AST and keep that annotation around (till the next image save, but you can subscribe to ASTCacheReset and re-install the AST in the cache after cleaning. (This is used by MetaLinks to make sure they survive image restart).

The last thing that it provides is that we do have a quite powerful mapping between bytecode/text/context and the AST. Regardless of how you navigate, you get the same object.

e.g. even this one works:

    [ 1+2 ] sourceNode == thisContext method ast blockNodes first

**NOTE** due to the cached AST, Modification of the AST can be a problem.
Code that wants to modify the AST without making sure the compiledMethod is in sync later should use #parseTree. 

"
Class {
	#name : #TPASTCache,
	#superclass : #WeakIdentityKeyDictionary,
	#classInstVars : [
		'default'
	],
	#category : #'TemporaryParser-Parser'
}

{ #category : #'private - announcements' }
TPASTCache class >> announceCacheReset [

	SystemAnnouncer uniqueInstance announce: TPASTCacheReset new 
]

{ #category : #accessing }
TPASTCache class >> at: aCompiledMethod [
	^ self default at: aCompiledMethod
]

{ #category : #accessing }
TPASTCache class >> default [
	^ default ifNil: [ 
		SessionManager default registerSystemClassNamed: self name.
		default := self new ]
]

{ #category : #accessing }
TPASTCache class >> default: anASTCache [
	default := anASTCache
]

{ #category : #initialization }
TPASTCache class >> reset [
	<script>
	self default reset.
	self announceCacheReset
]

{ #category : #'system startup' }
TPASTCache class >> shutDown [	
	self reset
]

{ #category : #accessing }
TPASTCache >> at: aCompiledMethod [
	^ self 
		at: aCompiledMethod
		ifAbsentPut: [ 
			aCompiledMethod reflectiveMethod 
				ifNil: [ aCompiledMethod parseTree doSemanticAnalysisIn: aCompiledMethod methodClass ]
				ifNotNil: [: rfMethod | rfMethod ast ] ]
]

{ #category : #initialization }
TPASTCache >> reset [
	self removeAll
]
