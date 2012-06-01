XmlElement = require('./xmlElement')
crypto = require('crypto')

# Xml digital signature generation
#
# sha1 algorithm is used for digest calculation
# RSA-SHA1 algorithm is used for signature calculation
class SignedXml

  constructor: (sourceXml) ->
    @sourceXml = sourceXml
    @digestValue = null
    @signature = null
    @reference = null
    #@signatureValue = null

  getXmlString = (xml) ->
    xml.toXml?()

  computeDigest: ->
    text = getXmlString(@sourceXml)
    @digestValue = crypto.createHash('sha1').update(text).digest('base64') if text?

  computeSignature: (privateKey, publicKey) ->
    @computeDigest()
    @reference.digestValue = @digestValue

    signedInfo = new SignedInfo(@digestValue)
    signedInfo.reference = @reference
    signedInfoXml = signedInfo.toXml()
    signatureValue = crypto.createSign('RSA-SHA1').update(signedInfoXml).sign(privateKey, 'base64');

    @signature = new Signature(signedInfo)
    @signature.signatureValue = signatureValue
    @signature.x509Certificate = publicKey

    @signature

  getSignedInfo: -> @signature

# Signature element declaration
class Signature extends XmlElement
  constructor: (signedInfo) ->
    super('Signature')
    @addElement(signedInfo)
    @namespace = 'http://www.w3.org/2000/09/xmldsig#'

    @.__defineGetter__('signatureValue', -> @getElement('SignatureValue'))
    @.__defineSetter__('signatureValue', (value) ->
      signatureValueElement = new XmlElement('SignatureValue')
      signatureValueElement.value = value
      @setElement('SignatureValue', signatureValueElement))

    # Publlic key to validate signature
    @.__defineGetter__('x509Certificate', ->
      x509Certificate = @getElement('KeyInfo')?.getElement('X509Data')?.getElement('X509Certificate')
      x509Certificate ? null
    )
    @.__defineSetter__('x509Certificate', (value) ->
      keyInfo = new XmlElement('KeyInfo')
      x509Data = new XmlElement('X509Data')
      x509Certificate = new XmlElement('X509Certificate')
      x509Certificate.value = value
      x509Data.addElement(x509Certificate)
      keyInfo.addElement(x509Data)
      @setElement('KeyInfo', keyInfo))


# SignedInfo element declaration
class SignedInfo extends XmlElement
  constructor: (digestValue) ->
    super('SignedInfo')
    @namespace = 'http://www.w3.org/2000/09/xmldsig#'

    @addElement(new XmlElement('CanonicalizationMethod',
      Algorithm: 'http://www.w3.org/2001/10/xml-exc-c14n#'))
    @addElement(new XmlElement('SignatureMethod',
      Algorithm: 'http://www.w3.org/2000/09/xmldsig#rsa-sha1'))

    @.__defineGetter__('reference', -> @getElement('Reference'))
    @.__defineSetter__('reference', (value) -> @setElement('Reference', value))

# Transforms element declaration
class TransformChain extends XmlElement
  constructor: ->
    super('Transforms')

  # Add Transform algorithm
  add: (algorithm) ->
    transform = new XmlElement('Transform', Algorithm: algorithm)
    @addElement(transform)

# Reference element declaration
class Reference extends XmlElement
  constructor: (uri) ->
    super('Reference')
    @addAttr('URI', uri)

    @transforms = new TransformChain()

    @addElement(@transforms)

    @addElement(new XmlElement('DigestMethod',
      Algorithm: 'http://www.w3.org/2000/09/xmldsig#sha1'))

    @.__defineGetter__('digestValue', -> @getElement('DigestValue'))
    @.__defineSetter__('digestValue', (value) ->
      digestValue = new XmlElement('DigestValue')
      digestValue.value = value
      @setElement('DigestValue', digestValue))

  # Add Transform algorithm
  addTransform: (algName) ->
    @transforms.add(algName)

  prepareModel: ->
    @setElement(@transforms.elementName, @transforms)
    super

module.exports.Reference = Reference
module.exports.SignedXml = SignedXml