SamlElement = require './samlElement'
XmlElement = require '../xml/xmlElement'

class SubjectElement extends SamlElement
  constructor: ->
    @nameIdentifierObj  = null

  Object.defineProperty @prototype, 'nameIdentifier',
    get: -> @nameIdentifierObj
    set: (value) -> @nameIdentifierObj = value

  Object.defineProperty @prototype, 'subjectXml',
    get: ->
      if @nameIdentifier?
        subjElement = new XmlElement 'Subject'
        niElement = new XmlElement 'NameIdentifier',
          Format: @nameIdentifier.format
          NameQualifier: ''
        niElement.value = @nameIdentifier.value
        subjElement.addElement niElement
        return subjElement
      null

module.exports = SubjectElement