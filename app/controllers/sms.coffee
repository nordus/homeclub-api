sendSms = require '../lib/send-sms'


module.exports = (req, res) ->
  sendSms req.body.to, req.body.body, (err, sms) ->
    res.json err || sms