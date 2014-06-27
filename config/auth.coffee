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