async                   = require 'async'
db                      = require('../../config/db')
{CustomerAccount, User} = db.models
whiteListedAttrs  = '-__v'


exports.create = (req, res) ->
  async.parallel
    user: (cb) ->
      User.create req.body, cb
    customerAccount: (cb) ->
      CustomerAccount.create req.body, cb
  , (e, r) ->
    r.user.link 'customerAccount', r.customerAccount, (e, r) ->
      return res.json(500, { error:e })  if e
      res.json r


exports.index = (req, res) ->
  params = switch req.query.carrier
    when undefined then {}
    else carrier: db.Types.ObjectId(req.query.carrier)

  # select all attributes by default
  attrsToSelect = req.query.select || ''

  CustomerAccount.find params, attrsToSelect, (e, accounts) ->
    res.json accounts


exports.update = (req, res) ->
  delete req.body._id
  delete req.body.__v
  if req.body.user && req.body.user._id
    req.body.user = db.Types.ObjectId(req.body.user._id)

  CustomerAccount.findOneAndUpdate _id: db.Types.ObjectId(req.params.id),
    $set: req.body
  , (err, account) ->
    CustomerAccount.findById account._id, ( e, updatedAccount ) ->
      res.json updatedAccount


exports.show = (req, res) ->
  CustomerAccount.findOne db.Types.ObjectId(req.params.id), whiteListedAttrs, (err, customerAccount) ->
    res.json customerAccount


exports.delete = (req, res) ->
  CustomerAccount.findByIdAndRemove db.Types.ObjectId(req.params.id), (err, account) ->
    return res.json(err)  if err
    res.json account