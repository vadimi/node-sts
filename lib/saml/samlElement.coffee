XmlElement = require '../xml/xmlElement'

#
# Base class for common SAML elements
class SamlElement
  writeXml: (xml) ->
    console.log xml
    xml

module.exports = SamlElement