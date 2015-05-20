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

#  SensorHub.find params, (e, sensorHubs) ->
  SensorHub.find(params).exec (e, sensorHubs) ->
    res.json sensorHubs


updateAndRespond = ( req, res ) ->
  SensorHub.findOneAndUpdate
    _id: req.params.id
  ,
    $set: req.body
  , (err, sensorHub) ->
    res.json sensorHub

exports.update = (req, res) ->
  delete req.body._id

  if req.body.deviceThresholds
    DeviceThresholds.create req.body.deviceThresholds, (err, deviceThresholds) ->
      req.body.pendingDeviceThresholds = deviceThresholds._id
      delete req.body.deviceThresholds
      updateAndRespond( req, res )

  else
    updateAndRespond( req, res )


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