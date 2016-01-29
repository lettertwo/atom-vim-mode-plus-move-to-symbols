requireFrom = (pack, path) ->
  packPath = atom.packages.resolvePackagePath(pack)
  require "#{packPath}/#{path}"

{getVimState} = requireFrom 'vim-mode-plus', 'spec/spec-helper'

describe "vim-mode-plus-move-to-symbols", ->
  [set, ensure, keystroke, editor, editorElement, vimState] = []

  waitsForFinishOperation = (fn) ->
    finished = false
    vimState.onDidFinishOperation -> finished = true
    fn()
    waitsFor -> finished

  ensureMoveToSymbols = (_keystroke, options) ->
    runs ->
      waitsForFinishOperation ->
        keystroke _keystroke
      runs ->
        ensure options

  beforeEach ->
    atom.keymaps.add "test",
      'atom-text-editor.vim-mode-plus:not(.insert-mode)':
        '(': 'vim-mode-plus-user:move-to-previous-symbol'
        ')': 'vim-mode-plus-user:move-to-next-symbol'

    waitsForPromise ->
      atom.packages.activatePackage('vim-mode-plus-move-to-symbols')

  describe "coffee editor", ->
    pack = 'language-coffee-script'
    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage(pack)

      getVimState 'sample.coffee', (state, vim) ->
        vimState = state
        {editor, editorElement} = state
        {set, ensure, keystroke} = vim

      waitsForPromise ->
        atom.packages.activatePackage('vim-mode-plus-move-to-symbols')

      runs ->
        set cursor: [0, 0]

    afterEach ->
      atom.packages.deactivatePackage(pack)

    it "move next and previous symbols", ->
      ensureMoveToSymbols ')', cursor: [1, 2]
      ensureMoveToSymbols ')', cursor: [3, 2]
      ensureMoveToSymbols ')', cursor: [5, 2]
      ensureMoveToSymbols ')', cursor: [7, 0]
      ensureMoveToSymbols ')', cursor: [8, 2]

      ensureMoveToSymbols '(', cursor: [7, 0]
      ensureMoveToSymbols '(', cursor: [5, 2]
      ensureMoveToSymbols '(', cursor: [3, 2]
      ensureMoveToSymbols '(', cursor: [1, 2]
      ensureMoveToSymbols '(', cursor: [0, 0]

    it "support count", ->
      ensureMoveToSymbols '3)', cursor: [5, 2]
      ensureMoveToSymbols '2)', cursor: [8, 2]

      ensureMoveToSymbols '3(', cursor: [3, 2]
      ensureMoveToSymbols '2(', cursor: [0, 0]

  describe "github markdown editor", ->
    pack = 'language-gfm'
    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage(pack)

      getVimState 'sample.md', (state, vim) ->
        vimState = state
        {editor, editorElement} = state
        {set, ensure, keystroke} = vim

      runs ->
        set cursor: [0, 0]

    afterEach ->
      atom.packages.deactivatePackage(pack)

    it "move next and previous symbols", ->
      ensureMoveToSymbols ')', cursor: [2, 0]
      ensureMoveToSymbols ')', cursor: [4, 0]
      ensureMoveToSymbols ')', cursor: [5, 0]
      ensureMoveToSymbols ')', cursor: [7, 0]
      ensureMoveToSymbols ')', cursor: [9, 0]
      ensureMoveToSymbols ')', cursor: [10, 0]

      ensureMoveToSymbols '(', cursor: [9, 0]
      ensureMoveToSymbols '(', cursor: [7, 0]
      ensureMoveToSymbols '(', cursor: [5, 0]
      ensureMoveToSymbols '(', cursor: [4, 0]
      ensureMoveToSymbols '(', cursor: [2, 0]
      ensureMoveToSymbols '(', cursor: [0, 0]
