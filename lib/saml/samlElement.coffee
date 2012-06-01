XmlElement = require '../xml/xmlElement'

#
# Base class for common SAML elements
class SamlElement
  writeXml: (xml) ->
    xml

module.exports = SamlElement