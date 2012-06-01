winston = require('winston')
moment = require('moment')

#todo: move logs folder to config

now = moment()
logger = new (winston.Logger)({
  transports: [
    new (winston.transports.File)(
      timestamp: ->
        date = now.format('YYYY-MM-DD HH:mm:ss')
        "[#{date}]"
      json: false
      maxsize: 10485760
      filename: "#{__dirname}/../logs/log#{now.format('YYYYMMDD')}.log")
  ]
})

module.exports = logger