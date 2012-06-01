class ErrorRoute
# app - Expressjs application
  init: (app) ->
    app.all('*', @error404)


  error404: (req, res) ->
    res.status(404)
    res.render("404")

module.exports = ErrorRoute