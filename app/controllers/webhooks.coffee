{CustomerAccount, OutboundEmail, OutboundSms} = require('../../config/db').models
alertText = require('../lib/alert-text')
async = require('async')
sendSms = require('../lib/send-sms')
sendEmail = require('../lib/send-email')


exports.networkHubEvent = (req, res) ->
  # find account with networkHubEvent number in email/SMS subscriptions array
  async.parallel
    accountToEmail: (cb) -> CustomerAccount.findOne( gateways:req.body.macAddress, gatewayEventEmailSubscriptions:req.body.gatewayEventCode ).populate('user').exec cb
    accountToSms: (cb) -> CustomerAccount.findOne { gateways:req.body.macAddress, gatewayEventSmsSubscriptions:req.body.gatewayEventCode }, cb
  , (e, r) ->
    if e
      console.log '[async.parallel] ERROR:'
      console.log e


    if r.accountToEmail && r.accountToEmail.user.email

      email = r.accountToEmail.user.email
      body = alertText.gatewayEvent(req.body.gatewayEventCode)

      sendEmail {recipientEmail:email, subject:'Network Hub Alert', body}, (err, message) ->
        if err
          console.log '[sendEmail] ERROR:'
          console.log err
        else

          console.log 'Email sent to: ', email

          OutboundEmail.create
            gateway         : req.body.macAddress
            customerAccount : r.accountToEmail._id
            email           : email
            reading         : req.body


    if r.accountToSms && r.accountToSms.phone

      phoneNumber = "+1#{r.accountToSms.phone.replace(/\D/g, '')}"
      body = alertText.gatewayEvent(req.body.gatewayEventCode)

      sendSms phoneNumber, body, (err, responseData) ->
        if err
          console.log '[sendSms] ERROR:'
          console.log err
        else

          console.log 'SMS sent to: ', phoneNumber
    
          # save to db for tracking purposes
          OutboundSms.create
            gateway         : req.body.macAddress
            customerAccount : r.accountToSms._id
            phoneNumber     : phoneNumber
            reading         : req.body


    res.json
      email: r.accountToEmail
      sms: r.accountToSms



getCategory = (eventCode) ->
  return "water" if eventCode in [1]
  return "motion" if eventCode in [2]
  return "temperature" if eventCode in [3,4]
  return "humidity" if eventCode in [5,6]
  return "light" if eventCode in [7,8]
  return "movement" if eventCode in [9]

categoryIsMuted = (account, shMacAddress, eventCode) ->
  category = getCategory(eventCode)
  mutedCategories = account.mutedSensorCategories?[shMacAddress]
  mutedCategories && category in mutedCategories

exports.sensorHubEvent = (req, res) ->
  eventResolved = req.body.sensorEventEnd isnt 0

  if eventResolved
    sensorHubEvent = req.body.sensorEventEnd
  else
    sensorHubEvent = req.body.sensorEventStart

  # find account with sensorHubEvent number in email/SMS subscriptions array
  async.parallel
    accountToEmail: (cb) -> CustomerAccount.findOne( gateways:req.body.macAddress, sensorHubEventEmailSubscriptions:sensorHubEvent ).populate('user').exec cb
    accountToSms: (cb) -> CustomerAccount.findOne { gateways:req.body.macAddress, sensorHubEventSmsSubscriptions:sensorHubEvent }, cb
  , (e, r) ->
    if e
      console.log '[async.parallel] ERROR:'
      console.log e


    if r.accountToEmail && r.accountToEmail.user.email
      unless categoryIsMuted(r.accountToEmail, req.body.sensorHubMacAddress, sensorHubEvent)

        email = r.accountToEmail.user.email
        body = alertText.sensorHubEvent(sensorHubEvent, eventResolved)
  
        sendEmail {recipientEmail:email, subject:'Sensor Alert', body}, (err, message) ->
          if err
            console.log '[sendEmail] ERROR:'
            console.log err
          else

            console.log 'Email sent to: ', email

            OutboundEmail.create
              gateway         : req.body.macAddress
              customerAccount : r.accountToEmail._id
              email           : email
              reading         : req.body


    if r.accountToSms && r.accountToSms.phone
      unless categoryIsMuted(r.accountToSms, req.body.sensorHubMacAddress, sensorHubEvent)

        phoneNumber = "+1#{r.accountToSms.phone.replace(/\D/g, '')}"
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
              customerAccount : r.accountToSms._id
              phoneNumber     : phoneNumber
              reading         : req.body


    res.json
      email: r.accountToEmail
      sms: r.accountToSms