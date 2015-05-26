
_         = require('lodash')
buildHC2  = require '../lib/build-hc2'
db        = require '../../config/db'
sendSms   = require '../lib/send-sms'
_         = require('lodash')

{DeviceThresholds, Gateway, OutboundCommand} = db.models

ensureArray = ( item ) ->
  if Array.isArray( item ) then item else [item]

removeUnchanged = ( obj ) ->
  _.omit obj, ( v, k ) ->
    v in [255, 65535]


module.exports = ( req, res ) ->

  params        = _.clone req.body.formInputs
  networkHubIDs = params.networkHubMAC or params.recipients
  networkHubIDs = ensureArray networkHubIDs

  Gateway.where( '_id' ).in( networkHubIDs ).populate( 'customerAccount' ).exec ( err, gateways ) ->

    gateways.forEach ( gateway ) ->

      command = buildHC2( params )

      sendSms gateway.phone, command, ( err, smsTransactionDetails ) ->

        changedThresholds = removeUnchanged( params )

        DeviceThresholds.create changedThresholds, ( err, dt ) ->

          OutboundCommand.create
            gateway               : gateway._id
            customerAccount       : gateway.customerAccount._id
            carrier               : gateway.customerAccount.carrier
            phoneNumber           : gateway.phone
            command               : command
            sentAt                : Date.now()
            smsTransactionDetails : smsTransactionDetails
            msgType               : 'HC2'
            params                : params
            sensorHub             : params.sensorHubMAC
            deviceThresholds      : dt._id
          , ( err, outboundCommand ) ->

            gateway.pendingOutboundCommand = outboundCommand

            gateway.save ( e ) ->

            if gateways.length == 1
              res.json outboundCommand


    if gateways.length != 1
      res.json { ooga:'booga' }