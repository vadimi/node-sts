stsConfig = require '../lib/stsConfig'
Ticket = require '../lib/ticket'
User = require '../lib/users'
querystring = require 'querystring'
url = require 'url'
Step = require 'step'
_ = require 'underscore'
authForms = require '../forms/authForms'

class AuthRoute

  # app - Expressjs application
  init: (app) ->
    app.get('/signup', @signup)
    app.post('/signup', authForms.Signup, @doSignup)
    app.get('/fedlogin', authForms.FedRequest, @fedlogin)
    app.post('/fedlogin', authForms.Login, @doFedLogin)
    app.get('/signup-success', @signupSuccess)

  signup: (req, res) ->
    res.render('signup')

  # get /fedlogin
  #
  # used only from SharePoint redirect
  # validation should be performed against querystring parameters
  fedlogin: (req, res) ->
    unless req.form.isValid
      throw new Error('Invalid request.')

    res.render('fedlogin',
      _.extend(req.form,
        validationErrors: req.form.getErrors()
        query: querystring.stringify(req.query))
    )

  # post /fedlogin
  doFedLogin: (req, res, next) ->
    model = req.form
    unless model.isValid
      model.validationErrors = model.getErrors()
      model.query = querystring.stringify(req.query)
      res.render('fedlogin', model)
    else
      User.authenticate(model.userName, model.password,
        (err, user) ->
          if err
            next err
          if user?
            assertion = Ticket.getForUser(user)
            model.wresult = assertion
            model.layout = false
            res.render('splogin', model)
          else
            model.query = querystring.stringify(req.query)
            model.globalError = 'User cannot be found.'
            res.render('fedlogin', model)
      )

  # register new user
  doSignup: (req, res, next) ->
    model = req.form
    unless model.isValid
      model.validationErrors = model.getErrors()
      res.render('signup', model)
    else
      Step(
        # validate existance
        validate = () ->
          User.validateUserName(model.userName, @)
          return
        ,# register if valid
        register = (err, isValid) ->
          throw err if err
          unless isValid
            model.globalError = "The specified user already exists"
            @()
          else
            User.register(model.userName, model.password, model.email, @)
            return
        ,# render response
        render = (err, user) ->
          if model.globalError?
            res.render('signup', model)
            return
          if err
            next new Error('Cannot proceed your request')
          else
            res.redirect('/signup-success')
      )

  signupSuccess: (req, res) ->
    res.render("signup-success")

module.exports = AuthRoute