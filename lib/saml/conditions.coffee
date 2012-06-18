XmlElement = require '../xml/xmlElement'
SamlElement = require './samlElement'

class Conditions extends SamlElement
  constructor: (notBefore, notOnOrAfter) ->
    @notBefore = notBefore
    @notOnOrAfter = notOnOrAfter
    @audience = 'urn:federation:awesome'

  writeXml: (xml) ->
    element = new XmlElement 'Conditions'
    element.addAttr 'NotBefore', @notBefore
    element.addAttr 'NotOnOrAfter', @notOnOrAfter

    if @audience?
      audienceRC = new XmlElement 'AudienceRestrictionCondition'
      audienceElement = new XmlElement 'Audience'
      audienceElement.value = @audience
      audienceRC.addElement audienceElement
      element.addElement audienceRC

    if xml?
      xml.addElement element
      return xml

    element

module.exports = Conditions