mongoose = require('mongoose')


customerAccountSchema = new mongoose.Schema
  phone: String
  houseName:
    type    : String
    default : 'House 1'
  houseNumber: String
  streetName: String
  city: String
  state: String
  zip: String
  
  name:
    first: String
    last: String
  
  carrier:
    ref: 'Carrier'
    type: mongoose.Schema.Types.ObjectId

  gateways: [
    ref: 'Gateway', type: String
  ]

  user:
    ref: 'User'
    type: mongoose.Schema.Types.ObjectId

  # Array of sensorHubEventStart/sensorHubEventEnd that customerAccount wants to be emailed about
  # [1,6]  => wants to be notified about water detect and high temperature
  sensorHubEventEmailSubscriptions:
    default : [1]
    type    : [Number]
  # Array of sensorHubEventStart/sensorHubEventEnd that customerAccount wants to be texted about
  sensorHubEventSmsSubscriptions:
    default : [1,2]
    type    : [Number]
  gatewayEventEmailSubscriptions:
    default : [1,2]
    type    : [Number]
  gatewayEventSmsSubscriptions:
    default : [1,2]
    type    : [Number]

    
mongoose.model 'CustomerAccount', customerAccountSchema