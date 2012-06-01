module.exports = (app) ->
  ['homeRoute', 'authRoute', 'usersRoute', 'errorRoute'].forEach(
    (routeName) ->
      route = require("./#{routeName}")
      routeObj = new route()
      routeObj.init(app) if routeObj.init
  )