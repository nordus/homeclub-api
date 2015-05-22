path = require('path')
buildHC2 = require '../lib/build-hc2'

configDirPath = path.resolve(__dirname, '..', '..', 'config')
db = require("#{configDirPath}/db")
{SensorHub, DeviceThresholds} = db.models
whiteListedAttrs = '-__v'


exports.index = (req, res) ->
  params = switch req.query.sensorHubMacAddresses
    when undefined then {}
    else _id:
      $in:req.query.sensorHubMacAddresses

  SensorHub.find(params).populate('deviceThresholds').exec (e, sensorHubs) ->
    res.json sensorHubs


exports.update = (req, res) ->
  delete req.body._id

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