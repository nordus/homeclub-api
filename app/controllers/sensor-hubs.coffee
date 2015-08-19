path = require('path')
buildHC2 = require '../lib/build-hc2'
_ = require 'lodash'


configDirPath = path.resolve(__dirname, '..', '..', 'config')
db = require("#{configDirPath}/db")
{CustomerAccount, SensorHub, DeviceThresholds} = db.models
whiteListedAttrs = '-__v'


setSensorHubMacAddressesOfCarrier = ( req, res, next ) ->
  if req.user.roles.carrierAdmin && carrierId = req.query.carrier
    CustomerAccount.where( carrier:db.Types.ObjectId(carrierId) ).select('gateways').populate('gateways').lean().exec (e, customerAccounts) ->
      gateways = _.flatten(_.pluck(customerAccounts, 'gateways'))
      req.sensorHubMacAddressesOfCarrier = _.flatten(_.pluck(gateways, 'sensorHubs'))
      next()
  else
    next()

index = ( req, res, next ) ->
  sensorHubMacAddresses = req.query.sensorHubMacAddresses || req.sensorHubMacAddressesOfCarrier
  params = switch sensorHubMacAddresses
    when undefined then {}
    else _id:
      $in:sensorHubMacAddresses

  SensorHub.find(params).populate('deviceThresholds').exec (e, sensorHubs) ->
    res.json sensorHubs

exports.index = [setSensorHubMacAddressesOfCarrier, index]


exports.update = (req, res) ->
  delete req.body._id

  if req.body.deviceThresholds?._id
    req.body.deviceThresholds = req.body.deviceThresholds._id

  SensorHub.findOneAndUpdate
    _id: req.params.id
  ,
    $set: req.body
  , (err, sensorHub) ->
    SensorHub.findOne( _id:sensorHub._id ).populate('deviceThresholds').exec (err, sensorHubWithDeviceThresholds) ->
      res.json err || sensorHubWithDeviceThresholds


exports.show = (req, res) ->
  SensorHub.findOne req.params.id, whiteListedAttrs, (err, sensorHub) ->
    res.json sensorHub


exports.create = (req, res) ->
  # create / link DeviceThresholds record
  DeviceThresholds.create {}, (err, deviceThresholds) ->
    res.json err  if err
    req.body.deviceThresholds = deviceThresholds._id
    SensorHub.create req.body, (err, sensorHub) ->
      res.json err || sensorHub