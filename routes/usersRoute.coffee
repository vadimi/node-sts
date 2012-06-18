User = require '../lib/users'
usersForms = require '../forms/usersForms'
Step = require 'step'
NotFound = require '../lib/notFound'

class UsersRoute
  # app - Expressjs application
  init: (app) ->
    app.get '/users', @getUsers
    # accept edit urls with correct ObjectId only, e.g. 24 symbols
    app.get /^\/users\/([a-zA-Z0-9]{24})\/edit$/, usersForms.EditForm, @editUser
    app.put /^\/users\/([a-zA-Z0-9]{24})$/, usersForms.SaveForm, @saveUser
    app.del '/users/delete', usersForms.DeleteForm, @deleteUser
    app.post '/users/find', usersForms.FindForm, @findUsers

  getUsers: (req, res, next) ->
    User.getAll (err, result) ->
      next err if err
      res.render 'users', users: result

  editUser: (req, res, next) ->
    User.get req.params[0], (err, user) ->
      if err
        next err
      else unless user?
        next new NotFound("User not found")
        return
      model = user
      model.saved = req.form.saved
      res.render 'editUser', model

  deleteUser: (req, res, next) ->
    unless req.form.isValid
      throw new Error('UserId cannot be empty.')

    User.remove req.form.userId, (err, result) ->
      next err if err
      res.redirect '/users'

  saveUser: (req, res, next) ->
    model = req.form
    unless model.isValid
      model.validationErrors = model.getErrors()
      res.render 'editUser', model
    else
      user = null
      Step(
        getUser = () ->
          User.get model._id, @
          return
        ,# validate existance
        validate = (err, userResult) ->
          user = userResult
          throw err if err
          if user.userName isnt model.userName
            User.validateUserName model.userName, @
          else
            @ null, true
          return
        ,# register if valid
        save = (err, isValid) ->
          throw err if err
          unless isValid
            model.globalError = "The specified user already exists"
            @()
          else
            User.save(user, model, @)
            return
        ,# render response
        render = (err, user) ->
          if model.globalError?
            res.render 'editUser', model
            return
          if err
            next new Error('Cannot proceed your request')
          else
            res.redirect "/users/#{model._id}/edit?saved=true"
      )

  findUsers: (req, res, next) ->
    unless req.form.isValid
      throw new Error 'Invalid request.'

    User.find req.form.userName, (err, users) ->
      if err
        next err
        return

      result = users: null

      if users? and users.length > 0
        result.users = users

      res.json result

module.exports = UsersRoute
