winston = require 'winston'
path = require 'path'
moment = require 'moment'
StsConfig = require './stsConfig'

now = moment()
logFile = "#{__dirname}/../logs/log#{now.format('YYYYMMDD')}.log"
if StsConfig.logPath?
  logFile = path.join StsConfig.logPath, "log#{now.format('YYYYMMDD')}.log"

logger = new (winston.Logger)({
  transports: [
    new (winston.transports.File)(
      timestamp: ->
        date = now.format('YYYY-MM-DD HH:mm:ss')
        "[#{date}]"
      json: false
      handleExceptions: true
      maxsize: 10485760
      filename: logFile)
  ]
})

module.exports = logger