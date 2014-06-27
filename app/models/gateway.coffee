mongoose = require('mongoose')


gatewaySchema = new mongoose.Schema

  # _id is gateway's MAC address
  #  - example: '00078003164B'
  _id   : String
  
  name  : String
  
  profile:
    ref   : 'GatewayProfile'
    type  : mongoose.Schema.Types.ObjectId
    
  customerAccount:
    ref   : 'CustomerAccount'
    type  : mongoose.Schema.Types.ObjectId
    
  sensorHubs: [
    ref: 'SensorHub', type: String
  ]
    
    
mongoose.model 'Gateway', gatewaySchema