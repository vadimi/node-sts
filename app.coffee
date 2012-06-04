express = require 'express'
mongoose = require 'mongoose'
ErrorHandler = require './lib/middleware/errorHandler'
config = require './lib/stsConfig'
logger = require './lib/logger'

app = module.exports = express.createServer()

# Configuration

app.configure(->
  app.use(express.cookieParser())
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')

  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(express.static(__dirname + '/public'))
  app.use(app.router)
  app.use(ErrorHandler.error)
)

app.configure('development', ->
  app.use(express.errorHandler( dumpExceptions: true, showStack: true ))
  app.set('view options',
    layout: false
    pretty: true)
  mongoose.connect(config.dbConnection)
)

app.configure('production', ->
  app.use(express.errorHandler())
  app.set('view options',
    layout: false
    pretty: true)
  mongoose.connect(config.dbConnection)
)

mongoose.connection.on('error', (err) ->
  console.log('mongo error:')
  console.log(err)
  logger.error(err.toString())
)

# Routes
require('./routes')(app)

app.listen(config.appPort)
console.log('Express server listening on port %d in %s mode', app.address().port, app.settings.env)
logger.info("Express server listening on port #{app.address().port} in #{app.settings.env} mode")