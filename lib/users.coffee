crypto = require 'crypto'
mongoose = require 'mongoose'
Schema = mongoose.Schema
util = require 'util'
stsutil = require './stsutil'
moment = require 'moment'

class User
  ROLE_USER = 'user'

  userSchema = new Schema(
    userName: { type: String, index: { unique: true, required: true } }
    password: { type: String, required: true }
    email: { type: String, required: true }
    role: String
    lastLogin: { type: Date }
  )

  userSchema.virtual('lastLoginString')
    .get(-> if @.lastLogin? then moment(@.lastLogin).format('YYYY-MM-DD HH:mm') else '')

  userModel = mongoose.model('users', userSchema)

  hash = (inputString) ->
    sha = crypto.createHash('sha256')
    sha.update(inputString, 'utf8')
    sha.digest('base64')

  @register = (userName, password, email, callback) ->
    newUser = new userModel()
    newUser.userName = userName
    newUser.password = hash(password)
    newUser.email = email
    newUser.role = ROLE_USER
    newUser.save((err) -> callback(err, newUser) if callback)

  # Validate user existtance only
  #
  # userName - non empty userName
  @validateUserName = (userName, callback) ->
    userModel.findOne({ userName: userName },
      (err, result) ->
        callback(err, result is null) if callback)

  @authenticate = (userName, password, callback) ->
    hashedPassword = hash(password)
    userModel.findOne({userName: userName, password: hashedPassword},
      (err, user) ->
        if user?
          user.lastLogin = new Date()
          user.save()
        callback(err, user) if callback)

  @getAll = (callback) ->
    userModel.find({}, ['userName', 'email', 'role', 'lastLogin'],
      (err, result) -> callback(err, result) if callback)

  # Get user by id
  #
  # userId - valid ObjectId
  @get = (userId, callback) ->
    userModel.findById(userId,
      (err, result) -> callback(err, result) if callback)

  @remove = (userId, callback) ->
    userModel.findOne({ _id: userId },
    (err, user) ->
      if err
        callback(err) if callback
        return
      if user?
        user.remove((err) ->
          callback(err) if callback)
    )

  @save = (oldUser, newUser, callback) ->
    if oldUser?
      oldUser.userName = newUser.userName
      oldUser.email = newUser.email
      oldUser.save((err) -> callback(err, oldUser) if callback)

  # Find users by userName
  # It will search users whos userName starts with provided value ignoring casing
  #
  # userName - non empty string
  @find = (userName, callback) ->
    searchPattern = '^' + stsutil.escapeRegex(userName)
    userModel.find({ userName: { $regex: searchPattern, $options: 'i' } },
      ['userName', 'email', 'lastLogin'],
      (err, result) -> callback(err, result) if callback)
module.exports = User