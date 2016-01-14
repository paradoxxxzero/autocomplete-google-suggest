provider = require './provider'

module.exports =
  config:
    suggestQueryUrl:
      type: 'string'
      default: 'http://suggestqueries.google.com/complete/search?output=firefox&q=<search>'
    automaticCompletionLetterThreshold:
      type: 'integer'
      default: 3
    completeCurrentWordOnly:
      type: 'boolean'
      default: false
    manualCompletionOnly:
      type: 'boolean'
      default: false


  getProvider: -> provider
