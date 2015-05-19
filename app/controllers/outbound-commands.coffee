db          = require '../../config/db'
OutboundCommand = db.models.OutboundCommand


exports.index = (req, res) ->
  OutboundCommand
  .find({})
  .sort({_id: 'desc'})
  .select('sentAt resolvedAt msgType command customerAccount carrier params')
  .limit(25)
  .exec (err, outboundCommands) ->
    res.json outboundCommands