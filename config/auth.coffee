
jwt = require 'jsonwebtoken'


exports.requiresRole = (role) ->
  (req, res, next) ->
    if req.isAuthenticated() and req.user.roles[role]
      next()
    else
      res.status 403
      res.end()

exports.requiresApiLogin = (req, res, next) ->
  if req.isAuthenticated()
    next()
  else
    res.status 403
    res.end()

exports.setUserFromAuthToken = ( req, res, next ) ->
  if !req.user && req.headers.authorization
    token     = req.headers.authorization.split(' ')[1]
    req.user  = jwt.decode( token, 's3ss10ns3cr3t' )

  next()