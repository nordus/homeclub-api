
_         = require('lodash')
buildHC2  = require '../lib/build-hc2'
db        = require '../../config/db'
sendSms   = require '../lib/send-sms'

{Gateway, OutboundCommand} = db.models

ensureArray = ( item ) ->
  if Array.isArray( item ) then item else [item]


module.exports = ( req, res ) ->

  params        = _.clone req.body.formInputs
  console.log params
  networkHubIDs = params.networkHubMAC or params.recipients
  console.log 'networkHubIDs before:'
  console.log networkHubIDs
  networkHubIDs = ensureArray networkHubIDs

  # TEST
  console.log networkHubIDs

  Gateway.where( '_id' ).in( networkHubIDs ).populate( 'customerAccount' ).exec ( err, gateways ) ->

    # TEST
    if err
      console.log err

    gateways.forEach ( gateway ) ->

      command = buildHC2( params )

      sendSms gateway.phone, command, ( err, smsTransactionDetails ) ->

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
        , ( err, outboundCommand ) ->

          gateway.pendingOutboundCommand = outboundCommand

          gateway.save ( e ) ->

    res.json { ooga:'booga' }