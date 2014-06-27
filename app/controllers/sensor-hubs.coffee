path = require('path')

configDirPath = path.resolve(__dirname, '..', '..', 'config')
db = require("#{configDirPath}/db")
{SensorHub} = db.models
whiteListedAttrs = '-__v'


exports.index = (req, res) ->
  SensorHub.where('_id').in(req.query.sensorHubMacAddresses).exec (e, sensorHubs) ->
    res.json sensorHubs


exports.update = (req, res) ->
  delete req.body._id

  SensorHub.findOneAndUpdate
    _id: req.params.id
  ,
    $set: req.body
  , (err, sensorHub) ->
    res.json sensorHub


exports.show = (req, res) ->
  SensorHub.findOne req.params.id, whiteListedAttrs, (err, sensorHub) ->
    res.json sensorHub


exports.create = (req, res) ->
  SensorHub.create req.body, (err, sensorHub) ->
    res.json sensorHub