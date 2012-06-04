SamlResponse = require './SamlResponse'
Saml = require '../xml/SignedXml'

class SamlTokenIssuer
  constructor: ->
    @privateKey = null
    @publicKey = null

  issue: (assertion) ->
    samlResponse = new SamlResponse()

    reference = new Saml.Reference('#' + assertion.assertionId)
    # add canonicalization algorithms
    reference.addTransform('http://www.w3.org/2000/09/xmldsig#enveloped-signature')
    reference.addTransform('http://www.w3.org/2001/10/xml-exc-c14n#')

    signedXml = new Saml.SignedXml(assertion)
    signedXml.reference = reference
    signature = signedXml.computeSignature(@privateKey, @publicKey)

    assertion.signature = signature
    samlResponse.assertion = assertion.toXmlElement()
    samlResponse.toXmlString()



module.exports = SamlTokenIssuer