db = require('../../config/db')
{HomeClubAdmin} = db.models
whiteListedAttrs  = '-__v'


exports.index = (req, res) ->
  HomeClubAdmin.find {}, (err, admins) ->
    res.json admins


exports.create = (req, res) ->
  HomeClubAdmin.create req.body, (err, admin) ->
    res.json admin


exports.show = (req, res) ->
  HomeClubAdmin.findOne db.Types.ObjectId(req.params.id), whiteListedAttrs, (err, homeClubAdmin) ->
    res.json homeClubAdmin


exports.delete = (req, res) ->
  HomeClubAdmin.findByIdAndRemove db.Types.ObjectId(req.params.id), (err, admin) ->
    return res.json(err)  if err
    res.json admin