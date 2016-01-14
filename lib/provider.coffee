request = require 'request'

module.exports =
  selector: '*'
  suggestionPriority: -1

  getSuggestsFromCompletions: (completions, prefix, fullPrefix='') ->
    [term, completions] = completions

    for completion in completions
      if completion.trim() is fullPrefix.trim()
        continue
      text: completion
      displayText: if fullPrefix and completion.startsWith(fullPrefix) then completion.slice(fullPrefix.length - prefix.length) else completion
      replacementPrefix: fullPrefix or prefix
      type: if fullPrefix then 's' else 'w'
      rightLabel: if fullPrefix then (if completion.startsWith(fullPrefix) then '+' else '*') else null
      description: if fullPrefix and completion.startsWith(fullPrefix) then completion else null

  requestOptions: (query) ->
    url: atom.config.get('autocomplete-google-suggest.suggestQueryUrl').replace('<search>', query or ' ')
    json: true
    encoding: 'binary'

  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix, activatedManually}) ->
    new Promise (resolve) =>
      return resolve([]) unless (!atom.config.get('autocomplete-google-suggest.manualCompletionOnly') and
        prefix.trim().length > atom.config.get('autocomplete-google-suggest.automaticCompletionLetterThreshold')
      ) or activatedManually

      fullPrefix = editor.getTextInBufferRange([
          [bufferPosition.row, 0],
          [bufferPosition.row, bufferPosition.column]
      ])

      request @requestOptions(prefix), (error, response, completions) =>
        suggests = []
        if response and response.statusCode is 200
          suggests = @getSuggestsFromCompletions(completions, prefix)

        if atom.config.get('autocomplete-google-suggest.completeCurrentWordOnly') or prefix.trim() is fullPrefix.trim()
          return resolve(suggests)

        request @requestOptions(fullPrefix), (error, response, completions) =>
          if response and response.statusCode is 200
            suggests = @getSuggestsFromCompletions(completions, prefix, fullPrefix).concat(suggests)

          return resolve(suggests)
