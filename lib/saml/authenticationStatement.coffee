SamlElement = require './samlElement'
XmlElement = require '../xml/xmlElement'
SubjectElement = require './subjectElement'
moment = require 'moment'

class AuthenticationStatement extends SubjectElement
  constructor: ->
    @authInstant = null
    @authMethod = null

  Object.defineProperty @prototype, 'authenticationInstant',
    get: -> if @authInstant? then moment(@authInstant).format() else moment().format()
    set: (value) -> @authInstant = value

  Object.defineProperty @prototype, 'authenticationMethod',
    get: -> @authMethod ? 'urn:oasis:names:tc:SAML:1.0:am:classes:password'
    set: (value) -> @authMethod = value

  writeXml: (xml) ->
    element = new XmlElement 'AuthenticationStatement'
    element.addAttr 'AuthenticationInstant', @authenticationInstant
    element.addAttr 'AuthenticationMethod', @authenticationMethod
    element.addElement @subjectXml if @subjectXml?

    if xml?
      xml.addElement element
      return xml

    element

module.exports = AuthenticationStatement