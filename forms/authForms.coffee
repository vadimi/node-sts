form = require 'express-form'
filter = form.filter
validate = form.validate
url = require 'url'

form.configure(
  flashErrors: false
  passThrough: true
)

commonFilters = [
  validate('wa').required().equals('wsignin1.0'),
  validate('wtrealm').required(),
  validate('wctx').required(),
  validate('wreply').required(),
  filter('sourceUrl').custom((value, sourceForm) ->
    url.parse(sourceForm.wctx, true).query['Source'])
]

FedRequest = form.apply(@, commonFilters)

Login = form.apply(@,
  commonFilters.concat([
    filter('userName').trim(),
    validate('userName').required(null, 'User Name cannot be empty'),

    filter('password').trim(),
    validate('password').required(null, 'Password cannot be empty')
  ])
)

Signup = form(
  filter('userName').trim(),
  validate('userName').required(null, 'User Name cannot be empty'),

  filter('password').trim(),
  validate('password').required(null, 'Password cannot be empty'),

  filter('email').trim(),
  validate('email').required(null, 'Email cannot be empty')
)

exports.Login = Login
exports.FedRequest = FedRequest
exports.Signup = Signup