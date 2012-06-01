class HomeRoute
  # app - Expressjs application
  init: (app) ->
    app.get('/', @index)


  index: (req, res) ->
    res.render("index")

module.exports = HomeRoute