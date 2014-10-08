mongoose = require('mongoose')

outboundSmsSchema = new mongoose.Schema

  gateway:
    ref   : 'Gateway'
    type  : String
    
  customerAccount:
    ref   : 'CustomerAccount'
    type  : mongoose.Schema.Types.ObjectId
    
  phoneNumber: String

  reading: {}


mongoose.model 'OutboundSms', outboundSmsSchema