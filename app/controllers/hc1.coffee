
_         = require('lodash')
buildHC1  = require '../lib/build-hc1'
db        = require '../../config/db'
sendSms   = require '../lib/send-sms'

{Gateway, OutboundCommand} = db.models


module.exports = ( req, res ) ->

  params = _.clone req.body.formInputs

  Gateway.where( '_id' ).in( req.body.recipients ).populate('customerAccount').exec ( err, gateways ) ->
    gateways.forEach (gateway) ->
      params.networkHubMAC  = gateway._id
      command             = buildHC1( params )
      sendSms gateway.phone, command, (err, smsTransactionDetails) ->
        OutboundCommand.create
          gateway               : gateway._id
          customerAccount       : gateway.customerAccount._id
          carrier               : gateway.customerAccount.carrier
          phoneNumber           : gateway.phone
          command               : command
          sentAt                : Date.now()
          smsTransactionDetails : smsTransactionDetails
          msgType               : 'HC1'
          params                : params
        , ( err, outboundCommand ) ->

            gateway.pendingOutboundCommand = outboundCommand

            gateway.save ( e ) ->
              if gateways.length is 1
                return res.json( outboundCommand )

    if gateways.length > 1
      res.json gateways