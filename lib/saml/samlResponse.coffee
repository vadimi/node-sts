XmlElement = require '../xml/xmlElement'

class SamlResponse
  constructor: ->
    @assertion = null

  toXmlString: (xml) ->
    rstResponse = new XmlElement 'RequestSecurityTokenResponse',
      'xmlns': 'http://schemas.xmlsoap.org/ws/2005/02/trust'
    rsToken = new XmlElement 'RequestedSecurityToken'
    rsToken.addElement @assertion
    rstResponse.addElement rsToken
    rstResponse.toXmlString()

module.exports = SamlResponse