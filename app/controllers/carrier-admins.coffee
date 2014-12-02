db = require('../../config/db')
{CarrierAdmin} = db.models
whiteListedAttrs  = '-__v'


exports.index = (req, res) ->
  params = switch req.query.carrier
    when undefined then {}
    else carrier: db.Types.ObjectId(req.query.carrier)

  CarrierAdmin.find params, (err, carriers) ->
    res.json carriers


exports.create = (req, res) ->
  CarrierAdmin.create req.body, (err, carrier) ->
    res.json carrier


exports.show = (req, res) ->
  CarrierAdmin.findOne db.Types.ObjectId(req.params.id), whiteListedAttrs, (err, carrierAdmin) ->
    res.json carrierAdmin


exports.delete = (req, res) ->
  CarrierAdmin.findByIdAndRemove db.Types.ObjectId(req.params.id), (err, admin) ->
    return res.json(err)  if err
    res.json admin