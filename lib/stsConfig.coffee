config = require '../config.json'
path = require 'path'
fs = require 'fs'

class StsConfig
  @init = (baseDir, configJson) ->
    # Private key file path
    @privateKeyPath = path.resolve baseDir, configJson.privateKey

    # Public key file path
    @publicKeyPath = path.resolve baseDir, configJson.publicKey

    # Used to create digital xml signature
    @privateKey = loadFile @privateKeyPath

    # Necessary to include public key for validation on receiving side
    @publicKey = loadPublicKey @publicKeyPath

    # DB connection string
    @dbConnection = "mongodb://#{configJson.dbConnection}"

    # Express application port
    @appPort = configJson.appPort

    # Log files folder
    @logPath = configJson.logPath

  loadPublicKey = (path) ->
    key = loadFile path
    keyLines = key.split '\n'
    keyLines = keyLines[1...keyLines.length - 2]
    keyLines.join ''

  loadFile = (path) ->
    fs.readFileSync(path).toString()

  #self init
  @init "#{__dirname}/../", config
module.exports = StsConfig
