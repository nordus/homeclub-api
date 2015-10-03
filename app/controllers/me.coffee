jwt = require 'jsonwebtoken'
db  = require('../../config/db')
{CarrierAdmin, CustomerAccount, HomeClubAdmin} = db.models


sendAccountAndToken = ( req, res, account ) ->

  carrier       = account.carrier
  homeClubAdmin = req.user.roles.homeClubAdmin

  tokenPayload  =
    _id         : req.user._id
    carrierName : if homeClubAdmin then '*' else carrier.name.toLowerCase()
    roles       : req.user.roles

  unless homeClubAdmin
    tokenPayload.carrierId  = carrier._id

  token = jwt.sign tokenPayload, 's3ss10ns3cr3t'

  # delete Passport session - set req.user = null and delete req._passport.session.user.
  # all future requests must include token in req.Authorization
  # so express-jwt can set req.user
  req.logout()

  res.json
    account : account
    token   : token


exports.customerAccount = (req, res) ->
  CustomerAccount.findOne(db.Types.ObjectId( req.user.roles.customerAccount )).populate('user gateways carrier').exec (e, account) ->
    sendAccountAndToken( req, res, account )


exports.homeClubAdmin = (req, res) ->
  HomeClubAdmin.findOne(db.Types.ObjectId( req.user.roles.homeClubAdmin )).populate('user').exec (e, homeClubAdmin) ->
    sendAccountAndToken( req, res, homeClubAdmin )


exports.carrierAdmin = (req, res) ->
  CarrierAdmin.findOne(db.Types.ObjectId( req.user.roles.carrierAdmin )).populate('user carrier').exec (e, carrierAdmin) ->
    sendAccountAndToken( req, res, carrierAdmin )
