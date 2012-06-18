Assertion = require '../lib/saml/assertion'
AuthenticationStatement = require '../lib/saml/authenticationStatement'
AttributeStatement = require '../lib/saml/attributeStatement'
SamlTokenIssuer = require '../lib/saml/SamlTokenIssuer'
stsConfig = require '../lib/stsConfig'

class Ticket
  CLAIMS_NS = 'http://schemas.xmlsoap.org/claims'

  @getForUser = (user) ->
    assertion = new Assertion()

    assertion.statements.push getAuthStatement(user)
    assertion.statements.push getAttributeStatement(user)

    sti = new SamlTokenIssuer()
    sti.privateKey = stsConfig.privateKey
    sti.publicKey = stsConfig.publicKey
    sti.issue assertion

  getAuthStatement = (user) ->
    authStatement = new AuthenticationStatement()
    authStatement.authInstant = new Date()
    authStatement.authMethod = 'urn:oasis:names:tc:SAML:1.0:am:classes:password'
    authStatement.nameIdentifier =
      format: 'http://schemas.xmlsoap.org/claims/UPN'
      value: user.userName
    authStatement

  getAttributeStatement = (user) ->
    attrStatement = new AttributeStatement()
    attrStatement.nameIdentifier =
      format: 'http://schemas.xmlsoap.org/claims/UPN'
      value: user.userName
    attrStatement.add 'emailAddress', user.email, CLAIMS_NS
    attrStatement.add 'UserDomain', 'NA', CLAIMS_NS
    attrStatement.add 'upn', user.userName, CLAIMS_NS
    attrStatement

module.exports = Ticket