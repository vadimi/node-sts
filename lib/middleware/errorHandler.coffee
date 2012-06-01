NotFound = require '../notFound'
logger = require '../logger'

class ErrorHandler
  @error = (err, req, res, next) ->
    if err instanceof NotFound
      res.render('404', status: 404)
      return

    logger.error(err.stack)
    res.render '500',
      status: err.status || 500
      message: err.message
      stacktrace: err.stack

module.exports = ErrorHandler