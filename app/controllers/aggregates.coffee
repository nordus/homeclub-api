{CustomerAccount, SensorHub, Gateway} = require('../../config/db').models
async = require('async')

module.exports = (req, res) ->
  async.parallel
    customerAccounts  : (cb) -> CustomerAccount.count {}, cb
    sensorHubs        : (cb) -> SensorHub.count {}, cb
    gateways          : (cb) -> Gateway.count {}, cb
  , (e, r) ->
    res.json r