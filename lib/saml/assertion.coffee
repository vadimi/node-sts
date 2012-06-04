AuthenticationStatement = require './authenticationStatement'
AttributeStatement = require './attributeStatement'
Conditions = require './conditions'
SamlElement = require './samlElement'
XmlElement = require '../xml/xmlElement'
moment = require 'moment'
uuid = require 'node-uuid'

class Assertion
  constructor: ->
    now = moment()
    @notBefore = now.format()
    # TODO: move 4 hours to config file
    @notOnOrAfter = now.add('hours', 4).format()

    # TODO: move to config
    @issuer = 'urn:federation:awesome'

    @statements = []

    # xml signature
    @signature = null

    @assertionId = generateUniqueId()

  toXmlElement: ->
    xml = new XmlElement 'Assertion',
      'xmlns': 'urn:oasis:names:tc:SAML:1.0:assertion'
      'AssertionID': @assertionId
      'IssueInstant': moment().format()
      'Issuer': @issuer
      'MajorVersion': '1'
      'MinorVersion': '1'

    conditions = new Conditions(@notBefore, @notOnOrAfter)
    conditions.audience = @issuer
    conditions.writeXml xml

    # authentication and attribute statements
    for statement in @statements
      statement.writeXml xml if statement instanceof SamlElement

    xml.addElement(@signature) if @signature?
    xml

  toXmlString: ->
    xml = @toXmlElement()
    # return xml string
    xml.toXmlString()

  generateUniqueId = ->
    id = uuid.v4().replace(/-/g, '')
    "SM#{id}"
module.exports = Assertion