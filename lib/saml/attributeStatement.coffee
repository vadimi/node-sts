SubjectElement = require './subjectElement'
XmlElement = require '../xml/xmlElement'

class AttributeStatement extends SubjectElement
  constructor: ->
    @attributeElements = []

  add: (attrName, attrValue, attrNs) ->
    attrXml = new XmlElement('Attribute', AttributeName: attrName, AttributeNamespace: attrNs)
    attrValueXml = new XmlElement('AttributeValue')
    attrValueXml.value = attrValue
    attrXml.addElement(attrValueXml)
    @attributeElements.push(attrXml)

  writeXml: (xml) ->
    element = new XmlElement('AttributeStatement')
    element.addElement(@subjectXml) if @subjectXml?
    element.addElements(@attributeElements)

    if xml?
      xml.addElement(element)
      return xml

    element

module.exports = AttributeStatement