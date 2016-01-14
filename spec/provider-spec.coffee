describe "Google suggest autocompletions", ->
  [editor, provider] = []

  getCompletions = (manually=false) ->
    cursor = editor.getLastCursor()
    start = cursor.getBeginningOfCurrentWordBufferPosition()
    end = cursor.getBufferPosition()
    prefix = editor.getTextInRange([start, end])

    request =
      editor: editor
      bufferPosition: end
      scopeDescriptor: cursor.getScopeDescriptor()
      prefix: prefix
      activatedManually: manually
    provider.getSuggestions(request)

  beforeEach ->
    waitsForPromise -> atom.packages.activatePackage('autocomplete-google-suggest')

    runs ->
      provider = atom.packages.getActivePackage('autocomplete-google-suggest').mainModule.getProvider()

    waitsForPromise -> atom.workspace.open('test.js')

    runs -> editor = atom.workspace.getActiveTextEditor()

  it "returns no completions when empty editor", ->
    editor.setText('')
    promise = getCompletions()
    waitsForPromise ->
      promise.then (completions) ->
        expect(completions.length).toBe 0


  it "returns 10 completions for a word", ->
    editor.setText('davi')
    editor.setCursorBufferPosition([0, 0])
    promise = getCompletions()
    waitsForPromise ->
      promise.then (completions) ->
        expect(completions.length).toBe 0

        editor.setCursorBufferPosition([0, 4])
        promise = getCompletions()
        waitsForPromise ->
          promise.then (completions) ->
            expect(completions.length).toBe 10

  it "returns no completions automatically under 3 characters", ->
    editor.setText('dav')
    editor.setCursorBufferPosition([0, 3])
    promise = getCompletions()
    waitsForPromise ->
      promise.then (completions) ->
        expect(completions.length).toBe 0

  it "returns 10 completions manually under 3 characters", ->
    editor.setText('dav')
    editor.setCursorBufferPosition([0, 3])
    promise = getCompletions(true)
    waitsForPromise ->
      promise.then (completions) ->
        expect(completions.length).toBe 10

  it "returns 20 completions with context", ->
    editor.setText('hello how a')
    editor.setCursorBufferPosition([0, 11])
    promise = getCompletions(true)
    waitsForPromise ->
      promise.then (completions) ->
        expect(completions.length).toBe 20
