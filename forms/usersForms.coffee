form = require 'express-form'
filter = form.filter
validate = form.validate
url = require 'url'

DeleteForm = form(
  filter('userId').trim(),
  validate('userId').required null, 'UserId cannot be empty'
)

FindForm = form(
  filter('userName').trim(),
  validate('userName').required null, 'UserName cannot be empty'
)

EditForm = form filter('saved').toBoolean()

SaveForm = form(
  filter('userName').trim(),
  validate('userName').required(null, 'User Name cannot be empty'),

  filter('email').trim(),
  validate('email').required(null, 'Email cannot be empty'),

  filter('_id').custom((value, sourceForm) ->
    # userId is first parameter of the url
    sourceForm['0'])
)

exports.EditForm = EditForm
exports.SaveForm = SaveForm
exports.DeleteForm = DeleteForm
exports.FindForm = FindForm