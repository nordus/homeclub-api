db                                    = require('../../config/db')
{CustomerAccount, SensorHub, Gateway} = db.models
async                                 = require('async')
_                                     = require('lodash')


module.exports = (req, res) ->
  if carrierId = req.query.carrier
    CustomerAccount.where( carrier:db.Types.ObjectId(carrierId) ).select('gateways').populate('gateways', 'sensorHubs').lean().exec (e, customerAccounts) ->
      gateways = _.flatten(_.pluck(customerAccounts, 'gateways'))
      sensorHubs = _.flatten(_.pluck(gateways, 'sensorHubs'))
      res.json
        customerAccounts  : customerAccounts.length
        gateways          : gateways.length
        sensorHubs        : sensorHubs.length
  else
    async.parallel
      customerAccounts  : (cb) -> CustomerAccount.count {}, cb
      sensorHubs        : (cb) -> SensorHub.count {}, cb
      gateways          : (cb) -> Gateway.count {}, cb
    , (e, r) ->
      res.json r