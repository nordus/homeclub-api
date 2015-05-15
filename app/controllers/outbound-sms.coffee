db          = require '../../config/db'
OutboundSms = db.models.OutboundSms


exports.index = (req, res) ->
  OutboundSms
    .find({})
    .sort({_id: 'desc'})
    .select('created customerAccount phoneNumber reading')
    .$where('this.reading !== undefined')
    .limit(25)
    .exec (err, outboundSms) ->
      res.json outboundSms