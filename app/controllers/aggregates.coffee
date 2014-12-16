db                                    = require('../../config/db')
{CustomerAccount, SensorHub, Gateway, OutboundEmail, OutboundSms} = db.models
async                                 = require('async')
_                                     = require('lodash')


module.exports = (req, res) ->
  if carrierId = req.query.carrier
    CustomerAccount.where( carrier:db.Types.ObjectId(carrierId) ).select('gateways').populate('gateways', 'sensorHubs').lean().exec (e, customerAccounts) ->
      gateways = _.flatten(_.pluck(customerAccounts, 'gateways'))
      sensorHubs = _.flatten(_.pluck(gateways, 'sensorHubs'))
      customerAccountIds = _.pluck(customerAccounts, '_id')
      async.parallel
        outboundEmailCount  : (cb) -> OutboundEmail.where('customerAccount').in(customerAccountIds).count {}, cb
        outboundSmsCount    : (cb) -> OutboundSms.where('customerAccount').in(customerAccountIds).count {}, cb
      , (e, r) ->
        res.json
          customerAccounts  : customerAccounts.length
          gateways          : gateways.length
          sensorHubs        : sensorHubs.length
          outboundEmails    : r.outboundEmailCount
          outboundSms       : r.outboundSmsCount
  else
    async.parallel
      customerAccounts  : (cb) -> CustomerAccount.count {}, cb
      sensorHubs        : (cb) -> SensorHub.count {}, cb
      gateways          : (cb) -> Gateway.count {}, cb
      outboundEmails    : (cb) -> OutboundEmail.count {}, cb
      outboundSms       : (cb) -> OutboundSms.count {}, cb
    , (e, r) ->
      res.json r