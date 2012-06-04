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

  getXmlString = (xml) ->
    xml.toXmlString?()

  computeDigest: ->
    text = getXmlString(@sourceXml)
    @digestValue = crypto.createHash('sha1').update(text).digest('base64') if text?

  computeSignature: (privateKey, publicKey) ->
    @computeDigest()
    @reference.digestValue = @digestValue

    signedInfo = new SignedInfo(@digestValue)
    signedInfo.reference = @reference
    signedInfoXml = signedInfo.writeXml().toXmlString()
    signatureValue = crypto.createSign('RSA-SHA1').update(signedInfoXml).sign(privateKey, 'base64');

    @signature = new Signature(signedInfo)
    @signature.signedInfo = signedInfo
    @signature.signatureValue = signatureValue
    @signature.x509Certificate = publicKey

    @signature.toXmlString()

  getSignedInfo: -> @signature

# Signature element declaration
class Signature
  constructor: ->
    @signedInfo = null

    # Signature value
    @signatureValue = null

    # Publlic key to validate signature
    @x509Certificate = null

  toXmlString: ->

    signature = new XmlElement('Signature')
    signature.namespace = 'http://www.w3.org/2000/09/xmldsig#'

    @signedInfo.writeXml signature if @signedInfo?

    signatureValueElement = new XmlElement('SignatureValue')
    signatureValueElement.value = @signatureValue
    signature.addElement signatureValueElement

    keyInfo = new XmlElement('KeyInfo')
    x509Data = new XmlElement('X509Data')
    x509CertificateElement = new XmlElement('X509Certificate')
    x509CertificateElement.value = @x509Certificate
    x509Data.addElement(x509CertificateElement)
    keyInfo.addElement(x509Data)
    signature.addElement keyInfo

    signature

# SignedInfo element declaration
class SignedInfo
  constructor: ->
    @reference = null

  writeXml: (xml) ->
    signedInfo = new XmlElement('SignedInfo')
    signedInfo.namespace = 'http://www.w3.org/2000/09/xmldsig#'
    signedInfo.addElement(new XmlElement('CanonicalizationMethod',
      Algorithm: 'http://www.w3.org/2001/10/xml-exc-c14n#'))
    signedInfo.addElement(new XmlElement('SignatureMethod',
      Algorithm: 'http://www.w3.org/2000/09/xmldsig#rsa-sha1'))

    @reference.writeXml signedInfo if @reference?

    if xml?
      xml.addElement signedInfo
      return xml

    signedInfo

# Transforms element declaration
class TransformChain
  constructor: ->
    @algorithms = []

  # Add Transform algorithm
  add: (algorithm) ->
    @algorithms.push(algorithm)

  writeXml: (xml) ->
    transforms = new XmlElement('Transforms')
    for algorithm in @algorithms
      transform = new XmlElement('Transform', Algorithm: algorithm)
      transforms.addElement(transform)

    if xml?
      xml.addElement(transforms)
      return xml

    transforms

# Reference element declaration
class Reference
  constructor: (uri) ->
    @uri = uri
    @transforms = new TransformChain()
    @digestValue = null

  # Add Transform algorithm
  addTransform: (algName) ->
    @transforms.add(algName)

  writeXml: (xml) ->
    reference = new XmlElement('Reference', 'URI': @uri)
    @transforms.writeXml(reference)
    reference.addElement(new XmlElement('DigestMethod',
      Algorithm: 'http://www.w3.org/2000/09/xmldsig#sha1'))
    digestValueElement = new XmlElement('DigestValue')
    digestValueElement.value = @digestValue

    reference.addElement(digestValueElement)

    if xml?
      xml.addElement(reference)
      return xml

    reference

module.exports.Reference = Reference
module.exports.SignedXml = SignedXml