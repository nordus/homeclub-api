db = require('../../config/db')
{Gateway} = db.models
whiteListedAttrs = '-__v'


exports.index = (req, res) ->
  Gateway.find {}, (err, gateways) ->
    res.json gateways


exports.create = (req, res) ->
  Gateway.create req.body, (err, gateways) ->
    res.json gateways


exports.show = (req, res) ->
  Gateway.findOne _id:req.params.id, whiteListedAttrs, (err, gateway) ->
    res.json gateway


exports.update = (req, res) ->
  delete req.body._id

  Gateway.findOneAndUpdate _id: req.params.id,
    $set: req.body
  , (err, gateway) ->
    res.json gateway


exports.delete = (req, res) ->
  Gateway.findByIdAndRemove req.params.id, (err, gateway) ->
    return res.json(err)  if err
    res.json gateway