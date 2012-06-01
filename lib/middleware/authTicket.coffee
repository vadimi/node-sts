crypto = require 'crypto'

class AuthTicket
  constructor: (encryptedValue) ->
    @encryptedValue = encryptedValue
    @data = {}

  encrypt: ->
    cipher = crypto.createCipher('des-ede3-cbc', 'SECRET_KEY')
    @encryptedValue = cipher.update('Asymmetric Encryption Sample in Node.js: Encrypt and Decrypt using Password as a key(SECRET_KEY)', 'utf8', 'base64')
    @encryptedValue += cipher.final('base64')

  decrypt: ->
    decipher = crypto.createDecipher('des-ede3-cbc', 'SECRET_KEY')
    decryptedText = decipher.update(@encryptedValue, 'base64', 'utf8')
    decryptedText += decipher.final('utf8')

module.exports = AuthTicket