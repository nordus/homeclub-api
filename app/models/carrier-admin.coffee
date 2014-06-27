mongoose = require('mongoose')


carrierAdminSchema = new mongoose.Schema
  name:
    first : String
    last  : String

  carrier:
    ref   : 'Carrier'
    type  : mongoose.Schema.Types.ObjectId

  user:
    ref   : 'User'
    type  : mongoose.Schema.Types.ObjectId


mongoose.model 'CarrierAdmin', carrierAdminSchema