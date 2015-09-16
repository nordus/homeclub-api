{CustomerAccount, OutboundCommand, OutboundEmail, OutboundSms, SensorHub} = require('../../config/db').models

alertText = require('../lib/alert-text')
async     = require('async')
sendSms   = require('../lib/send-sms')
sendEmail = require('../lib/send-email')



exports.smsInitiatedAck = (req, res) ->

  res.sendStatus 200

  networkHubSystemMessages =
    '1'   : 'smsSuccess'
    '10'  : 'smsFail'

  status = networkHubSystemMessages[req.body.networkHubSystemMessage]

  if status is 'smsSuccess'

    # find most recent outboundCommand by network hub MAC
    OutboundCommand.findOne( gateway:req.body.macAddress ).sort('-_id').populate('gateway').exec ( err, oc ) ->

      # set deliveredAt
      oc.deliveredAt                      = Date.now()

      # if HC1 remove pendingOutboundCommand
      if oc.msgType is 'HC1'

        oc.resolvedAt                     = Date.now()

        oc.gateway.pendingOutboundCommand = undefined
        oc.gateway.save (err) ->

      oc.save (e) ->
        console.log '\n\n', "-= [smsInitiatedAck] smsSuccess!  #{oc.msgType} to #{oc.sensorHub || oc.gateway} deliveredAt #{new Date().toLocaleTimeString()} =-"



exports.smsInitiatedOutcome = (req, res) ->

  res.sendStatus 200

  sensorHubSystemMessages =
    '1'   : 'updateSuccess'
    '10'  : 'updateFail'

  status = sensorHubSystemMessages[req.body.sensorHubSystemMessage]

  if status is 'updateSuccess'

    OutboundCommand.findOne( gateway:req.body.macAddress ).sort('-_id').populate('gateway sensorHub').exec ( err, oc ) ->

      # TEST
      console.log '\n\n', "-= [smsInitiatedOutcome] #{oc.sensorHub._id} updateSuccess at #{new Date().toLocaleTimeString()} =-"
      console.log "deviceThresholds: ", oc.sensorHub.deviceThresholds

      oc.resolvedAt                     = Date.now()

      oc.sensorHub.deviceThresholds     = oc.deviceThresholds
      oc.sensorHub.save (err) ->
        unless err
          console.log "updated deviceThresholds: ", oc.sensorHub.deviceThresholds

      oc.gateway.pendingOutboundCommand = undefined
      oc.gateway.save (err) ->

      oc.save (e) ->



exports.networkHubEvent = (req, res) ->

  res.sendStatus 200

  # TODO: remove gatewayEventEmailSubscriptions and gatewayEventSmsSubscriptions from customerAccount schema
  #  - customerAccount no longer checks opt-in
  #  - gateway only sends if gatewayEventCode in [1,2]
  #  - customerAccount no longer has gatewayEventEmailSubscriptions or gatewayEventSmsSubscriptions

  CustomerAccount.findOne( gateways:req.body.macAddress ).populate( 'user' ).exec ( err, account ) ->

    pastShipDate  = account.shipDate < Date.now
    email         = account.user.email
    body          = alertText.gatewayEvent( req.body.gatewayEventCode )

    return unless pastShipDate

    sendEmail
      recipientEmail  : email
      subject         : 'Network Hub Alert'
      body
    , (err, message) ->

        console.log 'Email sent to: ', email

        OutboundEmail.create
          gateway         : req.body.macAddress
          customerAccount : account._id
          email
          reading         : req.body

    phoneNumber = "+1#{account.phone.replace(/\D/g, '')}"

    sendSms phoneNumber, body, ( err, responseData ) ->

      console.log 'SMS sent to: ', phoneNumber

      OutboundSms.create
        gateway         : req.body.macAddress
        customerAccount : account._id
        phoneNumber
        reading         : req.body


getCategory = (eventCode) ->
  return "water" if eventCode in [1]
  return "motion" if eventCode in [2]
  return "temperature" if eventCode in [3,4]
  return "humidity" if eventCode in [5,6]
  return "light" if eventCode in [7,8]
  return "movement" if eventCode in [9]

capitalize = (str) ->
  str.charAt(0).toUpperCase() + str.slice(1)

exports.sensorHubEvent = (req, res) ->

  res.sendStatus 200

  eventResolved = req.body.sensorEventEnd isnt 0

  if eventResolved
    sensorHubEvent = req.body.sensorEventEnd
  else
    sensorHubEvent = req.body.sensorEventStart

  category = getCategory(sensorHubEvent)

  # find SensorHub with sensorHubEvent number in email/SMS subscriptions array
  async.parallel
    email: (cb) -> SensorHub.findOne { _id:req.body.sensorHubMacAddress, emailSubscriptions:category }, cb
    sms: (cb) -> SensorHub.findOne { _id:req.body.sensorHubMacAddress, smsSubscriptions:category }, cb
  , (e, r) ->
    if e
      console.log '[async.parallel] ERROR:'
      console.log e


    if r.email
      CustomerAccount.findOne( gateways:req.body.macAddress ).populate('user').exec (err, accountToEmail) ->

        pastShipDate  = accountToEmail.shipDate < Date.now()

        return unless pastShipDate and accountToEmail.user

        email = accountToEmail.user.email
        body = alertText.sensorHubEvent(sensorHubEvent, eventResolved)

        sendEmail {recipientEmail:email, subject:"#{capitalize(category)} Alert", body}, (err, message) ->
          if err
            console.log '[sendEmail] ERROR:'
            console.log err
          else

            console.log 'Email sent to: ', email

            OutboundEmail.create
              gateway         : req.body.macAddress
              customerAccount : accountToEmail._id
              email           : email
              reading         : req.body


    if r.sms
      CustomerAccount.findOne { gateways:req.body.macAddress }, (err, accountToSms) ->

        pastShipDate  = accountToSms.shipDate < Date.now()

        return unless pastShipDate and accountToSms.phone

        phoneNumber = "+1#{accountToSms.phone.replace(/\D/g, '')}"
        body = alertText.sensorHubEvent(sensorHubEvent, eventResolved)

        sendSms phoneNumber, body, (err, responseData) ->
          if err
            console.log '[sendSms] ERROR:'
            console.log err
          else

            console.log 'SMS sent to: ', phoneNumber

            # save to db for tracking purposes
            OutboundSms.create
              gateway         : req.body.macAddress
              customerAccount : accountToSms._id
              phoneNumber     : phoneNumber
              reading         : req.body
