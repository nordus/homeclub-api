{CarrierAdmin, CustomerAccount, HomeClubAdmin} = require('../../config/db').models


exports.customerAccount = (req, res) ->
  CustomerAccount.findOne(req.user.roles.customerAccount).populate('user gateways').exec (e, account) ->
    res.json account


exports.homeClubAdmin = (req, res) ->
  HomeClubAdmin.findOne(req.user.roles.homeClubAdmin).populate('user').exec (e, homeClubAdmin) ->
    res.json homeClubAdmin


exports.carrierAdmin = (req, res) ->
  CarrierAdmin.findOne(req.user.roles.carrierAdmin).populate('user').exec (e, carrierAdmin) ->
    res.json carrierAdmin