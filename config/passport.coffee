{User} = require('./db').models


module.exports = (passport) ->

  LocalStrategy = require('passport-local').Strategy

  passport.use new LocalStrategy 
    usernameField: 'email'
  , (email, password, done) ->
    User.findOne
      email: email
    , (err, user) ->
        return done(err, user)  unless user
        done(null, user)  if user.authenticate(password)

  passport.serializeUser (user, done) ->
    done(null, user._id)

  passport.deserializeUser (id, done) ->
    User.findById id, (err, user) ->
      done(err, user)