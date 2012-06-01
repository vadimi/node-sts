class NotFound extends Error
  constructor: (msg) ->
    @name = 'NotFound';
    Error.call(this, msg);
    Error.captureStackTrace(this, arguments.callee);

module.exports = NotFound