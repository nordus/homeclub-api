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

    
mongoose.model 'CustomerAccount', customerAccountSchema